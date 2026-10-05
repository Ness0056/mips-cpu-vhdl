library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;

library std;
use std.textio.all;

library work;
use work.mipsISA.all;
use work.proc_config.all;

entity mipsCtrlFsm_tb is
end mipsCtrlFsm_tb;

architecture behavioral of mipsCtrlFsm_tb is

    signal clk : std_logic := '0';
    signal rst : std_logic := '0';
    signal op : std_logic_vector(5 downto 0);
    signal jr : std_logic := '0';
    signal state_uut : mips_ctrl_state_type;
    signal outputSignals_uut : std_logic_vector(17 downto 0);
    constant LUI_IDX : integer := 17;
    -- constant REG_DST_IDX : range := 16 downto 15;
    constant MEM_READ_IDX : integer := 14;
    constant MEM_TO_REG_IDX : integer := 13;
    -- constant ALU_OP_RANGE : range := 12 downto 11;
    constant MEM_WRITE_IDX : integer := 10;
    constant REG_WRITE_IDX : integer := 9;
    constant ALU_SRC_A_IDX : integer := 8;
    -- constant ALU_SRC_B_RANGE : range := 7 downto 6;
    -- constant PC_SRC_RANGE : range := 5 downto 4;
    constant IR_WRITE_IDX : integer := 3;
    constant I_OR_D_IDX : integer := 2;
    constant PC_WRITE_IDX : integer := 1;
    constant PC_WRITE_COND_IDX : integer := 0;

    type output_signal_identifiers_type is array (17 downto 0) of string(1 to 11);
    constant output_signal_identifiers : output_signal_identifiers_type :=
        (                              "lui        ", "regDst     ",
         "regDst     ", "memRead    ", "memToReg   ", "aluOp      ",
         "aluOp      ", "memWrite   ", "regWrite   ", "aluSrcA    ",
         "aluSrcB    ", "aluSrcB    ", "pcSrc      ", "pcSrc      ",
         "irWrite    ", "IorD       ", "pcWrite    ", "pcWriteCond");

    constant NUM_TESTCASES : integer := 11;
    type test_state_trace_type is array(1 to 5) of mips_ctrl_state_type;
    type test_output_trace_type is array(1 to 5) of std_logic_vector(17 downto 0);
    type test_record_type is record
        op : std_logic_vector(5 downto 0);
        numCycles : integer range 2 to 5;
        jrTrace : std_logic_vector(1 to 5);
        stateTrace : test_state_trace_type;
        outputTrace : test_output_trace_type;
    end record;
    type test_record_array_type is array (0 to NUM_TESTCASES - 1) of test_record_type;
    constant test_record_array : test_record_array_type :=
        (
            (BEQ_OPCODE, 3,
                "00000",
                (INSTR_FETCH, INSTR_DECODE, BRANCH_COMPL, INSTR_FETCH, INSTR_FETCH),
                ("000100000001001010", "000000000011000000", "000000100100010001", "000000000000000000", "000000000000000000")
            ),
            (J_OPCODE, 3,
                "00000",
                (INSTR_FETCH, INSTR_DECODE, JUMP_COMPL, INSTR_FETCH, INSTR_FETCH),
                ("000100000001001010", "000000000011000000", "000000000000100010", "000000000000000000", "000000000000000000")
            ),
            (R_FORMAT_OPCODE, 4,
                "00000",
                (INSTR_FETCH, INSTR_DECODE, EXECUTION, RTYPE_COMPL, INSTR_FETCH),
                ("000100000001001010", "000000000011000000", "000001000100000000", "001000001000000000", "000000000000000000")
            ),
            (LW_OPCODE, 5,
                "00000",
                (INSTR_FETCH, INSTR_DECODE, MEM_ADDR_CALC, MEM_READ, MEM_READ_COMPL),
                ("000100000001001010", "000000000011000000", "000000000110000000", "000100000000000100", "000010001000000000")
            ),
            (SW_OPCODE, 4,
                "00000",
                (INSTR_FETCH, INSTR_DECODE, MEM_ADDR_CALC, MEM_WRITE, INSTR_FETCH),
                ("000100000001001010", "000000000011000000", "000000000110000000", "000000010000000100", "000000000000000000")
            ),
            (LUI_OPCODE, 3,
                "00000",
                (INSTR_FETCH, INSTR_DECODE, LUI_COMPL, INSTR_FETCH, INSTR_FETCH),
                ("000100000001001010", "000000000011000000", "100000001000000000", "000000000000000000", "000000000000000000")
            ),
            (JAL_OPCODE, 5,
                "00000",
                (INSTR_FETCH, INSTR_DECODE, JAL_ADD, LR_WRITE, JUMP_COMPL),
                ("000100000001001010", "000000000011000000", "000000000001000000", "010000001000000000", "000000000000100010")
            ),
            (R_FORMAT_OPCODE, 4,
                "00100",
                (INSTR_FETCH, INSTR_DECODE, EXECUTION, JR_COMPL, INSTR_FETCH),
                ("000100000001001010", "000000000011000000", "000001000100000000", "000000000000010010", "000000000000000000")
            ),
            (ADDI_OPCODE, 4,
                "00000",
                (INSTR_FETCH, INSTR_DECODE, ADDI_CALC, ITYPE_COMPL, INSTR_FETCH),
                ("000100000001001010", "000000000011000000", "000000000110000000", "000000001000000000", "000000000000000000")
            ),
            (ADDIU_OPCODE, 4,
                "00000",
                (INSTR_FETCH, INSTR_DECODE, ADDI_CALC, ITYPE_COMPL, INSTR_FETCH),
                ("000100000001001010", "000000000011000000", "000000000110000000", "000000001000000000", "000000000000000000")
            ),
            ("111111", 2,
                "00000",
                (INSTR_FETCH, INSTR_DECODE, INSTR_FETCH, INSTR_FETCH, INSTR_FETCH),
                ("000100000001001010", "000000000011000000", "000000000000000000", "000000000000000000", "000000000000000000")
            )
        );

    signal sim_stop : boolean := false;

begin

    UUT: entity work.mipsCtrlFsm(behavioral)
        port map(clk => clk,
                 rst => rst,
                 op => op,
                 jr => jr,
                 regDst => outputSignals_uut(16 downto 15),
                 memRead => outputSignals_uut(MEM_READ_IDX),
                 memToReg => outputSignals_uut(MEM_TO_REG_IDX),
                 aluOp => outputSignals_uut(12 downto 11),
                 memWrite => outputSignals_uut(MEM_WRITE_IDX),
                 regWrite => outputSignals_uut(REG_WRITE_IDX),
                 aluSrcA => outputSignals_uut(ALU_SRC_A_IDX),
                 aluSrcB => outputSignals_uut(7 downto 6),
                 pcSrc => outputSignals_uut(5 downto 4),
                 irWrite => outputSignals_uut(IR_WRITE_IDX),
                 IorD => outputSignals_uut(I_OR_D_IDX),
                 pcWrite => outputSignals_uut(PC_WRITE_IDX),
                 pcWriteCond => outputSignals_uut(PC_WRITE_COND_IDX),
                 lui => outputSignals_uut(LUI_IDX),
                 mipsCtrlState_debug => state_uut);

    CLK_GEN: process
    begin
        if sim_stop then
            wait;
        end if;
        wait for CLK_PERIOD / 2;
        clk <= not clk;
    end process;

    TESTBENCH: process
        variable resetWorks : boolean := true;
        variable numStateErrors : integer := 0;
        variable numOutputErrors : integer := 0;
        variable points : integer := 0;
        variable l : line;
    begin
        wait until rising_edge(clk);
        -- test reset and skip following tests if it doesn't work
        rst <= '1';
        wait for (5 * CLK_PERIOD) / 2;
        rst <= '0';
        if state_uut /= INSTR_FETCH then
            write(l, time'image(now));
            write(l, string'(": Reset funktioniert nicht! Alle weiteren Tests werden nicht durchgefuehrt!"));
            writeline(OUTPUT, l);
            resetWorks := false;
        end if;

        if resetWorks then
            for i in 0 to NUM_TESTCASES - 1 loop
                op <= test_record_array(i).op;

                for nCycles in 1 to test_record_array(i).numCycles loop
                    jr <= test_record_array(i).jrTrace(nCycles);

                    if state_uut /= test_record_array(i).stateTrace(nCycles) then
                        write(l, time'image(now));
                        write(l, string'(": Falscher Zustand im MipsCtrlFsm-Modul: op = """));
                        write(l, op);
                        write(l, string'(""""));
                        writeline(OUTPUT, l);
                        write(l, string'("    state = " & toString(state_uut) & " (erwartet: " & toString(test_record_array(i).stateTrace(nCycles)) & ")"));
                        writeline(OUTPUT, l);
                        numStateErrors := numStateErrors + 1;

                        -- continue with next testcase
                        rst <= '1';
                        wait for CLK_PERIOD;
                        rst <= '0';
                        exit;
                    else
                        if outputSignals_uut /= test_record_array(i).outputTrace(nCycles) then
                            write(l, time'image(now));
                            write(l, string'(": Falsches Ergebnis am MipsCtrlFsm-Modul: state = " & toString(state_uut)));
                            writeline(OUTPUT, l);
                            numOutputErrors := numOutputErrors + 1;

                            for n in test_record_array(i).outputTrace(nCycles)'HIGH downto test_record_array(i).outputTrace(nCycles)'LOW loop
                                if n = 15 or n = 11 or n = 6 or n = 4 then

                                else
                                    write(l, string'("    " & output_signal_identifiers(n) & " = "));

                                    if n = 16 or n = 12 or n = 7 or n = 5 then
                                        write(l, string'(""""));
                                        write(l, outputSignals_uut(n downto n-1));
                                        write(l, string'(""" (erwartet: """));
                                        write(l, test_record_array(i).outputTrace(nCycles)(n downto n-1));
                                        write(l, string'(""")"));
                                    else
                                        write(l, string'("'"));
                                        write(l, outputSignals_uut(n));
                                        write(l, string'("'  (erwartet:  '"));
                                        write(l, test_record_array(i).outputTrace(nCycles)(n));
                                        write(l, string'("')"));
                                    end if;
                                    writeline(OUTPUT, l);

                                end if;
                            end loop;

                        end if;
                    end if;

                    wait for CLK_PERIOD;
                end loop;

            end loop;
        end if; -- resetWorks

        writeline(OUTPUT, l);

        -- evaluation
        writeline(OUTPUT, l);
        write(l, string'("---- Auswertung ----"));
        writeline(OUTPUT, l);
        writeline(OUTPUT, l);

        if not resetWorks then
            write(l, string'("  Es wurde keine Tests durchgefuehrt, weil das reset der FSM nicht funktioniert!"));
            writeline(OUTPUT, l);
        else
            points := points + 1;

            if numStateErrors = 0 then
                write(l, string'("  Zustandsuebergaenge:        fehlerfrei"));
                points := points + 2;
            else
                write(l, string'("  Zustandsuebergaenge:        fehlerhaft (" & integer'image(numStateErrors) & " Fehler)"));
                if numStateErrors = 1 then
                    points := points + 1;
                end if;
            end if;
            writeline(OUTPUT, l);

            if numStateErrors = 0 and numOutputErrors = 0 then
                write(l, string'("  Ausgangssignale:            fehlerfrei"));
                points := points + 2;
            elsif numStateErrors > 3 then
                write(l, string'("  Ausgangssignale:            konnten wegen falschen Zustandsuebergaengen nicht ausreichend getestet werden"));
            else
                write(l, string'("  Ausgangssignale:            fehlerhaft (" & integer'image(numOutputErrors) & " Fehler)"));
                if numOutputErrors = 1 then
                    points := points + 1;
                end if;
            end if;
            writeline(OUTPUT, l);
            writeline(OUTPUT, l);
        end if;

        if points = 5 then
            report "Das MipsCtrl-Modul funktioniert einwandfrei! (Punktzahl: 5/5)" severity note;
            report "CI: All good." severity note;
        else
            report "Das MipsCtrl-Modul ist fehlerhaft! (Punktzahl: " & integer'image(points) & "/5)" severity failure;
        end if;

        sim_stop <= true;
        wait;
    end process;

end behavioral;
