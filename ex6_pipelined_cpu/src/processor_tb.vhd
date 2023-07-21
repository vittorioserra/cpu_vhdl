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
	signal btn_c : std_logic;
	signal btn_d : std_logic;
	signal btn_l : std_logic;
	signal btn_r : std_logic;
	signal btn_u : std_logic;
begin
    DUT : entity work.processor_top
        generic map(
            project_path => project_path,
			debounce => false)
        port map(
            clock => clock,
            switch => switch,
            leds => leds,
			btn_c => btn_c,
			btn_d => btn_d,
			btn_l => btn_l,
			btn_r => btn_r,
			btn_u => btn_u);

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
		btn_c <= '0';
		btn_d <= '0';
		btn_l <= '0';
		btn_r <= '0';
		btn_u <= '0';
		wait for CLOCK_PERIOD;
		
		switch(0) <= '1';
		wait for CLOCK_PERIOD;

		for i in 0 to 2000 loop
			btn_u <= '1';
			wait for CLOCK_PERIOD * 1000;
			btn_u <= '0';
			wait for CLOCK_PERIOD * 1000;
		end loop;

		btn_l <= '1';

		-- run
		wait;
	end process;
end tb;
