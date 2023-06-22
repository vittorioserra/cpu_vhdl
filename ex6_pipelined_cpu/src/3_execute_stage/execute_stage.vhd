----------------------------------------------------------------------------------
-- Company: FAU Erlangen - Nuernberg
-- Engineer: Cedric Donges and Vittorio Serra
--
-- Description: Execute stage of the pipelined CPU.
--              Contains the address_jump_control and alu.
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.utils.ALL;
use work.rv32i_defs.ALL;

entity execute_stage is
    Port(
        clock, reset_n, enable : IN std_logic;
        ready : OUT std_logic;

        de_func : IN ex_func_type;
        de_op1_value : IN std_logic_vector(xlen_range);
        de_op2_value : IN std_logic_vector(xlen_range);
        de_addr_base_value : IN std_logic_vector(xlen_range);
        de_addr_offset : IN std_logic_vector(xlen_range);
        de_jump_mode : IN jump_mode_type;
        de_mem_mode : IN mem_mode_type;
        de_rd_select : IN std_logic_vector(reg_range);

        me_data : OUT std_logic_vector(xlen_range);
        me_addr : OUT std_logic_vector(xlen_range);
        me_mem_mode : OUT mem_mode_type;
        me_rd_select : OUT std_logic_vector(reg_range);

        fe_jump_enable : OUT std_logic;
        fe_jump_target : OUT std_logic_vector(xlen_range));
end execute_stage;

architecture bh of execute_stage is
    signal alu_result : std_logic_vector(xlen_range);
    signal ajc_addr : std_logic_vector(xlen_range);
begin
    ready <= '1';
    me_data <= alu_result;
    me_addr <= ajc_addr;
    fe_jump_target <= ajc_addr;

    INPUT_REGISTER : process (clock)
    begin
        if (rising_edge(clock)) then
            if (reset_n = '0') then
                me_mem_mode  <= m_pass;
                me_rd_select <= reg_zero;
            elsif (enable = '1') then
                me_mem_mode  <= de_mem_mode;
                me_rd_select <= de_rd_select;
            end if;
        end if;
    end process;

    ALU : entity work.alu
        port map(
            clock => clock,
            reset_n => reset_n,
            enable => enable,
            func => de_func,
            op1 => de_op1_value,
            op2 => de_op2_value,
            res => alu_result);

    AJC : entity work.addr_jump_control
        port map(
            clock => clock,
            reset_n => reset_n,
            enable => enable,
            jump_condition => alu_result(0),
            jump_mode => de_jump_mode,
            jump_enable => fe_jump_enable,
            addr_base => de_addr_base_value,
            addr_offset => de_addr_offset,
            addr_target => ajc_addr);
end bh;
