library ieee;
use ieee.std_logic_1164.all;

entity mipsctrl is
    port(op : in std_logic_vector(5 downto 0);
        regdst : out std_logic;
        branch : out std_logic;
        memread : out std_logic;
        memtoreg : out std_logic;
        aluop : out std_logic_vector(1 downto 0);
        memwrite : out std_logic;
        alusrc : out std_logic;
        regwrite : out std_logic);
end mipsctrl;

architecture behavioral of mipsctrl is
    procedure init(name: string) is begin end;
    attribute foreign of init : procedure is "VHPIDIRECT vhdl_init_mipsctrl";
    procedure call(name: string;
        op : in std_logic_vector(5 downto 0);
        regdst : out std_logic;
        branch : out std_logic;
        memread : out std_logic;
        memtoreg : out std_logic;
        aluop : out std_logic_vector(1 downto 0);
        memwrite : out std_logic;
        alusrc : out std_logic;
        regwrite : out std_logic) is begin end;
    attribute foreign of call : procedure is "VHPIDIRECT vhdl_call_mipsctrl";
begin
    process
    begin
        init(mipsctrl'path_name);
        wait;
    end process;
    process (op)
        variable p_regdst : std_logic;
        variable p_branch : std_logic;
        variable p_memread : std_logic;
        variable p_memtoreg : std_logic;
        variable p_aluop : std_logic_vector(1 downto 0);
        variable p_memwrite : std_logic;
        variable p_alusrc : std_logic;
        variable p_regwrite : std_logic;
    begin
        call(mipsctrl'path_name & "\0", op, p_regdst, p_branch, p_memread, p_memtoreg, p_aluop, p_memwrite, p_alusrc, p_regwrite);
        regdst <= p_regdst;
        branch <= p_branch;
        memread <= p_memread;
        memtoreg <= p_memtoreg;
        aluop <= p_aluop;
        memwrite <= p_memwrite;
        alusrc <= p_alusrc;
        regwrite <= p_regwrite;
    end process;
end behavioral;
