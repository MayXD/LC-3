library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

entity Control_Store is

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
    Set_Priv        : out std_logic);

end Control_Store;

architecture behavior of Control_Store is

  subtype bits49 is std_logic_vector( 48 downto 0 );
  type bits49array is array (natural range <>) of bits49;

  constant Ctrl_Store : bits49array := (
    -- IRD COND J       LD_           GATE_      _MUX              REST

    --                          SS                                     S
    --                          aa                                     e
    --                          vvV      MV                  V       M t
    --                          eee      Ae            AA    e       I .
    --                         Pddc      RcP           DD    c     A O P
    --                  MM BR  rSUt    MAMtCP        S DD   Mt P   L .Rr
    --                  ADIEECPiSSo   PDLUo-SS   P D R RR S Ao S   U E.i
    --                  RRRNGCCvPPr   CRUXr1RP   C R 1 12 P Rr R   K NWv
    "0"&"010"&"010010"&"00000000000"&"00000000"&"XXXXXXXXXXXXXXX"&"XX0XX",  -- 0
    "0"&"000"&"010010"&"00001100000"&"00100000"&"XX0001XXXXXXXXX"&"000XX",  -- 1
    "0"&"000"&"011001"&"10000000000"&"00010000"&"XXXXXX010XX1XXX"&"XX0XX",  -- 2
    "0"&"000"&"010111"&"10000000000"&"00010000"&"XXXXXX010XX1XXX"&"XX0XX",  -- 3
    "0"&"011"&"010100"&"00000000000"&"00000000"&"XXXXXXXXXXXXXXX"&"XX0XX",  -- 4
    "0"&"000"&"010010"&"00001100000"&"00100000"&"XX0001XXXXXXXXX"&"010XX",  -- 5
    "0"&"000"&"011001"&"10000000000"&"00010000"&"XXXX01101XX1XXX"&"XX0XX",  -- 6
    "0"&"000"&"010111"&"10000000000"&"00010000"&"XXXX01101XX1XXX"&"XX0XX",  -- 7
    "X"&"XXX"&"XXXXXX"&"XXXXXXXXXXX"&"XXXXXXXX"&"XXXXXXXXXXXXXXX"&"XXXXX",  -- 8 INT
    "0"&"000"&"010010"&"00001100000"&"00100000"&"XX0001XXXXXXXXX"&"100XX",  -- 9
    "0"&"000"&"011000"&"10000000000"&"00010000"&"XXXXXX010XX1XXX"&"XX0XX",  --10
    "0"&"000"&"011101"&"10000000000"&"00010000"&"XXXXXX010XX1XXX"&"XX0XX",  --11
    "0"&"000"&"010010"&"00000010000"&"00100000"&"01XX01XXXXXXXXX"&"110XX",  --12
    "X"&"XXX"&"XXXXXX"&"XXXXXXXXXXX"&"XXXXXXXX"&"XXXXXXXXXXXXXXX"&"XXXXX",  --13 INT
    "0"&"000"&"010010"&"00001100000"&"00010000"&"XX00XX010XX1XXX"&"XX0XX",  --14
    "0"&"000"&"011100"&"10000000000"&"00010000"&"XXXXXXXXXXX0XXX"&"XX0XX",  --15
    "0"&"001"&"010000"&"00000000000"&"00000000"&"XXXXXXXXXXXXXXX"&"XX11X",  --16
    "X"&"XXX"&"XXXXXX"&"XXXXXXXXXXX"&"XXXXXXXX"&"XXXXXXXXXXXXXXX"&"XXXXX",  --17 UN
    "0"&"101"&"100001"&"10000010000"&"10000000"&"00XXXXXXXXXXXXX"&"XX0XX",  --18
    "X"&"XXX"&"XXXXXX"&"XXXXXXXXXXX"&"XXXXXXXX"&"XXXXXXXXXXXXXXX"&"XXXXX",  --19 UN
    "0"&"000"&"010010"&"00001010000"&"10000000"&"100101100XXXXXX"&"XX0XX",  --20
    "0"&"000"&"010010"&"00001010000"&"10000000"&"1001XX011XXXXXX"&"XX0XX",  --21
    "0"&"000"&"010010"&"00000010000"&"00000000"&"10XXXX010XXXXXX"&"XX0XX",  --22
    "0"&"000"&"010000"&"01000000000"&"00100000"&"XXXX00XXXXXXXXX"&"110XX",  --23
    "0"&"001"&"011000"&"01000000000"&"00000000"&"XXXXXXXXXXXXXXX"&"XX10X",  --24
    "0"&"001"&"011001"&"01000000000"&"00000000"&"XXXXXXXXXXXXXXX"&"XX10X",  --25
    "0"&"000"&"011001"&"10000000000"&"01000000"&"XXXXXXXXXXXXXXX"&"XX0XX",  --26
    "0"&"000"&"010010"&"00001100000"&"01000000"&"XX00XXXXXXXXXXX"&"XX0XX",  --27
    "0"&"001"&"011100"&"01001000000"&"10000000"&"XX01XXXXXXXXXXX"&"XX10X",  --28
    "0"&"001"&"011101"&"01000000000"&"00000000"&"XXXXXXXXXXXXXXX"&"XX10X",  --29
    "0"&"000"&"010010"&"00000010000"&"01000000"&"01XXXXXXXXXXXXX"&"XX0XX",  --30
    "0"&"000"&"010111"&"10000000000"&"01000000"&"XXXXXXXXXXXXXXX"&"XX0XX",  --31
    "1"&"XXX"&"XXXXXX"&"00010000000"&"00000000"&"XXXXXXXXXXXXXXX"&"XX0XX",  --32
    "0"&"001"&"100001"&"01000000000"&"00000000"&"XXXXXXXXXXXXXXX"&"XX10X",  --33
    "X"&"XXX"&"XXXXXX"&"XXXXXXXXXXX"&"XXXXXXXX"&"XXXXXXXXXXXXXXX"&"XXXXX",  --34 INT
    "0"&"000"&"100000"&"00100000000"&"01000000"&"XXXXXXXXXXXXXXX"&"XX0XX",  --35
    "X"&"XXX"&"XXXXXX"&"XXXXXXXXXXX"&"XXXXXXXX"&"XXXXXXXXXXXXXXX"&"XXXXX",  --36 INT
    "X"&"XXX"&"XXXXXX"&"XXXXXXXXXXX"&"XXXXXXXX"&"XXXXXXXXXXXXXXX"&"XXXXX",  --37 INT
    "X"&"XXX"&"XXXXXX"&"XXXXXXXXXXX"&"XXXXXXXX"&"XXXXXXXXXXXXXXX"&"XXXXX",  --38 INT
    "X"&"XXX"&"XXXXXX"&"XXXXXXXXXXX"&"XXXXXXXX"&"XXXXXXXXXXXXXXX"&"XXXXX",  --39 INT
    "X"&"XXX"&"XXXXXX"&"XXXXXXXXXXX"&"XXXXXXXX"&"XXXXXXXXXXXXXXX"&"XXXXX",  --40 INT
    "X"&"XXX"&"XXXXXX"&"XXXXXXXXXXX"&"XXXXXXXX"&"XXXXXXXXXXXXXXX"&"XXXXX",  --41 INT
    "X"&"XXX"&"XXXXXX"&"XXXXXXXXXXX"&"XXXXXXXX"&"XXXXXXXXXXXXXXX"&"XXXXX",  --42 INT
    "X"&"XXX"&"XXXXXX"&"XXXXXXXXXXX"&"XXXXXXXX"&"XXXXXXXXXXXXXXX"&"XXXXX",  --43 INT
    "X"&"XXX"&"XXXXXX"&"XXXXXXXXXXX"&"XXXXXXXX"&"XXXXXXXXXXXXXXX"&"XXXXX",  --44 INT
    "X"&"XXX"&"XXXXXX"&"XXXXXXXXXXX"&"XXXXXXXX"&"XXXXXXXXXXXXXXX"&"XXXXX",  --45 INT
    "X"&"XXX"&"XXXXXX"&"XXXXXXXXXXX"&"XXXXXXXX"&"XXXXXXXXXXXXXXX"&"XXXXX",  --46 UN
    "X"&"XXX"&"XXXXXX"&"XXXXXXXXXXX"&"XXXXXXXX"&"XXXXXXXXXXXXXXX"&"XXXXX",  --47 INT
    "X"&"XXX"&"XXXXXX"&"XXXXXXXXXXX"&"XXXXXXXX"&"XXXXXXXXXXXXXXX"&"XXXXX",  --48 INT
    "X"&"XXX"&"XXXXXX"&"XXXXXXXXXXX"&"XXXXXXXX"&"XXXXXXXXXXXXXXX"&"XXXXX",  --49 INT
    "X"&"XXX"&"XXXXXX"&"XXXXXXXXXXX"&"XXXXXXXX"&"XXXXXXXXXXXXXXX"&"XXXXX",  --50 INT
    "X"&"XXX"&"XXXXXX"&"XXXXXXXXXXX"&"XXXXXXXX"&"XXXXXXXXXXXXXXX"&"XXXXX",  --51 INT
    "X"&"XXX"&"XXXXXX"&"XXXXXXXXXXX"&"XXXXXXXX"&"XXXXXXXXXXXXXXX"&"XXXXX",  --52 INT
    "X"&"XXX"&"XXXXXX"&"XXXXXXXXXXX"&"XXXXXXXX"&"XXXXXXXXXXXXXXX"&"XXXXX",  --53 UN
    "X"&"XXX"&"XXXXXX"&"XXXXXXXXXXX"&"XXXXXXXX"&"XXXXXXXXXXXXXXX"&"XXXXX",  --54 INT
    "X"&"XXX"&"XXXXXX"&"XXXXXXXXXXX"&"XXXXXXXX"&"XXXXXXXXXXXXXXX"&"XXXXX",  --55 UN
    "X"&"XXX"&"XXXXXX"&"XXXXXXXXXXX"&"XXXXXXXX"&"XXXXXXXXXXXXXXX"&"XXXXX",  --56 UN
    "X"&"XXX"&"XXXXXX"&"XXXXXXXXXXX"&"XXXXXXXX"&"XXXXXXXXXXXXXXX"&"XXXXX",  --57 UN
    "X"&"XXX"&"XXXXXX"&"XXXXXXXXXXX"&"XXXXXXXX"&"XXXXXXXXXXXXXXX"&"XXXXX",  --58 UN
    "X"&"XXX"&"XXXXXX"&"XXXXXXXXXXX"&"XXXXXXXX"&"XXXXXXXXXXXXXXX"&"XXXXX",  --59 INT
    "X"&"XXX"&"XXXXXX"&"XXXXXXXXXXX"&"XXXXXXXX"&"XXXXXXXXXXXXXXX"&"XXXXX",  --60 UN
    "X"&"XXX"&"XXXXXX"&"XXXXXXXXXXX"&"XXXXXXXX"&"XXXXXXXXXXXXXXX"&"XXXXX",  --61 UN
    "X"&"XXX"&"XXXXXX"&"XXXXXXXXXXX"&"XXXXXXXX"&"XXXXXXXXXXXXXXX"&"XXXXX",  --62 UN
    "X"&"XXX"&"XXXXXX"&"XXXXXXXXXXX"&"XXXXXXXX"&"XXXXXXXXXXXXXXX"&"XXXXX");  --63 UN

  signal Microinstruction      : bits49;
  signal next_Microinstruction : bits49;

begin

  -- The following line takes bits from 'next_state',
  -- converts them to an integer, and uses that
  -- integer to index the array called Ctrl_Store.
  -- It then assigns that row to 'next_Microinstruction'.

  next_Microinstruction <= Ctrl_Store( conv_integer( next_state ));

  latch_microinstruction_register : process ( Clock, Reset )
  begin
-- @W:"/s/chopin/k/grad/kaito/sec/VHDL/Control_Store.vhd":145:4:145:5|
--  Optimizing register bit microinstruction(0) to a constant 0
--
--    @N:"/s/chopin/k/grad/kaito/sec/VHDL/template_register.vhd":
--    28:4:28:5|Found counter in view:
--    work.LC_3_data_path(structure) inst reg_PC.REG_out[15:0]
--    @N:"/s/chopin/k/grad/kaito/sec/VHDL/Control_Store.vhd":
--    141:27:141:65|Generating ROM next_microinstruction[46:37]
--    @N:"/s/chopin/k/grad/kaito/sec/VHDL/Control_Store.vhd":
--    141:27:141:65|Generating ROM next_microinstruction[34:32]
--    @N:"/s/chopin/k/grad/kaito/sec/VHDL/Control_Store.vhd":
--    141:27:141:65|Generating ROM next_microinstruction[27:24]
--
--    @N|The option to pack flops in the IOB has not been specified
--
--    @N| This timing report estimates place and route data.
--    Please look at the place and route timing report for final timing.


    if Reset = '1' then
      Microinstruction <= ( "0"&"101"&"100001"&"10000010000"&
                            "10000000"&"00XXXXXXXXXXXXX"&"XX0XX" ); -- state 18
    elsif Clock'event and Clock = '1' then
      Microinstruction <= next_Microinstruction;
    end if;
  end process latch_microinstruction_register;

  IRD             <= Microinstruction( 48 );
  COND            <= Microinstruction( 47 downto 45 );
  J               <= Microinstruction( 44 downto 39 );
  LD_MAR          <= Microinstruction( 38 );
  LD_MDR          <= Microinstruction( 37 );
  LD_IR           <= Microinstruction( 36 );
  LD_BEN          <= Microinstruction( 35 );
  LD_REG          <= Microinstruction( 34 );
  LD_CC           <= Microinstruction( 33 );
  LD_PC           <= Microinstruction( 32 );
  LD_Priv         <= Microinstruction( 31 );
  LD_SavedSSP     <= Microinstruction( 30 );
  LD_SavedUSP     <= Microinstruction( 29 );
  LD_Vector       <= Microinstruction( 28 );
  Gate_PC         <= Microinstruction( 27 );
  Gate_MDR        <= Microinstruction( 26 );
  Gate_ALU        <= Microinstruction( 25 );
  Gate_MARMUX     <= Microinstruction( 24 );
  Gate_Vector     <= Microinstruction( 23 );
  Gate_PC_minus_1 <= Microinstruction( 22 );
  Gate_PSR        <= Microinstruction( 21 );
  Gate_SP         <= Microinstruction( 20 );
  PC_MUX          <= Microinstruction( 19 downto 18 );
  DR_MUX          <= Microinstruction( 17 downto 16 );
  SR1_MUX         <= Microinstruction( 15 downto 14 );
  ADDR1_MUX       <= Microinstruction( 13 );
  ADDR2_MUX       <= Microinstruction( 12 downto 11 );
  SP_MUX          <= Microinstruction( 10 downto 9 );
  MAR_MUX         <= Microinstruction( 8 );
  Vector_MUX      <= Microinstruction( 7 downto 6 );
  PSR_MUX         <= Microinstruction( 5 );
  ALUK            <= Microinstruction( 4 downto 3 );
  MIO_EN          <= Microinstruction( 2 );
  R_W             <= Microinstruction( 1 );
  Set_Priv        <= Microinstruction( 0 );

end behavior;
