----------------------------------------------------------------------------------
-- Company: FAU Erlangen - Nuernberg
-- Engineer: Vittorio Serra and Cedric Donges
--
-- Description: testbench for fetch unit
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.utils.ALL;
use work.rv32i_defs.ALL;

entity fetch_unit_tb is
end fetch_unit_tb;

architecture tb of fetch_unit_tb is
    constant CLOCK_PERIOD   : time := 10 ns;
    signal clock            : std_logic;
	
    constant MEM_INIT_FILE      : string := "../src/fetch_unit_tb_testcode.o";
    constant PC_OF_ENTRY        : std_logic_vector(xlen_range) := (others => '0');
    
    
    signal enable, reset_n  : std_logic;
    signal i_bus_miso       : i_bus_miso_rec;
    signal i_bus_mosi       : i_bus_mosi_rec;
    signal jump_enable      : std_logic;
    signal jump_target      : std_logic_vector(xlen_range);
    signal pc_now           : std_logic_vector(xlen_range);
    signal pc_next          : std_logic_vector(xlen_range);
    signal instr            : std_logic_vector(instr_range);
    signal ready            : std_logic;
begin
    DUT : entity work.fetch_unit
        generic map (
            pc_of_entry => PC_OF_ENTRY)
        port map (
            clock => clock,
            enable => enable,
            reset_n => reset_n,
            i_bus_in => i_bus_miso,
            i_bus_out => i_bus_mosi,
            jump_enable => jump_enable,
            jump_target => jump_target,
            pc_now => pc_now,
            pc_next => pc_next,
            instr => instr,
            ready => ready);

    MEM : entity work.mem
        generic map (
            mem_init_file => MEM_INIT_FILE)
        port map (
            clock => clock,
            d_bus_in => (others => (others => '0')),
            d_bus_out => open,
            i_bus_in => i_bus_mosi,
            i_bus_out => i_bus_miso);

    gen_clk : process
    begin
        clock <= '0';
        wait for CLOCK_PERIOD / 2;
        clock <= '1';
        wait for CLOCK_PERIOD / 2;
    end process;

    stimuli : process
    begin
        -- reset to entry point
        reset_n <= '0';
        enable <= '1';
        wait for CLOCK_PERIOD;
        
        -- test fetch
        reset_n <= '1';
		for i in 0 to 40 loop
			wait for CLOCK_PERIOD;
		end loop;
        
        -- jump to entry point and test fetch
        jump_enable <= '1';
        jump_target <= PC_OF_ENTRY;
        wait for CLOCK_PERIOD;
        jump_enable <= '0';
		for i in 0 to 30 loop
			wait for CLOCK_PERIOD;
		end loop;
        
        -- jump to aligned 32 bit instruction and test fetch
        jump_enable <= '1';
        jump_target <= x"0000003c";
        wait for CLOCK_PERIOD;
        jump_enable <= '0';
		for i in 0 to 7 loop
			wait for CLOCK_PERIOD;
		end loop;
        
        -- jump to 16 bit instruction and test fetch
        jump_enable <= '1';
        jump_target <= x"00000008";
        wait for CLOCK_PERIOD;
        jump_enable <= '0';
		for i in 0 to 7 loop
			wait for CLOCK_PERIOD;
		end loop;
        
        -- jump to misaligned 32 bit instruction and test fetch
        jump_enable <= '1';
        jump_target <= x"00000016";
        wait for CLOCK_PERIOD;
        jump_enable <= '0';
		for i in 0 to 7 loop
			wait for CLOCK_PERIOD;
		end loop;
        
        wait;

    end process;
end tb;