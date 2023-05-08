----------------------------------------------------------------------------------
-- Company: FAU Erlangen - Nuernberg
-- Engineer: Vittorio Serra and Cedric Donges
--
-- Description: testbench for register file v 1.0
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity program_counter_tb is
end program_counter_tb;

architecture tb of program_counter_tb is
	constant CLOCK_PERIOD  : time := 10 ns;
	constant PORT_WIDTH  : positive := 32;
	constant ADDRESS_WIDTH : positive := 5;
	constant NUM_REGISTERS : positive := 32;

	signal clock, enable : std_logic;
    signal async_read_address : std_logic_vector (ADDRESS_WIDTH -1 downto 0);
    signal async_output : std_logic_vector (PORT_WIDTH -1 downto 0);
    signal sync_write_address : std_logic_vector (ADDRESS_WIDTH -1 downto 0);
    signal input_dataport : std_logic_vector (PORT_WIDTH -1 downto 0);
begin
	DUT : entity work.regfile
		generic map (
			port_width => PORT_WIDTH,
			num_registers => NUM_REGISTERS,
			address_width => ADDRESS_WIDTH
			)
		port map (
			clock => clock,
			enable => enable,
			async_read_address => async_read_address,
			async_output => async_output,
			sync_write_address => sync_write_address,
			input_dataport => input_dataport );

	gen_clk : process
	begin
		clock <= '1';
		wait for CLOCK_PERIOD / 2;
		clock <= '0';
		wait for CLOCK_PERIOD / 2;
	end process;

	stimuli : process
	begin
		enable <= '1';
		sync_write_address <= b"00000";
		input_dataport <= x"DEADCAFE";
		wait for CLOCK_PERIOD;

        enable <= '0';
        async_read_address <= b"00000";
		wait for CLOCK_PERIOD;
		
		enable <= '1';
		sync_write_address <= b"11111";
		input_dataport <= x"CAFEBEEF";
		wait for CLOCK_PERIOD;

        async_read_address  <= b"11111";
		wait for CLOCK_PERIOD;

        enable <= '0';
        async_read_address <= b"11111";
		wait for CLOCK_PERIOD;

		wait;

	end process;
end tb;