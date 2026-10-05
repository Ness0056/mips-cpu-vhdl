entity mux2 is
   port( a: in bit;
         b : in bit;
         s : in bit;
         y : out bit );
end mux2;

architecture behavioral of mux2 is
begin
    y <= (a and (not s)) or (b and s);
end behavioral ;
