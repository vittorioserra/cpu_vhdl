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
        mem_alu_mux_sel : OUT std_logic;
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
begin

process(operation) begin --main decoder program
    case operation is
    --lw
    when "0000011" =>
        --single_main_controls <= "10010010000";
        regfile_wen <= '0';
        extension_unit_ctrl <= s_type;
        mem_alu_mux_sel <= '1';
        data_mem_we <= '1';
        jump<='0';
        branch:='0';
        result_out_mux_sel <= data_mem;
    --sw
    when "0100011" =>
        --single_main_controls <= "00111000000";
        regfile_wen <= '0';
        extension_unit_ctrl <= s_type;
        
        
    --R type
    when "00110011" =>
        single_main_controls <= "1--00000100";
    --beq
    when "1100011" =>
        single_main_controls <= "01000001010";
    --I type
    when "0010011" => 
        single_main_controls <= "10010000100";
    --jal 
    when "1101111" => 
        single_main_controls <= "11100100001";
    --invalid instruction, all don't cares
    when others =>
        single_main_controls <=(10 downto 0 => '-');
    end case;
end process;


end bh;
