library ieee;
use ieee.std_logic_1164.all;

-- Diese Zeile ist notwendig, damit ihr Entities aus der ROrgPrSimLib verwenden könnt.
-- Dies könnte z.B. die 1-bit ALU sein, wenn ihr die entsprechende
-- Aufgabe nicht erfolgreich bearbeitet habt =)
-- Um ein Entity aus der ROrgPrSimLib zu verwenden, instanziiert es einfach als
-- "entity ROrgPrSimLib.<EntityName>" statt "entity work.<EntityName>".
-- Also z.B. "entity ROrgPrSimLib.alu_1bit" statt "entity work.alu_1bit".
library ROrgPrSimLib;

library work;
use work.proc_config.all;

entity mipsAlu is
    generic(WIDTH : integer); -- WIDTH must be >= 2 otherwise this implementation breaks in multiple places
    port(ctrl : in std_logic_vector(3 downto 0);
         a : in std_logic_vector(WIDTH - 1 downto 0);
         b : in std_logic_vector(WIDTH - 1 downto 0);
         result : out std_logic_vector(WIDTH - 1 downto 0);
         overflow : out std_logic;
         zero : out std_logic);
end mipsAlu;

architecture behavioral of mipsAlu is

    signal carry_signals : std_logic_vector(WIDTH - 1 downto 0);
    signal slt_signal : std_logic;

begin

    gen: for i in 0 to WIDTH-1 generate -- loop for all 1-bit-alus to get added
        firstAlu: if i = 0 generate -- alu 0
            newAlu : entity work.alu_1bit
                port map(
                    operation => ctrl(1 downto 0),
                    a => a(i),
                    aInvert => ctrl(3),
                    b => b(i),
                    bInvert => ctrl(2),
                    carryIn => ctrl(2), -- support subtraction
                    less => slt_signal,
                    result => result(i),
                    carryOut => carry_signals(i),
                    set => open
                );
        end generate firstAlu;
        normalAlu: if (i > 0 AND i < WIDTH - 1) generate -- alus >0:
            newAlu : entity work.alu_1bit
                port map(
                    operation => ctrl(1 downto 0),
                    a => a(i),
                    aInvert => ctrl(3),
                    b => b(i),
                    bInvert => ctrl(2),
                    carryIn => carry_signals(i - 1),
                    less => '0',
                    result => result(i),
                    carryOut => carry_signals(i),
                    set => open
                );
        end generate normalAlu;
        finalAlu: if (i = WIDTH - 1) generate -- final alu:
            newAlu : entity work.alu_1bit
                port map(
                    operation => ctrl(1 downto 0),
                    a => a(i),
                    aInvert => ctrl(3),
                    b => b(i),
                    bInvert => ctrl(2),
                    carryIn => carry_signals(i - 1),
                    less => '0',
                    result => result(i),
                    carryOut => carry_signals(i),
                    set => slt_signal
                );
        end generate finalAlu;
    end generate gen;

    zero <=
        '1' when result = (result'range => '0') else
        '0';

    overflow <= 
        '0' when ctrl(1 downto 0) /= "10" else
        '1' when carry_signals(WIDTH - 1) /= carry_signals(WIDTH - 2) else
        '0';

end behavioral;
