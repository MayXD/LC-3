library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_signed.all;

-- see Figure C.3 pg. 570
entity ADDR_CTL_LOGIC is

  port (
    MAR    : in std_logic_vector(15 downto 0);
    MIO_EN : in std_logic;
    R_W    : in std_logic;

    LD_KBSR : out std_logic;
    LD_DSR  : out std_logic;
    LD_DDR  : out std_logic;
    MEM_EN  : out std_logic;
    IN_MUX  : out std_logic_vector(1 downto 0));

end ADDR_CTL_LOGIC;

-- see Table C.3 pg. 576
architecture behavior of ADDR_CTL_LOGIC is

-- ModelSim's 'vcom': "Case choice must be a locally static expression."
-- see _Essential VHDL: RTL synthesis done right_, pp. 34-35
-- := "1111"&"1110"&"0000"&"0000"; FAILED TO COMPILE WITH vsim

  constant KBSR : std_logic_vector(15 downto 0)
 := "1111111000000000";                 -- xFE00

-- := "1111"&"1110"&"0000"&"0010";  -- xFE02
  constant KBDR : std_logic_vector(15 downto 0)
 := "1111111000000010";                 -- xFE02

-- := "1111"&"1110"&"0000"&"0100";  -- xFE04
  constant DSR : std_logic_vector(15 downto 0)
 := "1111111000000100";                 -- xFE04

-- := "1111"&"1110"&"0000"&"0110";  -- xFE06
  constant DDR : std_logic_vector(15 downto 0)
 := "1111111000000110";                 -- xFE06

begin  -- behavior

  address_control_logic : process (MAR, MIO_EN, R_W)
  begin
    
    LD_KBSR <= '0';
    LD_DSR  <= '0';
    LD_DDR  <= '0';
    MEM_EN  <= '0';
    IN_MUX  <= "11";

    if MIO_EN = '1' then
      case R_W is
        when '0' =>
          case MAR(15 downto 0) is
            when KBSR =>
              IN_MUX <= "01";
            when KBDR =>
              IN_MUX <= "00";
            when DSR =>
              IN_MUX <= "10";
            when others =>
              MEM_EN <= '1';
              IN_MUX <= "11";
          end case;
        when '1' =>
          case MAR(15 downto 0) is
            when KBSR =>
              LD_KBSR <= '1';
            when DSR =>
              LD_DSR <= '1';
            when DDR =>
              LD_DDR <= '1';
            when others =>
              MEM_EN <= '1';
          end case;
        when others =>
          null;
      end case;
    end if;
  end process address_control_logic;

end behavior;
