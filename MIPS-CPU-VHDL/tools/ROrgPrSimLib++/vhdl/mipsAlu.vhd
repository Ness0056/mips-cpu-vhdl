library ieee;
use ieee.std_logic_1164.all;

library work;
use work.proc_config.all;

entity mipsAlu is
    generic(WIDTH : integer);
    port(ctrl : in std_logic_vector(3 downto 0);
         a : in std_logic_vector(WIDTH - 1 downto 0);
         b : in std_logic_vector(WIDTH - 1 downto 0);
         result : out std_logic_vector(WIDTH - 1 downto 0);
         overflow : out std_logic;
         zero : out std_logic);
end mipsAlu;

architecture behavioral of mipsAlu is
    procedure init(name: string; WIDTH: integer) is begin end;
    attribute foreign of init : procedure is "VHPIDIRECT vhdl_init_mipsAlu";

    procedure call(name: string;
        ctrl : in std_logic_vector(3 downto 0);
        a : in std_logic_vector(WIDTH - 1 downto 0);
        b : in std_logic_vector(WIDTH - 1 downto 0);
        result : out std_logic_vector(WIDTH - 1 downto 0);
        overflow : out std_logic;
        zero : out std_logic) is begin end;
    attribute foreign of call : procedure is "VHPIDIRECT vhdl_call_mipsAlu";
begin
    process
    begin
        init(mipsAlu'path_name & "\0", WIDTH);
        wait;
    end process;

    process (ctrl, a, b)
        variable pResult : std_logic_vector(WIDTH - 1 downto 0);
        variable pOverflow : std_logic;
        variable pZero : std_logic;
    begin
        call(mipsAlu'path_name & "\0", ctrl, a, b, pResult, pOverflow, pZero);
        result <= pResult;
        overflow <= pOverflow;
        zero <= pZero;
    end process;
end architecture;
