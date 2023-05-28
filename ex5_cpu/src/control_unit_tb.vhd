----------------------------------------------------------------------------------
-- Company: FAU Erlangen - Nuernberg
-- Engineer: Vittorio Serra and Cedric Donges
--
-- Description: testbench for control unit
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.utils.ALL;
use work.rv32i_defs.ALL;

entity control_unit_tb is
end control_unit_tb;

architecture tb of control_unit_tb is
    constant CLOCK_PERIOD : time := 10 ns;
	
	signal pc_enable           : std_logic;
    signal data_mem_we         : std_logic;
    signal alu_ctrl            : alu_func;
    signal alu_op2_mux_sel     : op2_select;
    signal extension_unit_ctrl : extension_control_type;
    signal regfile_wen         : std_logic;
    signal result_out_mux_sel  : result_ctrl;
    
    signal jump                : std_logic;

    signal operation           : std_logic_vector(oplen_range);
    signal funct3_field        : std_logic_vector(funct3_range);
    signal funct7b5_field      : std_logic;
    signal zero_flag_from_alu  : std_logic;
    
    signal clock : std_logic;
    
    function operation_carve_out(opcode : std_logic_vector(xlen_range)) return std_logic_vector is variable op_outcarved : std_logic_vector(oplen_range);
    begin
    
    op_outcarved := opcode(6 downto 0);
    
    return op_outcarved;
    end function;
    
    function funct3_carve_out(opcode : std_logic_vector(xlen_range)) return std_logic_vector is variable funct3_outcarved : std_logic_vector(funct3_range);
    begin
    
    funct3_outcarved := opcode(14 downto 12);
    
    return funct3_outcarved;
    end function;
    
    function funct7b5_carve_out(opcode : std_logic_vector(xlen_range)) return std_logic is variable funct7b5_outcarved : std_logic;
    begin
    
    funct7b5_outcarved := opcode(30);
    
    return funct7b5_outcarved;
    end function;
    
begin

    DUT : entity work.control_unit
		port map (
		pc_enable           =>        pc_enable          ,
        data_mem_we         =>        data_mem_we        ,
        alu_ctrl            =>        alu_ctrl           ,
        alu_op2_mux_sel     =>        alu_op2_mux_sel    ,
        extension_unit_ctrl =>        extension_unit_ctrl,
        regfile_wen         =>        regfile_wen        ,
        result_out_mux_sel  =>        result_out_mux_sel ,
                                                        
        jump                =>        jump               ,
                                                        
        operation           =>        operation          ,
        funct3_field        =>        funct3_field       ,
        funct7b5_field      =>        funct7b5_field     ,
        zero_flag_from_alu  =>        zero_flag_from_alu 
		);

	gen_clk : process
	begin
		clock <= '1';
		wait for CLOCK_PERIOD / 2;
		clock <= '0';
		wait for CLOCK_PERIOD / 2;
	end process;

	stimuli : process
	
	variable instruction : std_logic_vector(xlen_range);
	
	begin
	    
	    instruction := x"FFC4A303";
		operation      <= operation_carve_out(instruction);
		funct3_field   <= funct3_carve_out(instruction);
		funct7b5_field <= funct7b5_carve_out(instruction);
		zero_flag_from_alu <= '0'; --does not play any role at this point, it is just there for coherency with the book
		wait for CLOCK_PERIOD;
		
		instruction := x"0064A423";
	    operation      <= operation_carve_out(instruction);
		funct3_field   <= funct3_carve_out(instruction);
		funct7b5_field <= funct7b5_carve_out(instruction);
		zero_flag_from_alu <= '0'; --does not play any role at this point, it is just there for coherency with the book
		wait for CLOCK_PERIOD;
		
		instruction := x"FE420AE3";
	    operation      <= operation_carve_out(instruction);
		funct3_field   <= funct3_carve_out(instruction);
		funct7b5_field <= funct7b5_carve_out(instruction);
		zero_flag_from_alu <= '0'; --does not play any role at this point, it is just there for coherency with the book
		wait for CLOCK_PERIOD;
		
		instruction := x"00008067";
		operation      <= operation_carve_out(instruction);
		funct3_field   <= funct3_carve_out(instruction);
		funct7b5_field <= funct7b5_carve_out(instruction);
		zero_flag_from_alu <= '0'; --does not play any role at this point, it is just there for coherency with the book
		wait for CLOCK_PERIOD;
		
		wait for CLOCK_PERIOD;
		
		wait;

	end process;
end tb;