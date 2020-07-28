library ieee;
use ieee.std_logic_1164.all;

entity template_register is

  generic (
    BIT_WIDTH : integer := 16);
  port (
    Clock  : in std_logic;
    Reset  : in std_logic;
    REG_in : in std_logic_vector((BIT_WIDTH - 1) downto 0);
    LD_REG : in std_logic;

    REG_out : out std_logic_vector((BIT_WIDTH - 1) downto 0));

end template_register;

architecture behavior of template_register is

  signal reg      : std_logic_vector((BIT_WIDTH - 1) downto 0);

begin  -- behavior

  latch_reg : process (Clock, Reset)
  begin  -- process latch_reg
    if Reset = '1' then                     -- asynchronous reset (active high)
      reg <= (others => '0');
    elsif Clock'event and Clock = '1' then  -- rising clock edge
      if LD_REG = '1' then
        -- Since the process I'm in is already sequential
        -- and sensitive only to Clock and Reset, the absence
        -- of an 'else' clause will not infer a latch (which,
        -- by the way, is unclocked)
        reg <= REG_in;                  
      end if;
    end if;
  end process latch_reg;

  -- all you want is a MUX, so you don't need
  -- a process here. The process I had here before
  -- merely inferred a MUX. Anytime you write a
  -- process, you're inferring something, even
  -- in the latch_reg process above which infers,
  -- but does not instantiate a dff.

  REG_out <= reg;

end behavior;
