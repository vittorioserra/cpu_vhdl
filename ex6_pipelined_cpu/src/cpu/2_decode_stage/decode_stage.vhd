----------------------------------------------------------------------------------
-- Company: FAU Erlangen - Nuernberg
-- Engineer: Cedric Donges and Vittorio Serra
--
-- Description: Decode stage of the pipelined CPU.
--              Contains the decoder and forwarding logic.
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.utils.ALL;
use work.rv32i_defs.ALL;

entity decode_stage is
    Port(
        clock, reset_n, enable : IN std_logic;
        ready : OUT std_logic;

        fe_instr : IN std_logic_vector(instr_range);
        fe_pc_now : IN std_logic_vector(xlen_range);
        fe_pc_next : IN std_logic_vector(xlen_range);
        
        ex_func : OUT ex_func_type;
        ex_op1_value : OUT std_logic_vector(xlen_range);
        ex_op2_value : OUT std_logic_vector(xlen_range);
        ex_addr_base_value : OUT std_logic_vector(xlen_range);
        ex_addr_offset : OUT std_logic_vector(xlen_range);
        ex_jump_mode : OUT jump_mode_type;
        ex_rd_select : OUT std_logic_vector(reg_range);
        ex_mem_mode : OUT mem_mode_type;
        
        wb_rs1_select : OUT std_logic_vector(reg_range);
        wb_rs2_select : OUT std_logic_vector(reg_range);
        wb_rs1_value : IN std_logic_vector(xlen_range);
        wb_rs2_value : IN std_logic_vector(xlen_range);

        ex_me_mem_mode : IN mem_mode_type;
        ex_me_rd_select : IN std_logic_vector(reg_range);
        ex_me_rd_value : IN std_logic_vector(xlen_range);
        
        me_wb_rd_select : IN std_logic_vector(reg_range);
        me_wb_rd_value : IN std_logic_vector(xlen_range));
end decode_stage;

architecture bh of decode_stage is
    signal fe_pc_now_reg, fe_pc_next_reg : std_logic_vector(xlen_range);
    signal fe_decompr_instr : std_logic_vector(instr_range);
    signal de_enable, de_ready, fwd_ready : std_logic;
    signal de_fwd_rs1_select, de_fwd_rs2_select : std_logic_vector(reg_range);
    signal de_jump_mode : jump_mode_type;
    signal de_rd_select : std_logic_vector(reg_range);
    signal de_mem_mode : mem_mode_type;
    signal de_op1_select : ex_op1_type;
    signal de_op2_select : ex_op2_type;
    signal de_addr_base : addr_base_type;
    signal de_rs1_value, de_rs2_value, de_imm_value : std_logic_vector(xlen_range);
begin
    INPUT_REGISTER : process (clock)
    begin
        if (rising_edge(clock)) then
            if (reset_n = '0') then
                fe_pc_now_reg  <= (others => '0');
                fe_pc_next_reg <= (others => '0');
            elsif (enable = '1') then
                fe_pc_now_reg  <= fe_pc_now;
                fe_pc_next_reg <= fe_pc_next;
            end if;
        end if;
    end process;

    MUX : process (fwd_ready, de_ready, enable, de_jump_mode, de_rd_select, de_mem_mode,
        de_op1_select, de_rs1_value, fe_pc_now_reg, fe_pc_next_reg, de_op2_select, de_rs2_value, de_imm_value, de_addr_base)
    begin
        if (fwd_ready = '0') then
            -- prevent irreversible changes in the following stages if the forwarding is not ready
            ready <= '0';
            de_enable <= '0';
            ex_jump_mode <= j_n;
            ex_rd_select <= reg_zero;
            ex_mem_mode <= m_pass;
        else
            -- normal mode
            ready <= de_ready;
            de_enable <= enable;
            ex_jump_mode <= de_jump_mode;
            ex_rd_select <= de_rd_select;
            ex_mem_mode <= de_mem_mode;
        end if;

        -- execute stage multiplexer
        case de_op1_select is
            when sel_zero => ex_op1_value <= (others => '0');
            when sel_rs1  => ex_op1_value <= de_rs1_value;
            when sel_pc   => ex_op1_value <= fe_pc_now_reg;
            when sel_pc_n => ex_op1_value <= fe_pc_next_reg;
        end case;
        case de_op2_select is
            when sel_rs2  => ex_op2_value <= de_rs2_value;
            when sel_imm  => ex_op2_value <= de_imm_value;
        end case;
        case de_addr_base is
            when sel_rs1  => ex_addr_base_value <= de_rs1_value;
            when sel_pc   => ex_addr_base_value <= fe_pc_now_reg;
        end case;
        ex_addr_offset <= de_imm_value;
    end process;
    
    DCOMPR : entity work.decompressor
        port map(
            instr_in => fe_instr,
            instr_out => fe_decompr_instr);

    DE : entity work.decoder
        port map(
            clock => clock,
            reset_n => reset_n,
            enable => de_enable,
            instr => fe_decompr_instr,
            rs1_select => de_fwd_rs1_select,
            rs2_select => de_fwd_rs2_select,
            imm_value => de_imm_value,
            func => ex_func,
            op1_select => de_op1_select,
            op2_select => de_op2_select,
            addr_base => de_addr_base,
            jump_mode => de_jump_mode,
            rd_select => de_rd_select,
            mem_mode => de_mem_mode,
            ready => de_ready);

    FWD : entity work.forwarding_logic
        port map(
            de_rs1_select => de_fwd_rs1_select,
            de_rs2_select => de_fwd_rs2_select,
            ex_rd_select => ex_me_rd_select,
            ex_mem_mode => ex_me_mem_mode,
            ex_rd_value => ex_me_rd_value,
            me_rd_select => me_wb_rd_select,
            me_rd_value => me_wb_rd_value,
            wb_rs1_value => wb_rs1_value,
            wb_rs2_value => wb_rs2_value,
            wb_rs1_select => wb_rs1_select,
            wb_rs2_select => wb_rs2_select,
            de_rs1_value => de_rs1_value,
            de_rs2_value => de_rs2_value,
            ready => fwd_ready);
end bh;
