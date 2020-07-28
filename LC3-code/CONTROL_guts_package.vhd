library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_signed.all;

package CONTROL_guts_package is

  component Microsequencer
    port (
      IRD           : in std_logic;
      COND          : in std_logic_vector( 2 downto 0 );
      J             : in std_logic_vector( 5 downto 0 );  -- fig.C.5 pg. 573
      INT           : in std_logic;
      R             : in std_logic;
      IR_opcode     : in std_logic_vector( 3 downto 0 );
      IR_eleven     : in std_logic;                       -- JSR vs. JSRR 
      BEN           : in std_logic;                       -- branch enable
      PSR_privilege : in std_logic;                       -- bit 15 of PSR

      next_state : out std_logic_vector( 5 downto 0 ));  -- fig.C.4 pg. 571
  end component;

  component Control_Store
    port (
      Clock      : in std_logic;
      Reset      : in std_logic;
      next_state : in std_logic_vector( 5 downto 0 );  -- Microsequencer output

      IRD             : out std_logic;
      COND            : out std_logic_vector( 2 downto 0 );
      J               : out std_logic_vector( 5 downto 0 );
      LD_MAR          : out std_logic;
      LD_MDR          : out std_logic;
      LD_IR           : out std_logic;
      LD_BEN          : out std_logic;
      LD_REG          : out std_logic;
      LD_CC           : out std_logic;
      LD_PC           : out std_logic;
      LD_Priv         : out std_logic;
      LD_SavedSSP     : out std_logic;
      LD_SavedUSP     : out std_logic;
      LD_Vector       : out std_logic;
      Gate_PC         : out std_logic;
      Gate_MDR        : out std_logic;
      Gate_ALU        : out std_logic;
      Gate_MARMUX     : out std_logic;
      Gate_Vector     : out std_logic;
      Gate_PC_minus_1 : out std_logic;
      Gate_PSR        : out std_logic;
      Gate_SP         : out std_logic;
      PC_MUX          : out std_logic_vector( 1 downto 0 );
      DR_MUX          : out std_logic_vector( 1 downto 0 );
      SR1_MUX         : out std_logic_vector( 1 downto 0 );
      ADDR1_MUX       : out std_logic;
      ADDR2_MUX       : out std_logic_vector( 1 downto 0 );
      SP_MUX          : out std_logic_vector( 1 downto 0 );
      MAR_MUX         : out std_logic;
      Vector_MUX      : out std_logic_vector( 1 downto 0 );
      PSR_MUX         : out std_logic;
      ALUK            : out std_logic_vector( 1 downto 0 );
      MIO_EN          : out std_logic;
      R_W             : out std_logic;
      Set_Priv        : out std_logic );
  end component;

end CONTROL_guts_package;
