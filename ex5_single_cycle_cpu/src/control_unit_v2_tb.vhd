----------------------------------------------------------------------------------
-- Company: FAU Erlangen - Nuernberg
-- Engineer: Vittorio Serra and Cedric Donges
--
-- Description: testbench for extension unit
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.utils.ALL;
use work.rv32i_defs.ALL;

entity ctrl_u_v2_tb is
end ctrl_u_v2_tb;

architecture tb of ctrl_u_v2_tb is

    constant CLOCK_PERIOD : time := 10 ns;
	
	signal pc_jmp_en : std_logic;
    signal data_mem_we : std_logic;
    signal alu_ctrl : alu_func;
    signal alu_op2_mux_sel : op2_select;
    signal extension_unit_ctrl : extension_control_type;
    signal regfile_wen : std_logic;
    signal result_out_mux_sel : result_ctrl;
         
    signal opcode : std_logic_vector(oplen_range);
    signal funct3_field : std_logic_vector(funct3_range);
    signal funct7_field : std_logic_vector(6 downto 0);
    signal funct7b5_field : std_logic;
    signal zero_flag_from_alu : std_logic; -- added for consistency, as of now, quite useless
    
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
    
    function funct7_carve_out(opcode : std_logic_vector(xlen_range)) return std_logic_vector is variable funct7_outcarved : std_logic_vector(31 downto 25);
    begin
    
    funct7_outcarved := opcode(31 downto 25);
    
    return funct7_outcarved;
    end function;
    
    function funct7b5_carve_out(opcode : std_logic_vector(xlen_range)) return std_logic is variable funct7b5_outcarved : std_logic;
    begin
    
    funct7b5_outcarved := opcode(30);
    
    return funct7b5_outcarved;
    end function;
    
begin

    DUT : entity work.ctrl_u_v2
		port map (
		pc_jmp_en =>pc_jmp_en,
        data_mem_we => data_mem_we,
        alu_ctrl => alu_ctrl,
        alu_op2_mux_sel => alu_op2_mux_sel,
        extension_unit_ctrl => extension_unit_ctrl,
        regfile_wen => regfile_wen,
        result_out_mux_sel => result_out_mux_sel,
                
        opcode => opcode,
        funct3_field => funct3_field,
        funct7_field => funct7_field,
        funct7b5_field => funct7b5_field,
        zero_flag_from_alu => zero_flag_from_alu -- added for consistency, as of now, quite useless
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
	
	   --testing r type instructions
       --add x6 x4 x5
       --sub x8 x9 x10
       --sll x9 x10 x11
       --slt x11 x12 x13
       --sltu x14 x15 x2
       --xor x6 x7 x8
       --srl x5 x4 x3
       --sll x7 x8 x9
       --sra x2 x3 x4
       --or  x1 x2 x3
       --and x2 x3 x4
       
       --add x6 x4 x5
	   instruction := x"00520333";
	   opcode         <= operation_carve_out(instruction);
	   funct3_field   <= funct3_carve_out(instruction);
	   funct7_field   <= funct7_carve_out(instruction);
	   funct7b5_field <= funct7b5_carve_out(instruction);
	   zero_flag_from_alu <= '0';
	   wait for CLOCK_PERIOD; 

	   --sub x8 x9 x10  
	   instruction := x"40a48433";
	   opcode         <= operation_carve_out(instruction);
	   funct3_field   <= funct3_carve_out(instruction);
	   funct7_field   <= funct7_carve_out(instruction);
	   funct7b5_field <= funct7b5_carve_out(instruction);
	   zero_flag_from_alu <= '0';
	   wait for CLOCK_PERIOD; 
	   
	   --sll x9 x10 x11
	   instruction := x"00b514b3";
	   opcode         <= operation_carve_out(instruction);
	   funct3_field   <= funct3_carve_out(instruction);
	   funct7_field   <= funct7_carve_out(instruction);
	   funct7b5_field <= funct7b5_carve_out(instruction);
	   zero_flag_from_alu <= '0'; 
	   wait for CLOCK_PERIOD;
	   
	   --slt x11 x12 x13
	   instruction := x"00d625b3";
	   opcode         <= operation_carve_out(instruction);
	   funct3_field   <= funct3_carve_out(instruction);
	   funct7_field   <= funct7_carve_out(instruction);
	   funct7b5_field <= funct7b5_carve_out(instruction);
	   zero_flag_from_alu <= '0';
	   wait for CLOCK_PERIOD;
	   
       --sltu x14 x15 x2
       instruction := x"0027b733";
	   opcode         <= operation_carve_out(instruction);
	   funct3_field   <= funct3_carve_out(instruction);
	   funct7_field   <= funct7_carve_out(instruction);
	   funct7b5_field <= funct7b5_carve_out(instruction);
	   zero_flag_from_alu <= '0';
	   wait for CLOCK_PERIOD;
	   
       --xor x6 x7 x8
       instruction := x"0083c333";	   
	   opcode         <= operation_carve_out(instruction);
	   funct3_field   <= funct3_carve_out(instruction);
	   funct7_field   <= funct7_carve_out(instruction);
	   funct7b5_field <= funct7b5_carve_out(instruction);
	   zero_flag_from_alu <= '0';
	   wait for CLOCK_PERIOD;
	   
       --srl x5 x4 x3
       instruction := x"003252b3";	   
	   opcode         <= operation_carve_out(instruction);
	   funct3_field   <= funct3_carve_out(instruction);
	   funct7_field   <= funct7_carve_out(instruction);
	   funct7b5_field <= funct7b5_carve_out(instruction);
	   zero_flag_from_alu <= '0';
	   wait for CLOCK_PERIOD;
	   
       --sll x7 x8 x9
       instruction := x"009413b3";       
	   opcode         <= operation_carve_out(instruction);
	   funct3_field   <= funct3_carve_out(instruction);
	   funct7_field   <= funct7_carve_out(instruction);
	   funct7b5_field <= funct7b5_carve_out(instruction);
	   zero_flag_from_alu <= '0';
	   wait for CLOCK_PERIOD;
	   
       --sra x2 x3 x4
       instruction := x"4041d133"; 	   
	   opcode         <= operation_carve_out(instruction);
	   funct3_field   <= funct3_carve_out(instruction);
	   funct7_field   <= funct7_carve_out(instruction);
	   funct7b5_field <= funct7b5_carve_out(instruction);
	   zero_flag_from_alu <= '0';
	   wait for CLOCK_PERIOD;
	   
       --or  x1 x2 x3
       instruction := x"003160b3"; 	   
	   opcode         <= operation_carve_out(instruction);
	   funct3_field   <= funct3_carve_out(instruction);
	   funct7_field   <= funct7_carve_out(instruction);
	   funct7b5_field <= funct7b5_carve_out(instruction);
	   zero_flag_from_alu <= '0';
	   wait for CLOCK_PERIOD;
	   
       --and x2 x3 x4
       instruction := x"0041f133";	   
	   opcode         <= operation_carve_out(instruction);
	   funct3_field   <= funct3_carve_out(instruction);
	   funct7_field   <= funct7_carve_out(instruction);
	   funct7b5_field <= funct7b5_carve_out(instruction);
	   zero_flag_from_alu <= '0';
	   wait for CLOCK_PERIOD;
	   
	   
	   --testing i type instructions
	   
	   --addi
	   --slli
	   --slti
	   --sltiu
	   --xori
	   --srli
	   --srai
	   --ori
	   --andi
	   
	   --lw
	   
	   --addi x1 x2 4
       --slli x2 x3 1
       --slti x3 x4 5
       --sltiu x4 x5 6
       --xori x6 x7 0xa5
       --srli x7 x8 0xf
       --srai x8 x9 10
       --ori x9 x10 11
       --andi x10 x11 42
       
       --lw x11 8(x12)
       
       --addi x1 x2 4
       instruction := x"00410093";
	   opcode         <= operation_carve_out(instruction);
	   funct3_field   <= funct3_carve_out(instruction);
	   funct7_field   <= funct7_carve_out(instruction);
	   funct7b5_field <= funct7b5_carve_out(instruction);
	   zero_flag_from_alu <= '0'; 
	   wait for CLOCK_PERIOD;
       --slli x2 x3 1
       instruction := x"00119113";
	   opcode         <= operation_carve_out(instruction);
	   funct3_field   <= funct3_carve_out(instruction);
	   funct7_field   <= funct7_carve_out(instruction);
	   funct7b5_field <= funct7b5_carve_out(instruction);
	   zero_flag_from_alu <= '0'; 
	   wait for CLOCK_PERIOD;
       --slti x3 x4 5
       instruction := x"00522193";
	   opcode         <= operation_carve_out(instruction);
	   funct3_field   <= funct3_carve_out(instruction);
	   funct7_field   <= funct7_carve_out(instruction);
	   funct7b5_field <= funct7b5_carve_out(instruction);
	   zero_flag_from_alu <= '0'; 
	   wait for CLOCK_PERIOD;
       --sltiu x4 x5 6
       instruction := x"0062b213";
	   opcode         <= operation_carve_out(instruction);
	   funct3_field   <= funct3_carve_out(instruction);
	   funct7_field   <= funct7_carve_out(instruction);
	   funct7b5_field <= funct7b5_carve_out(instruction);
	   zero_flag_from_alu <= '0'; 
	   wait for CLOCK_PERIOD;
       --xori x6 x7 0xa5
       instruction := x"0a53c313";
	   opcode         <= operation_carve_out(instruction);
	   funct3_field   <= funct3_carve_out(instruction);
	   funct7_field   <= funct7_carve_out(instruction);
	   funct7b5_field <= funct7b5_carve_out(instruction);
	   zero_flag_from_alu <= '0'; 
	   wait for CLOCK_PERIOD;
       --srli x7 x8 0xf
       instruction := x"004f5393";
	   opcode         <= operation_carve_out(instruction);
	   funct3_field   <= funct3_carve_out(instruction);
	   funct7_field   <= funct7_carve_out(instruction);
	   funct7b5_field <= funct7b5_carve_out(instruction);
	   zero_flag_from_alu <= '0'; 
	   wait for CLOCK_PERIOD;
       --srai x8 x9 10
       instruction := x"40a4d413";
	   opcode         <= operation_carve_out(instruction);
	   funct3_field   <= funct3_carve_out(instruction);
	   funct7_field   <= funct7_carve_out(instruction);
	   funct7b5_field <= funct7b5_carve_out(instruction);
	   zero_flag_from_alu <= '0'; 
	   wait for CLOCK_PERIOD;
       --ori x9 x10 11
       instruction := x"00b56493";
	   opcode         <= operation_carve_out(instruction);
	   funct3_field   <= funct3_carve_out(instruction);
	   funct7_field   <= funct7_carve_out(instruction);
	   funct7b5_field <= funct7b5_carve_out(instruction);
	   zero_flag_from_alu <= '0'; 
	   wait for CLOCK_PERIOD;
       --andi x10 x11 42
       instruction := x"02a5f513";
	   opcode         <= operation_carve_out(instruction);
	   funct3_field   <= funct3_carve_out(instruction);
	   funct7_field   <= funct7_carve_out(instruction);
	   funct7b5_field <= funct7b5_carve_out(instruction);
	   zero_flag_from_alu <= '0'; 
	   wait for CLOCK_PERIOD;
       
       --lw x11 8(x12)
       instruction := x"00862583";
	   opcode         <= operation_carve_out(instruction);
	   funct3_field   <= funct3_carve_out(instruction);
	   funct7_field   <= funct7_carve_out(instruction);
	   funct7b5_field <= funct7b5_carve_out(instruction);
	   zero_flag_from_alu <= '0'; 
	   wait for CLOCK_PERIOD;
	   
	   --s type
	   --sw x10 4(x12) 00a62223
       instruction := x"00a62223";
	   opcode         <= operation_carve_out(instruction);
	   funct3_field   <= funct3_carve_out(instruction);
	   funct7_field   <= funct7_carve_out(instruction);
	   funct7b5_field <= funct7b5_carve_out(instruction);
	   zero_flag_from_alu <= '0'; 
	   wait for CLOCK_PERIOD;
       
       --b tyoe
       --beq
       --bne
       
       --blt
       --bge
       --bltu
       --bgeu
       
       --label:
       -- addi x15 x15 0xa5
       
       --beq x1 x2 label
       instruction := x"fe208ee3";
	   opcode         <= operation_carve_out(instruction);
	   funct3_field   <= funct3_carve_out(instruction);
	   funct7_field   <= funct7_carve_out(instruction);
	   funct7b5_field <= funct7b5_carve_out(instruction);
	   zero_flag_from_alu <= '0'; 
	   wait for CLOCK_PERIOD;
	   
	   instruction := x"fe208ee3";
	   opcode         <= operation_carve_out(instruction);
	   funct3_field   <= funct3_carve_out(instruction);
	   funct7_field   <= funct7_carve_out(instruction);
	   funct7b5_field <= funct7b5_carve_out(instruction);
	   zero_flag_from_alu <= '1'; 
	   wait for CLOCK_PERIOD;
	   
       --bne x2 x3 label
       instruction := x"fe311ce3";
	   opcode         <= operation_carve_out(instruction);
	   funct3_field   <= funct3_carve_out(instruction);
	   funct7_field   <= funct7_carve_out(instruction);
	   funct7b5_field <= funct7b5_carve_out(instruction);
	   zero_flag_from_alu <= '0'; 
	   wait for CLOCK_PERIOD;
	   
	   instruction := x"fe311ce3";
	   opcode         <= operation_carve_out(instruction);
	   funct3_field   <= funct3_carve_out(instruction);
	   funct7_field   <= funct7_carve_out(instruction);
	   funct7b5_field <= funct7b5_carve_out(instruction);
	   zero_flag_from_alu <= '1'; 
	   wait for CLOCK_PERIOD;
       
       --j type
       --jal
       
       --label:
       -- addi x15 x15 0xa5
       --
       --jal x1 label
       instruction := x"ffdff0ef";
	   opcode         <= operation_carve_out(instruction);
	   funct3_field   <= funct3_carve_out(instruction);
	   funct7_field   <= funct7_carve_out(instruction);
	   funct7b5_field <= funct7b5_carve_out(instruction);
	   zero_flag_from_alu <= '1'; 
	   wait for CLOCK_PERIOD;
 
	
	wait;

	end process;
	
end tb;