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
use work.rv32i_defs.ALL;

entity regfile is
    Generic(
        reg_count : positive := 32);
    Port(
        clock, reset_n, rd_write_enable : IN std_logic;
        rs1_select, rs2_select, rd_select : IN std_logic_vector(reg_range);
        rs1_value, rs2_value : OUT std_logic_vector(xlen_range);
        rd_value : IN std_logic_vector(xlen_range));
end regfile;

architecture bh of regfile is
    type reg_t is array (reg_count - 1 downto 0) of std_logic_vector(xlen_range);
    signal reg : reg_t := (others => (others => '0'));
begin
    rs1_value <= reg(vec2ui(rs1_select));
    rs2_value <= reg(vec2ui(rs2_select));

    process(clock)
    begin
        if (rising_edge(clock)) then
            if (reset_n = '0') then
                reg <= (others => (others => '0'));
            elsif (rd_write_enable = '1' and rd_select /= reg_zero) then
                reg(to_integer(unsigned(rd_select))) <= rd_value;  
            end if;
        end if;
    end process;
end bh;
