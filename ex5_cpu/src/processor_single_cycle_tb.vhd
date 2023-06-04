----------------------------------------------------------------------------------
-- Company: FAU Erlangen - Nuernberg
-- Engineer: Vittorio Serra and Cedric Donges
--
-- Description: testbench for single cicle processor
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.utils.ALL;
use work.rv32i_defs.ALL;

entity processor_single_cycle_tb is
--  Port ( );
end processor_single_cycle_tb;

architecture bh of processor_single_cycle_tb is

    constant CLOCK_PERIOD : time := 10 ns;
    
    signal clock : std_logic; 

begin

    DUT : entity work.processor_single_cycle
		port map (
		clock => clock,
		reset => '0'
		);
		
   	gen_clk : process
	begin
		clock <= '1';
		wait for CLOCK_PERIOD / 2;
		clock <= '0';
		wait for CLOCK_PERIOD / 2;
	end process;
	
	simuli : process
	begin 
	wait;
	end process;


end bh;
