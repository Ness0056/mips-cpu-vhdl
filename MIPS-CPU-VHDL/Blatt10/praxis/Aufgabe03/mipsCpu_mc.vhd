library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Diese Zeile ist notwendig, damit ihr Entities aus der ROrgPrSimLib verwenden könnt.
-- Dies könnte z.B. die ALU, der Register-Speicher etc. sein, wenn ihr die entsprechenden
-- Aufgaben nicht erfolgreich bearbeitet habt.
-- Um ein Entity aus der ROrgPrSimLib zu verwenden, instanziiert es einfach als
-- "entity ROrgPrSimLib.<EntityName>" statt "entity work.<EntityName>".
-- Also z.B. "entity ROrgPrSimLib.regFile" statt "entity work.regFile".
-- Spezifiziert in diesen Fällen KEINE architecture.
library ROrgPrSimLib;

library work;
use work.proc_config.all;
use work.flashRAM;

entity mipsCpu_mc is
    generic(INIT_FILE_NAME : string);
    port(clk : in std_logic;
         rst : in std_logic;

         -- debug ports
         ramElements_debug   : out ram_elements_type;
         registers_debug     : out reg_vector_type;
         pc7SegDigits_debug  : out pc_7seg_digits_type;
         mipsCtrlState_debug : out mips_ctrl_state_type
         );
end mipsCpu_mc;

architecture structure of mipsCpu_mc is

    signal clk_inv : std_logic;

    -- MIPS CTRL (FSM)
    signal ctrl_RegDst : std_logic_vector(1 downto 0);
    signal ctrl_MemRead : std_logic;
    signal ctrl_MemToReg : std_logic;
    signal ctrl_ALUOp : std_logic_vector(1 downto 0);
    signal ctrl_MemWrite : std_logic;
    signal ctrl_RegWrite : std_logic;
    signal ctrl_ALUSrcA : std_logic;
    signal ctrl_ALUSrcB : std_logic_vector(1 downto 0);
    signal ctrl_PCSource : std_logic_vector(1 downto 0);
    signal ctrl_IRWrite : std_logic;
    signal ctrl_IorD : std_logic;
    signal ctrl_PCWrite : std_logic;
    signal ctrl_PCWriteCond : std_logic;
    signal ctrl_Lui : std_logic;

    signal reg_PC_out : std_logic_vector(PC_WIDTH - 1 downto 0);

    signal mux_IorD_out : std_logic_vector(LOG2_NUM_RAM_ELEMENTS - 1 downto 0);

    -- Flash RAM
    signal ram_MemData : std_logic_vector(RAM_ELEMENT_WIDTH - 1 downto 0);

    -- Reg Instr
    signal reg_Instruction_out : std_logic_vector(32 - 1 downto 0);

    -- Reg Mem Data 
    signal reg_Memory_data_out : std_logic_vector(32 - 1 downto 0);


    signal concat_lui_out : std_logic_vector(32 - 1 downto 0);
    signal mux_Write_register_out : std_logic_vector(LOG2_NUM_REGS - 1 downto 0);
    signal mux_Write_data_out : std_logic_vector(NUM_REGS - 1 downto 0);

    signal signExt_result_signed : signed(32 - 1 downto 0);
    signal signExt_result_vector : std_logic_vector(32 - 1 downto 0);
    signal shiftLeft_signExt_result : std_logic_vector(32 - 1 downto 0);

    -- ReadData Regs
    signal reg_ReadDataA_in : std_logic_vector(REG_WIDTH - 1 downto 0); 
    signal reg_ReadDataA_out : std_logic_vector(REG_WIDTH - 1 downto 0); 
    signal reg_ReadDataB_in : std_logic_vector(REG_WIDTH - 1 downto 0); 
    signal reg_ReadDataB_out : std_logic_vector(REG_WIDTH - 1 downto 0); 


    signal mux_ALUSrcA_out : std_logic_vector(ALU_WIDTH - 1 downto 0);
    signal mux_ALUSrcB_out : std_logic_vector(ALU_WIDTH - 1 downto 0);


    signal shiftLeft_jump_result : std_logic_vector(28 - 1 downto 0);

    -- ALU
    signal alu_result : std_logic_vector(ALU_WIDTH - 1 downto 0);
    signal alu_Zero : std_logic;

    -- ALU CTRL
    signal aluctrl_operation : std_logic_vector(3 downto 0);
    signal aluctrl_jr : std_logic;

    -- ALUOut Reg
    signal reg_ALUOut_out : std_logic_vector(ALU_WIDTH - 1 downto 0);


    signal mux_PCSource_out : std_logic_vector(PC_WIDTH - 1 downto 0);

begin

    clk_inv <= NOT clk;

    -- MIPS Control
    MIPS_CTRL_FSM: entity work.mipsCtrlFsm(behavioral) port map (
	clk => clk,
	rst => rst,
	op => reg_Instruction_out(31 downto 26),
	jr => aluctrl_jr,
	regDst => ctrl_RegDst,
	memRead => ctrl_MemRead,
	memToReg => ctrl_MemToReg,
	aluOp => ctrl_ALUOp,
	memWrite => ctrl_MemWrite,
	regWrite => ctrl_RegWrite,
	aluSrcA => ctrl_ALUSrcA,
	aluSrcB => ctrl_ALUSrcB,
	pcSrc => ctrl_PCSource,
	irWrite => ctrl_IRWrite,
	IorD => ctrl_IorD,
	pcWrite => ctrl_PCWrite,
	pcWriteCond => ctrl_PCWriteCond,
	lui => ctrl_Lui,
	mipsCtrlState_debug => mipsCtrlState_debug
    );

    -- bin2char x4
    OUT_0: entity work.bin2Char(behavioral)
	port map (bin => reg_PC_out( 3 downto  0),
		  bitmask => pc7SegDigits_debug(0));
    OUT_1: entity work.bin2Char(behavioral)
	port map (bin => reg_PC_out( 7 downto  4),
		  bitmask => pc7SegDigits_debug(1));
    OUT_2: entity work.bin2Char(behavioral)
	port map (bin => reg_PC_out(11 downto  8),
		  bitmask => pc7SegDigits_debug(2));
    OUT_3: entity work.bin2Char(behavioral)
	port map (bin => reg_PC_out(15 downto 12),
		  bitmask => pc7SegDigits_debug(3));

 
    REG_PC: entity work.reg(behavioral)
	generic map (WIDTH => PC_WIDTH)
	port map (
            clk => clk,
            rst => rst,
            en => ctrl_PCWrite OR (ctrl_PCWriteCond AND alu_Zero),
            D => mux_PCSource_out,
            Q => reg_PC_out
	);

    mux_IorD_out <=
	reg_ALUOut_out(LOG2_NUM_RAM_ELEMENTS + 2 - 1 downto 2) when ctrl_IorD = '1' else
	reg_PC_out(LOG2_NUM_RAM_ELEMENTS + 2 - 1 downto 2);

    -- Daten und Instruktionsspeicher
    INSTR_AND_DATA_MEMORY: entity work.flashRAM(behavioral)
        generic map(NUM_ELEMENTS => NUM_RAM_ELEMENTS,
                    LOG2_NUM_ELEMENTS => LOG2_NUM_RAM_ELEMENTS,
                    ELEMENT_WIDTH => RAM_ELEMENT_WIDTH,
                    INIT_FILE_NAME => INIT_FILE_NAME)
        port map(clk => clk_inv,
                 address => mux_IorD_out,
                 readEn => ctrl_MemRead,
                 readData => ram_MemData,
                 writeEn => ctrl_MemWrite,
                 writeData => reg_ReadDataB_out,
                 ramElements_debug => ramElements_debug);

    REG_INSTR: entity work.reg(behavioral)
	generic map(WIDTH => 32)
        port map(
            clk => clk,
            rst => rst,
            en => ctrl_IRWrite,
            D => ram_MemData,
            Q => reg_Instruction_out
	);

    REG_MEMDATA: entity work.reg(behavioral)
	generic map(WIDTH => 32)
        port map(
            clk => clk,
            rst => rst,
            en => '1', -- Always write to Memory data register
            D => ram_MemData,
            Q => reg_Memory_data_out
	);

    concat_lui_out <= reg_Instruction_out(16 - 1 downto 0) & (16 - 1 downto 0 => '0');
    mux_Write_register_out <= 
	reg_Instruction_out(20 downto 16)	when ctrl_RegDst = "00" else
	reg_Instruction_out(15 downto 11)	when ctrl_RegDst = "01" else
	(5 - 1 downto 0 => '1')			when ctrl_RegDst = "10" else --> "11111" = 31
	(5 - 1 downto 0 => '0');
    mux_Write_data_out <=
	reg_ALUOut_out		when ctrl_Lui = '0' and ctrl_MemtoReg = '0' else
	reg_Memory_data_out	when ctrl_Lui = '0' and ctrl_MemtoReg = '1' else
	concat_lui_out		when ctrl_Lui = '1' and ctrl_MemtoReg = '0' else
	(32 - 1 downto 0 => '0');

    REGFILE: entity work.regFile(structural)
        generic map(
            NUM_REGS       => NUM_REGS,
            LOG2_NUM_REGS  => LOG2_NUM_REGS,
            REG_WIDTH      => REG_WIDTH
        )
        port map(
            clk           => clk,
            rst           => rst,
            readAddr1     => reg_Instruction_out(25 downto 21),
            readData1     => reg_ReadDataA_in,
            readAddr2     => reg_Instruction_out(20 downto 16),
            readData2     => reg_ReadDataB_in,
            writeEn       => ctrl_RegWrite,
            writeAddr     => mux_Write_register_out,
            writeData     => mux_Write_data_out,
            reg_vect_debug => registers_debug
        );

    SIGN_EXT: entity work.signExtend(behavioral)
        generic map(
            INPUT_WIDTH  => 16,
            OUTPUT_WIDTH => 32
        )
        port map(
            number        => signed(reg_Instruction_out(15 downto 0)),
            signExtNumber => signExt_result_signed
        );

    signExt_result_vector <= std_logic_vector(signExt_result_signed);

    SHIFT_LEFT_2_SIGN_EXT: entity work.leftShifter(behavioral)
        generic map(
            WIDTH        => 32,
            SHIFT_AMOUNT => 2
        )
        port map(
            number        => signExt_result_vector,
            shiftedNumber => shiftLeft_signExt_result
        );

    REG_READDATA_A: entity work.reg(behavioral)
	generic map(WIDTH => REG_WIDTH)
        port map(
            clk => clk,
            rst => rst,
            en => '1',
            D => reg_ReadDataA_in,
            Q => reg_ReadDataA_out
	);
    REG_READDATA_B: entity work.reg(behavioral)
	generic map(WIDTH => REG_WIDTH)
        port map(
            clk => clk,
            rst => rst,
            en => '1',
            D => reg_ReadDataB_in,
            Q => reg_ReadDataB_out
	);

    mux_ALUSrcA_out <= reg_ReadDataA_out when ctrl_ALUSrcA = '1' else reg_PC_out;
    mux_ALUSrcB_out <=
	(ALU_WIDTH - 1 downto 3 => '0') & "100"	when ctrl_ALUSrcB = "01" else
	signExt_result_vector			when ctrl_ALUSrcB = "10" else
	shiftLeft_signExt_result		when ctrl_ALUSrcB = "11" else
	reg_ReadDataB_out;

    SHIFT_LEFT_2_JUMP: entity work.leftShifter(behavioral)
        generic map(
            WIDTH        => 28,
            SHIFT_AMOUNT => 2
        )
        port map(
            number        => "00" & reg_Instruction_out(25 downto 0),
            shiftedNumber => shiftLeft_jump_result
        );

    ALU_CTRL: entity work.aluCtrlExt(behavioral)
	port map(
	    aluOp	=> ctrl_ALUOp,
            f		=> reg_Instruction_out(5 downto 0),
            operation	=> aluctrl_operation,
            jr		=> aluctrl_jr
	);

    ALU: entity work.mipsAlu(behavioral)
        generic map(WIDTH => ALU_WIDTH)
        port map(
            ctrl     => aluctrl_operation,
            a        => mux_ALUSrcA_out,
            b        => mux_ALUSrcB_out,
            result   => alu_result,
            overflow => open,
            zero     => alu_Zero
        );

    REG_ALU_OUT: entity work.reg(behavioral)
	generic map(WIDTH => ALU_WIDTH)
        port map(
            clk => clk,
            rst => rst,
            en => '1',
            D => alu_result,
            Q => reg_ALUOut_out
	);

    mux_PCSource_out <=
	alu_result						when ctrl_PCSource = "00" else
	reg_ALUOut_out						when ctrl_PCSource = "01" else
	reg_PC_out(31 downto 28) & shiftLeft_jump_result	when ctrl_PCSource = "10" else
	(31 downto 0 => '0');

end architecture;
