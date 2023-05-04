----------------------------------------------------------------------------------
-- Company: FAU Erlangen - Nuernberg
-- Engineer: Vittorio Serra and Cedric Donges
--
-- Description: top level for program counter demo on zedboard
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity program_counter_demo is
    Port (
        clock : IN std_logic;
        btn_c, btn_u, btn_r, btn_d, btn_l : IN std_logic;
        switch : IN std_logic_vector(0 to 7);
        led : OUT std_logic_vector(0 to 7));
end program_counter_demo;

architecture bh of program_counter_demo is
	signal reset_n : std_logic;
	signal load_value, pc_value : std_logic_vector(31 downto 0);
begin
	PC : entity work.program_counter
		generic map (
			pc_width => 32)
		port map (
			clock => clock,
			enable => btn_u,
			reset_n => reset_n,
			load => btn_c,
			load_value => load_value,
			pc_value => pc_value);

    led <= pc_value(31 downto 24);
    load_value(31 downto 24) <= switch;
    load_value(23 downto 0) <= (others => '0');
end bh;