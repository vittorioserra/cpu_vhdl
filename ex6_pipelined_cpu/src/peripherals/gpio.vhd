----------------------------------------------------------------------------------
-- Company: FAU Erlangen - Nuernberg
-- Engineer: Cedric Donges and Vittorio Serra
--
-- Description: GPIO module for CPU
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.utils.ALL;
use work.rv32i_defs.ALL;

entity gpio is
    Port(
        clock : IN std_logic;
        chip_addr : IN std_logic_vector(addr_range);
        d_bus_in : IN d_bus_mosi_rec;
        d_bus_out : OUT d_bus_miso_rec;
        input : IN std_logic_vector(xlen_range);
        output : OUT std_logic_vector(xlen_range));
end gpio;

architecture bh of gpio is
begin
    process(clock)
    begin
        if (rising_edge(clock)) then
            if (is_selected(chip_addr, d_bus_in.addr)) then
                d_bus_out.data <= input;
                for i in d_bus_in.write_enable'range loop
                    if (d_bus_in.write_enable(i) = '1') then
                        output(i * 8 + 7 downto i * 8) <= d_bus_in.data(i * 8 + 7 downto i * 8);
                    end if;
                end loop;
            else
                d_bus_out.data <= (others => '0');
            end if;
        end if;
    end process;
end bh;
