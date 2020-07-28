library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_signed.all; 

entity ALU is

  port (
    A    : in std_logic_vector( 15 downto 0 );
    B    : in std_logic_vector( 15 downto 0 );
    ALUK : in std_logic_vector( 1 downto 0 );

    ALU_out : out std_logic_vector( 15 downto 0 ));

end ALU;

architecture behavior of ALU is

-- never ever ever type anything for 'initialization'
  signal A_plus_B : std_logic_vector( 15 downto 0 );
  signal A_and_B  : std_logic_vector( 15 downto 0 );
  signal A_not    : std_logic_vector( 15 downto 0 );

begin

  A_plus_B <= A + B;
  A_and_B  <= A and B;
  A_not    <= not A;

-- building a 4-input mux
  ALU_out <= A_plus_B when ALUK = "00" else
             A_and_B  when ALUK = "01" else
             A_not    when ALUK = "10" else
             A;                         -- when ALUK = "11" else
                                        -- "XXXX"&"XXXX"&"XXXX"&"XXXX";
                                        -- 'don't care' Xs must be caps

end behavior;
