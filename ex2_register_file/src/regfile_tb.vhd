----------------------------------------------------------------------------------
-- Company: FAU Erlangen - Nuernberg
-- Engineer: Vittorio Serra and Cedric Donges
--
-- Description: testbench for register file
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.utils.ALL;

entity regfile_tb is
end regfile_tb;

architecture tb of regfile_tb is
	constant CLOCK_PERIOD  : time := 10 ns;
	constant PORT_WIDTH  : positive := 32;
	constant REG_COUNT : positive := 32;
	constant SEL_WIDTH : positive := getAddressSize(REG_COUNT);

	signal clock, reset_n, w_enable : std_logic;
    signal r1_select, r2_select, w_select : std_logic_vector(SEL_WIDTH-1 downto 0);
    signal r1_value, r2_value, w_value : std_logic_vector(PORT_WIDTH-1 downto 0);
begin
	DUT : entity work.regfile
		generic map (
			port_width => PORT_WIDTH,
			reg_count => REG_COUNT)
		port map (
			clock => clock, reset_n => reset_n, w_enable => w_enable,
			r1_select => r1_select, r2_select => r2_select, w_select => w_select,
			r1_value => r1_value, r2_value => r2_value, w_value => w_value
		);

	gen_clk : process
	begin
		clock <= '1';
		wait for CLOCK_PERIOD / 2;
		clock <= '0';
		wait for CLOCK_PERIOD / 2;
	end process;

	stimuli : process
	begin
	    reset_n <= '1';
	    w_enable <= '0';
	    wait for CLOCK_PERIOD;
	    
	    reset_n <= '0';
	    wait for CLOCK_PERIOD;
	    
	    reset_n <= '1';
	    r1_select <= ui2vec(0, SEL_WIDTH);
	    r2_select <= ui2vec(1, SEL_WIDTH);
	    wait for CLOCK_PERIOD;
	    
	    w_value <= x"DEADCAFE";
	    w_enable <= '1';
	    for i in 0 to REG_COUNT-1 loop
            w_select <= ui2vec(i, SEL_WIDTH);
            wait for CLOCK_PERIOD;
		end loop;
		
	    w_value <= x"CAFEBEEF";
	    w_enable <= '0';
	    for i in 0 to REG_COUNT-1 loop
            w_select <= ui2vec(i, SEL_WIDTH);
            wait for CLOCK_PERIOD;
		end loop;
		
	    w_enable <= '1';
	    for i in 0 to REG_COUNT-1 loop
            r1_select <= ui2vec(i-1, SEL_WIDTH);
            r2_select <= ui2vec(i, SEL_WIDTH);
	        w_value <= ui2vec(i, PORT_WIDTH);
            w_select <= ui2vec(i, SEL_WIDTH);
            wait for CLOCK_PERIOD;
		end loop;

		wait;

	end process;
end tb;