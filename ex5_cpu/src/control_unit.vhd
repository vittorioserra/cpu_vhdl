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

entity control_unit is
    Port(
        pc_enable : OUT std_logic;
        data_mem_we : OUT std_logic;
        alu_ctrl : OUT alu_func;
        alu_op2_mux_sel : OUT op2_select;
        extension_unit_ctrl : OUT extension_control_type;
        regfile_wen : OUT std_logic;
        result_out_mux_sel : OUT result_ctrl;
        
        jump : buffer std_logic;
        
        
        operation : IN std_logic_vector(oplen_range);
        funct3_field : IN std_logic_vector(funct3_range);
        funct7b5_field : IN std_logic;
        zero_flag_from_alu : IN std_logic -- added for consistency, as of now, quite useless
        );
end control_unit;

architecture bh of control_unit is
    signal single_main_controls : std_logic_vector(10 downto 0);
    shared variable branch : std_logic;
    shared variable internal_op : internal_alu_op; 
    
function alu_decode(alu_op : internal_alu_op; funct3_in : std_logic_vector(funct3_range); op : std_logic_vector(oplen_range); funct7b5 : std_logic

) return alu_func is variable decoded_alu_func : alu_func;
    begin
    
    case alu_op is 
    
        when immediate_add => decoded_alu_func := func_add;
        when immediate_sub => decoded_alu_func := func_sub;
        when decode_from_funct3 =>
            case funct3_in is
            
                when "000" =>
                    if (op(5) and funct7b5) = '1' then 
                        decoded_alu_func := func_sub;
                    else
                        decoded_alu_func := func_add;
                    
                    end if; 
                when "010" => decoded_alu_func  := func_sltu;
                when "110" => decoded_alu_func  := func_or;
                when "111" => decoded_alu_func  := func_and;
                when others => decoded_alu_func := func_add; --just pegged it to this value, should not be in final version
                end case;
    end case;

    return func_add;
    end function;
    
begin

main_dec : process(operation) begin --main decoder program
    case operation is
    --lw
    when "0000011" =>
        --single_main_controls <= "10010010000";
        regfile_wen <= '0';
        extension_unit_ctrl <= s_type;
        alu_op2_mux_sel <= select_imm;
        data_mem_we <= '1';
        result_out_mux_sel <= data_mem;
        branch:='0';
        internal_op := immediate_add;
        alu_ctrl <= alu_decode(internal_op, operation, funct3_field, funct7b5_field);
        jump<='0';
    --sw
    when "0100011" =>
        --single_main_controls <= "00111000000";
        regfile_wen <= '0';
        extension_unit_ctrl <= s_type;
        alu_op2_mux_sel <= select_rs2;
        data_mem_we<='1';
        result_out_mux_sel <= alu_res;
        branch := '0';
        internal_op := immediate_add;
        alu_ctrl <= alu_decode(internal_op, operation, funct3_field, funct7b5_field);      
        jump<='0';
    --R type
    when "00110011" =>
        --single_main_controls <= "1--00000100";
        regfile_wen <= '1';
        extension_unit_ctrl <= complement;
        alu_op2_mux_sel <= select_rs2;
        data_mem_we<='1';
        result_out_mux_sel <= alu_res;
        branch := '1';
        internal_op := decode_from_funct3;
        alu_ctrl <= alu_decode(internal_op, operation, funct3_field, funct7b5_field);
        --alu_ctrl <= func_add; -- add is R type, so this should be fine, imho
        jump<='0';
    --beq
    when "1100011" =>
        --single_main_controls <= "01000001010";
        regfile_wen <= '0';
        extension_unit_ctrl <= b_type;
        alu_op2_mux_sel <= select_rs2;
        data_mem_we<='0';
        result_out_mux_sel <= data_mem;
        branch := '0';
        internal_op := decode_from_funct3;
        alu_ctrl <= alu_decode(internal_op, operation, funct3_field, funct7b5_field);
        --alu_ctrl <= func_seq; -- set lowest bit when equal, in the book i think they use the zero port on the alu for this...
        jump<='0';
    --I type
    when "0010011" => 
        --single_main_controls <= "10010000100";
        regfile_wen <= '1';
        extension_unit_ctrl <= i_type;
        alu_op2_mux_sel <= select_imm;
        data_mem_we<='0';
        result_out_mux_sel <= alu_res;
        branch := '0';
        internal_op := decode_from_funct3;
        alu_ctrl <= alu_decode(internal_op, operation, funct3_field, funct7b5_field);
        --alu_ctrl <= func_add; -- add is R type, so this should be fine, imho
        jump<='0';
    --jal 
    when "1101111" => 
        --single_main_controls <= "11100100001";
        regfile_wen <= '1';
        extension_unit_ctrl <= j_type;
        alu_op2_mux_sel <= select_rs2;
        data_mem_we<='0';
        result_out_mux_sel <= data_mem;
        branch := '0';
        internal_op := immediate_add;
        alu_ctrl <= alu_decode(internal_op, operation, funct3_field, funct7b5_field);
        --alu_ctrl <= func_add; -- add is R type, so this should be fine, imho
        jump<='1';
    --invalid instruction, all don't cares
    when others =>
        single_main_controls <=(10 downto 0 => '-');
    end case;
end process;


end bh;
