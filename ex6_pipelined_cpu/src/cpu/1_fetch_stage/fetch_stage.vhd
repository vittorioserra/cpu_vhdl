----------------------------------------------------------------------------------
-- Company: FAU Erlangen - Nuernberg
-- Engineer: Cedric Donges and Vittorio Serra
--
-- Description: Fetch stage of the pipelined CPU.
--              Contains the fetch unit.
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.utils.ALL;
use work.rv32i_defs.ALL;

entity fetch_stage is
    Generic (
        pc_of_entry : std_logic_vector(xlen_range));
    Port(
        clock, reset_n, enable : IN std_logic;
        ready : OUT std_logic;

        i_bus_miso : IN i_bus_miso_rec;
        i_bus_mosi : OUT i_bus_mosi_rec;

		ex_jump_enable : IN std_logic;
		ex_jump_target : IN std_logic_vector(xlen_range);

		de_pc_now : OUT std_logic_vector(xlen_range);
		de_pc_next : OUT std_logic_vector(xlen_range);
        de_instr : OUT std_logic_vector(instr_range));
end fetch_stage;

architecture bh of fetch_stage is
begin
    FU : entity work.fetch_unit
        generic map (
            pc_of_entry => pc_of_entry)
        port map (
            clock => clock,
            enable => enable,
            reset_n => reset_n,
            i_bus_in => i_bus_miso,
            i_bus_out => i_bus_mosi,
            jump_enable => ex_jump_enable,
            jump_target => ex_jump_target,
            pc_now => de_pc_now,
            pc_next => de_pc_next,
            instr => de_instr,
            ready => ready);
end bh;
