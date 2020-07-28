library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_signed.all;
use ieee.std_logic_arith.all;           -- for SXT and EXT

entity LC_3_data_path is

  port (
    Clock   : in  std_logic;
    Reset   : in  std_logic;
    KBDR_in : in  std_logic_vector(15 downto 0);
    DDR_out : out std_logic_vector(15 downto 0));

end LC_3_data_path;

use work.data_path_package.all;

architecture structure of LC_3_data_path is

  signal MARMUX : std_logic_vector(15 downto 0);
  signal PCMUX  : std_logic_vector(15 downto 0);
  signal DRMUX  : std_logic_vector(2 downto 0);

  -- what are the origins of SR2 ??? No one seems to know.
  -- it is IR( 2 downto 0 ), used with ADD and AND
  -- signal SR2 : std_logic_vector( 2 downto 0 );
  signal SR1MUX   : std_logic_vector(2 downto 0);
  signal ADDR1MUX : std_logic_vector(15 downto 0);
  signal ADDR2MUX : std_logic_vector(15 downto 0);
  signal SR2MUX   : std_logic_vector(15 downto 0);
  signal MIOENMUX : std_logic_vector(15 downto 0);
  signal INMUX    : std_logic_vector(15 downto 0);

  signal sig_bus     : std_logic_vector(15 downto 0);
  signal SR1contents : std_logic_vector(15 downto 0);
  signal SR2contents : std_logic_vector(15 downto 0);
  signal sig_ALU     : std_logic_vector(15 downto 0);

  signal LD_MAR          : std_logic;
  signal LD_MDR          : std_logic;
  signal LD_IR           : std_logic;
  signal LD_BEN          : std_logic;
  signal LD_REG          : std_logic;
  signal LD_CC           : std_logic;
  signal LD_PC           : std_logic;
  signal LD_Priv         : std_logic;
  signal LD_SavedSSP     : std_logic;
  signal LD_SavedUSP     : std_logic;
  signal LD_Vector       : std_logic;
  signal Gate_PC         : std_logic;
  signal Gate_MDR        : std_logic;
  signal Gate_ALU        : std_logic;
  signal Gate_MARMUX     : std_logic;
  signal Gate_Vector     : std_logic;
  signal Gate_PC_minus_1 : std_logic;
  signal Gate_PSR        : std_logic;
  signal Gate_SP         : std_logic;
  signal PC_MUX          : std_logic_vector(1 downto 0);
  signal DR_MUX          : std_logic_vector(1 downto 0);
  signal SR1_MUX         : std_logic_vector(1 downto 0);
  signal ADDR1_MUX       : std_logic;
  signal ADDR2_MUX       : std_logic_vector(1 downto 0);
  signal SP_MUX          : std_logic_vector(1 downto 0);
  signal MAR_MUX         : std_logic;
  signal Vector_MUX      : std_logic_vector(1 downto 0);
  signal PSR_MUX         : std_logic;
  signal ALUK            : std_logic_vector(1 downto 0);
  signal MIO_EN          : std_logic;
  signal R_W             : std_logic;
  signal Set_Priv        : std_logic;

  signal N : std_logic;
  signal Z : std_logic;
  signal P : std_logic;

  signal LD_KBSR : std_logic;
  signal LD_DSR  : std_logic;
  signal LD_DDR  : std_logic;
  signal MEM_EN  : std_logic;
  signal IN_MUX  : std_logic_vector(1 downto 0);

  signal mem : std_logic_vector(15 downto 0);
  signal R   : std_logic;

  signal PC   : std_logic_vector(15 downto 0);
  signal IR   : std_logic_vector(15 downto 0);
  signal MAR  : std_logic_vector(15 downto 0);
  signal MDR  : std_logic_vector(15 downto 0);
  signal KBDR : std_logic_vector(15 downto 0);
  signal KBSR : std_logic_vector(15 downto 0);
  signal DDR  : std_logic_vector(15 downto 0);
  signal DSR  : std_logic_vector(15 downto 0);

  signal ADDRs : std_logic_vector(15 downto 0);

begin  -- structure

  ADDRs <= ADDR2MUX + ADDR1MUX;         -- common subexpression elimination

  -- with *synthesizeable* VHDL, you don't need
  -- the last 'when' and 'else' clauses
  -- you should never end a mux with a 'when' clause
  MARMUX <= EXT(IR(7 downto 0), 16) when MAR_MUX = '0' else
            ADDRs;                      -- when MAR_MUX = '1' else
                                        -- "XXXX"&"XXXX"&"XXXX"&"XXXX";

  PCMUX <= PC + 1 when PC_MUX = "00" else
           sig_bus when PC_MUX = "01" else
           ADDRs;                       -- when PC_MUX = "10" else
                                        --"XXXX"&"XXXX"&"XXXX"&"XXXX";

  DRMUX <= IR(11 downto 9) when DR_MUX = "00" else
           "111" when DR_MUX = "01" else
           "110";                       -- when DR_MUX = "10" else
                                        -- "XXX";

  SR1MUX <= IR(11 downto 9) when SR1_MUX = "00" else
            IR(8 downto 6) when SR1_MUX = "01" else
            "110";                      -- when SR1_MUX = "10" else
                                        -- "XXX";

  ADDR1MUX <= PC when ADDR1_MUX = '0' else
              SR1contents;              -- when ADDR1_MUX = '1' else
                                        -- "XXXX"&"XXXX"&"XXXX"&"XXXX";

  ADDR2MUX <= (others => '0') when ADDR2_MUX = "00" else
              SXT(IR(5 downto 0), 16) when ADDR2_MUX = "01" else
              SXT(IR(8 downto 0), 16) when ADDR2_MUX = "10" else
              SXT(IR(10 downto 0), 16);  -- when ADDR2_MUX = "11" else
                                         -- "XXXX"&"XXXX"&"XXXX"&"XXXX";

  -- whence cometh the select line for SR2MUX ??? Possible error in Fig. C.3
  SR2MUX <= SR2contents when IR(5) = '0' else
            SXT(IR(4 downto 0), 16);    --  when = IR( 5 ) = '1' else
                                        -- "XXXX"&"XXXX"&"XXXX"&"XXXX";

  MIOENMUX <= sig_bus when MIO_EN = '0' else
              INMUX;                    -- when = MIO_EN = '1' else
                                        -- "XXXX"&"XXXX"&"XXXX"&"XXXX";

  INMUX <= KBDR when IN_MUX = "00" else
           KBSR when IN_MUX = "01" else
           DSR  when IN_MUX = "10" else
           mem;                         -- when IN_MUX = "11" else
                                        -- "XXXX"&"XXXX"&"XXXX"&"XXXX";

  TheBUS : BussedDriversResolved
    port map (
      Gate_PC     => Gate_PC,
      PC_in       => PC,
      Gate_MDR    => Gate_MDR,
      MDR_in      => MDR,
      Gate_ALU    => Gate_ALU,
      ALU_in      => sig_ALU,
      Gate_MARMUX => Gate_MARMUX,
      MARMUX_in   => MARMUX,
      bus_out     => sig_bus);

  TheREG_FILE : REG_FILE
    port map (
      Clock   => Clock,
      Reset   => Reset,
      bus_in  => sig_bus,
      DR      => DRMUX,
      LD_REG  => LD_REG,
      SR1     => SR1MUX,
      SR2     => IR(2 downto 0),
      SR1_out => SR1contents,
      SR2_out => SR2contents);

  TheALU : ALU
    port map (
      A       => SR1contents,
      B       => SR2MUX,
      ALUK    => ALUK,
      ALU_out => sig_ALU);

  TheCONTROL : CONTROL
    port map (
      Clock           => Clock,
      Reset           => Reset,
      IR              => IR,
      R               => R,
      N               => N,
      Z               => Z,
      P               => P,
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
      Set_Priv        => Set_Priv);

  TheNZP_LOGIC : NZP_LOGIC
    port map (
      Clock  => Clock,
      Reset  => Reset,
      LD_CC  => LD_CC,
      bus_in => sig_bus,
      N_out  => N,
      Z_out  => Z,
      P_out  => P);

  TheADDR_CTL_LOGIC : ADDR_CTL_LOGIC
    port map (
      MAR     => MAR,
      MIO_EN  => MIO_EN,
      R_W     => R_W,
      LD_KBSR => LD_KBSR,
      LD_DSR  => LD_DSR,
      LD_DDR  => LD_DDR,
      MEM_EN  => MEM_EN,
      IN_MUX  => IN_MUX);

  TheMEMORY : MEMORY
    generic map (
      DATA_BITS   => 16,
      MEMORY_SIZE => 128)
    port map (
      Clock  => Clock,
      Reset  => Reset,
      MDR    => MDR,
      MAR    => MAR,
      R_W    => R_W,
      MEM_EN => MEM_EN,
      mem    => mem,
      R      => R);

  reg_PC : template_register
    generic map (
      BIT_WIDTH => 16)
    port map (
      Clock   => Clock,
      Reset   => Reset,
      REG_in  => PCMUX,
      LD_REG  => LD_PC,
      REG_out => PC);

  reg_IR : template_register
    generic map (
      BIT_WIDTH => 16)
    port map (
      Clock   => Clock,
      Reset   => Reset,
      REG_in  => sig_bus,
      LD_REG  => LD_IR,
      REG_out => IR);

  reg_MAR : template_register
    generic map (
      BIT_WIDTH => 16)
    port map (
      Clock   => Clock,
      Reset   => Reset,
      REG_in  => sig_bus,
      LD_REG  => LD_MAR,
      REG_out => MAR);

  reg_MDR : template_register
    generic map (
      BIT_WIDTH => 16)
    port map (
      Clock   => Clock,
      Reset   => Reset,
      REG_in  => MIOENMUX,
      LD_REG  => LD_MDR,
      REG_out => MDR);

  KBDR <= KBDR_in;

  reg_KBSR : template_register
    generic map (
      BIT_WIDTH => 16)
    port map (
      Clock   => Clock,
      Reset   => Reset,
      REG_in  => MDR,
      LD_REG  => LD_KBSR,
      REG_out => KBSR);                 -- IN_MUX = "01", INMUX( 1 )

  reg_DDR : template_register
    generic map (
      BIT_WIDTH => 16)
    port map (
      Clock   => Clock,
      Reset   => Reset,
      REG_in  => MDR,
      LD_REG  => LD_DDR,
      REG_out => DDR);

  DDR_out <= DDR;

  reg_DSR : template_register
    generic map (
      BIT_WIDTH => 16)
    port map (
      Clock   => Clock,
      Reset   => Reset,
      REG_in  => MDR,
      LD_REG  => LD_DSR,
      REG_out => DSR);                  -- IN_MUX = "10", INMUX( 2 )

end structure;
