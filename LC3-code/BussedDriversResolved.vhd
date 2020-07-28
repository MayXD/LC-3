library ieee;
use ieee.std_logic_1164.all;

entity BussedDriversResolved is
  port (
    Gate_PC : in std_logic;
    PC_in   : in std_logic_vector(15 downto 0);

    Gate_MDR : in std_logic;
    MDR_in   : in std_logic_vector(15 downto 0);

    Gate_ALU : in std_logic;
    ALU_in   : in std_logic_vector(15 downto 0);

    Gate_MARMUX : in std_logic;
    MARMUX_in   : in std_logic_vector(15 downto 0);

    bus_out : out std_logic_vector(15 downto 0));
end BussedDriversResolved;

architecture dataflow of BussedDriversResolved is

  -- constant high_impedence : std_logic_vector(15 downto 0) := (others => 'Z');

  -- If you see more than one assignment to a signal,
  -- you either have an ERROR or are using tri-state buffers. 
  -- The 'Zs' ('high_impedence') are what make the signal 
  -- a tri-state buffer and not an error.
begin
-- Using tri-state buffers: 
-- bus_out <= PC_in     when Gate_PC     = '1' else high_impedence;
-- bus_out <= MDR_in    when Gate_MDR    = '1' else high_impedence;
-- bus_out <= ALU_in    when Gate_ALU    = '1' else high_impedence;
-- bus_out <= MARMUX_in when Gate_MARMUX = '1' else high_impedence;

-- Using only a MUX without tri-state buffers: 
  bus_out <=
    PC_in     when Gate_PC     = '1' else
    MDR_in    when Gate_MDR    = '1' else
    ALU_in    when Gate_ALU    = '1' else
    MARMUX_in when Gate_MARMUX = '1' else
   (others => 'X');
  
end dataflow;
