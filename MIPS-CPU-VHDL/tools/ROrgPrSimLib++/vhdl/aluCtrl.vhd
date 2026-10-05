library ieee;
use ieee.std_logic_1164.all;

entity aluCtrl is
    port(aluOp : in std_logic_vector(1 downto 0);
         f : in std_logic_vector(5 downto 0);
         operation : out std_logic_vector(3 downto 0));
end aluCtrl;

architecture behavioral of aluCtrl is
    procedure init(name: string) is begin end;
    attribute foreign of init : procedure is "VHPIDIRECT vhdl_init_aluCtrl";

    procedure call(name: string;
        aluOp : in std_logic_vector(1 downto 0);
        f : in std_logic_vector(5 downto 0);
        operation : out std_logic_vector(3 downto 0)) is begin end;
    attribute foreign of call : procedure is "VHPIDIRECT vhdl_call_aluCtrl";
begin
    process
    begin
        init(aluCtrl'path_name);
        wait;
    end process;

    process (aluOp, f)
        variable pOperation : std_logic_vector(3 downto 0);
    begin
        call(aluCtrl'path_name & "\0", aluOp, f, pOperation);
        operation <= pOperation;
    end process;
end behavioral;
