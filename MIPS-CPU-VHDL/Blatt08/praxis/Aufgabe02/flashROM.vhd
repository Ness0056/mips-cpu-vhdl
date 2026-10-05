library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library std;
use std.standard.all;
use std.textio.all;

library work;
use work.proc_config.all;

entity flashROM is
    generic(NUM_ELEMENTS : integer;
            LOG2_NUM_ELEMENTS : integer;
            ELEMENT_WIDTH : integer;
            INIT_FILE_NAME : string);
    port(address : in std_logic_vector(LOG2_NUM_ELEMENTS - 1 downto 0);
         readData : out std_logic_vector(ELEMENT_WIDTH - 1 downto 0)
         );
        type rom_elements_type is array (0 to NUM_ELEMENTS - 1) of std_logic_vector(ELEMENT_WIDTH - 1 downto 0);
end flashROM;

architecture behavioral of flashROM is
    impure function InitRomFromFile (RomFileName : in string) return rom_elements_type is
        FILE RomFile : text open read_mode is RomFileName;
        variable RomFileLine : line;
        variable dataBuffer : bit_vector(ELEMENT_WIDTH - 1 downto 0);
        variable ROM : rom_elements_type;
    begin
        for i in rom_elements_type'range loop
            if endfile(RomFile) then
                ROM(i) := (others => '0');
            else
                readline(RomFile, RomFileLine);
                read(RomFileLine, dataBuffer);
                ROM(i) := to_stdlogicvector(dataBuffer);
            end if;
        end loop;
        return ROM;
    end function;

signal romElements : rom_elements_type := InitRomFromFile(INIT_FILE_NAME);

begin

    readData <= romElements(to_integer(unsigned(address)));

end behavioral;
