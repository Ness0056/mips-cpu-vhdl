library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.proc_config.all;

entity regFile is
    generic(NUM_REGS : integer;
            LOG2_NUM_REGS : integer;
            REG_WIDTH : integer);
    port(clk : in std_logic;
         rst : in std_logic;
         readAddr1 : in std_logic_vector(LOG2_NUM_REGS - 1 downto 0);
         readData1 : out std_logic_vector(REG_WIDTH - 1 downto 0);
         readAddr2 : in std_logic_vector(LOG2_NUM_REGS - 1 downto 0);
         readData2 : out std_logic_vector(REG_WIDTH - 1 downto 0);
         writeEn   : in std_logic;
         writeAddr : in std_logic_vector(LOG2_NUM_REGS - 1 downto 0);
         writeData : in std_logic_vector(REG_WIDTH - 1 downto 0);
         reg_vect_debug : out reg_vector_type);
end regFile;

architecture behavioral of regFile is
    procedure init(name: string; NUM_REGS: integer; LOG2_NUM_REGS: integer; REG_WIDTH: integer) is begin end;
    attribute foreign of init : procedure is "VHPIDIRECT vhdl_init_regFile";

    procedure call(name: string;
        clk : in std_logic;
        rst : in std_logic;
        readAddr1 : in std_logic_vector(LOG2_NUM_REGS - 1 downto 0);
        readAddr2 : in std_logic_vector(LOG2_NUM_REGS - 1 downto 0);
        writeEn   : in std_logic;
        writeAddr : in std_logic_vector(LOG2_NUM_REGS - 1 downto 0);
        writeData : in std_logic_vector(REG_WIDTH - 1 downto 0);
        readData1 : out std_logic_vector(REG_WIDTH - 1 downto 0);
        readData2 : out std_logic_vector(REG_WIDTH - 1 downto 0);
        reg_vect_debug : out reg_vector_type) is begin end;
    attribute foreign of call : procedure is "VHPIDIRECT vhdl_call_regFile";
begin
    process
    begin
        init(regFile'path_name & "\0", NUM_REGS, LOG2_NUM_REGS, REG_WIDTH);
        wait;
    end process;

    process (clk, rst, readAddr1, readAddr2, writeEn, writeAddr, writeData)
        variable pReadData1 : std_logic_vector(REG_WIDTH - 1 downto 0);
        variable pReadData2 : std_logic_vector(REG_WIDTH - 1 downto 0);
        variable pReg_vect_debug : reg_vector_type;
    begin
        call(regFile'path_name & "\0", clk, rst, readAddr1, readAddr2, writeEn, writeAddr, writeData,
            pReadData1, pReadData2, pReg_vect_debug);
        readData1 <= pReadData1;
        readData2 <= pReadData2;
        reg_vect_debug <= pReg_vect_debug;
    end process;
end architecture;
