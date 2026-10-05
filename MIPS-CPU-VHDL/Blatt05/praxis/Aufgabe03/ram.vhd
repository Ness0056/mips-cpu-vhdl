library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.proc_config.ram_elements_type;

entity ram is
    generic(
        NUM_ELEMENTS      : integer;
        LOG2_NUM_ELEMENTS : integer;
        ELEMENT_WIDTH     : integer);
    port(
        clk               : in  std_logic;
        address           : in  std_logic_vector( LOG2_NUM_ELEMENTS - 1 downto 0 );
        writeEn           : in  std_logic;
        writeData         : in  std_logic_vector( ELEMENT_WIDTH - 1 downto 0 );
        readEn            : in  std_logic;
        readData          : out std_logic_vector( ELEMENT_WIDTH - 1 downto 0 );
        ramElements_debug : out ram_elements_type);
end ram;

architecture behavioral of ram is

    -- Array, das alle Elemente des RAMs enthält
    signal ramElements : ram_elements_type := (others => (others => '0'));

begin

    -- synchro RAM, write-first
    process(clk)
        variable addr_int : integer;
    begin
        if rising_edge(clk) then
            addr_int := to_integer(unsigned(address));

            -- synchroner Schreibzugriff 
            if writeEn = '1' then
                ramElements(addr_int) <= writeData;
            end if;

            -- synchroner Lesezugriff (write-first)
            if readEn = '1' then
                if writeEn = '1' then
                    -- gleichzeitiges Read/Write: neues Datum lesen
                    readData <= writeData;
                else
                    readData <= ramElements(addr_int);
                end if;
            end if;
            -- bei readEn = '0' bleibt readData einfach auf dem letzten Wert
        end if;
    end process;
    ramElements_debug <= ramElements;

end architecture;
