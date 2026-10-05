library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity neq4_tb is
end neq4_tb;

architecture behavioral of neq4_tb is

    type neq4Data is
    record
        a, b               : std_logic_vector(3 downto 0);
        y_logic, y_netlist : std_logic;
    end record;

    signal uut_data   : neq4Data;
    signal ref_y      : std_logic;
    constant NUM_TESTCASES : integer := 256;

begin

    NEQ4_LOGIC_INST: entity work.neq4(logic)
    port map(a => uut_data.a, b => uut_data.b, y => uut_data.y_logic);

    NEQ4_NETLIST_INST: entity work.neq4(netlist)
    port map(a => uut_data.a, b => uut_data.b, y => uut_data.y_netlist);

    process
        variable numLogicErrors, numNetlistErrors : integer := 0;
        variable tmp_i : std_logic_vector(7 downto 0);
    begin

        for i in 0 to NUM_TESTCASES - 1 loop

            tmp_i := std_logic_vector(to_unsigned(i, 8));
            uut_data.a <= tmp_i(7 downto 4);
            uut_data.b <= tmp_i(3 downto 0);

            ref_y <= '1' when tmp_i(7 downto 4) /= tmp_i(3 downto 0) else '0';

            wait for 5 ns;

            if uut_data.y_logic /= ref_y then
                report "falsches Ergebnis am neq4-Modul(logic) (a = """ &
                integer'image(to_integer(unsigned'("" & uut_data.a(3)))) &
                integer'image(to_integer(unsigned'("" & uut_data.a(2)))) &
                integer'image(to_integer(unsigned'("" & uut_data.a(1)))) &
                integer'image(to_integer(unsigned'("" & uut_data.a(0)))) &
                """, b = """ &
                integer'image(to_integer(unsigned'("" & uut_data.b(3)))) &
                integer'image(to_integer(unsigned'("" & uut_data.b(2)))) &
                integer'image(to_integer(unsigned'("" & uut_data.b(1)))) &
                integer'image(to_integer(unsigned'("" & uut_data.b(0)))) &
                """): " & std_logic'image(uut_data.y_logic) & " (erwartet: " & std_logic'image(ref_y) & ")" severity error;
                numLogicErrors := numLogicErrors + 1;
            end if;

            if uut_data.y_netlist /= ref_y then
                report "falsches Ergebnis am neq4-Modul(netlist) (a = """ &
                integer'image(to_integer(unsigned'("" & uut_data.a(3)))) &
                integer'image(to_integer(unsigned'("" & uut_data.a(2)))) &
                integer'image(to_integer(unsigned'("" & uut_data.a(1)))) &
                integer'image(to_integer(unsigned'("" & uut_data.a(0)))) &
                """, b = """ &
                integer'image(to_integer(unsigned'("" & uut_data.b(3)))) &
                integer'image(to_integer(unsigned'("" & uut_data.b(2)))) &
                integer'image(to_integer(unsigned'("" & uut_data.b(1)))) &
                integer'image(to_integer(unsigned'("" & uut_data.b(0)))) &
                """): " & std_logic'image(uut_data.y_netlist) & " (erwartet: " & std_logic'image(ref_y) & ")" severity error;
                numNetlistErrors := numNetlistErrors + 1;
            end if;

            wait for 5 ns;

        end loop;

        if numLogicErrors = 0 then
            report "Das neq4-Modul(logic) funktioniert einwandfrei!" severity note;
        end if;
        if numNetlistErrors = 0 then
            report "Das neq4-Modul(netlist) funktioniert einwandfrei!" severity note;
        end if;

        if numLogicErrors > 0 and numNetlistErrors > 0 then
            report "Das neq4-Modul(logic) funktioniert nicht einwandfrei! (" & integer'image(numLogicErrors) & " von " & integer'image(NUM_TESTCASES) & " Tests fehlerhaft)" & lf &
            "Das neq4-Modul(netlist) funktioniert nicht einwandfrei! (" & integer'image(numNetlistErrors) & " von " & integer'image(NUM_TESTCASES) & " Tests fehlerhaft)" severity failure;
        end if;

        if numLogicErrors > 0 then
            report "Das neq4-Modul(logic) funktioniert nicht einwandfrei! (" & integer'image(numLogicErrors) & " von " & integer'image(NUM_TESTCASES) & " Tests fehlerhaft)" severity failure;
        end if;

        if numNetlistErrors > 0 then
            report "Das neq4-Modul(netlist) funktioniert nicht einwandfrei! (" & integer'image(numNetlistErrors) & " von " & integer'image(NUM_TESTCASES) & " Tests fehlerhaft)" severity failure;
        end if;

        if numLogicErrors = 0 and numNetlistErrors = 0 then
            report "CI: All good." severity note;
        end if;

        wait;

    end process;

end behavioral;
