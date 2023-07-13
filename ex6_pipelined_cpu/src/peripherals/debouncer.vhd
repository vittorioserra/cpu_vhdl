----------------------------------------------------------------------------------
-- Company: FAU Erlangen - Nuernberg
-- Engineer: Cedric Donges and Vittorio Serra
--
-- Description: Debounce inputs.
--              if stable_count > 1: Let the signal through if it is stable for a given number of cycles.
--              if stable_count = 1: Let the signal through each cycle.
--              if stable_count = 0: Wire the signal through.
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.utils.ALL;

entity debouncer is
    Generic(
        port_width : positive := 1;
        stable_count : natural := 8);
    Port(
        clock : IN std_logic;
        input : IN std_logic_vector(port_width - 1 downto 0);
        output : OUT std_logic_vector(port_width - 1 downto 0));
end debouncer;

architecture bh of debouncer is
    constant counter_width : integer := get_bit_count(sel(stable_count > 0, stable_count, 1));
    type counter_type is array (port_width - 1 downto 0) of unsigned(counter_width - 1 downto 0);

    signal stage1, stage2 : std_logic_vector(port_width - 1 downto 0);
    signal counter : counter_type;
begin
    MODE_NORMAL : if stable_count > 1 generate
        process(clock)
        begin
            if (rising_edge(clock)) then
                stage1 <= input;
                stage2 <= stage1;
                for i in input'range loop
                    if (stage1(i) /= stage2(i)) then
                        counter(i) <= to_unsigned(0, counter_width);
                    else
                        counter(i) <= counter(i) + 1;
                    end if;

                    if (counter(i) = to_unsigned(stable_count, counter_width)) then
                        output(i) <= stage2(i);
                    end if;
                end loop;
            end if;
        end process;
    end generate;

    MODE_REGISTER : if stable_count = 1 generate
        process(clock)
        begin
            if (rising_edge(clock)) then
                output <= input;
            end if;
        end process;
    end generate;
    
    MODE_WIRE : if stable_count = 0 generate
        output <= input;
    end generate;
end bh;
