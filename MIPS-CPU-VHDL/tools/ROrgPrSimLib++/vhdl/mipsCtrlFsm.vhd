library ieee;
use ieee.std_logic_1164.all;

library work;
use work.proc_config.mips_ctrl_state_type;

entity mipsctrlfsm is
    port(clk : in std_logic;
        rst : in std_logic;
        op : in std_logic_vector(5 downto 0);
        jr : in std_logic;
        regdst : out std_logic_vector(1 downto 0);
        memread : out std_logic;
        memtoreg : out std_logic;
        aluop : out std_logic_vector(1 downto 0);
        memwrite : out std_logic;
        regwrite : out std_logic;
        alusrca : out std_logic;
        alusrcb : out std_logic_vector(1 downto 0);
        pcsrc : out std_logic_vector(1 downto 0);
        irwrite : out std_logic;
        iord : out std_logic;
        pcwrite : out std_logic;
        pcwritecond : out std_logic;
        lui : out std_logic;
        mipsctrlstate_debug : out mips_ctrl_state_type);
end mipsctrlfsm;

architecture behavioral of mipsctrlfsm is
    procedure init(name: string) is begin end;
    attribute foreign of init : procedure is "VHPIDIRECT vhdl_init_mipsctrlfsm";
    procedure call(name: string;
        clk : in std_logic;
        rst : in std_logic;
        op : in std_logic_vector(5 downto 0);
        jr : in std_logic;
        regdst : out std_logic_vector(1 downto 0);
        memread : out std_logic;
        memtoreg : out std_logic;
        aluop : out std_logic_vector(1 downto 0);
        memwrite : out std_logic;
        regwrite : out std_logic;
        alusrca : out std_logic;
        alusrcb : out std_logic_vector(1 downto 0);
        pcsrc : out std_logic_vector(1 downto 0);
        irwrite : out std_logic;
        iord : out std_logic;
        pcwrite : out std_logic;
        pcwritecond : out std_logic;
        lui : out std_logic;
        mipsctrlstate_debug : out mips_ctrl_state_type) is begin end;
    attribute foreign of call : procedure is "VHPIDIRECT vhdl_call_mipsctrlfsm";
begin
    process
    begin
        init(mipsctrlfsm'path_name);
        wait;
    end process;
    process (clk, rst, op, jr)
        variable p_regdst : std_logic_vector(1 downto 0);
        variable p_memread : std_logic;
        variable p_memtoreg : std_logic;
        variable p_aluop : std_logic_vector(1 downto 0);
        variable p_memwrite : std_logic;
        variable p_regwrite : std_logic;
        variable p_alusrca : std_logic;
        variable p_alusrcb : std_logic_vector(1 downto 0);
        variable p_pcsrc : std_logic_vector(1 downto 0);
        variable p_irwrite : std_logic;
        variable p_iord : std_logic;
        variable p_pcwrite : std_logic;
        variable p_pcwritecond : std_logic;
        variable p_lui : std_logic;
        variable p_mipsctrlstate_debug : mips_ctrl_state_type;
    begin
        call(mipsctrlfsm'path_name & "\0", clk, rst, op, jr, p_regdst, p_memread, p_memtoreg, p_aluop, p_memwrite, p_regwrite, p_alusrca, p_alusrcb, p_pcsrc, p_irwrite, p_iord, p_pcwrite, p_pcwritecond, p_lui, p_mipsctrlstate_debug);
        regdst <= p_regdst;
        memread <= p_memread;
        memtoreg <= p_memtoreg;
        aluop <= p_aluop;
        memwrite <= p_memwrite;
        regwrite <= p_regwrite;
        alusrca <= p_alusrca;
        alusrcb <= p_alusrcb;
        pcsrc <= p_pcsrc;
        irwrite <= p_irwrite;
        iord <= p_iord;
        pcwrite <= p_pcwrite;
        pcwritecond <= p_pcwritecond;
        lui <= p_lui;
        mipsctrlstate_debug <= p_mipsctrlstate_debug;
    end process;
end behavioral;
