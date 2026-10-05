library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;

library std;
use std.textio.all;

entity alu_1bit_tb is
end alu_1bit_tb;

architecture behavioral of alu_1bit_tb is

	signal operation : std_logic_vector(1 downto 0);
	signal a, b : std_logic;
	signal aInvert, bInvert : std_logic;
	signal less : std_logic;
	signal carryIn, carryOut_uut : std_logic;
	signal result_uut : std_logic;
	signal set_uut : std_logic;
	constant MAX_ERRORS : integer := 10;

	type errByInv_type is array (4 downto 0) of integer;

	type content_arr is array(natural range <>) of std_logic_vector(0 to 2);
	constant res_ref : content_arr := ("000", "000", "000", "000", "001", "101", "101", "001", "001", "101", "101", "001", "110", "110", "010", "010", "001", "101", "101", "001", "110", "110", "010", "010", "000", "000", "000", "000", "001", "101", "101", "001", "001", "101", "101", "001", "000", "000", "000", "000", "110", "110", "010", "010", "001", "101", "101", "001", "110", "110", "010", "010", "001", "101", "101", "001", "001", "101", "101", "001", "000", "000", "000", "000", "001", "001", "101", "001", "010", "110", "010", "010", "010", "110", "010", "010", "111", "111", "111", "011", "010", "110", "010", "010", "111", "111", "111", "011", "001", "001", "101", "001", "010", "110", "010", "010", "010", "110", "010", "010", "001", "001", "101", "001", "111", "111", "111", "011", "010", "110", "010", "010", "111", "111", "111", "011", "010", "110", "010", "010", "010", "110", "010", "010", "001", "001", "101", "001", "000", "000", "000", "100", "001", "101", "101", "101", "001", "101", "101", "101", "110", "110", "010", "110", "001", "101", "101", "101", "110", "110", "010", "110", "000", "000", "000", "100", "001", "101", "101", "101", "001", "101", "101", "101", "000", "000", "000", "100", "110", "110", "010", "110", "001", "101", "101", "101", "110", "110", "010", "110", "001", "101", "101", "101", "001", "101", "101", "101", "000", "000", "000", "100", "001", "001", "101", "101", "010", "110", "010", "110", "010", "110", "010", "110", "111", "111", "111", "111", "010", "110", "010", "110", "111", "111", "111", "111", "001", "001", "101", "101", "010", "110", "010", "110", "010", "110", "010", "110", "001", "001", "101", "101", "111", "111", "111", "111", "010", "110", "010", "110", "111", "111", "111", "111", "010", "110", "010", "110", "010", "110", "010", "110", "001", "001", "101", "101");
begin

	UUT: entity work.alu_1bit(structural)
		port map(operation => operation,
				 a => a,
				 aInvert => aInvert,
				 b => b,
				 bInvert => bInvert,
				 carryIn => carryIn,
				 less => less,
				 result => result_uut,
				 carryOut => carryOut_uut,
				 set => set_uut);

	TESTBENCH: process
		variable points, numErrors, numResultErrors, numCarryErrors, numSetErrors : integer := 0;
		variable numAddErrors, numAndErrors, numOrErrors, numLessErrors : errByInv_type := (others => 0);
        variable l : line;
		variable tmp : std_logic_vector(7 downto 0);
		variable resultError, carryError, setError : boolean;
	begin
		for i in 0 to 255 loop
			tmp := std_logic_vector(to_unsigned(i, 8));
			aInvert <= tmp(3);
			bInvert <= tmp(2);
			operation(1) <= tmp(1);
			operation(0) <= tmp(0);
			a <= tmp(4);
			b <= tmp(5);
			carryIn <= tmp(6);
			less <= tmp(7);

			wait for 5 ns;

			resultError := result_uut /= res_ref(i)(0);
			carryError := carryOut_uut /= res_ref(i)(1);
			setError := set_uut /= res_ref(i)(2);

--			write(l, string'(""""));
--			write(l, result_uut);
--			write(l, carryOut_uut);
--			write(l, set_uut);
--			write(l, string'(""""));
--			writeline(OUTPUT, l);

			if resultError or carryError or setError then
				case tmp(1 downto 0) is
					when "00" =>
						if resultError then
							numAndErrors(to_integer(unsigned(tmp(3 downto 2)))) := numAndErrors(to_integer(unsigned(tmp(3 downto 2)))) + 1;
							numAndErrors(4) := numAndErrors(4) + 1;
						end if;
					when "01" =>
						if resultError then
							numOrErrors(to_integer(unsigned(tmp(3 downto 2)))) := numOrErrors(to_integer(unsigned(tmp(3 downto 2)))) + 1;
							numOrErrors(4) := numOrErrors(4) + 1;
						end if;
					when "10" =>
						if resultError or carryError then
							numAddErrors(to_integer(unsigned(tmp(3 downto 2)))) := numAddErrors(to_integer(unsigned(tmp(3 downto 2)))) + 1;
							numAddErrors(4) := numAddErrors(4) + 1;
						end if;
					when others =>
						if resultError or setError then
							numLessErrors(to_integer(unsigned(tmp(3 downto 2)))) := numLessErrors(to_integer(unsigned(tmp(3 downto 2)))) + 1;
							numLessErrors(4) := numLessErrors(4) + 1;
						end if;
				end case;

				if numErrors < MAX_ERRORS then
					write(l, time'image(now));
					write(l, string'(": Falsches Ergebnis an der 1-Bit-ALU:"));
					writeline(OUTPUT, l);
				elsif numErrors = MAX_ERRORS then
					write(l, time'image(now));
					write(l, string'(": Weitere Fehler werden nicht angezeigt ..."));
					writeline(OUTPUT, l);
				end if;

				if resultError then
					if numErrors < MAX_ERRORS then
						write(l, string'("    result = '"));
						write(l, result_uut);
						write(l, string'("' (erwartet: '"));
						write(l, res_ref(i)(0));
						write(l, string'("')"));
						writeline(OUTPUT, l);
					end if;
					numResultErrors := numResultErrors + 1;
				end if;

				if carryError then
					if numErrors < MAX_ERRORS then
						write(l, string'("    carryOut = '"));
						write(l, carryOut_uut);
						write(l, string'("' (erwartet: '"));
						write(l, res_ref(i)(1));
						write(l, string'("')"));
						writeline(OUTPUT, l);
					end if;
					numCarryErrors := numCarryErrors + 1;
				end if;

				if setError then
					if numErrors < MAX_ERRORS then
						write(l, string'("    set = '"));
						write(l, set_uut);
						write(l, string'("' (erwartet: '"));
						write(l, res_ref(i)(2));
						write(l, string'("')"));
						writeline(OUTPUT, l);
					end if;
					numSetErrors := numSetErrors + 1;
				end if;

				numErrors := numErrors + 1;
			end if;
			wait for 5 ns;
		end loop;

		-- evaluation
		writeline(OUTPUT, l);
		write(l, string'("---- Auswertung ----"));
		writeline(OUTPUT, l);
		writeline(OUTPUT, l);

		write(l, string'("---- Fehler nach Operation/Eingabe ----"));
		writeline(OUTPUT, l);

		write(l, string'("  Addition:                "));
		if numAddErrors(4) = 0 then
			write(l, string'("fehlerfrei"));
			points := points + 1;
		elsif numAddErrors(3) = 0 or numAddErrors(2) = 0 or numAddErrors(1) = 0 or numAddErrors(0) = 0 then
			write(l, string'("fuer bestimmte aInvert/bInvert fehlerhaft (" & integer'image(numAddErrors(4)) & " Fehler)"));
			points := points + 1;
		else
			write(l, string'("fehlerhaft (" & integer'image(numAddErrors(4)) & " Fehler)"));
		end if;
		writeline(OUTPUT, l);

		write(l, string'("  AND:                     "));
		if numAndErrors(4) = 0 then
			write(l, string'("fehlerfrei"));
			points := points + 1;
		elsif numAndErrors(3) = 0 or numAndErrors(2) = 0 or numAndErrors(1) = 0 or numAndErrors(0) = 0 then
			write(l, string'("fuer bestimmte aInvert/bInvert fehlerhaft (" & integer'image(numAndErrors(4)) & " Fehler)"));
			points := points + 1;
		else
			write(l, string'("fehlerhaft (" & integer'image(numAndErrors(4)) & " Fehler)"));
		end if;
		writeline(OUTPUT, l);

		write(l, string'("  OR:                      "));
		if numOrErrors(4) = 0 then
			write(l, string'("fehlerfrei"));
			points := points + 1;
		elsif numOrErrors(3) = 0 or numOrErrors(2) = 0 or numOrErrors(1) = 0 or numOrErrors(0) = 0 then
			write(l, string'("fuer bestimmte aInvert/bInvert fehlerhaft (" & integer'image(numOrErrors(4)) & " Fehler)"));
			points := points + 1;
		else
			write(l, string'("fehlerhaft (" & integer'image(numOrErrors(4)) & " Fehler)"));
		end if;
		writeline(OUTPUT, l);

		write(l, string'("  Set-less-than:           "));
		if numLessErrors(4) = 0 then
			write(l, string'("fehlerfrei"));
			points := points + 1;
		elsif numLessErrors(3) = 0 or numLessErrors(2) = 0 or numLessErrors(1) = 0 or numLessErrors(0) = 0 then
			write(l, string'("fuer bestimmte aInvert/bInvert fehlerhaft (" & integer'image(numLessErrors(4)) & " Fehler)"));
			points := points + 1;
		else
			write(l, string'("fehlerhaft (" & integer'image(numLessErrors(4)) & " Fehler)"));
		end if;
		writeline(OUTPUT, l);


		-- write(l, string'("(Hinweis: es werden nur die fuer diese Operation relevanten Ausgaenge beachtet)"));
		-- writeline(OUTPUT, l);

		write(l, string'("  aInvert:                 "));
		if numLessErrors(0) + numLessErrors(2) + numAndErrors(0) + numAndErrors(2) + numOrErrors(0) + numOrErrors(2) + numAddErrors(0) + numAddErrors(2) = 0 then
			points := points + 1;
			write(l, string'("fehlerfrei"));
		else
			write(l, string'("fehlerhaft"));
		end if;
		writeline(OUTPUT, l);

		write(l, string'("  bInvert:                 "));
		if numLessErrors(1) + numLessErrors(3) + numAndErrors(1) + numAndErrors(3) + numOrErrors(1) + numOrErrors(3) + numAddErrors(1) + numAddErrors(3) = 0 then
			if points /= 5 then
				points := points + 1;
			end if;
			write(l, string'("fehlerfrei"));
		else
			write(l, string'("fehlerhaft"));
		end if;
		writeline(OUTPUT, l);
		writeline(OUTPUT, l);


		write(l, string'("---- Fehler nach Ausgang ----"));
		writeline(OUTPUT, l);

		if numResultErrors = 0 then
			write(l, string'("  ALU-result:              fehlerfrei"));
		else
			write(l, string'("  ALU-result:              fehlerhaft (" & integer'image(numResultErrors) & " Fehler)"));
		end if;
		writeline(OUTPUT, l);

		if numCarryErrors = 0 then
			write(l, string'("  ALU-carryOut:            fehlerfrei"));
		else
			write(l, string'("  ALU-carryOut:            fehlerhaft (" & integer'image(numCarryErrors) & " Fehler)"));
		end if;
		writeline(OUTPUT, l);

		if numSetErrors = 0 then
			write(l, string'("  ALU-set:                 fehlerfrei"));
		else
			write(l, string'("  ALU-set:                 fehlerhaft (" & integer'image(numCarryErrors) & " Fehler)"));
		end if;
		writeline(OUTPUT, l);
		writeline(OUTPUT, l);

        if numErrors = 0 then
	        report "Die 1-Bit-ALU funktioniert einwandfrei! (alu_1bit: 3.0/3 Punkte)" severity note;
			report "CI: All good." severity note;
	    else
	        report "Die 1-Bit-ALU ist fehlerhaft! (alu_1bit: " & integer'image(points/2) & "." & integer'image(5*(points mod 2)) & "/3 Punkte)" severity failure;
	    end if;

		wait;
	end process;

end behavioral;
