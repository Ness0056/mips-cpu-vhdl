
entity and2 is 
        port( a: in bit;
              b : in bit ; 
              y : out bit );

end and2 ; 

architecture behavioral of and2 is 
begin 
    y <= a and b; 
end behavioral ; 

