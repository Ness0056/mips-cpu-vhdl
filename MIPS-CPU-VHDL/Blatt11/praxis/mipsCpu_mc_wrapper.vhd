library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.proc_config.all;

entity mipsCpu_mc_wrapper is
    Port ( clk : in STD_LOGIC;
           seg : out STD_LOGIC_VECTOR (6 downto 0);
           an : out STD_LOGIC_VECTOR (3 downto 0);
           led : out STD_LOGIC_VECTOR (15 downto 0);
           btnC : in STD_LOGIC;
           btnD : in STD_LOGIC);
end mipsCpu_mc_wrapper;

architecture behavioral of mipsCpu_mc_wrapper is

signal cpuClk, cpuRst : std_logic;
signal curPc : pc_7seg_digits_type;
signal curState : mips_ctrl_state_type;

signal counter : unsigned(23 downto 0) := (others => '0');

begin
    cpu: entity work.mipsCpu_mc
    generic map(
        INIT_FILE_NAME => "clip.s.mif"
    )
    port map(
        clk => cpuClk,
        rst => cpuRst,
        ramElements_debug => open,
        registers_debug => open,
        mipsCtrlState_debug => curState,
        pc7SegDigits_debug => curPC
    );

    --LEDs
    led(0) <= '1' when curState = INSTR_FETCH else '0';
    led(1) <= '1' when curState = INSTR_DECODE else '0';
    led(2) <= '1' when curState = BRANCH_COMPL else '0';
    led(3) <= '1' when curState = JUMP_COMPL else '0';
    led(4) <= '1' when curState = EXECUTION else '0';
    led(5) <= '1' when curState = RTYPE_COMPL else '0';
    led(6) <= '1' when curState = MEM_ADDR_CALC else '0';
    led(7) <= '1' when curState = MEM_WRITE else '0';
    led(8) <= '1' when curState = MEM_READ else '0';
    led(9) <= '1' when curState = MEM_READ_COMPL else '0';
    led(10) <= '1' when curState = JAL_ADD else '0';
    led(11) <= '1' when curState = LR_WRITE else '0';
    led(12) <= '1' when curState = JR_COMPL else '0';
    led(13) <= '1' when curState = LUI_COMPL else '0';
    led(14) <= '1' when curState = ADDI_CALC else '0';
    led(15) <= '1' when curState = ITYPE_COMPL else '0';

    -- 7Seg
    cnt: process(clk)
    begin
        if rising_edge(clk) then
            counter <= counter + 1;
        end if;
    end process;

    an(0) <= '0' when counter(16 downto 15) = "00" else '1';
    an(1) <= '0' when counter(16 downto 15) = "01" else '1';
    an(2) <= '0' when counter(16 downto 15) = "10" else '1';
    an(3) <= '0' when counter(16 downto 15) = "11" else '1';

    seg <= not curPc(to_integer(unsigned(counter(16 downto 15))));

    -- Buttons
    clkDebounce: entity work.btnDebounce
        port map(
            clk => clk,
            rst => '0',
            button_in => btnC,
            button_out => cpuClk
        );
    rstDebounce: entity work.btnDebounce
        port map(
            clk => clk,
            rst => '0',
            button_in => btnD,
            button_out => cpuRst
        );

end behavioral;
