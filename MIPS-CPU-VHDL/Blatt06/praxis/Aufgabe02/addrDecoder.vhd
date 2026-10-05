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
--    signal decoded_val : integer := 0; -- Musterloesung, geht nicht
    signal shiftable : std_logic_vector(POW2_ADDR_WIDTH - 1 downto 0) := (0 => '1', others => '0'); -- von komilitonen
begin

    -- AUS musterloesung, geht nicht:
  --  decoded_val <= to_integer(unsigned(address));

--    gen_loop : for i in POW2_ADDR_WIDTH - 1 downto 0 generate
--	bitmask(i) <= '1' when i = decoded_val;
  --  end generate;


    -- Vom komilitonen:
    bitmask <= shiftable sll to_integer(unsigned(address));


    -- GHDL is stupid! Folgendes ist nicht synthesefaehig:
    -- bitmask <= (POW2_ADDR_WIDTH - 1 downto to_integer(unsigned(address)) + 1 => '0') & '1' & (to_integer(unsigned(address)) - 1 downto 0 => '0');

end architecture;
