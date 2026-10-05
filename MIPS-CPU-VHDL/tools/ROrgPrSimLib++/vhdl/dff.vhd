library ieee;
use ieee.std_logic_1164.all;

entity dff is
    port(
        clk : in  std_logic;
        D   : in  std_logic;
        Q   : out std_logic );
end dff;

architecture behavioral of dff is
    procedure init(name: string) is begin end;
    attribute foreign of init : procedure is "VHPIDIRECT vhdl_init_dff";

    procedure call(name: string; clk: in std_logic; D : in std_logic; Q : out std_logic) is begin end;
    attribute foreign of call : procedure is "VHPIDIRECT vhdl_call_dff";
begin
    process
    begin
        init(dff'path_name);
        wait;
    end process;

    process (clk)
        variable Qp : std_logic := '1';
    begin
        call(dff'path_name & "\0", clk, D, Qp);
        Q <= Qp;
    end process;
end;
