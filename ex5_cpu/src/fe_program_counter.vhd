----------------------------------------------------------------------------------
-- Company: FAU Erlangen - Nuernberg
-- Engineer: Vittorio Serra and Cedric Donges
-- 
-- Description: program counter for the cpu, outputs also the next pc value and is able to jump
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.rv32i_defs.ALL;

entity program_counter is
	Port ( 
		clock, enable, reset_n, jump_enable, step_16 : IN std_logic;
		jump_value : IN std_logic_vector(xlen_range);
		pc_now : OUT std_logic_vector(xlen_range);
		pc_next : OUT std_logic_vector(xlen_range));
end program_counter;

architecture bh of program_counter is
	signal pc_reg : std_logic_vector(xlen_range);
	signal pc_next_int : std_logic_vector(xlen_range);
	signal step_size : unsigned;
begin
    step_size <= unsigned(2) when step_16 = '1' else unsigned(4);
    pc_next_int <= std_logic_vector(unsigned(pc_reg) + step_size);
	pc_next <= pc_next_int;
	pc_now <= pc_reg;

	process(clock, reset_n, enable)
	begin
		if (reset_n = '0') then
			pc_reg <= (others => '0');
		elsif (rising_edge(clock) and enable = '1') then
			if (jump_enable = '1') then
				pc_reg <= jump_value;
			else
				pc_reg <= pc_next_int;
			end if;
		end if;
	end process;
end bh;
