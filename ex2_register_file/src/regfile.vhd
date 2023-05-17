----------------------------------------------------------------------------------
-- Company: FAU Erlangen - Nuernberg
-- Engineer: Vittorio Serra and Cedric Donges
--
-- Description: register file, double async read, single sync write, reg0 is always 0
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.utils.ALL;

entity regfile is
    Generic(
        port_width : positive := 32;
        reg_count : positive := 32);
    Port(
        clock, reset_n, w_enable : IN std_logic;
        r1_select, r2_select, w_select : IN std_logic_vector(get_bit_count(reg_count) - 1 downto 0);
        r1_value, r2_value : OUT std_logic_vector(port_width - 1 downto 0);
        w_value : IN std_logic_vector(port_width - 1 downto 0));
end regfile;

architecture bh of regfile is
    type t_reg is array (reg_count - 1 downto 0) of std_logic_vector(port_width - 1 downto 0);
    signal reg : t_reg := (others => (others => '0'));
begin
    r1_value <= reg(to_integer(unsigned(r1_select)));
    r2_value <= reg(to_integer(unsigned(r2_select)));

    process(clock)
    begin
        if (reset_n = '0') then
            reg <= (others => (others => '0'));
        elsif (rising_edge(clock) and w_enable = '1' and unsigned(w_select) /= 0) then
            reg(to_integer(unsigned(w_select))) <= w_value;  
        end if;
    end process;
end bh;
