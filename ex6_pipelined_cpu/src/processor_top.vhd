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
        project_path : string;
        debounce : boolean := true);
    Port(
        clock : IN std_logic;
        switch : IN std_logic_vector(7 downto 0);
        leds : OUT std_logic_vector(7 downto 0);
        btn_c, btn_d, btn_l, btn_r, btn_u : IN std_logic);
end processor_top;

architecture bh of processor_top is
    constant pc_of_entry : std_logic_vector(xlen_range) := x"00000000";

    constant ram_init_file : string := "../src/software/bootloader/bootloader.hex";
    constant ram_chip_addr : std_logic_vector(xlen_range) := x"00000000";
    constant ram_block_count : positive := 4096;
    
    constant gpio_chip_addr : std_logic_vector(xlen_range) := x"77770000";
    signal gpio_input : std_logic_vector(xlen_range);
    signal gpio_output : std_logic_vector(xlen_range);
    
    constant timer_chip_addr : std_logic_vector(xlen_range) := x"CCCC0000";

    signal i_bus_miso : i_bus_miso_rec;
    signal i_bus_mosi : i_bus_mosi_rec;
    signal d_bus_miso, ram_d_bus_out, gpio_d_bus_out, timer_d_bus_out : d_bus_miso_rec;
    signal d_bus_mosi : d_bus_mosi_rec;

    signal deb_switch : std_logic_vector(7 downto 0);
    signal deb_btn_c, deb_btn_d, deb_btn_l, deb_btn_r, deb_btn_u : std_logic;

    signal virtual_clock : std_logic;
begin
    gpio_input <= (31 downto 13 => '0') & deb_btn_c & deb_btn_d & deb_btn_l & deb_btn_r & deb_btn_u & deb_switch;
    leds <= gpio_output(7 downto 0);
    d_bus_miso.data <= ram_d_bus_out.data or gpio_d_bus_out.data or timer_d_bus_out.data;

    CPU : entity work.pipelined_cpu
        generic map(
            pc_of_entry => pc_of_entry)
        port map(
            clock => virtual_clock,
            reset_n => deb_switch(0),
            i_bus_miso => i_bus_miso,
            i_bus_mosi => i_bus_mosi,
            d_bus_miso => d_bus_miso,
            d_bus_mosi => d_bus_mosi);
            
    RAM : entity work.mem
        generic map(
            project_path => project_path,
            mem_init_file => ram_init_file,
            chip_addr => ram_chip_addr,
            block_count => ram_block_count)
        port map(
            clock => virtual_clock,
            d_bus_in => d_bus_mosi,
            d_bus_out => ram_d_bus_out,
            i_bus_in => i_bus_mosi,
            i_bus_out => i_bus_miso);
            
    GPIO : entity work.gpio
        generic map(
            chip_addr => gpio_chip_addr)
        port map(
            clock => virtual_clock,
            d_bus_in => d_bus_mosi,
            d_bus_out => gpio_d_bus_out,
            input => gpio_input,
            output => gpio_output);
            
    TIMER : entity work.timer
        generic map(
            chip_addr => timer_chip_addr)
        port map(
            clock => virtual_clock,
            d_bus_in => d_bus_mosi,
            d_bus_out => timer_d_bus_out);
            
    DEB : entity work.debouncer
        generic map(
            port_width => 13,
            stable_count => sel(debounce, 100000, 0)) -- 1 ms @ 100 MHz
        port map(
            clock => virtual_clock,
            input(12) => btn_c,
            input(11) => btn_d,
            input(10) => btn_l,
            input(9) => btn_r,
            input(8) => btn_u,
            input(7 downto 0) => switch,
            output(12) => deb_btn_c,
            output(11) => deb_btn_d,
            output(10) => deb_btn_l,
            output(9) => deb_btn_r,
            output(8) => deb_btn_u,
            output(7 downto 0) => deb_switch);
    
    virtual_clock <= clock;
    --MMCM : entity work.clk_wiz_0
    --    port map(
    --        clk_in1 => clock,
    --        clk_out1 => virtual_clock);
end bh;
