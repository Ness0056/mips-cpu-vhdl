library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity mux4_tb is
end mux4_tb;

architecture behavioral of mux4_tb is

    constant DATA_WIDTH : integer := 32;
    signal a : std_logic_vector(DATA_WIDTH - 1 downto 0) := (others => '0');
    signal b : std_logic_vector(DATA_WIDTH - 1 downto 0) := x"FF00FF00";
    signal c : std_logic_vector(DATA_WIDTH - 1 downto 0) := x"00FF00FF";
    signal d : std_logic_vector(DATA_WIDTH - 1 downto 0) := (others => '1');
    signal sel : std_logic_vector(1 downto 0) := "00";
    signal y : std_logic_vector(DATA_WIDTH - 1 downto 0);

    type y_vec is array(0 to 3) of std_logic_vector(DATA_WIDTH - 1 downto 0);
    constant y_ref : y_vec := (a, b, c, d);
begin

    MUX_INST: entity work.mux4
    generic map(DATA_WIDTH => DATA_WIDTH)
    port map(a => a, b => b, c => c, d => d,
             sel => sel, y => y);

    TESTBENCH: process
        variable points : integer := 0;
        variable numErrors : integer := 0;
    begin

        -- check if mux works correctly under common conditions
        for i in 0 to 3 loop
            sel <= std_logic_vector(to_unsigned(i, 2));
            wait for 5 ns;
            if y /= y_ref(i) then
                report "Ausgang des Multiplexers unterscheidet sich vom selektierten Eingang!" severity error;
                numErrors := numErrors + 1;
            end if;
            wait for 5 ns;
        end loop;

        if numErrors = 0 then
            points := points + 1;
        end if;

        sel <= "00";
        a <= (others => 'U');

        -- check if uninitialized input arrives at output
        wait for 5 ns;
        if y /= a then
            report "Uninitialisiertes Signal wird nicht auf den Ausgang durchgeschaltet!" severity error;
        elsif numErrors < 4 then
            points := points + 1;
        end if;
        wait for 5 ns;


        -- evaluation
        if points = 2 then
            report "Der Multiplexer funktioniert einwandfrei! (mux4: 2/2 Punkte)" severity note;
            report "CI: All good." severity note;
        else
            report "Der Multiplexer funktioniert nicht einwandfrei! (mux4: "
            & integer'image(points) & "/2 Punkte)" severity failure;
        end if;

        wait;
    end process;

end behavioral;
