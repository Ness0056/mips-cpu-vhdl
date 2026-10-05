library ieee;
use ieee.std_logic_1164.all;

library work;
use work.proc_config.mips_ctrl_state_type;
use work.mipsISA.all;

entity mipsCtrlFsm is
port(clk : in std_logic;
     rst : in std_logic;
     op : in std_logic_vector(5 downto 0);
     jr : in std_logic;
     regDst : out std_logic_vector(1 downto 0);
     memRead : out std_logic;
     memToReg : out std_logic;
     aluOp : out std_logic_vector(1 downto 0);
     memWrite : out std_logic;
     regWrite : out std_logic;
     aluSrcA : out std_logic;
     aluSrcB : out std_logic_vector(1 downto 0);
     pcSrc : out std_logic_vector(1 downto 0);
     irWrite : out std_logic;
     IorD : out std_logic;
     pcWrite : out std_logic;
     pcWriteCond : out std_logic;
     lui : out std_logic;

     -- debug port
     mipsCtrlState_debug : out mips_ctrl_state_type);
end mipsCtrlFsm;

architecture behavioral of mipsCtrlFsm is
    signal state_reg : mips_ctrl_state_type;
begin


    -- reset or update case on rising edge
    process (clk, rst) begin
	if rst = '1' then
	    state_reg <= INSTR_FETCH;
	elsif rising_edge(clk) then
	    case state_reg is
		when INSTR_FETCH  => state_reg <= INSTR_DECODE;
		when INSTR_DECODE =>
		    case op is
			when       LW_OPCODE => state_reg <= MEM_ADDR_CALC;
			when       SW_OPCODE => state_reg <= MEM_ADDR_CALC;
			when     ADDI_OPCODE => state_reg <=     ADDI_CALC;
			when    ADDIU_OPCODE => state_reg <=     ADDI_CALC;
			when R_FORMAT_OPCODE => state_reg <=     EXECUTION;
			when      JAL_OPCODE => state_reg <=       JAL_ADD;
			when        J_OPCODE => state_reg <=    JUMP_COMPL;
			when      LUI_OPCODE => state_reg <=     LUI_COMPL;
			when      BEQ_OPCODE => state_reg <=  BRANCH_COMPL;
			when          others => state_reg <=   INSTR_FETCH;
		    end case;
                when MEM_ADDR_CALC =>
                    case op is
                        when       LW_OPCODE => state_reg <=   MEM_READ;
                        when       SW_OPCODE => state_reg <=   MEM_WRITE;
			when          others => state_reg <= INSTR_FETCH;
                    end case;
                when MEM_READ  => state_reg <= MEM_READ_COMPL;
                when ADDI_CALC => state_reg <=    ITYPE_COMPL;
                when EXECUTION =>
                    case jr is
                        when             '1' => state_reg <=    JR_COMPL;
                        when          others => state_reg <= RTYPE_COMPL;
                    end case;
                when JAL_ADD  => state_reg <= LR_WRITE;
                when LR_WRITE => state_reg <= JUMP_COMPL;
                when others   => state_reg <= INSTR_FETCH;
	    end case;
	end if;
    end process;

    -- update output signals when case changes
    process (state_reg) begin
	-- set defaults, overwrite later if applicable
	lui <= '0';
	regDst <= "00";
	memRead <= '0';
	memToReg <= '0';
	aluOp <= "00";
	memWrite <= '0';
	regWrite <= '0';
	aluSrcA <= '0';
	aluSrcB <= "00";
	pcSrc <= "00";
	irWrite <= '0';
	IorD <= '0';
	pcWrite <= '0';
	pcWriteCond <= '0';

	-- state check
	case state_reg is
	    when INSTR_FETCH =>
		memRead <= '1';
		aluSrcA <= '0';
                IorD <= '0';
		irWrite <= '1';
                aluSrcB <= "01";
                aluOp <= "00";
                pcWrite <= '1';
		pcSrc <= "00";

	    when INSTR_DECODE =>
		aluSrcA <= '0';
		aluSrcB <= "11";
		aluOp <= "00";

	    when JAL_ADD =>
		aluSrcA <= '0';
		aluSrcB <= "01";
		aluOp <= "00";

	    when MEM_ADDR_CALC =>
		aluSrcA <= '1';
		aluSrcB <= "10";
		aluOp <= "00";
	    when ADDI_CALC =>
		aluSrcA <= '1';
		aluSrcB <= "10";
		aluOp <= "00";
	    when EXECUTION =>
		aluSrcA <= '1';
		aluSrcB <= "00";
		aluOp <= "10";
	    when LR_WRITE =>
		regDst <= "10";
		regWrite <= '1';
		memToReg <= '0';
		lui <= '0';
	    when LUI_COMPL =>
		regDst <= "00";
		regWrite <= '1';
		memToReg <= '0';
		lui <= '1';
	    when BRANCH_COMPL =>
		aluSrcA <= '1';
		aluSrcB <= "00";
		aluOp <= "01";
		pcWriteCond <= '1';
		pcSrc <= "01";

	    when MEM_READ =>
		memRead <= '1';
		iOrD <= '1';
	    when MEM_WRITE =>
		memWrite <= '1';
		iOrD <= '1';
	    when ITYPE_COMPL =>
		regDst <= "00";
		regWrite <= '1';
		memToReg <= '0';
		lui <= '0';
	    when RTYPE_COMPL =>
		regDst <= "01";
		regWrite <= '1';
		memToReg <= '0';
		lui <= '0';
	    when JR_COMPL =>
		pcWrite <= '1';
		pcSrc <= "01";
	    when JUMP_COMPL =>
		pcWrite <= '1';
		pcSrc <= "10";

	    when MEM_READ_COMPL =>
		regDst <= "00";
		regWrite <= '1';
		memToReg <= '1';	    

	    when others =>
	end case;
    end process;

    mipsCtrlState_debug <= state_reg;

end behavioral;
