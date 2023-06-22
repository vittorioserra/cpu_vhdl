----------------------------------------------------------------------------------
-- Company: FAU Erlangen - Nuernberg
-- Engineer: Cedric Donges and Vittorio Serra
--
-- Description: Writeback stage of the pipelined CPU.
--              Contains the register file.
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.utils.ALL;
use work.rv32i_defs.ALL;

entity writeback_stage is
    Port(
        clock, reset_n, enable : IN std_logic;
        ready : OUT std_logic;
        
        me_rd_select : IN std_logic_vector(reg_range);
        me_rd_value : IN std_logic_vector(xlen_range);

        de_rs1_select : IN std_logic_vector(reg_range);
        de_rs2_select : IN std_logic_vector(reg_range);
        de_rs1_value : OUT std_logic_vector(xlen_range);
        de_rs2_value : OUT std_logic_vector(xlen_range));
end writeback_stage;

architecture bh of writeback_stage is
begin
    ready <= '1';

    REG : entity work.regfile
        generic map(
            reg_count => reg_count)
        port map(
            clock => clock,
            reset_n => reset_n,
            rd_write_enable => enable,
            rs1_select => de_rs1_select,
            rs2_select => de_rs2_select,
            rd_select => me_rd_select,
            rs1_value => de_rs1_value,
            rs2_value => de_rs2_value,
            rd_value => me_rd_value);
end bh;
