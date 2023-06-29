----------------------------------------------------------------------------------
-- Company: FAU Erlangen - Nuernberg
-- Engineer: Cedric Donges and Vittorio Serra
--
-- Description: Memory stage of the pipelined CPU.
--              Contains the data control unit to access memory.
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.utils.ALL;
use work.rv32i_defs.ALL;

entity memory_stage is
    Port(
        clock, reset_n, enable : IN std_logic;
        ready : OUT std_logic;
        
        ex_mem_mode : IN mem_mode_type;
        ex_data : IN std_logic_vector(xlen_range);
        ex_addr : IN std_logic_vector(xlen_range);
        ex_rd_select : IN std_logic_vector(reg_range);

        d_bus_miso : IN d_bus_miso_rec;
        d_bus_mosi : OUT d_bus_mosi_rec;

        wb_rd_value : OUT std_logic_vector(xlen_range);
        wb_rd_select : OUT std_logic_vector(reg_range));
end memory_stage;

architecture bh of memory_stage is
    signal ex_rd_select_reg : std_logic_vector(reg_range);
    signal dc_ready : std_logic;
begin
    ready <= dc_ready;
    wb_rd_select <= sel(dc_ready = '1', ex_rd_select_reg, reg_zero);
    
    INPUT_REGISTER : process (clock)
    begin
        if (rising_edge(clock)) then
            if (reset_n = '0') then
                ex_rd_select_reg <= reg_zero;
            elsif (enable = '1') then
                ex_rd_select_reg <= ex_rd_select;
            end if;
        end if;
    end process;

    DC : entity work.data_control
        port map(
            clock => clock,
            reset_n => reset_n,
            enable => enable,
            mode => ex_mem_mode,
            data_addr => ex_addr,
            data_in => ex_data,
            d_bus_in => d_bus_miso,
            d_bus_out => d_bus_mosi,
            data_out => wb_rd_value,
            ready => dc_ready);
end bh;
