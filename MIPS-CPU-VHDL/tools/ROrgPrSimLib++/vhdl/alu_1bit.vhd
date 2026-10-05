library ieee;
use ieee.std_logic_1164.all;

entity alu_1bit is
    port(operation : in std_logic_vector(1 downto 0);
        a : in std_logic;
        ainvert : in std_logic;
        b : in std_logic;
        binvert : in std_logic;
        carryin : in std_logic;
        less : in std_logic;
        result : out std_logic;
        carryout : out std_logic;
        set : out std_logic);
end alu_1bit;

architecture behavioral of alu_1bit is
    procedure init(name: string) is begin end;
    attribute foreign of init : procedure is "VHPIDIRECT vhdl_init_alu_1bit";
    procedure call(name: string;
        operation : in std_logic_vector(1 downto 0);
        a : in std_logic;
        ainvert : in std_logic;
        b : in std_logic;
        binvert : in std_logic;
        carryin : in std_logic;
        less : in std_logic;
        result : out std_logic;
        carryout : out std_logic;
        set : out std_logic) is begin end;
    attribute foreign of call : procedure is "VHPIDIRECT vhdl_call_alu_1bit";
begin
    process
    begin
        init(alu_1bit'path_name);
        wait;
    end process;

    process (operation, a, ainvert, b, binvert, carryin, less)
        variable p_result : std_logic;
        variable p_carryout : std_logic;
        variable p_set : std_logic;
    begin
        call(alu_1bit'path_name & "\0", operation, a, ainvert, b, binvert, carryin, less, p_result, p_carryout, p_set);
        result <= p_result;
        carryout <= p_carryout;
        set <= p_set;
    end process;
end behavioral;
