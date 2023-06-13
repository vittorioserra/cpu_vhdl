----------------------------------------------------------------------------------
-- Company: FAU Erlangen - Nuernberg
-- Engineer: Vittorio Serra and Cedric Donges
--
-- Description: testbench for extension unit
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.utils.ALL;
use work.rv32i_defs.ALL;

entity extension_unit_tb is
end extension_unit_tb;

architecture tb of extension_unit_tb is
    constant CLOCK_PERIOD : time := 10 ns;
	
	signal select_extension : extension_control_type;
    signal input_to_extend  : std_logic_vector(31 downto 7);
    signal extended_output  : std_logic_vector(xlen_range);
    
    signal clock : std_logic;
    
begin

    DUT : entity work.extension_unit
		port map (
			select_extension => select_extension,
			input_to_extend  => input_to_extend,
			extended_output  => extended_output);

	gen_clk : process
	begin
		clock <= '1';
		wait for CLOCK_PERIOD / 2;
		clock <= '0';
		wait for CLOCK_PERIOD / 2;
	end process;

	stimuli : process
	
	variable instruction : std_logic_vector(xlen_range);
	
	begin
	
		select_extension <= i_type;
		instruction := x"FFC4A303";
		input_to_extend <= instruction(31 downto 7);
		wait for CLOCK_PERIOD;
		
		select_extension <= s_type;
		instruction := x"0064A423";
		input_to_extend <= instruction(31 downto 7);
		wait for CLOCK_PERIOD;
		
		select_extension <= b_type;
		instruction := x"FE420AE3";
		input_to_extend <= instruction(31 downto 7);
		wait for CLOCK_PERIOD;
		
		select_extension <= j_type;
		instruction := x"00008067";
		input_to_extend <= instruction(31 downto 7);
		wait for CLOCK_PERIOD;
		
		select_extension <= complement;
		instruction := x"FFC4A303";
		input_to_extend <= instruction(31 downto 7);
		wait for CLOCK_PERIOD;
		
		wait;

	end process;
end tb;