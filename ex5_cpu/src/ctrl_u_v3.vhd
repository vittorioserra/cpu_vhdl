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

entity ctrl_u_v3 is
    Port(
        pc_jmp_en : OUT std_logic;
        data_mem_we : OUT std_logic;
        alu_ctrl : OUT alu_func;
        alu_op2_mux_sel : OUT op2_select;
        extension_unit_ctrl : OUT extension_control_type;
        regfile_wen : OUT std_logic;
        result_out_mux_sel : OUT result_ctrl;
        jmp_src_sel : OUT jump_reg_sel;
        data_mem_qty : OUT mem_qty;
        s_ext_mode : OUT mem_res_sgn_ext;
        
        jump : buffer std_logic;
        
        instr : IN std_logic_vector(xlen_range);
        cmp_flag_from_alu : IN std_logic

        );
end ctrl_u_v3;

architecture bh of ctrl_u_v3 is 
   
begin

process(instr)  --main decoder program

    variable opcode             :  std_logic_vector(oplen_range);
    variable funct3_field       :  std_logic_vector(funct3_range);
    variable funct7_field       :  std_logic_vector(6 downto 0);
    
    begin
    
    opcode := opcode_carve_out(instr);
    funct3_field := funct3_carve_out(instr);
    funct7_field := funct7_carve_out(instr);
    
    --all r type instructions
    
    --add
    if opcode = "0110011" and funct3_field = "000" and funct7_field = "0000000" then
    
        alu_ctrl <= func_add;
        alu_op2_mux_sel <= select_rs2;
        regfile_wen <= '1';
        result_out_mux_sel <= alu_res;
        
        pc_jmp_en <= '0';
        data_mem_we <= '0';
        jmp_src_sel <= select_pc;

    
    end if;
    
    --sub
    if opcode = "0110011" and funct3_field = "000" and funct7_field = "0100000" then
    
        alu_ctrl <= func_sub;
        alu_op2_mux_sel <= select_rs2;
        regfile_wen <= '1';
        result_out_mux_sel <= alu_res;
        
        pc_jmp_en <= '0';
        data_mem_we <= '0';
        jmp_src_sel <= select_pc;
    
    end if;
    
    --sll
    if opcode = "0110011" and funct3_field = "001" and funct7_field = "0000000" then
    
        alu_ctrl <= func_sll;
        alu_op2_mux_sel <= select_rs2;
        regfile_wen <= '1';
        result_out_mux_sel <= alu_res;
        
        pc_jmp_en <= '0';
        data_mem_we <= '0';
        jmp_src_sel <= select_pc;
    
    end if;
    
    --slts
    if opcode = "0110011" and funct3_field = "010" and funct7_field = "0000000" then
    
        alu_ctrl <= func_slts;
        alu_op2_mux_sel <= select_rs2;
        regfile_wen <= '1';
        result_out_mux_sel <= alu_res;
        
        pc_jmp_en <= '0';
        data_mem_we <= '0';
        jmp_src_sel <= select_pc;
    
    end if;
    
    --sltu
    if opcode = "0110011" and funct3_field = "011" and funct7_field = "0000000" then
    
        alu_ctrl <= func_sltu;
        alu_op2_mux_sel <= select_rs2;
        regfile_wen <= '1';
        result_out_mux_sel <= alu_res;
        
        pc_jmp_en <= '0';
        data_mem_we <= '0';
        jmp_src_sel <= select_pc;
    
    end if;
    
    --xor
    if opcode = "0110011" and funct3_field = "100" and funct7_field = "0000000" then
    
        alu_ctrl <= func_xor;
        alu_op2_mux_sel <= select_rs2;
        regfile_wen <= '1';
        result_out_mux_sel <= alu_res;
        
        pc_jmp_en <= '0';
        data_mem_we <= '0';
        jmp_src_sel <= select_pc;
    
    end if;
    
    --srl
    if opcode = "0110011" and funct3_field = "101" and funct7_field = "0000000" then
    
        alu_ctrl <= func_srl;
        alu_op2_mux_sel <= select_rs2;
        regfile_wen <= '1';
        result_out_mux_sel <= alu_res;
        
        pc_jmp_en <= '0';
        data_mem_we <= '0';
        jmp_src_sel <= select_pc;
    
    end if;
    
    --sra
    if opcode = "0110011" and funct3_field = "101" and funct7_field = "0100000" then
    
        alu_ctrl <= func_sra;
        alu_op2_mux_sel <= select_rs2;
        regfile_wen <= '1';
        result_out_mux_sel <= alu_res;
        
        pc_jmp_en <= '0';
        data_mem_we <= '0';
        jmp_src_sel <= select_pc;
    
    end if;
    
    --or
    if opcode = "0110011" and funct3_field = "110" and funct7_field = "0000000" then
    
        alu_ctrl <= func_or;
        alu_op2_mux_sel <= select_rs2;
        regfile_wen <= '1';
        result_out_mux_sel <= alu_res;
        
        pc_jmp_en <= '0';
        data_mem_we <= '0';
        jmp_src_sel <= select_pc;
    
    end if;
    
    --and
    if opcode = "0110011" and funct3_field = "111" and funct7_field = "0000000" then
    
        alu_ctrl <= func_and;
        alu_op2_mux_sel <= select_rs2;
        regfile_wen <= '1';
        result_out_mux_sel <= alu_res;
        
        pc_jmp_en <= '0';
        data_mem_we <= '0';
        jmp_src_sel <= select_pc;
    
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
        
        pc_jmp_en <= '0';
        data_mem_we <= '0';
        jmp_src_sel <= select_pc;
    
    end if;
    
    --srli
    if(opcode = "0010011" and funct3_field = "101" and funct7_field = "0000000") then
    
        alu_ctrl <= func_srl;
        extension_unit_ctrl <= i_type_shift; --the upper field is 0, so we can use this anyway
        alu_op2_mux_sel <= select_imm;
        regfile_wen <= '1';
        result_out_mux_sel <= alu_res;
        
        pc_jmp_en <= '0';
        data_mem_we <= '0';
        jmp_src_sel <= select_pc;
    
    end if;
    --srai (special handling of bit 30, which is '1')
    if(opcode = "0010011" and funct3_field = "101" and funct7_field = "0100000") then
    
        alu_ctrl <= func_sra;
        extension_unit_ctrl <= i_type_shift; --the upper field is 0, so we can use this anyway
        alu_op2_mux_sel <= select_imm;
        regfile_wen <= '1';
        result_out_mux_sel <= alu_res;
        
        pc_jmp_en <= '0';
        data_mem_we <= '0';
        jmp_src_sel <= select_pc;
    
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
        
        pc_jmp_en <= '0';
        data_mem_we <= '0';
        jmp_src_sel <= select_pc;
    
    end if;
    
    --slti
    if(opcode = "0010011" and funct3_field = "010") then
    
        alu_ctrl <= func_slts;
        extension_unit_ctrl <= i_type;
        alu_op2_mux_sel <= select_imm;
        regfile_wen <= '1';
        result_out_mux_sel <= alu_res;
        
        pc_jmp_en <= '0';
        data_mem_we <= '0';
        jmp_src_sel <= select_pc;
    
    end if;
    
    --sltiu
    if(opcode = "0010011" and funct3_field = "011") then
    
        alu_ctrl <= func_sltu;
        extension_unit_ctrl <= i_type;
        alu_op2_mux_sel <= select_imm;
        regfile_wen <= '1';
        result_out_mux_sel <= alu_res;
        
        pc_jmp_en <= '0';
        data_mem_we <= '0';
        jmp_src_sel <= select_pc;
    
    end if;
    
    --xori
    if(opcode = "0010011" and funct3_field = "100") then
    
        alu_ctrl <= func_xor;
        extension_unit_ctrl <= i_type;
        alu_op2_mux_sel <= select_imm;
        regfile_wen <= '1';
        result_out_mux_sel <= alu_res;
        
        pc_jmp_en <= '0';
        data_mem_we <= '0';
        jmp_src_sel <= select_pc;
    
    end if;
        
    --ori
    if(opcode = "0010011" and funct3_field = "110") then
    
        alu_ctrl <= func_or;
        extension_unit_ctrl <= i_type;
        alu_op2_mux_sel <= select_imm;
        regfile_wen <= '1';
        result_out_mux_sel <= alu_res;
        
        pc_jmp_en <= '0';
        data_mem_we <= '0';
        jmp_src_sel <= select_pc;
    
    end if;
    
    --andi
    if(opcode = "0010011" and funct3_field = "111") then
    
        alu_ctrl <= func_and;
        extension_unit_ctrl <= i_type;
        alu_op2_mux_sel <= select_imm;
        regfile_wen <= '1';
        result_out_mux_sel <= alu_res;
        
        pc_jmp_en <= '0';
        data_mem_we <= '0';
        jmp_src_sel <= select_pc;
    
    end if;
    
    --loading from memory
    --lb
    if(opcode = "0000011" and funct3_field = "000") then  
        --TODO : 
        -- 1 : Calculate alignment offset
        -- 2 : apply mask to sign extension unit
        
        -- 1 : calculate aligment offset --> (done by mem)
        -- 2 : telling memory to go into "byte-mode"
        
        
        alu_ctrl <= func_add; --add the immediate
        extension_unit_ctrl <= i_type; --extend, normal here
        alu_op2_mux_sel <= select_imm; --the immediate extended goes into the ali
        regfile_wen <= '1'; --the regfile writing is enabled
        result_out_mux_sel <= data_mem; --the result comes from the mem, the address is the result of the alu
        data_mem_qty <= byte;
        s_ext_mode <= sext;        
        
        pc_jmp_en <= '0';
        data_mem_we <= '0';
        jmp_src_sel <= select_pc;
        
    end if;
    
    --lh
    if (opcode = "0000011" and funct3_field = "001") then
    
        alu_ctrl <= func_add; --add the immediate
        extension_unit_ctrl <= i_type; --extend, normal here
        alu_op2_mux_sel <= select_imm; --the immediate extended goes into the ali
        regfile_wen <= '1'; --the regfile writing is enabled
        result_out_mux_sel <= data_mem; --the result comes from the mem, the address is the result of the alu
        data_mem_qty <= half;
        s_ext_mode <= sext;        
        
        
        pc_jmp_en <= '0';
        data_mem_we <= '0';
        jmp_src_sel <= select_pc;
    
    end if;
    
    --lw
    if(opcode = "0000011" and funct3_field = "010") then
    
        alu_ctrl <= func_add; --add the immediate
        extension_unit_ctrl <= i_type; --extend, normal here
        alu_op2_mux_sel <= select_imm; --the immediate extended goes into the ali
        regfile_wen <= '1'; --the regfile writing is enabled
        result_out_mux_sel <= data_mem; --the result comes from the mem, the address is the result of the alu
        data_mem_qty <= word;        
        s_ext_mode <= sext;
        
        pc_jmp_en <= '0';
        data_mem_we <= '0';
        jmp_src_sel <= select_pc;
    
    end if;
    
    --lbu
    if(opcode = "0000011" and funct3_field = "100") then  
        --TODO : 
        -- 1 : Calculate alignment offset
        -- 2 : apply mask to sign extension unit
        
        -- 1 : calculate aligment offset --> (done by mem)
        -- 2 : telling memory to go into "byte-mode"
        
        
        alu_ctrl <= func_add; --add the immediate
        extension_unit_ctrl <= i_type; --extend, normal here
        alu_op2_mux_sel <= select_imm; --the immediate extended goes into the ali
        regfile_wen <= '1'; --the regfile writing is enabled
        result_out_mux_sel <= data_mem; --the result comes from the mem, the address is the result of the alu
        data_mem_qty <= byte;        
        s_ext_mode <= uext;
        
        pc_jmp_en <= '0';
        data_mem_we <= '0';
        jmp_src_sel <= select_pc;
        
    end if;
    --lhu
    if(opcode = "0000011" and funct3_field = "100") then  
        --TODO : 
        -- 1 : Calculate alignment offset
        -- 2 : apply mask to sign extension unit
        
        -- 1 : calculate aligment offset --> (done by mem)
        -- 2 : telling memory to go into "byte-mode"
        
        
        alu_ctrl <= func_add; --add the immediate
        extension_unit_ctrl <= i_type; --extend, normal here
        alu_op2_mux_sel <= select_imm; --the immediate extended goes into the ali
        regfile_wen <= '1'; --the regfile writing is enabled
        result_out_mux_sel <= data_mem; --the result comes from the mem, the address is the result of the alu
        data_mem_qty <= half;
        s_ext_mode <= uext;        
        
        pc_jmp_en <= '0';
        data_mem_we <= '0';
        jmp_src_sel <= select_pc;
        
    end if;
    
    --s type instructions
    --sb
    if(opcode = "0100011" and funct3_field = "000") then
    
        alu_ctrl <= func_add; --add the immediate
        extension_unit_ctrl <= i_type; --extend, normal here
        alu_op2_mux_sel <= select_imm; --the immediate extended goes into the ali
        regfile_wen <= '1'; --the regfile writing is enabled
        result_out_mux_sel <= data_mem; --the result comes from the mem, the address is the result of the alu
        data_mem_qty <= byte;
        s_ext_mode <= uext; -- trick it this way
        
        pc_jmp_en <= '0';
        data_mem_we <= '1';
        jmp_src_sel <= select_pc;
    
    end if;
    
    --sh
        if(opcode = "0100011" and funct3_field = "001") then
    
        alu_ctrl <= func_add; --add the immediate
        extension_unit_ctrl <= i_type; --extend, normal here
        alu_op2_mux_sel <= select_imm; --the immediate extended goes into the ali
        regfile_wen <= '1'; --the regfile writing is enabled
        result_out_mux_sel <= data_mem; --the result comes from the mem, the address is the result of the alu
        data_mem_qty <= half;
        s_ext_mode <= uext; -- trick it this way

        
        pc_jmp_en <= '0';
        data_mem_we <= '1';
        jmp_src_sel <= select_pc;
    
    end if;
    
    --sw
    if(opcode = "0100011" and funct3_field = "010") then
    
        alu_ctrl <= func_add;    
        extension_unit_ctrl <= s_type;
        alu_op2_mux_sel <= select_imm;
        regfile_wen <= '0';
        data_mem_we <= '1';
        s_ext_mode <= uext; -- trick it this way

        
        pc_jmp_en <= '0';
        jmp_src_sel <= select_pc;
    
    end if;
    
    --b type
    --beq
    if(opcode ="1100011" and funct3_field = "000")then
        
        alu_ctrl <= func_seq;
        extension_unit_ctrl <=  b_type;
        alu_op2_mux_sel <= select_rs2;
        data_mem_we <= '0';
        regfile_wen <= '0';
        jmp_src_sel <= select_pc;
        
        if(cmp_flag_from_alu = '1') then
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
        jmp_src_sel <= select_pc;
        
        if(cmp_flag_from_alu = '0') then
            pc_jmp_en <= '1';
        else
            pc_jmp_en <= '0';
            
        end if; 
        
    end if;
    
    --blt
    if(opcode ="1100011" and funct3_field = "100")then
        
        alu_ctrl <= func_slts;
        extension_unit_ctrl <=  b_type;
        alu_op2_mux_sel <= select_rs2;
        data_mem_we <= '0';
        regfile_wen <= '0';
        jmp_src_sel <= select_pc;
        
        if(cmp_flag_from_alu = '1') then
            pc_jmp_en <= '1';
        else
            pc_jmp_en <= '0';
            
        end if; 
        
    end if;
    
    --bge
    if(opcode ="1100011" and funct3_field = "101")then
        
        alu_ctrl <= func_slts;
        extension_unit_ctrl <=  b_type;
        alu_op2_mux_sel <= select_rs2;
        data_mem_we <= '0';
        regfile_wen <= '0';
        jmp_src_sel <= select_pc;

        
        if(cmp_flag_from_alu = '0') then
            pc_jmp_en <= '1';
        else
            pc_jmp_en <= '0';
            
        end if; 
        
    end if;
    
    --bltu 
    if(opcode ="1100011" and funct3_field = "110")then
        
        alu_ctrl <= func_sltu;
        extension_unit_ctrl <=  b_type;
        alu_op2_mux_sel <= select_rs2;
        data_mem_we <= '0';
        regfile_wen <= '0';
        jmp_src_sel <= select_pc;

        
        if(cmp_flag_from_alu = '1') then
            pc_jmp_en <= '1';
        else
            pc_jmp_en <= '0';
            
        end if; 
        
    end if;
    --bgeu
    if(opcode ="1100011" and funct3_field = "111")then
        
        alu_ctrl <= func_sltu;
        extension_unit_ctrl <=  b_type;
        alu_op2_mux_sel <= select_rs2;
        data_mem_we <= '0';
        regfile_wen <= '0';
        jmp_src_sel <= select_pc;

        
        if(cmp_flag_from_alu = '0') then
            pc_jmp_en <= '1';
        else
            pc_jmp_en <= '0';
            
        end if; 
        
    end if;
    
    --j type
    --jal
    if(opcode = "1101111") then
    
        extension_unit_ctrl <= j_type;
        result_out_mux_sel <= prog_ctr_up;
        jmp_src_sel <= select_pc;

        data_mem_we <= '0';
        regfile_wen <= '1';
        pc_jmp_en <= '1';
        
            
    end if;
    
    --jalr
    if(opcode = "1100111" and funct3_field = "000") then
    
        extension_unit_ctrl <= j_type;
        result_out_mux_sel <= prog_ctr_up;
        regfile_wen <= '1';
        pc_jmp_en <= '1';
        
        --missing way to route alu_res to pc
        jmp_src_sel <= select_rs1;
        
        data_mem_we <= '0';
        alu_op2_mux_sel <= select_rs2;

            
    end if;
    
    --u type instructions
    --lui
    if(opcode = "0110111") then 
    
        extension_unit_ctrl <= u_type;
        result_out_mux_sel <= immediate;
        regfile_wen <= '1';
        
        pc_jmp_en <= '0';
        data_mem_we <= '0';
        alu_op2_mux_sel <= select_rs2;
        jmp_src_sel <= select_rs1;   
    
    end if;
    
    --aiupc
    if(opcode = "0010111") then 
    
        extension_unit_ctrl <= u_type;
        result_out_mux_sel <= prog_ctr_up;
        regfile_wen <= '1';
        
        pc_jmp_en <= '0';
        data_mem_we <= '0';
        alu_op2_mux_sel <= select_rs2;
        jmp_src_sel <= select_pc;   
    
    end if;
    
    
    -- LASCIATE OGNI SPERANZA VOI CHE ENTRATE --
    -- FROM HERE ONWARDS IT IS A WORK IN PROGRESS--
    --the following section is just a placeholder, unudeful for now
    
    --fence instructions
    --fence
    if(instr(31 downto 28) = "0000" and instr(19 downto 0) = "00000000000000001111")then 
    
        --operation ordering
    
    end if;
    --fence.i
    if(instr = "00000000000000000001000000001111") then
    
        --sync writes between instr-mem and instruction fetches
    
    end if;
    
    --e instructions --we do not have a supporting execution environment for now
    --all i type
    --ecall
     if(instr = "00000000000000000000000001110011") then 
     
     --TODO : generate environment call
     
     end if;
     
    --ebreak
    if(instr = "00000000000100000000000001110011") then
    
    --TODO : transfer control back to debugging environment
    
    end if;
    
    --csr instructions -- we do not have csr registers for now
    --all i type
    --csrrw
    if(opcode = "1110011" and funct3_field = "001") then
    
        --move value of crs in rd, and value of rs1 to csr
    
    end if;
    
    --csrrs
    if(opcode = "1110011" and funct3_field = "010") then
    
        --write value of csr to rd.  value at csr is bitwise csr | rs1
    
    end if;
    
    --csrrc
    if(opcode = "1110011" and funct3_field = "011") then
    
        --write value of csr to rd. clear bits in crs according to following bit-wise operation : 
        --csr & ~rs1
    
    end if;
    
    --csrrwi
    if(opcode = "1110011" and funct3_field = "101") then
    
        --write value of csr to rd. value in csr is ZeroExt of Uimm
    
    end if;
    
    --csrrsi
    if(opcode = "1110011" and funct3_field = "110") then
    
        --move value of csr to rd. set value in csr according to the following bit-wise expression : 
        --csr=csr| ZeroExt(uimm)
    
    end if;
    
    --csrrci
    if(opcode = "1110011" and funct3_field="111") then
    
        --move value of csr in rd. clear bits in crs according to following bit-wise operation : 
        --csr & ZeroExt(uimm)
    
    end if;
    
end process;


end bh;
