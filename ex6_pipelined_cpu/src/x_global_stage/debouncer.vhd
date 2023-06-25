----------------------------------------------------------------------------------
-- Company: FAU Erlangen - Nuernberg
-- Engineer: Cedric Donges and Vittorio Serra
--
-- Description: Debounce inputs. Let the signal through if it is stable for a given number of cycles.
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.utils.ALL;

entity debouncer is
    Generic(
        port_width : positive := 1;
        stable_count : integer := 8);
    Port(
        clock : IN std_logic;
        input : IN std_logic_vector(port_width - 1 downto 0);
        output : OUT std_logic_vector(port_width - 1 downto 0));
end debouncer;

architecture bh of debouncer is
    signal stage1, stage2 : std_logic_vector(port_width - 1 downto 0);
    type counter_type is array (port_width - 1 downto 0) of unsigned(get_bit_count(stable_count) - 1 downto 0);
    signal counter : counter_type;
begin
    process(clock)
    begin
        if (rising_edge(clock)) then
            stage1 <= input;
            stage2 <= stage1;
            for i in input'range loop
                if (stage1(i) /= stage2(i)) then
                    counter(i) <= to_unsigned(0, get_bit_count(stable_count));
                else
                    counter(i) <= counter(i) + 1;
                end if;

                if (counter(i) = to_unsigned(stable_count, get_bit_count(stable_count))) then
                    output(i) <= stage2(i);
                end if;
            end loop;
        end if;
    end process;
end bh;
