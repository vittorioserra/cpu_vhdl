----------------------------------------------------------------------------------
-- Company: FAU Erlangen - Nuernberg
-- Engineer: Cedric Donges and Vittorio Serra
--
-- Description: Testbench of the processor.
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.utils.ALL;
use work.rv32i_defs.ALL;

entity processor_tb is
    Generic(project_path : string);
end processor_tb;

architecture tb of processor_tb is
    constant CLOCK_PERIOD : time := 10 ns;

    signal clock : std_logic;
    signal switch : std_logic_vector(7 downto 0);
    signal leds : std_logic_vector(7 downto 0);
begin
    DUT : entity work.processor_top
        generic map(
            project_path => project_path)
        port map(
            clock => clock,
            switch => switch,
            leds => leds,
			btn_c => '1',
			btn_d => '0',
			btn_l => '1',
			btn_r => '0',
			btn_u => '1');

    gen_clk : process
	begin
		clock <= '0';
		wait for CLOCK_PERIOD / 2;
		clock <= '1';
		wait for CLOCK_PERIOD / 2;
	end process;
	
	stimuli : process
	begin
		-- general reset
		switch <= (others => '0');
		for i in 0 to 130 loop
			wait for CLOCK_PERIOD;
		end loop;
		switch <= "10000001";
		for i in 0 to 130 loop
			wait for CLOCK_PERIOD;
		end loop;
		
		-- run
		wait;
	end process;
end tb;
