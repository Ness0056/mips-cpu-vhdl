library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library std;
use std.textio.all;

library work;
use work.proc_config.all;
use work.mipsISA.all;

entity mipsCpu_mc_ref is
    generic(INIT_FILE_NAME : string);
    port(clk : in std_logic;
         rst : in std_logic;

         -- debug ports
         ramElements_debug : out ram_elements_type;
         registers_debug : out reg_vector_type;
         mipsCtrlState_debug : out mips_ctrl_state_type;
         pc7SegDigits_debug : out pc_7seg_digits_type
         );
end mipsCpu_mc_ref;

architecture structural of mipsCpu_mc_ref is
    type rom_elements_type is array (0 to NUM_ROM_ELEMENTS - 1) of std_logic_vector(PC_WIDTH - 1 downto 0);

    impure function InitRamFromFile (RamFileName : in string) return ram_elements_type is
            FILE RamFile : text open read_mode is RamFileName;
            variable RamFileLine : line;
            variable dataBuffer : bit_vector(31 downto 0);
            variable RAM : ram_elements_type;
    begin
        for i in ram_elements_type'range loop
            if endfile(RamFile) then
                RAM(i) := (others => '0');
            else
                readline(RamFile, RamFileLine);
                hread(RamFileLine, dataBuffer);
                RAM(i) := to_stdlogicvector(dataBuffer);
            end if;
        end loop;
        return RAM;
    end function;

    signal ram : ram_elements_type := InitRamFromFile(INIT_FILE_NAME);
    signal regs : reg_vector_type := (others => (others => '0'));
    signal pc : std_logic_vector(PC_WIDTH -1 downto 0);
    signal instr : std_logic_vector(PC_WIDTH - 1 downto 0);
    signal state : mips_ctrl_state_type;

    signal rs, rt, rd : integer range 0 to 31;
    signal imm : unsigned(15 downto 0);
    signal jaddr : unsigned(25 downto 0);

begin

    rs  <= to_integer(unsigned(instr(25 downto 21)));
    rt  <= to_integer(unsigned(instr(20 downto 16)));
    rd  <= to_integer(unsigned(instr(15 downto 11)));
    imm <= unsigned(instr(15 downto 0));
    jaddr <= unsigned(instr(25 downto 0));

    ref : process (clk) is
        variable l : line;
    begin
        if rising_edge(clk) then
            if rst then
                pc <= (others => '0');
                regs <= (others => (others => '0'));
                state <= INSTR_FETCH;
            else
                case state is
                    when INSTR_FETCH =>
                        pc <= std_logic_vector(unsigned(pc) + 4);
                        instr <= ram((to_integer(unsigned(pc) srl 2)) mod NUM_RAM_ELEMENTS);
                        state <= INSTR_DECODE;
                    when INSTR_DECODE =>
                        case instr(31 downto 26) is
                            when R_FORMAT_OPCODE =>
                                state <= EXECUTION;
                            when LW_OPCODE =>
                                state <= MEM_ADDR_CALC;
                            when SW_OPCODE =>
                                state <= MEM_ADDR_CALC;
                            when BEQ_OPCODE =>
                                state <= BRANCH_COMPL;
                            when LUI_OPCODE =>
                                state <= LUI_COMPL;
                            when J_OPCODE =>
                                state <= JUMP_COMPL;
                            when JAL_OPCODE =>
                                state <= JAL_ADD;
                            when ADDI_OPCODE | ADDIU_OPCODE =>
                                state <= ADDI_CALC;
                            when others =>
                                write(l, time'image(now));
                                write(l, string'(" PC: "));
                                hwrite(l, std_logic_vector(unsigned(pc) - 4));
                                write(l, string'(" Inst: "));
                                hwrite(l, instr);
                                writeline(OUTPUT, l);
                                report "ERROR OpCode" severity failure;

                                state <= INSTR_FETCH;
                        end case;

                    when BRANCH_COMPL =>
                        if regs(rs) = regs(rt) then
                            pc <= std_logic_vector(signed(pc) + signed(imm sll 2));
                        end if;
                        state <= INSTR_FETCH;

                    when JUMP_COMPL =>
                        pc <= pc(31 downto 28) & std_logic_vector(("00" & jaddr) sll 2);
                        state <= INSTR_FETCH;

                    when EXECUTION =>
                        if instr(5 downto 0) = JR_FUNCT then
                            state <= JR_COMPL;
                        else
                            state <= RTYPE_COMPL;
                        end if;

                    when RTYPE_COMPL =>
                        case instr(5 downto 0) is
                            when AND_FUNCT =>
                                regs(rd) <= regs(rt) and regs(rs);
                            when OR_FUNCT =>
                                regs(rd) <= regs(rt) or regs(rs);
                            when NOR_FUNCT =>
                                regs(rd) <= regs(rt) nor regs(rs);
                            when ADD_FUNCT | ADDU_FUNCT =>
                                regs(rd) <= std_logic_vector(unsigned(regs(rs)) + unsigned(regs(rt)));
                            when SUB_FUNCT | SUBU_FUNCT =>
                                regs(rd) <= std_logic_vector(unsigned(regs(rs)) - unsigned(regs(rt)));
                            when SLT_FUNCT =>
                                if signed(regs(rs)) < signed(regs(rt)) then
                                    regs(rd) <= std_logic_vector(to_unsigned(1, 32));
                                else
                                    regs(rd) <= (others => '0');
                                end if;
                            when others =>
                                if instr /= x"00000000" then -- ignore NOPs
                                    write(l, time'image(now));
                                    write(l, string'(" PC: "));
                                    hwrite(l, std_logic_vector(unsigned(pc) - 4));
                                    write(l, string'(" Inst: "));
                                    hwrite(l, instr);
                                    writeline(OUTPUT, l);
                                    report "ERROR RType" severity failure;
                                end if;
                        end case;
                        state <= INSTR_FETCH;

                    when ITYPE_COMPL =>
                        case instr(31 downto 26) is
                            when ADDIU_OPCODE | ADDI_OPCODE =>
                                regs(rt) <= std_logic_vector((signed(regs(rs)) + signed(imm)));
                            when others =>
                        end case;
                        state <= INSTR_FETCH;

                    when ADDI_CALC =>
                        state <= ITYPE_COMPL;

                    when MEM_ADDR_CALC =>
                        case instr(31 downto 26) is
                            when LW_OPCODE =>
                                state <= MEM_READ;
                            when SW_OPCODE =>
                                state <= MEM_WRITE;
                            when others =>
                                report "ERROR" severity failure;
                        end case;

                    when MEM_WRITE =>
                        ram(to_integer((unsigned(regs(rs))+imm) srl 2) mod NUM_RAM_ELEMENTS) <= regs(rt);
                        state <= INSTR_FETCH;

                    when MEM_READ =>
                        state <= MEM_READ_COMPL;

                    when MEM_READ_COMPL =>
                        regs(rt) <= ram(to_integer((unsigned(regs(rs))+imm) srl 2) mod NUM_RAM_ELEMENTS);
                        state <= INSTR_FETCH;

                    when JAL_ADD =>
                        state <= LR_WRITE;

                    when LR_WRITE =>
                        regs(31) <= std_logic_vector(unsigned(pc) + 4);
                        state <= JUMP_COMPL;

                    when JR_COMPL =>
                        pc <= regs(rs);
                        state <= INSTR_FETCH;

                    when LUI_COMPL =>
                        regs(rt) <= std_logic_vector((x"0000" & imm) sll 16);
                        state <= INSTR_FETCH;

                end case;
            end if;
        end if;
    end process;


    process (all)
        variable Bx : std_logic_vector(3 downto 0);
    begin
        for i in 0 to 3 loop
            Bx := pc(4*(i+1) - 1 downto 4*i);
            pc7SegDigits_debug(i)(6) <= (Bx(3) or Bx(2) or Bx(1)) and (Bx(3) or (not Bx(2)) or (not Bx(1)) or (not Bx(0))) and ((not Bx(3)) or (not Bx(2)) or Bx(1) or Bx(0));
            pc7SegDigits_debug(i)(5) <= (Bx(3) or Bx(2) or (not Bx(0))) and (Bx(3) or Bx(2) or (not Bx(1))) and (Bx(3) or (not Bx(1)) or (not Bx(0))) and ((not Bx(3)) or (not Bx(2)) or Bx(1) or (not Bx(0)));
            pc7SegDigits_debug(i)(4) <= (Bx(3) or (not Bx(0))) and (Bx(2) or Bx(1) or (not Bx(0))) and (Bx(3) or (not Bx(2)) or Bx(1));
            pc7SegDigits_debug(i)(3) <= (Bx(3) or Bx(2) or Bx(1) or (not Bx(0))) and (Bx(3) or (not Bx(2)) or Bx(1) or Bx(0)) and ((not Bx(2)) or (not Bx(1)) or (not Bx(0))) and ((not Bx(3)) or Bx(2) or (not Bx(1)) or Bx(0));
            pc7SegDigits_debug(i)(2) <= (Bx(3) or Bx(2) or (not Bx(1)) or Bx(0)) and ((not Bx(3)) or (not Bx(2)) or Bx(0)) and ((not Bx(3)) or (not Bx(2)) or (not Bx(1)));
            pc7SegDigits_debug(i)(1) <= (Bx(3) or (not Bx(2)) or Bx(1) or (not Bx(0))) and ((not Bx(2)) or (not Bx(1)) or Bx(0)) and ((not Bx(3)) or (not Bx(1)) or (not Bx(0))) and ((not Bx(3)) or (not Bx(2)) or Bx(0));
            pc7SegDigits_debug(i)(0) <= (Bx(3) or Bx(2) or Bx(1) or (not Bx(0))) and (Bx(3) or (not Bx(2)) or Bx(1) or Bx(0)) and ((not Bx(3)) or Bx(2) or (not Bx(1)) or (not Bx(0))) and ((not Bx(3)) or (not Bx(2)) or Bx(1) or (not Bx(0)));
        end loop;
    end process;

    ramElements_debug <= ram;
    registers_debug <= regs;
    mipsCtrlState_debug <= state;
end architecture;
