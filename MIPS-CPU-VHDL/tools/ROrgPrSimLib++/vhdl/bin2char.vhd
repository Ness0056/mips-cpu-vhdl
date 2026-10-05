library ieee;
use ieee.std_logic_1164.all;

entity bin2char is
    port(bin : in std_logic_vector(3 downto 0);
        bitmask : out std_logic_vector(6 downto 0));
end bin2char;

architecture behavioral of bin2char is
    procedure init(name: string) is begin end;
    attribute foreign of init : procedure is "VHPIDIRECT vhdl_init_bin2char";
    procedure call(name: string;
        bin : in std_logic_vector(3 downto 0);
        bitmask : out std_logic_vector(6 downto 0)) is begin end;
    attribute foreign of call : procedure is "VHPIDIRECT vhdl_call_bin2char";
begin
    process
    begin
        init(bin2char'path_name);
        wait;
    end process;
    process (bin)
        variable p_bitmask : std_logic_vector(6 downto 0);
    begin
        call(bin2char'path_name & "\0", bin, p_bitmask);
        bitmask <= p_bitmask;
end process;
end behavioral;
