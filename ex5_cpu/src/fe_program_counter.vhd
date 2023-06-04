----------------------------------------------------------------------------------
-- Company: FAU Erlangen - Nuernberg
-- Engineer: Vittorio Serra and Cedric Donges
-- 
-- Description: program counter for the cpu
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity program_counter is
	Generic (
		pc_width : positive := 32);
	Port ( 
		clock, enable, reset_n, load : IN std_logic;
		load_value : IN std_logic_vector(pc_width - 1 downto 0);
		pc_value : OUT std_logic_vector(pc_width - 1 downto 0);
		pc_value_next : OUT std_logic_vector(pc_width -1 downto 0));
end program_counter;

architecture bh of program_counter is
	signal pc_reg : std_logic_vector(pc_width - 1 downto 0);
begin
	pc_value <= pc_reg;
	pc_value_next <= std_logic_vector(unsigned(pc_reg)  + 4);

	process(clock, reset_n, enable)
	begin
		if (reset_n = '0') then
			pc_reg <= (others => '0');
	elsif (rising_edge(clock) and enable = '1') then
		if (load = '1') then
			pc_reg <= load_value;
		else
			pc_reg <= std_logic_vector(unsigned(pc_reg) + 4);
		end if;
	end if;
	end process;
end bh;