library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity leftShifter is
    generic(
        WIDTH 			: integer;
        SHIFT_AMOUNT 	: integer
    );
    port(
        number 			: in std_logic_vector(WIDTH - 1 downto 0);
        shiftedNumber 	: out std_logic_vector(WIDTH - 1 downto 0)
    );
end leftShifter;

architecture behavioral of leftShifter is
    procedure init(name: string; WIDTH: integer; SHIFT_AMOUNT: integer) is begin end;
    attribute foreign of init : procedure is "VHPIDIRECT vhdl_init_leftShifter";

    procedure call(name: string; number: in std_logic_vector(WIDTH - 1 downto 0); shiftedNumber: out std_logic_vector(WIDTH - 1 downto 0)) is begin end;
    attribute foreign of call : procedure is "VHPIDIRECT vhdl_call_leftShifter";
begin
    process
    begin
        init(leftShifter'path_name & "\0", WIDTH, SHIFT_AMOUNT);
        wait;
    end process;

    process (number)
        variable pShiftedNumber : std_logic_vector(WIDTH - 1 downto 0);
    begin
        call(leftShifter'path_name & "\0", number, pShiftedNumber);
        shiftedNumber <= pShiftedNumber;
    end process;
end architecture;
