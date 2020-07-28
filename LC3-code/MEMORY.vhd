library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_signed.all;

entity MEMORY is

  generic (
    DATA_BITS   : integer := 16;
    MEMORY_SIZE : integer := 32);

  port (
    Clock  : in std_logic;
    Reset  : in std_logic;
    MDR    : in std_logic_vector((DATA_BITS - 1) downto 0);
    MAR    : in std_logic_vector((DATA_BITS - 1) downto 0);
    R_W    : in std_logic;
    MEM_EN : in std_logic;

    mem : out std_logic_vector((DATA_BITS - 1) downto 0);
    R   : out std_logic);

end MEMORY;

architecture behavior of MEMORY is
  constant const_ADD  : std_logic_vector(3 downto 0) := "0001";  -- 10# 1#
  constant const_AND  : std_logic_vector(3 downto 0) := "0101";  -- 10# 5#
  constant const_BR   : std_logic_vector(3 downto 0) := "0000";  -- 10# 0#
  constant const_LEA  : std_logic_vector(3 downto 0) := "1110";  -- 10#14#
  constant const_JMP  : std_logic_vector(3 downto 0) := "1100";  -- 10#12#
  constant const_LDR  : std_logic_vector(3 downto 0) := "0110";  -- 10# 6#
  constant const_TRAP : std_logic_vector(3 downto 0) := "1111";  -- 10#15#

  constant R0 : std_logic_vector(2 downto 0) := "000";
  constant R1 : std_logic_vector(2 downto 0) := "001";
  constant R2 : std_logic_vector(2 downto 0) := "010";
  constant R3 : std_logic_vector(2 downto 0) := "011";
  constant R4 : std_logic_vector(2 downto 0) := "100";
  constant R5 : std_logic_vector(2 downto 0) := "101";
  constant R6 : std_logic_vector(2 downto 0) := "110";
  constant R7 : std_logic_vector(2 downto 0) := "111";
  
  subtype word is std_logic_vector((DATA_BITS - 1) downto 0);
  type    Words is array (natural range <>) of word;
  signal  SRAM      : Words(0 to MEMORY_SIZE - 1);
  signal  next_SRAM : Words(0 to MEMORY_SIZE - 1);
  signal  next_R    : std_logic;
  signal  next_mem  : std_logic_vector((DATA_BITS - 1) downto 0);

begin  -- behavior

  latch_outputs : process (Clock, Reset)
  begin
    if Reset = '1' then                 -- asynchronous reset (active high)
      R   <= '0';
      mem <= (others => '0');
      
      for i in 0 to MEMORY_SIZE - 1 loop
        SRAM(i) <= (others => '0');
      end loop;
      -- SRAM(0) <= const_ADD & R0 & R1 & '0' & "00" & R0;
      -- SRAM(1) <= const_BR & "111" & "111"&"111"&"110";
      
      -- SRAM(0) <= const_ADD & R4 & R4 & '1' & "11111";
      -- SRAM(1) <= const_BR & "111" & "111"&"111"&"110";

      -- SRAM(0) <= const_LEA & R7 & "101"&"111"&"111";-- -129 + (PC=1)= -128
      -- SRAM(1) <= const_LEA & R7 & "111"&"111"&"110";-- -2 + (PC=2)= 0
      -- SRAM(2) <= const_LEA & R7 & "001"&"111"&"101";-- 125 + (PC=3)= 128
      -- SRAM(3) <= const_BR & "111" & "111"&"111"&"100";--BRto(PC=4)+(-4)-->PC=0

      --I tried R0 here to see if it affected BEN at the wrong
      --times. It *does* affect BEN, but not when we're in state 0,
      --which is the only time a state transition appears to be
      --affected based on the BEN value.
      -- SRAM(0) <= const_LEA & R0 & "101"&"111"&"111";-- -129 + (PC=1)= -128
      -- SRAM(1) <= const_LEA & R0 & "111"&"111"&"110";-- -2 + (PC=2)= 0
      -- SRAM(2) <= const_LEA & R0 & "001"&"111"&"101";-- 125 + (PC=3)= 128
      -- SRAM(3) <= const_BR & "111" & "111"&"111"&"100";--BRto(PC=4)+(-4)-->PC=0

      -- R0 <= 10#1# + 10#0#; R0 <= 1
      -- PC <= 1
      -- SRAM(0) <= const_ADD & R0 & R1 & '0' & "00" & R0;
      -- SRAM(1) <= const_JMP & "000" & R0 & "000000";

      -- R1 <= R1 + 10#2#: 1,; 3; 5; 7; ...
      -- PC <= 0: 0; 1; 2; 0; 1; 2; ...
      -- SRAM(0) <= const_ADD & R1 & R1 & '0' & "00" & R2;
      -- SRAM(1) <= const_JMP & "000" & R0 & "000000";

      -- SRAM(0) <= const_LDR & R0 & R7 & "111101";
      --SRAM(1), "0000"&"0000"&"0000"&"0000", is
      --interpreted as a no-op BRanch instruction;
      --The same goes for SRAM(2) and SRAM(3).
      -- SRAM(4) <= const_BR & "111" & "111"&"111"&"011";

      --TRAP test 1
      SRAM(0)  <= const_ADD & R0 & R1 & '0' & "00" & R0;  --R0 grows by 1 each time
      SRAM(1)  <= const_TRAP & "0000" & "0001"&"0111";
      --R7 should now contain 10#2#, the value of the incremented PC
      --PC is then loaded with 10#23#
      SRAM(2)  <= const_BR & "111" & "111"&"111"&"101";  --BRto(PC=3)+(-3)-->PC=0
      SRAM(23) <= "0000"&"000"&"000"&"011"&"101";  --TRAP routine starts at SRAM(29)
      SRAM(29) <= const_ADD & R0 & R5 & '0' & "00" & R0;  --R0 grows by 5 each time
      SRAM(30) <= const_BR & "111" & "111"&"100"&"001";  --to(PC=31)+(-31)  -->PC=0
      --PC goes from 0 through 31 now
      --It no longer 'core dumps' by going to 32.
      --REMEMBER to do this: REAL TRAP routines must end by loading contents of R7 into PC.
      
    elsif Clock'event and Clock = '1' then  -- rising clock edge
      R    <= next_R;
      mem  <= next_mem;
      SRAM <= next_SRAM;
    end if;
  end process latch_outputs;


  build_nexts : process (MAR, MDR, MEM_EN, R_W, SRAM)
  begin
    next_R    <= '0';
    next_SRAM <= SRAM;
    next_mem  <= (others => '0');       -- PYGMY

    if MEM_EN = '1' then
      next_R <= '1';

      if R_W = '1' then
        next_SRAM(conv_integer(MAR)) <= MDR;

      else                              -- R_W = '0'
        next_mem <= SRAM(conv_integer(MAR));
      end if;
    end if;

  end process build_nexts;

end behavior;
