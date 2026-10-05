library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Diese Zeile ist notwendig, damit ihr Entities aus der ROrgPrSimLib verwenden könnt.
-- Dies könnte z.B. das Register oder der Adressdekoder sein, wenn ihr die entsprechenden
-- Aufgaben nicht erfolgreich bearbeitet habt.
-- Um ein Entity aus der ROrgPrSimLib zu verwenden, instanziiert es einfach als
-- "entity ROrgPrSimLib.<EntityName>" statt "entity work.<EntityName>".
-- Also z.B. "entity ROrgPrSimLib.reg" statt "entity work.reg".
library ROrgPrSimLib;

library work;
use work.proc_config.all;

entity regFile is
    generic(NUM_REGS : integer;
            LOG2_NUM_REGS : integer;
            REG_WIDTH : integer);
    port(clk : in std_logic;
         rst : in std_logic;
         readAddr1 : in std_logic_vector(LOG2_NUM_REGS - 1 downto 0);
         readData1 : out std_logic_vector(REG_WIDTH - 1 downto 0);
         readAddr2 : in std_logic_vector(LOG2_NUM_REGS - 1 downto 0);
         readData2 : out std_logic_vector(REG_WIDTH - 1 downto 0);
         writeEn   : in std_logic;
         writeAddr : in std_logic_vector(LOG2_NUM_REGS - 1 downto 0);
         writeData : in std_logic_vector(REG_WIDTH - 1 downto 0);
         reg_vect_debug : out reg_vector_type);
end regFile;

architecture structural of regFile is

    -- Array, das alle Einzelregister enthält
    signal reg_vect : reg_vector_type;

    -- std_logic_vector for decoder result
    signal addr_decode_result : std_logic_vector(NUM_REGS - 1 downto 0);
    
begin

    addrDecoder: entity work.addrDecoder
        generic map (
            POW2_ADDR_WIDTH => NUM_REGS,
            ADDR_WIDTH => LOG2_NUM_REGS
        )
        port map(
            address => writeAddr,
            bitmask => addr_decode_result
        );

    gen: for i in 0 to NUM_REGS-1 generate -- loop for all regs to get added
        zeroReg: if i = 0 generate -- reg 0 
            newReg : entity work.reg
                generic map (
                    WIDTH => REG_WIDTH
                )
                port map(
                    clk => clk,
                    rst => rst,
	            en => '0', -- null reg not writeable
                    D => writeData,
                    Q => reg_vect(i)
                );
        end generate zeroReg;
        normalReg: if (i > 0) generate -- regs >0:
            newReg : entity work.reg
                generic map (
                    WIDTH => REG_WIDTH
                )
                port map(
                    clk => clk,
                    rst => rst,
                    en => addr_decode_result(i) AND writeEn, -- regs >0 written if writeEn AND bitmap(i) is '1'
                    D => writeData,
                    Q => reg_vect(i)
                );
        end generate normalReg;
    end generate gen;

    -- output:
    readData1 <= reg_vect(to_integer(unsigned(readAddr1)));
    readData2 <= reg_vect(to_integer(unsigned(readAddr2)));

    -- Inhalt des Registerspeichers über den Debug-Port nach außen führen
    reg_vect_debug <= reg_vect;

end architecture;
