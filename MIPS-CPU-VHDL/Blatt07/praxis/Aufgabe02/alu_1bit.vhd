library ieee;
use ieee.std_logic_1164.all;

entity alu_1bit is
    port(operation : in std_logic_vector(1 downto 0);
         a : in std_logic;
         aInvert : in std_logic;
         b : in std_logic;
         bInvert : in std_logic;
         carryIn : in std_logic;
         less : in std_logic;
         result : out std_logic;
         carryOut : out std_logic;
         set : out std_logic);
end alu_1bit;

architecture structural of alu_1bit is

   signal inputA : std_logic; -- intermediate signal: a after aInvert MUX
   signal inputB : std_logic; -- intermediate signal: b after bInvert MUX

begin

   with aInvert select inputA <=
      NOT a when '1', -- invert a when aInvert is 1
      a when others;  -- passthrough otherwise
   with bInvert select inputB <=
      NOT b when '1', -- invert b when bInvert is 1
      b when others;  -- passthrough otherwise

   newReg : entity work.adder_1bit
      port map(
          a => inputA,
          b => inputB,
          cin => carryIn,
          sum => set,
          cout => carryOut
      );
   
   with operation select result <=
      inputA AND inputB when "00", -- and operation
      inputA OR inputB when "01",  -- or  operation
      set when "10",               -- add operation
      less when others;            -- result = less

end architecture;
