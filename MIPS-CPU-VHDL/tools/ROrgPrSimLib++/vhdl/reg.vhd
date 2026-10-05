library ieee;
use ieee.std_logic_1164.all;

entity reg is
    generic(WIDTH : integer);
    port(clk : in std_logic;
        rst : in std_logic;
        en : in std_logic;
        d : in std_logic_vector((WIDTH) - (1) downto 0);
        q : out std_logic_vector((WIDTH) - (1) downto 0));
end reg;

architecture behavioral of reg is
    procedure init(name: string;
        WIDTH : integer) is begin end;
    attribute foreign of init : procedure is "VHPIDIRECT vhdl_init_reg";
    procedure call(name: string;
        clk : in std_logic;
        rst : in std_logic;
        en : in std_logic;
        d : in std_logic_vector((WIDTH) - (1) downto 0);
        q : out std_logic_vector((WIDTH) - (1) downto 0)) is begin end;
    attribute foreign of call : procedure is "VHPIDIRECT vhdl_call_reg";
begin
    process
    begin
        init(reg'path_name & "\0", WIDTH);
        wait;
    end process;
    process (clk, rst, en, d)
        variable p_q : std_logic_vector((WIDTH) - (1) downto 0);
    begin
        call(reg'path_name & "\0", clk, rst, en, d, p_q);
        q <= p_q;
    end process;
end behavioral;
