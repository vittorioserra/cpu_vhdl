----------------------------------------------------------------------------------
-- Company: FAU Erlangen - Nuernberg
-- Engineer: Vittorio Serra and Cedric Donges
--
-- Description: Testbench for the data control unit
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.utils.ALL;
use work.rv32i_defs.ALL;

entity data_control_tb is
    Generic(PROJECT_PATH : string);
end data_control_tb;

architecture tb of data_control_tb is
    constant CLOCK_PERIOD : time := 10 ns;

    constant MEM_BLOCK_COUNT    : positive := 1024;
    constant MEM_BLOCK_ADDR     : std_logic_vector(31 downto 12) := x"00000";
    
	signal clock : std_logic;
	signal reset_n : std_logic;
	signal enable : std_logic;
	signal mode : mem_mode_type;
	signal data_addr : std_logic_vector(xlen_range);
	signal data_in : std_logic_vector(xlen_range);
	signal d_bus_miso : d_bus_miso_rec;
	signal d_bus_mosi : d_bus_mosi_rec;
	signal data_out : std_logic_vector(xlen_range);
	signal ready : std_logic;
begin

    DUT : entity work.data_control
		port map(
			clock => clock,
			reset_n => reset_n,
			enable => enable,
			mode => mode,
			data_addr => data_addr,
			data_in => data_in,
			d_bus_in => d_bus_miso,
			d_bus_out => d_bus_mosi,
			data_out => data_out,
			ready => ready);

    MEM : entity work.mem
        generic map (
            block_count => MEM_BLOCK_COUNT)
        port map (
            clock => clock,
            chip_addr => MEM_BLOCK_ADDR,
            d_bus_in => d_bus_mosi,
            d_bus_out => d_bus_miso,
            i_bus_in => (others => (others => '0')),
            i_bus_out => open);

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
		reset_n <= '0';
		enable <= '0';
		wait for CLOCK_PERIOD;
		reset_n <= '1';
		wait for CLOCK_PERIOD;
		enable <= '1';
		
		-- write bytes
		mode <= m_wb;
		for i in 0 to 7 loop
			data_addr <= si2vec(i, xlen);
			data_in <= si2vec(-i, xlen);
			wait for CLOCK_PERIOD;
		end loop;
		
		-- write half words
		mode <= m_wh;
		for i in 8 to 15 loop
			data_addr <= si2vec(i, xlen);
			data_in <= si2vec(vec2ui(x"44444444") + vec2ui(x"11111111") * (i - 8), xlen);
			wait for CLOCK_PERIOD / 2;
			if (ready = '0') then
				wait for CLOCK_PERIOD;
			end if;
			wait for CLOCK_PERIOD / 2;
		end loop;
		
		-- write words
		mode <= m_ww;
		for i in 16 to 23 loop
			data_addr <= si2vec(i, xlen);
			data_in <= si2vec(vec2ui(x"44444444") + vec2ui(x"11111111") * (i - 16), xlen);
			wait for CLOCK_PERIOD / 2;
			if (ready = '0') then
				wait for CLOCK_PERIOD;
			end if;
			wait for CLOCK_PERIOD / 2;
		end loop;
		
		-- read bytes unsigned
		mode <= m_rbu;
		for i in 0 to 7 loop
			data_addr <= si2vec(i, xlen);
			wait for CLOCK_PERIOD;
		end loop;
		
		-- read bytes signed
		mode <= m_rbs;
		for i in 0 to 7 loop
			data_addr <= si2vec(i, xlen);
			wait for CLOCK_PERIOD;
		end loop;

		-- read half words unsigned
		mode <= m_rhu;
		for i in 8 to 15 loop
			data_addr <= si2vec(i, xlen);
			wait for CLOCK_PERIOD / 2;
			if (ready = '0') then
				wait for CLOCK_PERIOD;
			end if;
			wait for CLOCK_PERIOD / 2;
		end loop;

		-- read half words signed
		mode <= m_rhs;
		for i in 8 to 15 loop
			data_addr <= si2vec(i, xlen);
			wait for CLOCK_PERIOD / 2;
			if (ready = '0') then
				wait for CLOCK_PERIOD;
			end if;
			wait for CLOCK_PERIOD / 2;
		end loop;
		
		-- read words
		mode <= m_rw;
		for i in 16 to 23 loop
			data_addr <= si2vec(i, xlen);
			wait for CLOCK_PERIOD / 2;
			if (ready = '0') then
				wait for CLOCK_PERIOD;
			end if;
			wait for CLOCK_PERIOD / 2;
		end loop;
		
		-- passthrough
		mode <= m_pass;
		for i in 0 to 8 loop
			data_addr <= si2vec(i, xlen);
			data_in <= si2vec(vec2ui(x"44444444") + vec2ui(x"11111111") * (i - 16), xlen);
			wait for CLOCK_PERIOD / 2;
			if (ready = '0') then
				wait for CLOCK_PERIOD;
			end if;
			wait for CLOCK_PERIOD / 2;
		end loop;
		
		-- disable
		enable <= '0';
		wait for CLOCK_PERIOD;

		wait;
	end process;
end tb;
