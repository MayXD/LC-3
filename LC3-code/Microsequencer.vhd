library IEEE;
use IEEE.std_logic_1164.all;
-- use IEEE.std_logic_signed.all;

entity Microsequencer is

  port (
    IRD           : in  std_logic;
    COND          : in  std_logic_vector( 2 downto 0 );
    J             : in  std_logic_vector( 5 downto 0 );   -- fig.C.5 pg. 573 
    INT           : in  std_logic;
    R             : in  std_logic;
    IR_opcode     : in  std_logic_vector( 3 downto 0 );
    IR_eleven     : in  std_logic;                        -- JSR vs. JSRR 
    BEN           : in  std_logic;                        -- branch enable
    PSR_privilege : in  std_logic;                        -- bit 15 of PSR
    next_state    : out std_logic_vector( 5 downto 0 ));  -- fig.C.4 pg. 571

end Microsequencer;

architecture behavior of Microsequencer is
  signal Interrupt_present   : std_logic;  -- fig.C.5 pg 573
  signal User_privilege_mode : std_logic;
  signal Branch              : std_logic;
  signal Ready               : std_logic;
  signal Addr_mode           : std_logic;
  signal J_modified          : std_logic_vector( 5 downto 0 );
  -- 00 concatenated with four opcode bits
  signal Opcode_extended     : std_logic_vector( 5 downto 0 );

begin  
  -- equivalent statements which will all work,
  -- but which will probably generate different hardware
  -- Addr_mode <= '1' when ( COND & IR_eleven ) = "0111" else '0';
  -- Addr_mode <= IR_eleven when COND = "011" else '0';
  Addr_mode           <= '1' when COND = "011" and IR_eleven = '1'     else '0';
  Ready               <= '1' when COND = "001" and R = '1'             else '0';
  Branch              <= '1' when COND = "010" and BEN = '1'           else '0';
  User_privilege_mode <= '1' when COND = "100" and PSR_privilege = '1' else '0';
  Interrupt_present   <= '1' when COND = "101" and INT = '1'           else '0';

  J_modified(0) <= J(0) or Addr_mode;
  J_modified(1) <= J(1) or Ready;
  J_modified(2) <= J(2) or Branch;
  J_modified(3) <= J(3) or User_privilege_mode;
  J_modified(4) <= J(4) or Interrupt_present;
  J_modified(5) <= J(5);

  Opcode_extended <= "00" & IR_opcode;  -- concatenates 00 with four opcode bits

  -- two-input MUX 
  next_state <= J_modified when IRD = '0' else Opcode_extended;

end behavior;
