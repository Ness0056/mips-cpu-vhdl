
entity xnor2 is 
        port(a: in bit ;
            b: in bit ; 
            y : out bit );

end xnor2 ; 

architecture behavioral of xnor2 is 
begin 
    y<= a xnor b; 
end behavioral ; 
