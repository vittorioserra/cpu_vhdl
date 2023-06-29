----------------------------------------------------------------------------------
-- Company: FAU Erlangen - Nuernberg
-- Engineer: Cedric Donges and Vittorio Serra
--
-- Description: Main Entity of the pipelined RISC-V CPU.
--              Contains all 5 stages and control.
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.utils.ALL;
use work.rv32i_defs.ALL;

entity pipelined_cpu is
    Generic(
        pc_of_entry : std_logic_vector(xlen_range));
    Port(
        clock, reset_n : IN std_logic;

        i_bus_miso : IN i_bus_miso_rec;
        i_bus_mosi : OUT i_bus_mosi_rec;
        d_bus_miso : IN d_bus_miso_rec;
        d_bus_mosi : OUT d_bus_mosi_rec);
end pipelined_cpu;

architecture bh of pipelined_cpu is
    signal fe_reset_n, de_reset_n, ex_reset_n, me_reset_n, wb_reset_n : std_logic;
    signal fe_enable, de_enable, ex_enable, me_enable, wb_enable : std_logic;
    signal fe_ready, de_ready, ex_ready, me_ready, wb_ready : std_logic;

    signal fe_de_pc_now : std_logic_vector(xlen_range);
    signal fe_de_pc_next : std_logic_vector(xlen_range);
    signal fe_de_instr : std_logic_vector(instr_range);

    signal de_ex_func : ex_func_type;
    signal de_ex_op1_value : std_logic_vector(xlen_range);
    signal de_ex_op2_value : std_logic_vector(xlen_range);
    signal de_ex_addr_base_value : std_logic_vector(xlen_range);
    signal de_ex_addr_offset : std_logic_vector(xlen_range);
    signal de_ex_jump_mode : jump_mode_type;
    signal de_ex_rd_select : std_logic_vector(reg_range);
    signal de_ex_mem_mode : mem_mode_type;
    signal de_wb_rs1_select : std_logic_vector(reg_range);
    signal de_wb_rs2_select : std_logic_vector(reg_range);

    signal ex_me_data : std_logic_vector(xlen_range);
    signal ex_me_addr : std_logic_vector(xlen_range);
    signal ex_me_mem_mode : mem_mode_type;
    signal ex_me_rd_select : std_logic_vector(reg_range);
    signal ex_fe_jump_enable : std_logic;
    signal ex_fe_jump_target : std_logic_vector(xlen_range);

    signal me_wb_rd_value : std_logic_vector(xlen_range);
    signal me_wb_rd_select : std_logic_vector(reg_range);

    signal wb_de_rs1_value : std_logic_vector(xlen_range);
    signal wb_de_rs2_value : std_logic_vector(xlen_range);
begin

    CONTROL : entity work.pipeline_control
        port map(
            reset_n => reset_n,
            jump_enable => ex_fe_jump_enable,
            fe_ready => fe_ready,
            de_ready => de_ready,
            ex_ready => ex_ready,
            me_ready => me_ready,
            wb_ready => wb_ready,
            fe_reset_n => fe_reset_n,
            de_reset_n => de_reset_n,
            ex_reset_n => ex_reset_n,
            me_reset_n => me_reset_n,
            wb_reset_n => wb_reset_n,
            fe_enable => fe_enable,
            de_enable => de_enable,
            ex_enable => ex_enable,
            me_enable => me_enable,
            wb_enable => wb_enable);

    FETCH : entity work.fetch_stage
        generic map(
            pc_of_entry => pc_of_entry)
        port map(
            clock => clock,
            reset_n => fe_reset_n,
            enable => fe_enable,
            ready => fe_ready,
            i_bus_miso => i_bus_miso,
            i_bus_mosi => i_bus_mosi,
            ex_jump_enable => ex_fe_jump_enable,
            ex_jump_target => ex_fe_jump_target,
            de_pc_now => fe_de_pc_now,
            de_pc_next => fe_de_pc_next,
            de_instr => fe_de_instr);

    DECODE : entity work.decode_stage
        port map(
            clock => clock,
            reset_n => de_reset_n,
            enable => de_enable,
            ready => de_ready,
            fe_instr => fe_de_instr,
            fe_pc_now => fe_de_pc_now,
            fe_pc_next => fe_de_pc_next,
            ex_func => de_ex_func,
            ex_op1_value => de_ex_op1_value,
            ex_op2_value => de_ex_op2_value,
            ex_addr_base_value => de_ex_addr_base_value,
            ex_addr_offset => de_ex_addr_offset,
            ex_jump_mode => de_ex_jump_mode,
            ex_rd_select => de_ex_rd_select,
            ex_mem_mode => de_ex_mem_mode,
            wb_rs1_select => de_wb_rs1_select,
            wb_rs2_select => de_wb_rs2_select,
            wb_rs1_value => wb_de_rs1_value,
            wb_rs2_value => wb_de_rs2_value,
            ex_me_mem_mode => ex_me_mem_mode,
            ex_me_rd_select => ex_me_rd_select,
            ex_me_rd_value => ex_me_data,
            me_wb_rd_select => me_wb_rd_select,
            me_wb_rd_value => me_wb_rd_value);

    EXECUTE : entity work.execute_stage
        port map(
            clock => clock,
            reset_n => ex_reset_n,
            enable => ex_enable,
            ready => ex_ready,
            de_func => de_ex_func,
            de_op1_value => de_ex_op1_value,
            de_op2_value => de_ex_op2_value,
            de_addr_base_value => de_ex_addr_base_value,
            de_addr_offset => de_ex_addr_offset,
            de_jump_mode => de_ex_jump_mode,
            de_mem_mode => de_ex_mem_mode,
            de_rd_select => de_ex_rd_select,
            me_data => ex_me_data,
            me_addr => ex_me_addr,
            me_mem_mode => ex_me_mem_mode,
            me_rd_select => ex_me_rd_select,
            fe_jump_enable => ex_fe_jump_enable,
            fe_jump_target => ex_fe_jump_target);
            
    MEMORY : entity work.memory_stage
        port map(
            clock => clock,
            reset_n => me_reset_n,
            enable => me_enable,
            ready => me_ready,
            ex_mem_mode => ex_me_mem_mode,
            ex_data => ex_me_data,
            ex_addr => ex_me_addr,
            ex_rd_select => ex_me_rd_select,
            d_bus_miso => d_bus_miso,
            d_bus_mosi => d_bus_mosi,
            wb_rd_value => me_wb_rd_value,
            wb_rd_select => me_wb_rd_select);

    WRITEBACK : entity work.writeback_stage
        port map(
            clock => clock,
            reset_n => wb_reset_n,
            enable => wb_enable,
            ready => wb_ready,
            me_rd_select => me_wb_rd_select,
            me_rd_value => me_wb_rd_value,
            de_rs1_select => de_wb_rs1_select,
            de_rs2_select => de_wb_rs2_select,
            de_rs1_value => wb_de_rs1_value,
            de_rs2_value => wb_de_rs2_value);
end bh;
