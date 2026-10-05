library ieee;
use ieee.std_logic_1164.all;

package mipsISA is

    constant R_FORMAT_OPCODE : std_logic_vector(5 downto 0) := "000000";
    constant   JR_FUNCT : std_logic_vector(5 downto 0) := "001000";
    constant  ADD_FUNCT : std_logic_vector(5 downto 0) := "100000";
    constant ADDU_FUNCT : std_logic_vector(5 downto 0) := "100001";
    constant  SUB_FUNCT : std_logic_vector(5 downto 0) := "100010";
    constant SUBU_FUNCT : std_logic_vector(5 downto 0) := "100011";
    constant  AND_FUNCT : std_logic_vector(5 downto 0) := "100100";
    constant   OR_FUNCT : std_logic_vector(5 downto 0) := "100101";
    constant  NOR_FUNCT : std_logic_vector(5 downto 0) := "100111";
    constant  SLT_FUNCT : std_logic_vector(5 downto 0) := "101010";
    constant SLTU_FUNCT : std_logic_vector(5 downto 0) := "101011";

    constant  ADDI_OPCODE : std_logic_vector(5 downto 0) := "001000"; --  8
    constant ADDIU_OPCODE : std_logic_vector(5 downto 0) := "001001"; --  9
    constant  ANDI_OPCODE : std_logic_vector(5 downto 0) := "001100"; -- 12
    constant   ORI_OPCODE : std_logic_vector(5 downto 0) := "001101"; -- 13
    constant  SLTI_OPCODE : std_logic_vector(5 downto 0) := "001010"; -- 10
    constant SLTIU_OPCODE : std_logic_vector(5 downto 0) := "001011"; -- 11
    constant    LW_OPCODE : std_logic_vector(5 downto 0) := "100011"; -- 35
    constant    SW_OPCODE : std_logic_vector(5 downto 0) := "101011"; -- 43
    constant   LUI_OPCODE : std_logic_vector(5 downto 0) := "001111"; -- 15
    constant   BEQ_OPCODE : std_logic_vector(5 downto 0) := "000100"; --  4
    constant   BNE_OPCODE : std_logic_vector(5 downto 0) := "000101"; --  5
    constant     J_OPCODE : std_logic_vector(5 downto 0) := "000010"; --  2
    constant   JAL_OPCODE : std_logic_vector(5 downto 0) := "000011"; --  3

end mipsISA;

package body mipsISA is

end mipsISA;
