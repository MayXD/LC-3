library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_signed.all;

entity NZP_LOGIC is

  port (
    Clock  : in std_logic;
    Reset  : in std_logic;
    LD_CC  : in std_logic;
    bus_in : in std_logic_vector( 15 downto 0 );

    N_out : out std_logic;
    Z_out : out std_logic;
    P_out : out std_logic );

end NZP_LOGIC;

architecture behavior of NZP_LOGIC is

  signal local_N : std_logic;
  signal local_Z : std_logic;
  signal local_P : std_logic;
  
  signal next_N : std_logic;
  signal next_Z : std_logic;
  signal next_P : std_logic;

begin  -- behavior

  latch_NZP : process ( Clock, Reset )
  begin  -- process latch_NZP
    if Reset = '1' then                 -- asynchronous reset ( active high )
      local_N <= '0';
      local_Z <= '1';                     -- initializing Registers to '0'
      local_P <= '0';                     -- therefore, the last write was a 'Z'
    elsif Clock'event and Clock = '1' then  -- rising clock edge
      local_N <= next_N;
      local_Z <= next_Z;
      local_P <= next_P;
    end if;
  end process latch_NZP;

  build_nexts : process ( LD_CC, bus_in, local_N, local_P, local_Z )
  begin  -- process build_nexts
    next_N <= local_N;
    next_Z <= local_Z;
    next_P <= local_P;

    if LD_CC = '1' then
      if ( conv_integer( bus_in )) < 0 then
        -- If high-order bit is '1', then
        -- bus_in is negative. 
        next_N <= '1';
        next_Z <= '0';
        next_P <= '0'; 
      elsif ( conv_integer( bus_in )) = 0 then
        -- Z requires only a straightforward '='
        -- comparison. 
        next_N <= '0';
        next_Z <= '1';
        next_P <= '0';
      else
        -- Another version would be to have
        -- 'if neither N nor Z is true, P is true',
        -- since equality comparisons are easy and
        -- involve only a single nand gate. 
        next_N <= '0';
        next_Z <= '0'; 
        next_P <= '1';
      end if;
    end if;
  end process build_nexts;

  N_out <= local_N;
  Z_out <= local_Z;
  P_out <= local_P; 

end behavior;
