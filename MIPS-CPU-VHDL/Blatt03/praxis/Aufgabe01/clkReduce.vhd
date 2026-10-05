library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity clkReduce is
    generic( divisor : integer := 1 );
    port( clk_in  : in  std_logic;
          clk_out : out std_logic );
end clkReduce;

architecture behavioral of clkReduce is
    signal internal_clk : std_logic := '0';
begin
    process(clk_in)
    
    variable count  : integer := 0;
    begin
        if (clk_in'event)then 
            if (count = divisor) then
                internal_clk <= not internal_clk;
                count := 1;
            else 
                count := count + 1;
            end if;     
        end if;       
    end process;
    clk_out <= internal_clk;
end behavioral;
