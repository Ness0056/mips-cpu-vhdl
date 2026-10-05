library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity signextend is
    generic(INPUT_WIDTH : integer;
        OUTPUT_WIDTH : integer);
    port(number : in signed((INPUT_WIDTH) - (1) downto 0);
        signextnumber : out signed((OUTPUT_WIDTH) - (1) downto 0));
end signextend;

architecture behavioral of signextend is
    procedure init(name: string;
        INPUT_WIDTH : integer;
        OUTPUT_WIDTH : integer) is begin end;
    attribute foreign of init : procedure is "VHPIDIRECT vhdl_init_signextend";
    procedure call(name: string;
        number : in std_logic_vector((INPUT_WIDTH) - (1) downto 0);
        signextnumber : out std_logic_vector((OUTPUT_WIDTH) - (1) downto 0)) is begin end;
    attribute foreign of call : procedure is "VHPIDIRECT vhdl_call_signextend";
begin
    process
    begin
        init(signextend'path_name & "\0", INPUT_WIDTH, OUTPUT_WIDTH);
        wait;
    end process;
    process (number)
        variable p_signextnumber : std_logic_vector((OUTPUT_WIDTH) - (1) downto 0);
    begin
        call(signextend'path_name & "\0", std_logic_vector(number), p_signextnumber);
        signextnumber <= signed(p_signextnumber);
    end process;
end behavioral;
