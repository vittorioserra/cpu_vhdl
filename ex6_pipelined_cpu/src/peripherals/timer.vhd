----------------------------------------------------------------------------------
-- Company: FAU Erlangen - Nuernberg
-- Engineer: Cedric Donges and Vittorio Serra
--
-- Description: 64 bit timer counter for CPU
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.utils.ALL;
use work.rv32i_defs.ALL;

entity timer is
    Generic(
        chip_addr : std_logic_vector(xlen_range));
    Port(
        clock : IN std_logic;
        d_bus_in : IN d_bus_mosi_rec;
        d_bus_out : OUT d_bus_miso_rec);
end timer;

architecture bh of timer is
    constant chip_addr_high : std_logic_vector(xlen_range) := std_logic_vector(unsigned(chip_addr) + 4);
    signal counter : std_logic_vector(63 downto 0) := (others => '0');
begin
    -- check if the chip_addr is aligned with 4
    assert vec2ui(chip_addr(addr_range'low - 1 downto 0)) = 0 report "timer origin must be aligned with 4 bytes" severity FAILURE;

    process(clock)
    begin
        if (rising_edge(clock)) then
            counter <= std_logic_vector(unsigned(counter) + 1);
            if (is_selected(chip_addr(addr_range), d_bus_in.addr)) then
                d_bus_out.data <= counter(31 downto 0);
                for i in d_bus_in.write_enable'range loop
                    if (d_bus_in.write_enable(i) = '1') then
                        counter(i * 8 + 7 downto i * 8) <= d_bus_in.data(i * 8 + 7 downto i * 8);
                    end if;
                end loop;
            elsif (is_selected(chip_addr_high(addr_range), d_bus_in.addr)) then
                d_bus_out.data <= counter(63 downto 32);
                for i in d_bus_in.write_enable'range loop
                    if (d_bus_in.write_enable(i) = '1') then
                        counter(32 + i * 8 + 7 downto 32 + i * 8) <= d_bus_in.data(i * 8 + 7 downto i * 8);
                    end if;
                end loop;
            else
                d_bus_out.data <= (others => '0');
            end if;
        end if;
    end process;
end bh;
