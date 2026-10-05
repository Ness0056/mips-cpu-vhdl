library ieee;
use ieee.std_logic_1164.all;

entity mipsCtrl is
    port(op : in std_logic_vector(5 downto 0);
         regDst : out std_logic;
         branch : out std_logic;
         memRead : out std_logic;
         memToReg : out std_logic;
         aluOp : out std_logic_vector(1 downto 0);
         memWrite : out std_logic;
         aluSrc : out std_logic;
         regWrite : out std_logic);
end mipsCtrl;

architecture structural of mipsCtrl is

signal and1Res, and2Res, and3Res, and4Res : std_logic;

begin
    and1Res <= (NOT op(0)) AND (NOT op(1)) AND (NOT op(2)) AND (NOT op(3)) AND (NOT op(4)) AND (NOT op(5));
    and2Res <= (    op(0)) AND (    op(1)) AND (NOT op(2)) AND (NOT op(3)) AND (NOT op(4)) AND (    op(5));
    and3Res <= (    op(0)) AND (    op(1)) AND (NOT op(2)) AND (    op(3)) AND (NOT op(4)) AND (    op(5));
    and4Res <= (NOT op(0)) AND (NOT op(1)) AND (    op(2)) AND (NOT op(3)) AND (NOT op(4)) AND (NOT op(5));

    regDst <= and1Res;
    aluSrc <= and2Res OR and3Res;
    memToReg <= and2Res;
    regWrite <= and1Res OR and2Res;
    memRead <= and2Res;
    memWrite <= and3Res;
    branch <= and4Res;
    aluOp <= and1Res & and4Res;

end architecture;
