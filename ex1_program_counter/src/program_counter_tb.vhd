----------------------------------------------------------------------------------
-- Company: FAU Erlangen - Nuernberg
-- Engineer: Vittorio Serra and Cedric Donges
--
-- Description: testbench for program counter
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity program_counter_tb is
end program_counter_tb;

architecture tb of program_counter_tb is
	constant CLOCK_PERIOD  : time := 10 ns;
	constant PC_WIDTH  : positive := 32;

	signal clock, reset_n, enable, load : std_logic;
	signal load_value, pc_value : std_logic_vector(PC_WIDTH - 1 downto 0);
begin
	DUT : entity work.program_counter
		generic map (
			pc_width => PC_WIDTH)
		port map (
			clock => clock,
			enable => enable,
			reset_n => reset_n,
			load => load,
			load_value => load_value,
			pc_value => pc_value);

	gen_clk : process
	begin
		clock <= '1';
		wait for CLOCK_PERIOD / 2;
		clock <= '0';
		wait for CLOCK_PERIOD / 2;
	end process;

	stimuli : process
	begin
		enable <= '0';
		reset_n <= '0';
		load <= '0';
		load_value <= x"00000000";
		wait for CLOCK_PERIOD;

		reset_n <= '1';
		wait for CLOCK_PERIOD;

		enable <= '1';
		wait for 8 * CLOCK_PERIOD;

		load <= '1';
		load_value <= x"DEADBEEF";
		wait for CLOCK_PERIOD;

		load <= '0';
		wait for 8 * CLOCK_PERIOD;

		for i in 0 to 255 loop
			if (i mod 2 = 0) then
				enable <= '1';
			else
				enable <= '0';
			end if;
			wait for CLOCK_PERIOD;
		end loop;

		enable <= '0';
		wait;

	end process;
end tb;
