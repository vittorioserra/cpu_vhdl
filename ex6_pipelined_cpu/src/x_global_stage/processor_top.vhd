----------------------------------------------------------------------------------
-- Company: FAU Erlangen - Nuernberg
-- Engineer: Cedric Donges and Vittorio Serra
--
-- Description: Top Entity of the pipelined RISC-V CPU connected with memory and IO.
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.utils.ALL;
use work.rv32i_defs.ALL;

entity processor_top is
    Generic(
        project_path : string);
    Port(
        clock : IN std_logic;
        switch : IN std_logic_vector(7 downto 0);
        leds : OUT std_logic_vector(7 downto 0));
end processor_top;

architecture bh of processor_top is
    constant pc_of_entry : std_logic_vector(xlen_range) := si2vec(0, xlen);

    constant ram_init_file : string := "../src/x_software/test_i.hex";
    constant ram_chip_addr : std_logic_vector(xlen_range) := x"00000000";
    constant ram_block_count : positive := 512;
    
    constant gpio_chip_addr : std_logic_vector(xlen_range) := x"77770000";
    signal gpio_input : std_logic_vector(xlen_range);
    signal gpio_output : std_logic_vector(xlen_range);

    signal i_bus_miso : i_bus_miso_rec;
    signal i_bus_mosi : i_bus_mosi_rec;
    signal d_bus_miso, ram_d_bus_out, gpio_d_bus_out : d_bus_miso_rec;
    signal d_bus_mosi : d_bus_mosi_rec;
begin
    gpio_input <= (31 downto 8 => '0') & switch;
    leds <= gpio_output(7 downto 0);
    d_bus_miso.data <= ram_d_bus_out.data or gpio_d_bus_out.data;

    CPU : entity work.pipelined_cpu
        generic map(
            pc_of_entry => pc_of_entry)
        port map(
            clock => clock,
            reset_n => switch(0),
            i_bus_miso => i_bus_miso,
            i_bus_mosi => i_bus_mosi,
            d_bus_miso => d_bus_miso,
            d_bus_mosi => d_bus_mosi);
            
    RAM : entity work.mem
        generic map(
            block_count => ram_block_count,
            project_path => project_path,
            mem_init_file => ram_init_file)
        port map(
            clock => clock,
            chip_addr => slice_chip_addr(ram_chip_addr(addr_range), ram_block_count),
            d_bus_in => d_bus_mosi,
            d_bus_out => ram_d_bus_out,
            i_bus_in => i_bus_mosi,
            i_bus_out => i_bus_miso);
            
    GPIO : entity work.gpio
        port map(
            clock => clock,
            chip_addr => gpio_chip_addr(addr_range),
            d_bus_in => d_bus_mosi,
            d_bus_out => gpio_d_bus_out,
            input => gpio_input,
            output => gpio_output);
end bh;
