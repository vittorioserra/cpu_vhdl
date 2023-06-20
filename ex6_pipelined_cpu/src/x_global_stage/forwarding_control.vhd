----------------------------------------------------------------------------------
-- Company: FAU Erlangen - Nuernberg
-- Engineer: Cedric Donges and Vittorio Serra
--
-- Description: Forwards source register values from ex and mem stage to dec stage.
--              Stalls if the value comes from memory but its in address phase.
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.rv32i_defs.ALL;

entity forwarding_control is
    Port(
        de_rs1_select : IN std_logic_vector(reg_range);
        de_rs2_select : IN std_logic_vector(reg_range);

        ex_rd_select : IN std_logic_vector(reg_range);
        ex_mem_mode : IN mem_mode_type;
        ex_rd_value : IN std_logic_vector(xlen_range);
        me_rd_select : IN std_logic_vector(reg_range);
        me_rd_value : IN std_logic_vector(xlen_range);
        
        wb_rs1_value : IN std_logic_vector(xlen_range);
        wb_rs2_value : IN std_logic_vector(xlen_range);
        wb_rs1_select : OUT std_logic_vector(reg_range);
        wb_rs2_select : OUT std_logic_vector(reg_range);

        de_rs1_value : OUT std_logic_vector(xlen_range);
        de_rs2_value : OUT std_logic_vector(xlen_range);
        ready : OUT std_logic);
end forwarding_control;

architecture bh of forwarding_control is
begin
    process (de_rs1_select, de_rs2_select, ex_rd_select, ex_mem_mode, ex_rd_value, me_rd_select, me_rd_value, wb_rs1_value, wb_rs2_value)
    begin
        wb_rs1_select <= de_rs1_select;
        wb_rs2_select <= de_rs2_select;

        ready <= '1';
        -- forwarding logic for rs1
        if (de_rs1_select = reg_zero) then
            -- value from zero register
            de_rs1_value <= wb_rs1_value;
        elsif (de_rs1_select = ex_rd_select and ex_mem_mode = m_pass) then
            -- value in ex stage
            de_rs1_value <= ex_rd_value;
        elsif (de_rs1_select = ex_rd_select and ex_mem_mode /= m_pass) then
            -- value from memory but its in address phase: not ready
            de_rs1_value <= me_rd_value;
            ready <= '0';
        elsif (de_rs1_select = me_rd_select) then
            -- value from memory
            de_rs1_value <= me_rd_value;
        else
            -- no forwarding needed
            de_rs1_value <= wb_rs1_value;
        end if;

        -- forwarding logic for rs2
        if (de_rs2_select = reg_zero) then
            -- value from zero register
            de_rs2_value <= wb_rs2_value;
        elsif (de_rs2_select = ex_rd_select and ex_mem_mode = m_pass) then
            -- value in ex stage
            de_rs2_value <= ex_rd_value;
        elsif (de_rs2_select = ex_rd_select and ex_mem_mode /= m_pass) then
            -- value from memory but its in address phase: not ready
            de_rs2_value <= me_rd_value;
            ready <= '0';
        elsif (de_rs2_select = me_rd_select) then
            -- value from memory
            de_rs2_value <= me_rd_value;
        else
            -- no forwarding needed
            de_rs2_value <= wb_rs2_value;
        end if;
    end process;
end bh;