----------------------------------------------------------------------------------
-- Company: FAU Erlangen - Nuernberg
-- Engineer: Vittorio Serra and Cedric Donges
--
-- Description: Testbench for the Memory
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.utils.ALL;

entity mem_tb is
end mem_tb;

architecture tb of mem_tb is
    constant CLOCK_PERIOD : time := 10 ns;
	constant PORT_WIDTH : positive := 32;
	constant BLOCK_COUNT : positive := 512;
	constant MEM_INIT_FILE : string := "../src/fibonacci_code/fibonacci.o";

	signal clock : std_logic;
	signal p1_enable, p2_enable, p2_write_enable : std_logic;
	signal p1_addr, p2_addr : std_logic_vector(get_bit_count(BLOCK_COUNT) - 1 downto 0);
	signal p2_val_in : std_logic_vector(PORT_WIDTH - 1 downto 0);
	signal p1_val_out, p2_val_out : std_logic_vector(PORT_WIDTH - 1 downto 0);
begin

    DUT : entity work.mem 
        generic map(
			port_width => PORT_WIDTH,
			block_count => BLOCK_COUNT,
			mem_init_file => MEM_INIT_FILE)
        port map(
			clock => clock,
			p1_enable => p1_enable, p2_enable => p2_enable,
			p2_write_enable => p2_write_enable,
			p1_addr => p1_addr, p2_addr => p2_addr,
			p2_val_in => p2_val_in,
			p1_val_out => p1_val_out, p2_val_out => p2_val_out);

    gen_clk : process
	begin
		clock <= '1';
		wait for CLOCK_PERIOD / 2;
		clock <= '0';
		wait for CLOCK_PERIOD / 2;
	end process;
	
	stimuli : process
	begin
		-- init
		p1_enable <= '0';
		p2_enable <= '0';
		p2_write_enable <= '0';
		p1_addr <= (others => '0');
		p2_addr <= (others => '0');
		p2_val_in <= (others => '0');
		wait for CLOCK_PERIOD;

		-- read the first 32 addresses
		p1_enable <= '1';
		p2_enable <= '1';
		for addr in 0 to 31 loop
			p1_addr <= ui2vec(addr, get_bit_count(BLOCK_COUNT));
			p2_addr <= ui2vec(addr + 1, get_bit_count(BLOCK_COUNT));
			wait for CLOCK_PERIOD;
		end loop;

		-- write the first 33 addresses
		p2_write_enable <= '1';
		for addr in 0 to 31 loop
			p1_addr <= ui2vec(addr, get_bit_count(BLOCK_COUNT));
			p2_addr <= ui2vec(addr + 1, get_bit_count(BLOCK_COUNT));
			p2_val_in <= ui2vec(vec2ui(x"DEADBEEF") + addr, PORT_WIDTH);
			wait for CLOCK_PERIOD;
		end loop;
		
		wait;
	end process;
end tb;
