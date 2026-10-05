library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Diese Zeile ist notwendig, damit ihr Entities aus der ROrgPrSimLib verwenden könnt.
-- Dies könnte z.B. die ALU, der Register-Speicher etc. sein, wenn ihr die entsprechenden
-- Aufgaben nicht erfolgreich bearbeitet habt.
-- Um ein Entity aus der ROrgPrSimLib zu verwenden, instanziiert es einfach als
-- "entity ROrgPrSimLib.<EntityName>" statt "entity work.<EntityName>".
-- Also z.B. "entity ROrgPrSimLib.mipsAlu" statt "entity work.mipsAlu".
-- Spezifiziert in diesen Fällen KEINE architecture, dies könnte sonst zu Problemen führen.
library ROrgPrSimLib;

library work;
use work.proc_config.all;

entity mipsCpu is
    generic(PROG_FILE_NAME : string;
            DATA_FILE_NAME : string
    );
    port(clk : in std_logic;
         rst : in std_logic;

         -- instruction insertion ports
         testMode_debug : in std_logic;
         testInstruction_debug : in std_logic_vector(31 downto 0);

         -- ram access ports
         ramInsertMode_debug :  in std_logic;
         ramWriteEn_debug :   in std_logic;
         ramWriteAddr_debug :    in std_logic_vector(LOG2_NUM_RAM_ELEMENTS - 1 downto 0);
         ramWriteData_debug :   in std_logic_vector(RAM_ELEMENT_WIDTH - 1 downto 0);
         ramElements_debug :   out ram_elements_type;

         -- register file access port
         registers_debug : out reg_vector_type;

         -- intermediate result ports
         pc_next_debug : out std_logic_vector(PC_WIDTH - 1 downto 0);
         pc7SegDigits_debug : out pc_7seg_digits_type
    );
end mipsCpu;

architecture structure of mipsCpu is


    -- Beschreibung der MIPS-CPU ergänzen
    -- PC
    signal pc_cur: std_logic_vector(PC_WIDTH - 1 downto 0); --aktuelle pc
    signal pc_plus4: std_logic_vector ( PC_WIDTH -1 downto 0 ); -- pc+4
    signal pc_branch: std_logic_vector( PC_WIDTH -1 downto 0 ); --branch ziel
    signal pc_next : std_logic_vector(PC_WIDTH-1 downto 0 );-- next pc 
    
    --clockss
    signal invClk :          std_logic; 
   

    -- Instruction path
    signal instr_rom :std_logic_vector(31 downto 0);-- aus rom lesen
    signal instr_used   : std_logic_vector(31 downto 0);
    

    -- Instruction fields
    
    signal op : std_logic_vector(5 downto 0); -- op code 
    signal  funct : std_logic_vector(5 downto 0);
    signal rs  : std_logic_vector(LOG2_NUM_REGS -1 downto 0);-- reg 1
    signal rt  : std_logic_vector(LOG2_NUM_REGS-1 downto 0);--reg2
    signal rd   : std_logic_vector(LOG2_NUM_REGS -1 downto 0 ); --destination
    signal imm16 : std_logic_vector(15 downto 0 ); -- immediat

    -- Control signals
    signal regDst          : std_logic; -- rd 1 or rt 0 
    signal branch          : std_logic; -- do we have branching ? 
    signal memRead         : std_logic; 
    signal memToReg        : std_logic;
    signal aluOp           : std_logic_vector(1 downto 0);
    signal memWrite        : std_logic;
    signal aluSrc          : std_logic;
    signal regWrite        : std_logic;

    -- Register file
    
    signal regData1        : std_logic_vector(REG_WIDTH-1 downto 0 ); -- data de rs
    signal regData2        : std_logic_vector(REG_WIDTH-1 downto 0 ); -- data de rt 
    signal writeRegAddr    : std_logic_vector(LOG2_NUM_REGS - 1 downto 0);-- adresse zum schreiben 
    signal writeBackData   : std_logic_vector(REG_WIDTH - 1 downto 0 ); -- data to write 

    -- Immediate / ALU
    signal immExt_signed   : signed(REG_WIDTH - 1 downto 0); --sign extend imm
    signal immExt          : std_logic_vector(REG_WIDTH - 1 downto 0);
    signal immShift2       : std_logic_vector(REG_WIDTH - 1 downto 0); -- <<2 für branch

    signal aluInB          : std_logic_vector(ALU_WIDTH - 1 downto 0); -- 2nd alu eingang 
    signal aluCtrlSig      : std_logic_vector(3 downto 0);-- alu steuerung 
    signal rTypeAluCtrlSig : std_logic_vector(3 downto 0); -- R-type Alu steuerung
    signal aluResult       : std_logic_vector(ALU_WIDTH - 1 downto 0); -- Alu result 
    signal aluOverflow     : std_logic; 
    signal aluZero         : std_logic;

    -- Data memory
    signal ramAddr_cpu     : std_logic_vector(LOG2_NUM_RAM_ELEMENTS - 1 downto 0); --wort - adresse
    signal ramReadData     : std_logic_vector(RAM_ELEMENT_WIDTH - 1 downto 0); -- gelesene Daten

    -- Debug RAM insert muxed signals
    signal ramWriteEn_mux  : std_logic;
    signal ramWriteAddr_mux: std_logic_vector(LOG2_NUM_RAM_ELEMENTS - 1 downto 0);
    signal ramWriteData_mux: std_logic_vector(RAM_ELEMENT_WIDTH - 1 downto 0);

    -- 7seg
    signal nib0, nib1, nib2, nib3 : std_logic_vector(3 downto 0);
begin
    invClk <= not clk; -- fallende flanke für RAM
     PC_REG: entity work.reg(behavioral)
        generic map(WIDTH => PC_WIDTH)
        port map(
            clk => clk,
            rst => rst,
            en  => not testMode_debug,  -- PC stays constant in testMode
            D   => pc_next,
            Q   => pc_cur
        );
    -- Instruction Memory (bereits vorgegeben)
    INSTR_MEMORY: entity work.flashROM(behavioral)
        generic map(NUM_ELEMENTS => NUM_ROM_ELEMENTS,
                    LOG2_NUM_ELEMENTS => LOG2_NUM_ROM_ELEMENTS,
                    ELEMENT_WIDTH => 32 ,
                    INIT_FILE_NAME => PROG_FILE_NAME)
        port map(address => pc_cur(LOG2_NUM_ROM_ELEMENTS + 1 downto 2),
                 readData => instr_rom );
    --Instruction insertion mux
    instr_used <= testInstruction_debug when testMode_debug = '1' else instr_rom;
--extraction
    op    <= instr_used(31 downto 26);
    rs    <= instr_used(25 downto 21);
    rt    <= instr_used(20 downto 16);
    rd    <= instr_used(15 downto 11);
    funct <= instr_used(5 downto 0);
    imm16 <= instr_used(15 downto 0);
    -- erzeugt alle steuersignale basierend auf dem opcode 
    CTRL: entity work.mipsCtrl(structural)
    port map(
        op       => op,
        regDst   => regDst,
        branch   => branch,
        memRead  => memRead,
        memToReg => memToReg,
        aluOp    => aluOp,
        memWrite => memWrite,
        aluSrc   => aluSrc,
        regWrite => regWrite
    );
    -- Register File
    writeRegAddr <= rd when regDst = '1' else rt;

    REGFILE: entity work.regFile(structural)
        generic map(
            NUM_REGS       => NUM_REGS,
            LOG2_NUM_REGS  => LOG2_NUM_REGS,
            REG_WIDTH      => REG_WIDTH
        )
        port map(
            clk           => clk,
            rst           => rst,
            readAddr1     => rs,
            readData1     => regData1,
            readAddr2     => rt,
            readData2     => regData2,
            writeEn       => regWrite,
            writeAddr     => writeRegAddr,
            writeData     => writeBackData,
            reg_vect_debug => registers_debug
        );
    -- Sign extend + shift left 2 for branch 

    -- 16bit to 32 vit
    SIGNEXT: entity work.signExtend(behavioral)
        generic map(
            INPUT_WIDTH  => 16,
            OUTPUT_WIDTH => REG_WIDTH
        )
        port map(
            number        => signed(imm16),
            signExtNumber  => immExt_signed
        );

    immExt <= std_logic_vector(immExt_signed);
-- left shift 
    SHL2: entity work.leftShifter(behavioral)
        generic map(
            WIDTH        => REG_WIDTH,
            SHIFT_AMOUNT => 2
        )
        port map(
            number        => immExt,
            shiftedNumber => immShift2
        );

    --ALUctrl
    rTypeAluCtrlSig <= "0010" when funct="100000" else -- ADD
                       "0110" when funct="100010" else -- SUB
                       "0000" when funct="100100" else -- AND
                       "0001" when funct="100101" else -- OR
                       "0111" when funct="101010" else -- SLT
                       "0010";                         -- default ADD

    aluCtrlSig <= "0010"          when aluOp="00" else -- ADD
                  "0110"          when aluOp="01" else -- SUB
                  rTypeAluCtrlSig when aluOp="10" else -- R-type (by funct)
                  "0010";                              -- default ADD

    --ALU Src mux  : imm or register 
    aluInB <= immExt when aluSrc = '1' else regData2;

    ALU: entity work.mipsAlu(behavioral)
        generic map(WIDTH => ALU_WIDTH)
        port map(
            ctrl     => aluCtrlSig,
            a        => regData1,
            b        => aluInB,
            result   => aluResult,
            overflow => aluOverflow,
            zero     => aluZero
        );
    -- PC calculation (pc+4, branch)
    pc_plus4  <= std_logic_vector(unsigned(pc_cur) + 4); -- standard R 

    pc_branch <= std_logic_vector(unsigned(pc_plus4) + unsigned(immShift2)); -- I branching

    pc_next <= pc_branch when (branch = '1' and aluZero = '1') else pc_plus4; -- J type

    -- Debug o: for next pc 
    pc_next_debug <= pc_next;
    -- Data memory address (byte ->  wort-adresse)
    ramAddr_cpu <= aluResult(LOG2_NUM_RAM_ELEMENTS + 1 downto 2);
    -- RAM Insert Mode muxes
    ramWriteEn_mux   <= ramWriteEn_debug   when ramInsertMode_debug = '1' else memWrite;
    ramWriteAddr_mux <= ramWriteAddr_debug when ramInsertMode_debug = '1' else ramAddr_cpu;
    ramWriteData_mux <= ramWriteData_debug when ramInsertMode_debug = '1' else regData2;


    -- Data Memory (bereits vorgegeben)
    DATA_MEMORY: entity work.flashRAM(behavioral) 
        generic map(
                    NUM_ELEMENTS => NUM_RAM_ELEMENTS,
                    LOG2_NUM_ELEMENTS => LOG2_NUM_RAM_ELEMENTS ,
                    ELEMENT_WIDTH => RAM_ELEMENT_WIDTH,
                    INIT_FILE_NAME => DATA_FILE_NAME)
        port map(clk => invClk,

                 address => ramWriteAddr_mux ,
                 writeEn => ramWriteEn_mux,
                 writeData => ramWriteData_mux,
                 readEn => memRead ,
                 readData =>  ramReadData,
                 ramElements_debug => ramElements_debug);
    -- Writeback mux (MemtoReg)


    writeBackData <= ramReadData when memToReg = '1' else aluResult;
    -- 7-seg output: show pc_next low 16 bits as hex digits
    nib0 <= pc_cur(3 downto 0);
    nib1 <= pc_cur(7 downto 4);
    nib2 <= pc_cur(11 downto 8);
    nib3 <= pc_cur(15 downto 12); 


    HEX0: entity work.bin2Char(behavioral) port map(bin => nib0, bitmask => pc7SegDigits_debug(0));
    HEX1: entity work.bin2Char(behavioral) port map(bin => nib1, bitmask => pc7SegDigits_debug(1));
    HEX2: entity work.bin2Char(behavioral) port map(bin => nib2, bitmask => pc7SegDigits_debug(2));
    HEX3: entity work.bin2Char(behavioral) port map(bin => nib3, bitmask => pc7SegDigits_debug(3));


end architecture;
