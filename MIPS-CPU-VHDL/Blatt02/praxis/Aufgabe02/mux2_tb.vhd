library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity mux2_tb is
end mux2_tb;

architecture behavioral of mux2_tb is
    constant NUM_TESTCASES : integer := 8;
    signal a_test : std_logic_vector(0 to NUM_TESTCASES - 1) := "0011XU11";
    signal b_test : std_logic_vector(0 to NUM_TESTCASES - 1) := "110000XU";
    signal sel_test : std_logic_vector(0 to NUM_TESTCASES - 1) := "01100110";
    signal y_ref : std_logic_vector(0 to NUM_TESTCASES - 1) := "0101X0X1";
    signal a,b,y,sel : std_logic;

begin

    MUX_INST: entity work.mux2(behavioral)
    port map(a => a, b => b,
             s => sel, y => y);

    TESTBENCH: process
        variable numErrors : integer := 0;
    begin

        -- check if mux works correctly under common conditions
        for i in 0 to NUM_TESTCASES - 1 loop
            a <= a_test(i);
            b <= b_test(i);
            sel <= sel_test(i);

            wait for 5 ns;

            if y /= y_ref(i) then
                report "falsches Ergebnis am Multiplexer: " & std_logic'image(y) & " (erwartet: " & std_logic'image(y_ref(i)) & ")" severity error;
                numErrors := numErrors + 1;
            end if;

            wait for 5 ns;

        end loop;


        -- evaluation
        if numErrors = 0 then
            report "Der Multiplexer funktioniert einwandfrei!" severity note;
            report "CI: All good." severity note;
        else
            report "Der Multiplexer funktioniert nicht einwandfrei! ("
            & integer'image(numErrors) & " Fehler)" severity failure;
        end if;

        wait;
    end process;

end behavioral;
