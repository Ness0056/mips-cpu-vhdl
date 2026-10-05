library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity btnDebounce is
    generic (
        stable_count : integer := 1_000
    );
    port (
        clk : in std_logic;
        rst : in std_logic;
        button_in : in std_logic;
        button_out : out std_logic
    );
end btnDebounce;

architecture behavioral of btnDebounce is
begin
    process(clk, rst)
        variable cnt : integer range 0 to stable_count := 0;
    begin
        if rising_edge(clk) then
            if rst = '1' then
                cnt := 0;
                button_out <= '0';
            else
                if button_in = '1' then
                    if cnt < stable_count then
                        cnt := cnt + 1;
                    else
                        button_out <= '1';
                    end if;
                else
                    cnt := 0;
                    button_out <= '0';
                end if;
            end if;
        end if;
    end process;
end architecture;
