library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity aluCtrlExt is
    port(aluOp : in std_logic_vector(1 downto 0);
         f : in std_logic_vector(5 downto 0);
         operation : out std_logic_vector(3 downto 0);
         jr : out std_logic);
end aluCtrlExt;

architecture behavioral of aluCtrlExt is
begin
    jr <= aluOp(1) and f(3) and (not f(0)) and (not f(1)) and (not f(2));
    operation(3) <= aluOp(1) and f(2) and f(1);
    operation(2) <= (aluOp(1) or aluOp(0)) and ((not aluOp(1)) or f(1));
    operation(1) <= ((not aluOp(1)) or (not f(2))) and ((not aluOp(1)) or (not f(3)) or f(1));
    operation(0) <= aluOp(1) and (f(3) or f(2)) and (f(3) or f(0)) and (f(3) or (not f(1)));
end behavioral;
