----------------------------------------------------------------------------------
-- Company: FAU Erlangen - Nuernberg
-- Engineer: Vittorio Serra and Cedric Donges
--
-- Description: Instruction Decoder for RV32IC
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.utils.ALL;
use work.rv32i_defs.ALL;

entity decoder is
    Port(
        clock, reset_n, enable : IN std_logic;

        instr : IN std_logic_vector(instr_range);

        rs1_select : OUT std_logic_vector(reg_range);
        rs2_select : OUT std_logic_vector(reg_range);
        imm_value : OUT std_logic_vector(xlen_range);

        ex_mode : OUT ex_func_type;
        ex_op1_select : OUT ex_op1_type;
        ex_op2_select : OUT ex_op2_type;
        ex_addr_base : OUT addr_base_type;
        ex_jump_mode : OUT jump_mode_type;

        rd_select : OUT std_logic_vector(reg_range);
        mem_mode : OUT mem_mode_type);
end decoder;

architecture bh of decoder is
    signal instr_reg : std_logic_vector(instr_range);
begin
    INPUT_REGISTER : process(clock, reset_n, enable)
    begin
        if (rising_edge(clock)) then
            if (reset_n = '0') then
                instr_reg <= "00000000000000000000000000010011"; -- nop (addi x0, x0, 0)
            elsif (enable = '1') then
                instr_reg <= instr;
            end if;
        end if;
    end process;

    DECODE_LOGIC : process(instr_reg)
        type instr_routing_type is ( -- instr-type op1  op2  addr_base
            u_zero_imm,         -- Upper Immediate zero imm  -
            u_pc_imm,           -- Upper Immediate pc   imm  -
            j_pc_n_zero_pc,     -- Jump            pc   zero pc
            b_rs1_rs2_pc,       -- Branch          rs1  rs2  pc
            s_zero_rs2_rs1,     -- Store           zero rs2  rs1
            r_rs1_rs2,          -- Register        rs1  rs2  -
            i_pc_n_zero_rs1,    -- Immediate       pc_n zero rs1
            i_zero_zero_rs1,    -- Immediate       zero zero rs1
            i_rs1_imm,          -- Immediate       rs1  imm  -
            i_zero_zero);       -- Immediate       zero zero -
        variable ir_type : instr_routing_type;
        alias rs1 : std_logic_vector(reg_range) is rs1_select;
        alias rs2 : std_logic_vector(reg_range) is rs2_select;
        alias imm : std_logic_vector(xlen_range) is imm_value;
        alias e_mode : ex_func_type is ex_mode;
        alias op1 : ex_op1_type is ex_op1_select;
        alias op2 : ex_op2_type is ex_op2_select;
        alias a_base : addr_base_type is ex_addr_base;
        alias j_mode : jump_mode_type is ex_jump_mode;
        alias rd : std_logic_vector(reg_range) is rd_select;
        alias m_mode : mem_mode_type is mem_mode;
    begin
        -- set default values
        j_mode <= j_n;
        m_mode <= m_pass;

        -- decode instructions
        case? instr_reg is
            --   "f7     rs2  rs1  f3 rd   opcode "             imm op1  op2  addr_base
            when "-------------------------0110111" => ir_type := u_zero_imm;      e_mode <= f_add;                   -- LUI
            when "-------------------------0010111" => ir_type := u_pc_imm;        e_mode <= f_add;                   -- AUIPC
            when "-------------------------1101111" => ir_type := j_pc_n_zero_pc;  e_mode <= f_add;  j_mode <= j_y;   -- JAL
            when "-----------------000-----1100111" => ir_type := i_pc_n_zero_rs1; e_mode <= f_add;  j_mode <= j_y;   -- JALR
            when "-----------------000-----1100011" => ir_type := b_rs1_rs2_pc;    e_mode <= f_seq;  j_mode <= j_c;   -- BEQ
            when "-----------------001-----1100011" => ir_type := b_rs1_rs2_pc;    e_mode <= f_seq;  j_mode <= j_c_n; -- BNE
            when "-----------------100-----1100011" => ir_type := b_rs1_rs2_pc;    e_mode <= f_slts; j_mode <= j_c;   -- BLT
            when "-----------------101-----1100011" => ir_type := b_rs1_rs2_pc;    e_mode <= f_slts; j_mode <= j_c_n; -- BGE
            when "-----------------110-----1100011" => ir_type := b_rs1_rs2_pc;    e_mode <= f_sltu; j_mode <= j_c;   -- BLTU
            when "-----------------111-----1100011" => ir_type := b_rs1_rs2_pc;    e_mode <= f_sltu; j_mode <= j_c_n; -- BGEU
            when "-----------------000-----0000011" => ir_type := i_zero_zero_rs1; e_mode <= f_add;  m_mode <= m_rbs; -- LB
            when "-----------------001-----0000011" => ir_type := i_zero_zero_rs1; e_mode <= f_add;  m_mode <= m_rhs; -- LH
            when "-----------------010-----0000011" => ir_type := i_zero_zero_rs1; e_mode <= f_add;  m_mode <= m_rw;  -- LW
            when "-----------------100-----0000011" => ir_type := i_zero_zero_rs1; e_mode <= f_add;  m_mode <= m_rbu; -- LBU
            when "-----------------101-----0000011" => ir_type := i_zero_zero_rs1; e_mode <= f_add;  m_mode <= m_rhu; -- LHU
            when "-----------------000-----0100011" => ir_type := s_zero_rs2_rs1;  e_mode <= f_add;  m_mode <= m_wb;  -- SB
            when "-----------------001-----0100011" => ir_type := s_zero_rs2_rs1;  e_mode <= f_add;  m_mode <= m_wh;  -- SH
            when "-----------------010-----0100011" => ir_type := s_zero_rs2_rs1;  e_mode <= f_add;  m_mode <= m_ww;  -- SW
            when "-----------------000-----0010011" => ir_type := i_rs1_imm;       e_mode <= f_add;                   -- ADDI
            when "-----------------010-----0010011" => ir_type := i_rs1_imm;       e_mode <= f_slts;                  -- SLTI
            when "-----------------011-----0010011" => ir_type := i_rs1_imm;       e_mode <= f_sltu;                  -- SLTIU
            when "-----------------100-----0010011" => ir_type := i_rs1_imm;       e_mode <= f_xor;                   -- XORI
            when "-----------------110-----0010011" => ir_type := i_rs1_imm;       e_mode <= f_or;                    -- ORI
            when "-----------------111-----0010011" => ir_type := i_rs1_imm;       e_mode <= f_and;                   -- ANDI
            when "0000000----------001-----0010011" => ir_type := i_rs1_imm;       e_mode <= f_sll;                   -- SLLI
            when "0000000----------101-----0010011" => ir_type := i_rs1_imm;       e_mode <= f_srl;                   -- SRLI
            when "0100000----------101-----0010011" => ir_type := i_rs1_imm;       e_mode <= f_sra;                   -- SRAI
            when "0000000----------000-----0110011" => ir_type := r_rs1_rs2;       e_mode <= f_add;                   -- ADD
            when "0100000----------000-----0110011" => ir_type := r_rs1_rs2;       e_mode <= f_sub;                   -- SUB
            when "0000000----------001-----0110011" => ir_type := r_rs1_rs2;       e_mode <= f_sll;                   -- SLL
            when "0000000----------010-----0110011" => ir_type := r_rs1_rs2;       e_mode <= f_slts;                  -- SLT
            when "0000000----------011-----0110011" => ir_type := r_rs1_rs2;       e_mode <= f_sltu;                  -- SLTU
            when "0000000----------100-----0110011" => ir_type := r_rs1_rs2;       e_mode <= f_xor;                   -- XOR
            when "0000000----------101-----0110011" => ir_type := r_rs1_rs2;       e_mode <= f_srl;                   -- SRL
            when "0100000----------101-----0110011" => ir_type := r_rs1_rs2;       e_mode <= f_sra;                   -- SRA
            when "0000000----------110-----0110011" => ir_type := r_rs1_rs2;       e_mode <= f_or;                    -- OR
            when "0000000----------111-----0110011" => ir_type := r_rs1_rs2;       e_mode <= f_and;                   -- AND
            when "-----------------000-----0001111" => ir_type := i_zero_zero;     e_mode <= f_add;                   -- FENCE (nop)
            when "-----------------001-----0001111" => ir_type := i_zero_zero;     e_mode <= f_add;                   -- FENCE.I (jump to fence.i handler) TODO jump and save mret, handler should execute some nops and jump back
            when "-------------------------1110011" => ir_type := i_zero_zero;     e_mode <= f_add;                   -- SYSTEM, ECALL, EBREAK, CSR (jump to system handler) TODO jump and save mret
            when others                             => ir_type := i_zero_zero;     e_mode <= f_add;                   -- ILLEGAL (jump to illegal instruction handler) TODO jump to handler
                                                                                                                      -- TODO compressed instructions
        end case?;

        -- route operands
        a_base <= sel_pc;
        rs1    <= instr_reg(19 downto 15);
        rs2    <= instr_reg(24 downto 20);
        rd     <= instr_reg(11 downto  7);
        case ir_type is
            when u_zero_imm      => op1 <= sel_zero; op2 <= sel_imm; rs1 <= reg_zero; rs2 <= reg_zero;
            when u_pc_imm        => op1 <= sel_pc;   op2 <= sel_imm; rs1 <= reg_zero; rs2 <= reg_zero;
            when j_pc_n_zero_pc  => op1 <= sel_pc_n; op2 <= sel_rs2; rs1 <= reg_zero; rs2 <= reg_zero;
            when b_rs1_rs2_pc    => op1 <= sel_rs1;  op2 <= sel_imm;
            when s_zero_rs2_rs1  => op1 <= sel_zero; op2 <= sel_imm;                                   a_base <= sel_rs1; rd <= reg_zero;
            when r_rs1_rs2       => op1 <= sel_rs1;  op2 <= sel_imm;
            when i_pc_n_zero_rs1 => op1 <= sel_pc_n; op2 <= sel_rs2;                  rs2 <= reg_zero; a_base <= sel_rs1;
            when i_zero_zero_rs1 => op1 <= sel_zero; op2 <= sel_rs2;                  rs2 <= reg_zero; a_base <= sel_rs1;
            when i_rs1_imm       => op1 <= sel_rs1;  op2 <= sel_imm;                  rs2 <= reg_zero;
            when i_zero_zero     => op1 <= sel_zero; op2 <= sel_rs2; rs1 <= reg_zero; rs2 <= reg_zero;
        end case;

        -- immediate extraction
        case ir_type is
            when u_zero_imm | u_pc_imm => imm <= instr_reg(31 downto 12) & (11 downto 0 => '0');
            when j_pc_n_zero_pc        => imm <= (31 downto 20 => instr_reg(31)) & instr_reg(19 downto 12) & instr_reg(20) & instr_reg(30 downto 21) & '0';
            when b_rs1_rs2_pc          => imm <= (31 downto 12 => instr_reg(31)) & instr_reg(7) & instr_reg(30 downto 25) & instr_reg(11 downto 8) & '0';
            when s_zero_rs2_rs1        => imm <= (31 downto 11 => instr_reg(31)) & instr_reg(30 downto 25) & instr_reg(11 downto 8) & instr_reg(7);
            -- r_rs1_rs2 | i_pc_n_zero_rs1 | i_zero_zero_rs1 | i_rs1_imm | i_zero_zero
            when others                => imm <= (31 downto 11 => instr_reg(31)) & instr_reg(30 downto 20);
        end case;
    end process;
end bh;
