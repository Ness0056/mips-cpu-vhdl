library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;

library std;
use std.textio.all;

library work;
use work.mipsISA.all;


entity aluCtrlExt_tb is
end aluCtrlExt_tb;

architecture behavioral of aluCtrlExt_tb is

    constant NUM_TESTCASES : integer := 36;
    type test_vector_type is record
	aluOp: std_logic_vector(1 downto 0);
        f : std_logic_vector(5 downto 0);
        operation : std_logic_vector(3 downto 0);
        jr : std_logic;
    end record;
    type test_vector_array_type is array (0 to NUM_TESTCASES - 1) of test_vector_type;
    constant testcases_and_results : test_vector_array_type :=
-- test aluOp | funct   ->   op |  jr
	-- 00 | XXXXXX
        (("00", "XXXXXX", "0010", '0'),
	 ("00", "000000", "0010", '0'),
	 ("00", "111111", "0010", '0'),
	-- 01 |  XXXXXX
	 ("01", "XXXXXX", "0110", '0'),
	 ("01", "000000", "0110", '0'),
	 ("01", "111111", "0110", '0'),
	-- 10 |  XX000X
	 ("10", "XX000X", "0010", '0'),
	 ("10", "000000", "0010", '0'),
	 ("10", "110001", "0010", '0'),
	-- 10 |  XX001X
	 ("10", "XX001X", "0110", '0'),
	 ("10", "000010", "0110", '0'),
	 ("10", "110011", "0110", '0'),
	-- 10 |  XX0100
	 ("10", "XX0100", "0000", '0'),
	 ("10", "000100", "0000", '0'),
	 ("10", "110100", "0000", '0'),
	-- 10 |  XXX101
	 ("10", "XXX101", "0001", '0'),
	 ("10", "000101", "0001", '0'),
	 ("10", "111101", "0001", '0'),
	-- 10 |  XX011X
	 ("10", "XX011X", "1100", '0'),
	 ("10", "000110", "1100", '0'),
	 ("10", "110111", "1100", '0'),
	-- 10 | XX1000
	 ("10", "XX1000", "0001", '1'),
	 ("10", "001000", "0001", '1'),
	 ("10", "111000", "0001", '1'),
	-- 10 |  XX1001
	 ("10", "XX1001", "0001", '0'),
	 ("10", "001001", "0001", '0'),
	 ("10", "111001", "0001", '0'),
	-- 10 |  XX101X
	 ("10", "XX101X", "0111", '0'),
	 ("10", "001010", "0111", '0'),
	 ("10", "111011", "0111", '0'),
	-- 10 |  XX1100
	 ("10", "XX1100", "0001", '0'),
	 ("10", "001100", "0001", '0'),
	 ("10", "111100", "0001", '0'),
	-- 10 |  XX111X
	 ("10", "XX111X", "1101", '0'),
	 ("10", "001110", "1101", '0'),
	 ("10", "111111", "1101", '0'));

    signal aluOp: std_logic_vector(1 downto 0);
    signal f : std_logic_vector(5 downto 0);
    signal operation : std_logic_vector(3 downto 0);
    signal jr : std_logic;

begin

    TO_TEST: entity work.aluCtrlExt(behavioral)
    port map(aluOp => aluOp,
              f => f,
              operation => operation,
              jr => jr);


    TESTBENCH: process
        variable numErrors, numOpErrors, numJrErrors, numErrorPropErrors : integer := 0;
        variable opError, jrError : boolean;
        variable l : line;
    begin
        for i in 0 to NUM_TESTCASES - 1 loop
            aluOp <= testcases_and_results(i).aluOp;
            f <= testcases_and_results(i).f;

            wait for 5 ns;
            opError := operation /= testcases_and_results(i).operation;
            jrError := jr /= testcases_and_results(i).jr;

            if opError or jrError then
                -- general error info
                if numErrors < 4 then
                    write(l, time'image(now));
                    write(l, string'(": Falsches Ergebnis an der ALU-CTRL: aluOp = """));
                    write(l, aluOp);    
		    write(l, string'(""", f = """));
                    write(l, f);                
                    write(l, string'(""""));
                    writeline(OUTPUT, l);

                    -- op error info
                    if opError then
                        write(l, string'("    operation = """));
                        write(l, operation);
                        write(l, string'(""" (erwartet: """));
                        write(l, testcases_and_results(i).operation);
                        write(l, string'(""")"));
                        writeline(OUTPUT, l);
                    end if;

                    -- jr error info
                    if jrError then
                        write(l, string'("    jr = '" & std_logic'image(jr) & "'"));
                        write(l, string'(", (erwartet: '" & std_logic'image(testcases_and_results(i).jr) & "')"));
                        writeline(OUTPUT, l);
                    end if;

                elsif numErrors = 4 then
                    write(l, time'image(now));
                    write(l, string'(": Weitere Fehler werden nicht angezeigt ..."));
                    writeline(OUTPUT, l);
                end if;

                numErrors := numErrors + 1;
                if opError then
                    numOpErrors := numOpErrors + 1;
                end if;
                if jrError then
                    numJrErrors := numJrErrors + 1;
                end if;

            end if;
            wait for 5 ns;
        end loop;

        -- evaluation
        writeline(OUTPUT, l);
        write(l, string'("---- Auswertung ----"));
        writeline(OUTPUT, l);
        writeline(OUTPUT, l);

        if numOpErrors = 0 then
            write(l, string'("  ALU-CTRL-operation:              fehlerfrei"));
        else
            write(l, string'("  ALU-CTRL-operation:              fehlerhaft (" & integer'image(numOpErrors) & " Fehler)"));
        end if;
        writeline(OUTPUT, l);

        if numJrErrors = 0 then
            write(l, string'("  ALU-CTRL-jr:        fehlerfrei"));
        else
            write(l, string'("  ALU-CTRL-jr:        fehlerhaft (" & integer'image(numJrErrors) & " Fehler)"));
        end if;
        writeline(OUTPUT, l);
        writeline(OUTPUT, l);

        if numErrors = 0 then
            report "ALU-CTRL funktioniert einwandfrei!" severity note;
            report "CI: All good." severity note;
        else
            report "ALU-CTRL ist fehlerhaft!" severity failure;
        end if;

        wait;
    end process;

    -- Ihr könnt ein `report "CI: All good." severity note;` einfügen (nur im Erfolgsfall),
    -- damit die automatischen Tests auch mit eurer Testbench funktionieren.
end behavioral;
