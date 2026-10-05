library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity logic_tb is
end logic_tb;

use work.all;

architecture behavioral of logic_tb is
    signal a, b : bit;
    signal or_res, or_ref : bit;

    component or2 is
        port(
            a, b : in  bit;
            y    : out bit
        );
    end component;
begin
    OR2_VHD: or2 port map(a => a, b => b, y => or_res);
    process
        variable tmp_i : std_logic_vector(1 downto 0);
        variable numErrors : integer := 0;
    begin
        for i in 0 to 3 loop
            tmp_i := std_logic_vector(to_unsigned(i, 2));
            a <= to_bit(tmp_i(0));
            b <= to_bit(tmp_i(1));

            or_ref <= '0' when i = 0 else '1';

            wait for 5 ns;

            if or_res /= or_ref then
                report "falsches Ergebnis am or-Gatter: " & bit'image(or_res) & " (erwartet: " & bit'image(or_ref) & ")" severity error;
                numErrors := numErrors + 1;
            end if;

            wait for 5 ns;
        end loop;

        if numErrors = 0 then
            report "Alle Gatter funktionieren einwandfrei!" severity note;
            report "CI: All good." severity note;
        else
            report "Nicht alle Gatter funktionieren einwandfrei!" severity failure;
        end if;

        wait;
    end process;
end behavioral;
