library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_signed.all;          -- do I need this in this .vhd file???

entity CONTROL is

  port (
    Clock  : in std_logic;
    Reset  : in std_logic;
    IR : in std_logic_vector( 15 downto 0 );
    R      : in std_logic;
    N  : in std_logic;
    Z  : in std_logic;
    P  : in std_logic;

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

end CONTROL;

use work.CONTROL_guts_package.all;

architecture structure of CONTROL is
  -- INT: until implementing interrupts, set to '0' 
  -- PSR_privilege: until implementing interrupts, set to Supervisor Mode
  signal local_INT           : std_logic;
  signal local_PSR_privilege : std_logic;
  signal local_IRD           : std_logic;
  signal local_COND          : std_logic_vector( 2 downto 0 );
  signal local_J             : std_logic_vector( 5 downto 0 );
  signal local_BEN           : std_logic;
  signal local_next_state    : std_logic_vector( 5 downto 0 );

begin

  local_INT           <= '0';
  local_PSR_privilege <= '0';
  -- BTW, BEN is working perfectly; see note about BEN 
  -- in MEMORY.vhd. 
  local_BEN           <= ( IR( 11 ) and N ) or
                         ( IR( 10 ) and Z ) or
                         ( IR( 9 ) and P );

  M : Microsequencer
    port map (
      IRD           => local_IRD,
      COND          => local_COND,
      J             => local_J,
      INT           => local_INT,
      R             => R,
      IR_opcode     => IR( 15 downto 12 ),
      IR_eleven     => IR( 11 ),
      BEN           => local_BEN,
      PSR_privilege => local_PSR_privilege,
      next_state    => local_next_state );

  C_S : Control_Store
    port map (
      Clock           => Clock,
      Reset           => Reset,
      next_state      => local_next_state,
      IRD             => local_IRD,
      COND            => local_COND,
      J               => local_J,
      LD_MAR          => LD_MAR,
      LD_MDR          => LD_MDR,
      LD_IR           => LD_IR,
      LD_BEN          => LD_BEN,
      LD_REG          => LD_REG,
      LD_CC           => LD_CC,
      LD_PC           => LD_PC,
      LD_Priv         => LD_Priv,
      LD_SavedSSP     => LD_SavedSSP,
      LD_SavedUSP     => LD_SavedUSP,
      LD_Vector       => LD_Vector,
      Gate_PC         => Gate_PC,
      Gate_MDR        => Gate_MDR,
      Gate_ALU        => Gate_ALU,
      Gate_MARMUX     => Gate_MARMUX,
      Gate_Vector     => Gate_Vector,
      Gate_PC_minus_1 => Gate_PC_minus_1,
      Gate_PSR        => Gate_PSR,
      Gate_SP         => Gate_SP,
      PC_MUX          => PC_MUX,
      DR_MUX          => DR_MUX,
      SR1_MUX         => SR1_MUX,
      ADDR1_MUX       => ADDR1_MUX,
      ADDR2_MUX       => ADDR2_MUX,
      SP_MUX          => SP_MUX,
      MAR_MUX         => MAR_MUX,
      Vector_MUX      => Vector_MUX,
      PSR_MUX         => PSR_MUX,
      ALUK            => ALUK,
      MIO_EN          => MIO_EN,
      R_W             => R_W,
      Set_Priv        => Set_Priv );

end structure;
