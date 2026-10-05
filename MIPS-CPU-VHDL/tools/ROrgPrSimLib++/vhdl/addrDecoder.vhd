library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity addrDecoder is
    generic(ADDR_WIDTH : integer;
            POW2_ADDR_WIDTH : integer);
    port(address : in std_logic_vector(ADDR_WIDTH - 1 downto 0);
         bitmask : out std_logic_vector(POW2_ADDR_WIDTH - 1 downto 0));
end addrDecoder;

architecture behavioral of addrDecoder is
    procedure init(name: string; ADDR_WIDTH: integer; POW2_ADDR_WIDTH: integer) is begin end;
    attribute foreign of init : procedure is "VHPIDIRECT vhdl_init_addrDecoder";

    procedure call(name: string;
        address : in std_logic_vector(ADDR_WIDTH - 1 downto 0);
        bitmask : out std_logic_vector(POW2_ADDR_WIDTH - 1 downto 0)) is begin end;
    attribute foreign of call : procedure is "VHPIDIRECT vhdl_call_addrDecoder";
begin
    process
    begin
        init(addrDecoder'path_name & "\0", ADDR_WIDTH, POW2_ADDR_WIDTH);
        wait;
    end process;

    process (address)
        variable pBitmask : std_logic_vector(POW2_ADDR_WIDTH - 1 downto 0);
    begin
        call(addrDecoder'path_name & "\0", address, pBitmask);
        bitmask <= pBitmask;
    end process;
end architecture;
