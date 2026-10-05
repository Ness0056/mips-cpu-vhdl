library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity mult32x32 is
    port(
        a   : in std_logic_vector(31 downto 0);
        b   : in std_logic_vector(31 downto 0);
        y   : out std_logic_vector(63 downto 0)
    );
end mult32x32;

architecture structural of mult32x32 is
   signal mult_result_1, mult_result_2, mult_result_3, mult_result_4 : signed(42 downto 0); -- all the multipliers will return a 42 bit signed value
   signal concat_result : signed(63 downto 0); -- the concatenation should result in a signed 64 bit value
   signal adder_33_bit_result : signed(32 downto 0); -- our 33 bit adder should output a 33 bit signed value
begin
   mult1: entity work.mult25x18(behavioral)
          port map(a => resize(signed(a(31 downto 16)), 25), -- sign-extend a[31:16] to 25 bit
                   b => resize(signed(b(31 downto 16)), 18), -- sign-extend b[31:16] to 18 bit
                   y => mult_result_1);
   mult2: entity work.mult25x18(behavioral)
          port map(a => signed(resize(unsigned(a(15 downto 0)), 25)), -- extend a[15:0] with leading zeros to 25 bit
                   b => signed(resize(unsigned(b(15 downto 0)), 18)), -- extend b[15:0] with leading zeros to 18 bit
                   y => mult_result_2);
   mult3: entity work.mult25x18(behavioral)
          port map(a => resize(signed(a(31 downto 16)), 25),          -- sign-extend a[31:16]                    to 25 bit
                   b => signed(resize(unsigned(b(15 downto 0)), 18)), -- extend      b[15:0]  with leading zeros to 18 bit
                   y => mult_result_3);
   mult4: entity work.mult25x18(behavioral)
          port map(a => resize(signed(b(31 downto 16)), 25),          -- sign-extend b[31:16]                    to 25 bit
                   b => signed(resize(unsigned(a(15 downto 0)), 18)), -- extent      a[15:0]  with leading zeros to 18 bit
                   y => mult_result_4);
   concat_result <= signed( -- the result of our concatenation is a signed 64 bit value
      std_logic_vector(resize(mult_result_1, 32))       -- resize 42 bit result from first multiplier                       to 32 bit
      & -- concatenate results from first two multiplication
      std_logic_vector(resize(unsigned(mult_result_2), 32)) -- interpret result from first multiplier as unsiged and resize to 32 bit
   );
   adder_33_bit_result <= resize(mult_result_3, 33) + resize(mult_result_4, 33); -- add signed results of final two multipliers after resizing to 33 bits
   y <= std_logic_vector( -- the final output is a 64 bit std_logic_vector
      concat_result
      + -- add signed concatenation result to signed result of 33bit addition 
      shift_left(resize(adder_33_bit_result, 64), 16) -- sign extend 33 bit adder result and append 16 zeros
   );
end architecture;
