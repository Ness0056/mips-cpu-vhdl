library ieee;
use ieee.std_logic_1164.all;

entity adder is
    generic(WIDTH : integer := 32);
    port ( a,b  : in  std_logic_vector(WIDTH-1 downto 0);
           sum  : out std_logic_vector(WIDTH-1 downto 0);
           cout : out std_logic);
end entity;

architecture behavioral of adder is
    signal c : std_logic_vector(WIDTH downto 0); --widh because  we have c(width) signals for a(width-1) cases
begin
    c(0) <= '0';

    loopi : for i in 0 to WIDTH-1 generate -- loop for all bits to get added 
    loppi2 : entity work.fulladd   
        port map(
                a    => a(i),     -- bit von a 
                b    => b(i),     -- bit von b
                cin  => c(i),     -- carry in 
                sum  => sum(i),   -- die summe in sum  von a+b+cin 
                cout => c(i+1)    -- carry out 
            );

        end generate loopi; 

    -- Last carry-out is the output cout 
    cout <= c(WIDTH);


end architecture behavioral;
