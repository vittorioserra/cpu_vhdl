----------------------------------------------------------------------------------
-- Company: FAU Erlangen - Nuernberg
-- Engineer: Vittorio Serra and Cedric Donges
--
-- Description: Control unit for RISC-V 32I, single cycle processor
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.utils.ALL;
use work.rv32i_defs.ALL;

entity ctrl_u_v2 is
    Port(
        pc_jmp_en : OUT std_logic;
        data_mem_we : OUT std_logic;
        alu_ctrl : OUT alu_func;
        alu_op2_mux_sel : OUT op2_select;
        extension_unit_ctrl : OUT extension_control_type;
        regfile_wen : OUT std_logic;
        result_out_mux_sel : OUT result_ctrl;
        
        jump : buffer std_logic;
        
        opcode : IN std_logic_vector(oplen_range);
        funct3_field : IN std_logic_vector(funct3_range);
        funct7_field : In std_logic_vector(6 downto 0);
        funct7b5_field : IN std_logic;
        zero_flag_from_alu : IN std_logic -- added for consistency, as of now, quite useless
        );
end ctrl_u_v2;

architecture bh of ctrl_u_v2 is
    
begin

process(opcode) begin --main decoder program

    --all r type instructions
    
    --add
    if(opcode = "0110011" and funct3_field = "000" and funct7_field = "000000") then
    
        alu_ctrl <= func_add;
        alu_op2_mux_sel <= select_rs2;
        regfile_wen <= '1';
        result_out_mux_sel <= alu_res;
    
    end if;
    
    --sub
    if(opcode = "0110011" and funct3_field = "000" and funct7_field = "010000") then
    
        alu_ctrl <= func_sub;
        alu_op2_mux_sel <= select_rs2;
        regfile_wen <= '1';
        result_out_mux_sel <= alu_res;
    
    end if;
    
    --sll
    if(opcode = "0110011" and funct3_field = "001" and funct7_field = "000000") then
    
        alu_ctrl <= func_sll;
        alu_op2_mux_sel <= select_rs2;
        regfile_wen <= '1';
        result_out_mux_sel <= alu_res;
    
    end if;
    
    --slts
    if(opcode = "0110011" and funct3_field = "010" and funct7_field = "000000") then
    
        alu_ctrl <= func_slts;
        alu_op2_mux_sel <= select_rs2;
        regfile_wen <= '1';
        result_out_mux_sel <= alu_res;
    
    end if;
    
    --sltu
    if(opcode = "0110011" and funct3_field = "011" and funct7_field = "000000") then
    
        alu_ctrl <= func_sltu;
        alu_op2_mux_sel <= select_rs2;
        regfile_wen <= '1';
        result_out_mux_sel <= alu_res;
    
    end if;
    
    --xor
    if(opcode = "0110011" and funct3_field = "100" and funct7_field = "000000") then
    
        alu_ctrl <= func_xor;
        alu_op2_mux_sel <= select_rs2;
        regfile_wen <= '1';
        result_out_mux_sel <= alu_res;
    
    end if;
    
    --srl
    if(opcode = "0110011" and funct3_field = "101" and funct7_field = "000000") then
    
        alu_ctrl <= func_srl;
        alu_op2_mux_sel <= select_rs2;
        regfile_wen <= '1';
        result_out_mux_sel <= alu_res;
    
    end if;
    
    --sra
    if(opcode = "0110011" and funct3_field = "101" and funct7_field = "010000") then
    
        alu_ctrl <= func_sra;
        alu_op2_mux_sel <= select_rs2;
        regfile_wen <= '1';
        result_out_mux_sel <= alu_res;
    
    end if;
    
    --or
    if(opcode = "0110011" and funct3_field = "110" and funct7_field = "000000") then
    
        alu_ctrl <= func_or;
        alu_op2_mux_sel <= select_rs2;
        regfile_wen <= '1';
        result_out_mux_sel <= alu_res;
    
    end if;
    
    --and
    if(opcode = "0110011" and funct3_field = "111" and funct7_field = "000000") then
    
        alu_ctrl <= func_and;
        alu_op2_mux_sel <= select_rs2;
        regfile_wen <= '1';
        result_out_mux_sel <= alu_res;
    
    end if;
    
    --i type instructions
    
    --5 bits unsigned immediate (all for alu)
    --slli
    if(opcode = "0010011" and funct3_field = "001" and funct7_field = "0000000") then
    
        alu_ctrl <= func_sll;
        extension_unit_ctrl <= i_type_shift; --the upper field is 0, so we can use this anyway
        alu_op2_mux_sel <= select_imm;
        regfile_wen <= '1';
        result_out_mux_sel <= alu_res;
    
    end if;
    
    --srli
    if(opcode = "0010011" and funct3_field = "010" and funct7_field = "0000000") then
    
        alu_ctrl <= func_srl;
        extension_unit_ctrl <= i_type_shift; --the upper field is 0, so we can use this anyway
        alu_op2_mux_sel <= select_imm;
        regfile_wen <= '1';
        result_out_mux_sel <= alu_res;
    
    end if;
    --srai (special handling of bit 30, which is '1')
    if(opcode = "0010011" and funct3_field = "101" and funct7_field = "0100000") then
    
        alu_ctrl <= func_sll;
        extension_unit_ctrl <= i_type_shift; --the upper field is 0, so we can use this anyway
        alu_op2_mux_sel <= select_imm;
        regfile_wen <= '1';
        result_out_mux_sel <= alu_res;
    
    end if;
    
    --12 bits signed immediate to extend
    --for alu
    --addi
    if(opcode = "0010011" and funct3_field = "000") then
    
        alu_ctrl <= func_add;
        extension_unit_ctrl <= i_type;
        alu_op2_mux_sel <= select_imm;
        regfile_wen <= '1';
        result_out_mux_sel <= alu_res;
    
    end if;
    
    --slti
    if(opcode = "0010011" and funct3_field = "010") then
    
        alu_ctrl <= func_slts;
        extension_unit_ctrl <= i_type;
        alu_op2_mux_sel <= select_imm;
        regfile_wen <= '1';
        result_out_mux_sel <= alu_res;
    
    end if;
    
    --sltiu
    if(opcode = "0010011" and funct3_field = "011") then
    
        alu_ctrl <= func_sltu;
        extension_unit_ctrl <= i_type;
        alu_op2_mux_sel <= select_imm;
        regfile_wen <= '1';
        result_out_mux_sel <= alu_res;
    
    end if;
    
    --xori
    if(opcode = "0010011" and funct3_field = "100") then
    
        alu_ctrl <= func_xor;
        extension_unit_ctrl <= i_type;
        alu_op2_mux_sel <= select_imm;
        regfile_wen <= '1';
        result_out_mux_sel <= alu_res;
    
    end if;
    
    --ori
    if(opcode = "0010011" and funct3_field = "110") then
    
        alu_ctrl <= func_or;
        extension_unit_ctrl <= i_type;
        alu_op2_mux_sel <= select_imm;
        regfile_wen <= '1';
        result_out_mux_sel <= alu_res;
    
    end if;
    
    --andi
    if(opcode = "0010011" and funct3_field = "111") then
    
        alu_ctrl <= func_and;
        extension_unit_ctrl <= i_type;
        alu_op2_mux_sel <= select_imm;
        regfile_wen <= '1';
        result_out_mux_sel <= alu_res;
    
    end if;
    
    --loading from memory
    --lb --> need mask
    --lh --> need mask
    --lw
    if(opcode = "0000011" and funct3_field = "010") then
    
        alu_ctrl <= func_and; --add the immediate
        extension_unit_ctrl <= i_type; --extend, normal here
        alu_op2_mux_sel <= select_imm; --the immediate extended goes into the ali
        regfile_wen <= '1'; --the regfile writing is enabled
        result_out_mux_sel <= data_mem; --the result comes from the mem, the address is the result of the alu
    
    end if;
    --lbu --> need mask
    --lhu --> need mask
    --jalr --> not implemented for now
    
    --s type instructions
    --sb --> needs mask
    --sh --> needs mask
    --sw
    if(opcode = "0100011" and funct3_field = "010") then
    
        alu_ctrl <= func_add;    
        extension_unit_ctrl <= s_type;
        alu_op2_mux_sel <= select_imm;
        regfile_wen <= '0';
        data_mem_we <= '0';
    
    end if;
    
    --b type
    --beq
    if(opcode ="1100011" and funct3_field = "000")then
        
        alu_ctrl <= func_seq;
        extension_unit_ctrl <=  b_type;
        alu_op2_mux_sel <= select_rs2;
        data_mem_we <= '0';
        regfile_wen <= '0';
        
        if(zero_flag_from_alu = '1') then
            pc_jmp_en <= '1';
        else
            pc_jmp_en <= '0';
            
        end if; 
        
    end if;
    
    --bne
    if(opcode ="1100011" and funct3_field = "001")then
        
        alu_ctrl <= func_seq;
        extension_unit_ctrl <=  b_type;
        alu_op2_mux_sel <= select_rs2;
        data_mem_we <= '0';
        regfile_wen <= '0';
        
        if(zero_flag_from_alu = '0') then
            pc_jmp_en <= '1';
        else
            pc_jmp_en <= '0';
            
        end if; 
        
    end if;
    
    --blt -->need last bit from alu flag
    --bge -->need last bit from alu flag
    --bltu -->need last bit from alu flag
    --bgeu -->need last bit from alu flag
    
    --j type
    --jal
    if(opcode = "1111111") then
    
        extension_unit_ctrl <= j_type;
        data_mem_we <= '0';
        regfile_wen <= '1';
        pc_jmp_en <= '1';
            
    end if;
    
    --u type instructions are missing as of now
    
    
end process;


end bh;
