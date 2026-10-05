library ieee;
use ieee.std_logic_1164.all;

entity leftShifter is
    generic(
        WIDTH           : integer;
        SHIFT_AMOUNT    : integer
    );
    port(
        number          : in std_logic_vector(WIDTH - 1 downto 0);
        shiftedNumber   : out std_logic_vector(WIDTH - 1 downto 0)
    );
end leftShifter;

architecture behavioral of leftShifter is
begin

    shiftedNumber <= number(WIDTH-1-SHIFT_AMOUNT downto 0) & 
    (SHIFT_AMOUNT-1 downto 0 => '0');

end architecture;
