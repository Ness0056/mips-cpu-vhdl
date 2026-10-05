library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity reg is
    generic(
        WIDTH : integer);
    port(
        clk : in  std_logic;
        rst : in  std_logic;
        en  : in  std_logic;
        D   : in  std_logic_vector(WIDTH - 1 downto 0);
        Q   : out std_logic_vector(WIDTH - 1 downto 0));
end reg;

architecture behavioral of reg is
begin
   process(clk) begin   
      if rising_edge (clk) then -- only on rising
         if en = '1' then -- only write when flag is set
            Q <= D; -- write to output
         end if;
         if rst = '1' then -- only reset when reset signal is 1
            Q <= (WIDTH - 1 downto 0 => '0'); -- fill output with zeros, aka reset
         end if;
      end if;
   end process;
end architecture;
