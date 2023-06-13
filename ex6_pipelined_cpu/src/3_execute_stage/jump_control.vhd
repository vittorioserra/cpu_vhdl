----------------------------------------------------------------------------------
-- Company:     FAU Erlangen - Nuernberg
-- Engineer:    Cedric Donges and Vittorio Serra
--
-- Description: Calculates Jump/Branch targets and enables the jump if condition is met.
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.utils.ALL;
use work.rv32i_defs.ALL;

entity jump_control is
    Port(
        clock, reset_n, enable : IN std_logic;
        jump_condition : IN std_logic;
        jump_base, jump_offset : IN std_logic_vector(xlen_range);
        jump_mode : IN jump_mode_type;
        jump_enable : OUT std_logic;
        jump_target : OUT std_logic_vector(xlen_range));
end jump_control;

architecture bh of jump_control is
    signal jump_base_reg : IN std_logic_vector(xlen_range);
    signal jump_offset_reg : IN std_logic_vector(xlen_range);
    signal jump_mode_reg : IN jump_mode_type;
begin
    INPUT_REGISTER : process (clock)
    begin
        if (rising_edge(clock)) then
            if (reset_n = '0') then
                jump_base_reg <= (others => '0');
                jump_offset_reg <= (others => '0');
                jump_mode_reg <= jump_none;
            elsif (enable = '1') then
                jump_base_reg <= jump_base;
                jump_offset_reg <= jump_offset;
                jump_mode_reg <= jump_mode;
            end if;
        end if;
    end process;
    
    LOGIC : process (jump_base_reg, jump_offset_reg, jump_mode_reg, jump_condition)
    begin
        jump_target <= std_logic_vector(unsigned(jump_base_reg) + unsigned(jump_offset_reg));
        case jump_mode_reg is
            when jump_none =>
                jump_enable <= '0';
            when jump_branch =>
                jump_enable <= jump_condition;
            when jump_branch_n =>
                jump_enable <= not jump_condition;
            when jump_definitive =>
                jump_enable <= '1';
        end case;
    end process;
end bh;
