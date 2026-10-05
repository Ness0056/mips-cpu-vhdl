library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;

library std;
use std.textio.all;

library work;
use work.proc_config.ALU_WIDTH;

entity mipsAlu_tb is
end mipsAlu_tb;

architecture behavioral of mipsAlu_tb is

    signal ctrl : std_logic_vector(3 downto 0);
    signal a, b : std_logic_vector(ALU_WIDTH - 1 downto 0);

    constant NUM_ALU_TESTCASES : integer := 16;
    type test_vector_type is record
        ctrl : std_logic_vector(3 downto 0);
        a : std_logic_vector(ALU_WIDTH - 1 downto 0);
        b : std_logic_vector(ALU_WIDTH - 1 downto 0);
    end record;
    type test_vector_array_type is array (0 to NUM_ALU_TESTCASES - 1) of test_vector_type;
    constant testcases : test_vector_array_type :=
        -- result tests
        (("0000", x"FF00FF00", x"0F0F0F0F"), ("0001", x"00FF00FF", x"F0F0F0F0"),
         ("0010", x"00008000", x"00007F00"), ("0010", x"FFFFFFFF", x"00000008"),
         ("0110", x"08000000", x"0F000000"), ("0110", x"00010000", x"00000001"),
         ("0111", x"00000010", x"00000100"), ("1100", x"00FF00FF", x"F0F0F0F0"),

        -- overflow tests
         ("0010", x"40000000", x"40000000"), ("0010", x"80000000", x"80000000"),
         ("0110", x"40000000", x"C0000000"), ("0110", x"A0000000", x"40000000"),

        -- zero tests
         ("0000", x"F0F0F0F0", x"0F0F0F0F"), ("0001", x"00000000", x"00000000"),
         ("0010", x"00010000", x"FFFF0000"), ("0110", x"00000010", x"00000010"));

    signal result_uut : std_logic_vector(ALU_WIDTH - 1 downto 0);
    signal overflow_uut : std_logic;
    signal zero_uut : std_logic;

    type content_arr is array(natural range <>) of std_logic_vector(0 to ALU_WIDTH-1+2);
    constant res_ref : content_arr := ("0000111100000000000011110000000000", "1111000011111111111100001111111100", "0000000000000000111111110000000000", "0000000000000000000000000000011100", "1111100100000000000000000000000000", "0000000000000000111111111111111100", "0000000000000000000000000000000100", "0000111100000000000011110000000000", "1000000000000000000000000000000010", "0000000000000000000000000000000011", "1000000000000000000000000000000010", "0110000000000000000000000000000010", "0000000000000000000000000000000001", "0000000000000000000000000000000001", "0000000000000000000000000000000001", "0000000000000000000000000000000001");
begin

    UUT: entity work.mipsAlu(behavioral)
    generic map (WIDTH => ALU_WIDTH)
    port map(ctrl => ctrl,
              a => a,
              b => b,
              result => result_uut,
              overflow => overflow_uut,
              zero => zero_uut);

    TESTBENCH: process
        variable points, numErrors, numResultErrors, numOverflowErrors, numZeroErrors, numErrorPropErrors : integer := 0;
        variable resultError, overflowError, zeroError : boolean;
        variable l : line;
    begin
        for i in 0 to NUM_ALU_TESTCASES - 1 loop
            ctrl <= testcases(i).ctrl;
            a <= testcases(i).a;
            b <= testcases(i).b;

            wait for 5 ns;
            resultError := result_uut /= res_ref(i)(0 to ALU_WIDTH-1);
            overflowError := overflow_uut /= res_ref(i)(ALU_WIDTH);
            zeroError := zero_uut /= res_ref(i)(ALU_WIDTH+1);

--			write(l, string'(""""));
--			write(l, result_uut);
--			write(l, overflow_uut);
--			write(l, zero_uut);
--			write(l, string'(""""));
--			writeline(OUTPUT, l);

            if resultError or overflowError or zeroError then
                -- general error info
                if numErrors < 4 then
                    write(l, time'image(now));
                    write(l, string'(": Falsches Ergebnis an der cs-ALU: ctrl = """));
                    write(l, ctrl);
                    write(l, string'(""", a = x"""));
                    hwrite(l, a);
                    write(l, string'(""", b = x"""));
                    hwrite(l, b);
                    write(l, string'(""""));
                    writeline(OUTPUT, l);

                    -- result error info
                    if resultError then
                        write(l, string'("    result = x"""));
                        hwrite(l, result_uut);
                        write(l, string'(""" (erwartet: x"""));
                        hwrite(l, res_ref(i)(0 to ALU_WIDTH-1));
                        write(l, string'(""")"));
                        writeline(OUTPUT, l);
                    end if;

                    -- overflow error info
                    if overflowError then
                        write(l, string'("    overflow = '" & std_logic'image(overflow_uut) & "'"));
                        write(l, string'(", (erwartet: '" & std_logic'image(res_ref(i)(ALU_WIDTH)) & "')"));
                        writeline(OUTPUT, l);
                    end if;

                    -- zero error info
                    if zeroError then
                        write(l, string'("    zero = '" & std_logic'image(zero_uut) & "'"));
                        write(l, string'(", (erwartet: '" & std_logic'image(res_ref(i)(ALU_WIDTH+1)) & "')"));
                        writeline(OUTPUT, l);
                    end if;

                elsif numErrors = 4 then
                    write(l, time'image(now));
                    write(l, string'(": Weitere Fehler werden nicht angezeigt ..."));
                    writeline(OUTPUT, l);
                end if;

                numErrors := numErrors + 1;
                if resultError then
                    numResultErrors := numResultErrors + 1;
                end if;
                if OverflowError then
                    numOverflowErrors := numOverflowErrors + 1;
                end if;
                if ZeroError then
                    numZeroErrors := numZeroErrors + 1;
                end if;

                numErrors := numErrors + 1;

            end if;
            wait for 5 ns;
        end loop;

        -- evaluation
        writeline(OUTPUT, l);
        write(l, string'("---- Auswertung ----"));
        writeline(OUTPUT, l);
        writeline(OUTPUT, l);

        if numResultErrors = 0 then
            write(l, string'("  ALU-result:              fehlerfrei"));
            points := points + 3;
        else
            write(l, string'("  ALU-result:              fehlerhaft (" & integer'image(numResultErrors) & " Fehler)"));
        end if;
        writeline(OUTPUT, l);

        if numOverflowErrors = 0 then
            write(l, string'("  ALU-overflow-bit:        fehlerfrei"));
            points := points + 1;
        else
            write(l, string'("  ALU-overflow-bit:        fehlerhaft (" & integer'image(numOverflowErrors) & " Fehler)"));
        end if;
        writeline(OUTPUT, l);

        if numZeroErrors = 0 then
            write(l, string'("  ALU-zero-bit:            fehlerfrei"));
            points := points + 1;
        else
            write(l, string'("  ALU-zero-bit:            fehlerhaft (" & integer'image(numZeroErrors) & " Fehler)"));
        end if;
        writeline(OUTPUT, l);
        writeline(OUTPUT, l);

        if numErrors = 0 then
            report "Die cs-ALU funktioniert einwandfrei! (mipsAlu: 5/5 Punkte)" severity note;
            report "CI: All good." severity note;
        else
            report "Die cs-ALU ist fehlerhaft! (mipsAlu: " & integer'image(points) & "/5 Punkte)" severity failure;
        end if;

        wait;
    end process;

end behavioral;
