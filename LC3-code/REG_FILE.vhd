library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_signed.all;

entity REG_FILE is

  port (
    Clock  : in std_logic;              -- clocks only go IN, not OUT 
                                        -- anytime you have a clock
                                        -- you MUST have a reset
    Reset  : in std_logic;
    bus_in : in std_logic_vector(15 downto 0);
    DR     : in std_logic_vector(2 downto 0);
    LD_REG : in std_logic;
    SR1    : in std_logic_vector(2 downto 0);
    SR2    : in std_logic_vector(2 downto 0);

    SR1_out : out std_logic_vector(15 downto 0);
    SR2_out : out std_logic_vector(15 downto 0));

end REG_FILE;

architecture behavior of REG_FILE is
  -- the registers
  signal R0, R1, R2, R3, R4, R5, R6, R7 : std_logic_vector(15 downto 0);
  -- the next values of the registers
  signal N0, N1, N2, N3, N4, N5, N6, N7 : std_logic_vector(15 downto 0);
begin

-- since we can't imagine the circuit diagram
-- for this, given fig.C.3 pg. 570,
-- we're going to build it behaviorally,
-- as opposed to structurally with OR-gates, etc.

-- How you build a register
-- Input side
  latch_registers : process (Clock, Reset)
  begin
    if Reset = '1' then                   -- asynchronous Reset 
      R0 <= "0000"&"0000"&"0000"&"0000";  -- 10#0#
      R1 <= "0000"&"0000"&"0000"&"0001";  -- 10#1#
      R2 <= "0000"&"0000"&"0000"&"0010";  -- 10#2#
      R3 <= "0000"&"0000"&"0000"&"0011";  -- 10#3#
      R4 <= "0000"&"0000"&"0000"&"0100";  -- 10#4#
      R5 <= "0000"&"0000"&"0000"&"0101";  -- 10#5#
      R6 <= "0000"&"0000"&"0000"&"0110";  -- 10#6#
      R7 <= "0000"&"0000"&"0000"&"0111";  -- 10#7#

-- R0 <= ( others => '0' );  -- all sixteen bits are 0.
--      R1 <= ( others => '0' );
--      R2 <= ( others => '0' );
--      R3 <= ( others => '0' );
--      R4 <= ( others => '0' );
--      R5 <= ( others => '0' );
--      R6 <= ( others => '0' );
--      R7 <= ( others => '0' );
    elsif Clock'event and Clock = '1' then  -- rising edge of clock
      R0 <= N0;
      R1 <= N1;
      R2 <= N2;
      R3 <= N3;
      R4 <= N4;
      R5 <= N5;
      R6 <= N6;
      R7 <= N7;
    end if;
  end process latch_registers;

  build_N : process (DR , LD_REG, R0, R1, R2, R3, R4, R5, R6, R7, bus_in)
  begin
    N0 <= R0;
    N1 <= R1;
    N2 <= R2;
    N3 <= R3;
    N4 <= R4;
    N5 <= R5;
    N6 <= R6;
    N7 <= R7;

    if LD_REG = '1' then
      case DR is
        when "000" =>
          N0 <= bus_in;
        when "001" =>
          N1 <= bus_in;
        when "010" =>
          N2 <= bus_in;
        when "011" =>
          N3 <= bus_in;
        when "100" =>
          N4 <= bus_in;
        when "101" =>
          N5 <= bus_in;
        when "110" =>
          N6 <= bus_in;
        when "111" =>
          N7 <= bus_in;
        when others => null;
      end case;
    end if;
  end process build_N;

  build_outputs : process (R0, R1, R2, R3, R4, R5, R6, R7, SR1 , SR2)
  begin
    SR1_out <= (others => '0');
    SR2_out <= (others => '0');

    case SR1 is
      when "000" =>
        SR1_out <= R0;
      when "001" =>
        SR1_out <= R1;
      when "010" =>
        SR1_out <= R2;
      when "011" =>
        SR1_out <= R3;
      when "100" =>
        SR1_out <= R4;
      when "101" =>
        SR1_out <= R5;
      when "110" =>
        SR1_out <= R6;
      when "111" =>
        SR1_out <= R7;
      when others => null;
    end case;

    case SR2 is
      when "000" =>
        SR2_out <= R0;
      when "001" =>
        SR2_out <= R1;
      when "010" =>
        SR2_out <= R2;
      when "011" =>
        SR2_out <= R3;
      when "100" =>
        SR2_out <= R4;
      when "101" =>
        SR2_out <= R5;
      when "110" =>
        SR2_out <= R6;
      when "111" =>
        SR2_out <= R7;
      when others => null;
    end case;
  end process build_outputs;
end behavior;
