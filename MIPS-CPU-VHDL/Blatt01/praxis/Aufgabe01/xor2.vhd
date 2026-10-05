
entity xor2 is 
        port(a: in bit ;
            b: in bit  ; 
            y : out bit  );

end xor2 ; 

architecture behavioral of xor2 is 
begin 
    y<= a xor b; 
end behavioral ; 

