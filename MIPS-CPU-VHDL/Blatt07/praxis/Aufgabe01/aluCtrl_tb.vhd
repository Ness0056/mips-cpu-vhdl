library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;

library std;
use std.textio.all;

entity aluCtrl_tb is
end aluCtrl_tb;

architecture behavioral of aluCtrl_tb is

    signal aluOp : std_logic_vector(1 downto 0);
    signal f : std_logic_vector(5 downto 0);
    signal op_uut : std_logic_vector(3 downto 0);

    type content_arr is array(natural range <>) of std_logic_vector(3 downto 0);
    constant op_ref : content_arr := ("0010", "0110", "0010", "0110", "0010", "0110", "0011", "0111", "0010", "0110", "0110", "0110", "0010", "0110", "0111", "0111", "0010", "0110", "0000", "0100", "0010", "0110", "0001", "0101", "0010", "0110", "0100", "0100", "0010", "0110", "0101", "0101", "0010", "0110", "0011", "0111", "0010", "0110", "0011", "0111", "0010", "0110", "0111", "0111", "0010", "0110", "0111", "0111", "0010", "0110", "0001", "0101", "0010", "0110", "0001", "0101", "0010", "0110", "0101", "0101", "0010", "0110", "0101", "0101", "0010", "0110", "0010", "0110", "0010", "0110", "0011", "0111", "0010", "0110", "0110", "0110", "0010", "0110", "0111", "0111", "0010", "0110", "0000", "0100", "0010", "0110", "0001", "0101", "0010", "0110", "0100", "0100", "0010", "0110", "0101", "0101", "0010", "0110", "0011", "0111", "0010", "0110", "0011", "0111", "0010", "0110", "0111", "0111", "0010", "0110", "0111", "0111", "0010", "0110", "0001", "0101", "0010", "0110", "0001", "0101", "0010", "0110", "0101", "0101", "0010", "0110", "0101", "0101", "0010", "0110", "0010", "0110", "0010", "0110", "0011", "0111", "0010", "0110", "0110", "0110", "0010", "0110", "0111", "0111", "0010", "0110", "0000", "0100", "0010", "0110", "0001", "0101", "0010", "0110", "0100", "0100", "0010", "0110", "0101", "0101", "0010", "0110", "0011", "0111", "0010", "0110", "0011", "0111", "0010", "0110", "0111", "0111", "0010", "0110", "0111", "0111", "0010", "0110", "0001", "0101", "0010", "0110", "0001", "0101", "0010", "0110", "0101", "0101", "0010", "0110", "0101", "0101", "0010", "0110", "0010", "0110", "0010", "0110", "0011", "0111", "0010", "0110", "0110", "0110", "0010", "0110", "0111", "0111", "0010", "0110", "0000", "0100", "0010", "0110", "0001", "0101", "0010", "0110", "0100", "0100", "0010", "0110", "0101", "0101", "0010", "0110", "0011", "0111", "0010", "0110", "0011", "0111", "0010", "0110", "0111", "0111", "0010", "0110", "0111", "0111", "0010", "0110", "0001", "0101", "0010", "0110", "0001", "0101", "0010", "0110", "0101", "0101", "0010", "0110", "0101", "0101");
begin

    UUT: entity work.aluCtrl(behavioral)
        port map(aluOp => aluOp,
                 f => f,
                 operation => op_uut);

    TESTBENCH: process
        variable numErrors : integer := 0;
        variable l : line;
        variable tmp : std_logic_vector(7 downto 0);
    begin
        for i in 0 to 255 loop
            tmp := std_logic_vector(to_unsigned(i, 8));
            aluOp <= tmp(1 downto 0);
            f <= tmp(7 downto 2);
            wait for 5 ns;
--			write(l, string'(""""));
--			write(l, op_uut);
--			write(l, string'(""""));
--			writeline(OUTPUT, l);
            if op_uut /= op_ref(i) then
                if numErrors < 4 then
                    write(l, time'image(now));
                    write(l, string'(": Falsches Ergebnis am AluCtrl-Modul: operation = """));
                    write(l, op_uut);
                    write(l, string'(""" (erwartet: """));
                    write(l, op_ref(i));
                    write(l, string'(""")"));
                    writeline(OUTPUT, l);
                elsif numErrors = 4 then
                    write(l, time'image(now));
                    write(l, string'(": Weitere Fehler werden nicht angezeigt ..."));
                    writeline(OUTPUT, l);
                end if;
                numErrors := numErrors + 1;
            end if;
            wait for 5 ns;
        end loop;

        -- evaluation
        if numErrors = 0 then
            report "Das AluCtrl-Modul funktioniert einwandfrei! (Punktzahl: 2/2)" severity note;
            report "CI: All good." severity note;
        else
            report "Das AluCtrl-Modul ist fehlerhaft! (Punktzahl: 0/2)" severity failure;
        end if;

        wait;
    end process;

end behavioral;
