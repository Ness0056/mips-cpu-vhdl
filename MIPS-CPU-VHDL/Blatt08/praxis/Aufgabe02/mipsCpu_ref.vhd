library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library std;
use std.textio.all;

library work;
use work.proc_config.all;
use work.mipsISA.all;

entity mipsCpu_ref is
    generic(PROG_FILE_NAME : string;
            DATA_FILE_NAME : string);
    port(clk : in std_logic;
         rst : in std_logic;

         -- instruction insertion ports
         testMode_debug : in std_logic;
         testInstruction_debug : in std_logic_vector(31 downto 0);

         -- ram access ports
         ramInsertMode_debug : in std_logic;
         ramWriteEn_debug : in std_logic;
         ramWriteAddr_debug : in std_logic_vector(LOG2_NUM_RAM_ELEMENTS - 1 downto 0);
         ramWriteData_debug : in std_logic_vector(RAM_ELEMENT_WIDTH - 1 downto 0);
         ramElements_debug : out ram_elements_type;

         -- register file access port
         registers_debug : out reg_vector_type;

         -- intermediate regs(rd)ult ports
         pc_next_debug : out std_logic_vector(PC_WIDTH - 1 downto 0);
         pc7SegDigits_debug : out pc_7seg_digits_type
         );
end mipsCpu_ref;

architecture structural of mipsCpu_ref is
    type rom_elements_type is array (0 to NUM_ROM_ELEMENTS - 1) of std_logic_vector(PC_WIDTH - 1 downto 0);

    impure function InitRamFromFile (RamFileName : in string) return ram_elements_type is
            FILE RamFile : text open read_mode is RamFileName;
            variable RamFileLine : line;
            variable dataBuffer : bit_vector(31 downto 0);
            variable RAM : ram_elements_type;
    begin
        for i in ram_elements_type'range loop
            if endfile(RamFile) then
                RAM(i) := (others => '0');
            else
                readline(RamFile, RamFileLine);
                read(RamFileLine, dataBuffer);
                RAM(i) := to_stdlogicvector(dataBuffer);
            end if;
        end loop;
        return RAM;
    end function;

    impure function InitRomFromFile (RomFileName : in string) return rom_elements_type is
        FILE RomFile : text open read_mode is RomFileName;
        variable RomFileLine : line;
        variable dataBuffer : bit_vector(31 downto 0);
        variable ROM : rom_elements_type;
    begin
        for i in rom_elements_type'range loop
            if endfile(RomFile) then
                ROM(i) := (others => '0');
            else
                readline(RomFile, RomFileLine);
                read(RomFileLine, dataBuffer);
                ROM(i) := to_stdlogicvector(dataBuffer);
            end if;
        end loop;
        return ROM;
    end function;

    signal ram : ram_elements_type := InitRamFromFile(DATA_FILE_NAME);
    constant rom : rom_elements_type := InitRomFromFile(PROG_FILE_NAME);
    signal regs : reg_vector_type := (others => (others => '0'));
    signal pc, pc_next : std_logic_vector(PC_WIDTH -1 downto 0);
    signal instr : std_logic_vector(PC_WIDTH - 1 downto 0);

    signal rs, rt, rd : integer range 0 to 31;
    signal imm : unsigned(15 downto 0);

begin

    rs  <= to_integer(unsigned(instr(25 downto 21)));
    rt  <= to_integer(unsigned(instr(20 downto 16)));
    rd  <= to_integer(unsigned(instr(15 downto 11)));
    imm <= unsigned(instr(15 downto 0));

    ref : process (clk) is
    begin
        if rising_edge(clk) then
            if rst then
                pc <= (others => '0');
                regs <= (others => (others => '0'));
            else
                if not testMode_debug then
                    pc <= pc_next;
                end if;

                if ramInsertMode_debug and ramWriteEn_debug then
                    ram(to_integer(unsigned(ramWriteAddr_debug))) <= ramWriteData_debug;
                else
                    case instr(31 downto 26) is
                        when R_FORMAT_OPCODE =>
                            case instr(5 downto 0) is
                                when AND_FUNCT =>
                                    regs(rd) <= regs(rt) and regs(rs);
                                when OR_FUNCT =>
                                    regs(rd) <= regs(rt) or regs(rs);
                                when ADD_FUNCT =>
                                    regs(rd) <= std_logic_vector(unsigned(regs(rs)) + unsigned(regs(rt)));
                                    when SUB_FUNCT =>
                                    regs(rd) <= std_logic_vector(unsigned(regs(rs)) - unsigned(regs(rt)));
                                when SLT_FUNCT =>
                                    if signed(regs(rs)) < signed(regs(rt)) then
                                        regs(rd) <= std_logic_vector(to_unsigned(1, 32));
                                    else
                                        regs(rd) <= (others => '0');
                                    end if;
                                when others =>
                                    --report "ERROR" severity failure;
                            end case;
                        when LW_OPCODE =>
                            regs(rt) <= ram(to_integer((unsigned(regs(rs))+imm) srl 2));
                        when SW_OPCODE =>
                            ram(to_integer((unsigned(regs(rs))+imm) srl 2)) <= regs(rt);
                        when BEQ_OPCODE =>

                        when others =>
                    end case;
                end if;
            end if;
        end if;
    end process;


    pc_next <= std_logic_vector(signed(pc) + signed(imm sll 2) + 4) when instr(31 downto 26) = BEQ_OPCODE and regs(rs) = regs(rt) else
    std_logic_vector(unsigned(pc) + 4);


    instr <= testInstruction_debug when testMode_debug else rom((to_integer(unsigned(pc) srl 2)) mod NUM_ROM_ELEMENTS);

    process (all)
        variable Bx : std_logic_vector(3 downto 0);
    begin
        for i in 0 to 3 loop
            Bx := pc(4*(i+1) - 1 downto 4*i);
            pc7SegDigits_debug(i)(6) <= (Bx(3) or Bx(2) or Bx(1)) and (Bx(3) or (not Bx(2)) or (not Bx(1)) or (not Bx(0))) and ((not Bx(3)) or (not Bx(2)) or Bx(1) or Bx(0));
            pc7SegDigits_debug(i)(5) <= (Bx(3) or Bx(2) or (not Bx(0))) and (Bx(3) or Bx(2) or (not Bx(1))) and (Bx(3) or (not Bx(1)) or (not Bx(0))) and ((not Bx(3)) or (not Bx(2)) or Bx(1) or (not Bx(0)));
            pc7SegDigits_debug(i)(4) <= (Bx(3) or (not Bx(0))) and (Bx(2) or Bx(1) or (not Bx(0))) and (Bx(3) or (not Bx(2)) or Bx(1));
            pc7SegDigits_debug(i)(3) <= (Bx(3) or Bx(2) or Bx(1) or (not Bx(0))) and (Bx(3) or (not Bx(2)) or Bx(1) or Bx(0)) and ((not Bx(2)) or (not Bx(1)) or (not Bx(0))) and ((not Bx(3)) or Bx(2) or (not Bx(1)) or Bx(0));
            pc7SegDigits_debug(i)(2) <= (Bx(3) or Bx(2) or (not Bx(1)) or Bx(0)) and ((not Bx(3)) or (not Bx(2)) or Bx(0)) and ((not Bx(3)) or (not Bx(2)) or (not Bx(1)));
            pc7SegDigits_debug(i)(1) <= (Bx(3) or (not Bx(2)) or Bx(1) or (not Bx(0))) and ((not Bx(2)) or (not Bx(1)) or Bx(0)) and ((not Bx(3)) or (not Bx(1)) or (not Bx(0))) and ((not Bx(3)) or (not Bx(2)) or Bx(0));
            pc7SegDigits_debug(i)(0) <= (Bx(3) or Bx(2) or Bx(1) or (not Bx(0))) and (Bx(3) or (not Bx(2)) or Bx(1) or Bx(0)) and ((not Bx(3)) or Bx(2) or (not Bx(1)) or (not Bx(0))) and ((not Bx(3)) or (not Bx(2)) or Bx(1) or (not Bx(0)));
        end loop;
    end process;

        ramElements_debug <= ram;
        registers_debug <= regs;
        pc_next_debug <= pc_next;
end architecture;
