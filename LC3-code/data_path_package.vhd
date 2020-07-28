library ieee;
use ieee.std_logic_1164.all;

package data_path_package is
  component REG_FILE
    port (
      Clock   : in  std_logic;
      Reset   : in  std_logic;
      bus_in  : in  std_logic_vector( 15 downto 0 );
      DR      : in  std_logic_vector( 2 downto 0 );
      LD_REG  : in  std_logic;
      SR1     : in  std_logic_vector( 2 downto 0 );
      SR2     : in  std_logic_vector( 2 downto 0 );
      SR1_out : out std_logic_vector( 15 downto 0 );
      SR2_out : out std_logic_vector( 15 downto 0 ));
  end component;

  component ALU
    port (
      A       : in  std_logic_vector( 15 downto 0 );
      B       : in  std_logic_vector( 15 downto 0 );
      ALUK    : in  std_logic_vector( 1 downto 0 );
      ALU_out : out std_logic_vector( 15 downto 0 ));
  end component;

  component CONTROL
    port (
      Clock           : in  std_logic;
      Reset           : in  std_logic;
      IR              : in  std_logic_vector( 15 downto 0 );
      R               : in  std_logic;
      N               : in  std_logic;
      Z               : in  std_logic;
      P               : in  std_logic;
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
      Set_Priv        : out std_logic);
  end component;

  component NZP_LOGIC
    port (
      Clock  : in  std_logic;
      Reset  : in  std_logic;
      LD_CC  : in  std_logic;
      bus_in : in  std_logic_vector( 15 downto 0 );
      N_out  : out std_logic;
      Z_out  : out std_logic;
      P_out  : out std_logic);
  end component;

  component ADDR_CTL_LOGIC
    port (
      MAR     : in  std_logic_vector( 15 downto 0 );
      MIO_EN  : in  std_logic;
      R_W     : in  std_logic;
      LD_KBSR : out std_logic;
      LD_DSR  : out std_logic;
      LD_DDR  : out std_logic;
      MEM_EN  : out std_logic;
      IN_MUX  : out std_logic_vector( 1 downto 0 ));
  end component;

  component MEMORY
    generic (
      DATA_BITS   :     integer;
      MEMORY_SIZE :     integer);
    port (
      Clock       : in  std_logic;
      Reset       : in  std_logic;
      MDR         : in  std_logic_vector(( DATA_BITS - 1 ) downto 0 );
      MAR         : in  std_logic_vector(( DATA_BITS - 1 ) downto 0 );
      R_W         : in  std_logic;
      MEM_EN      : in  std_logic;
      mem         : out std_logic_vector(( DATA_BITS - 1 ) downto 0 );
      R           : out std_logic);
  end component;

  component BussedDriversResolved
    port (
      Gate_PC     : in  std_logic;
      PC_in       : in  std_logic_vector( 15 downto 0 );
      Gate_MDR    : in  std_logic;
      MDR_in      : in  std_logic_vector( 15 downto 0 );
      Gate_ALU    : in  std_logic;
      ALU_in      : in  std_logic_vector( 15 downto 0 );
      Gate_MARMUX : in  std_logic;
      MARMUX_in   : in  std_logic_vector( 15 downto 0 );
      bus_out     : out std_logic_vector( 15 downto 0 ));
  end component;

  component template_register
    generic (
      BIT_WIDTH :     integer );
    port (
      Clock     : in  std_logic;
      Reset     : in  std_logic;
      REG_in    : in  std_logic_vector(( BIT_WIDTH - 1 ) downto 0 );
      LD_REG    : in  std_logic;
      REG_out   : out std_logic_vector(( BIT_WIDTH - 1 ) downto 0 ));
  end component;
end data_path_package;
