----------------------------------------------------------------------------------
-- Company: FAU Erlangen - Nuernberg
-- Engineer: Vittorio Serra and Cedric Donges
--
-- Description: Single-Cycle-CPU top module for RISC-V 32I, single cycle processor
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.utils.ALL;
use work.rv32i_defs.ALL;

entity processor_single_cycle is
--  Port ( );
end processor_single_cycle;

architecture bh of processor_single_cycle is

constant CLOCK_PERIOD : time := 10 ns;

signal clock : std_logic;
signal alu_func_from_ctrl : alu_func;

signal we_int_datamem : std_logic;
signal we_int_regfile : std_logic;

signal int_extension_unit_ctrl : extension_control_type;
signal int_res_mux_control : result_ctrl;
signal int_op2_sel : op2_select;

signal operation_dummy : std_logic_vector(oplen_range);
signal funct3_field_dummy : std_logic_vector(funct3_range);
signal funct7b5_field_dummy : std_logic;

signal int_zero_flag : std_logic;

signal int_alu_in_reg1 : std_logic_vector(xlen_range);
signal int_alu_in_reg2 : std_logic_vector(xlen_range);

signal alu_mux_regfile_in : std_logic_vector(xlen_range);
signal int_immediate_going_around : std_logic_vector(xlen_range);

signal black_hole_all_std_logic : std_logic;

signal int_extension_ctrl : extension_control_type;
signal int_input_to_extend : std_logic_vector(31 downto 7);
signal int_extended_output : std_logic_vector(xlen_range);

begin

    ALU : entity work.alu
		port map (reset_n => '1',
                  clock => clock,
                  func => alu_func_from_ctrl,
                  op1 => x"00000000",
                  op2 => x"00000000", 
                  zero_flag => int_zero_flag);
                  
    REG_B_MUX : entity work.mux_alu_reg_b
        port map (
                  reg_selection => int_op2_sel,
        
                  rs2_in => alu_mux_regfile_in,
                  immediate_in => int_immediate_going_around,
                    
                  muxed_out => int_alu_in_reg2
                  );
             	
	CTRL_U : entity work.control_unit
	    port map(pc_enable => black_hole_all_std_logic, --always enabled
                 data_mem_we => black_hole_all_std_logic, --land in nothing
                 alu_ctrl => alu_func_from_ctrl,
                 alu_op2_mux_sel => int_op2_sel, --not here for now
                 extension_unit_ctrl => int_extension_unit_ctrl, --not here for now
                 regfile_wen => we_int_regfile,
                 result_out_mux_sel => int_res_mux_control,                 
                 
                 operation => operation_dummy,
                 funct3_field => funct3_field_dummy,
                 funct7b5_field => funct7b5_field_dummy,
                 zero_flag_from_alu  => int_zero_flag);
                 
    REGFILE : entity work.regfile
         port map(clock => clock,
                  reset_n => '1',
                  rd_write_enable => we_int_regfile,
                  rs1_select => "00000", --go to zero
                  rs2_select => "00000", --go to zero 
                  rd_select => "00000",
                  rs1_value =>  int_alu_in_reg1,
                  rs2_value => int_alu_in_reg2,
                  rd_value => x"00000000" --go to zero for now
                  );
    
    EXT_UNIT : entity work.extension_unit
         port map(select_extension => int_extension_ctrl,
                  input_to_extend => int_input_to_extend,
                  extended_output => int_extended_output
                  );
                  
    OUTPUT_MUX : entity work.res
    
    

end bh;
