----------------------------------------------------------------------------------
-- Company: FAU Erlangen - Nuernberg
-- Engineer: Vittorio Serra and Cedric Donges
--
-- Description: testbench for single cicle processor
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.utils.ALL;
use work.rv32i_defs.ALL;

entity processor_single_cycle_tb is
--  Port ( );
end processor_single_cycle_tb;

architecture bh of processor_single_cycle_tb is

    constant CLOCK_PERIOD : time := 10 ns;
    
    signal clock                : std_logic;
    signal pc_observe           : std_logic_vector(xlen_range);
    signal instr_observe        : std_logic_vector(xlen_range);
    signal mem_we_observe       : std_logic;
    signal regfile_we_observe   : std_logic;
    signal alu_res_observe      : std_logic_vector(xlen_range);
    signal data_mem_out_observe : std_logic_vector(xlen_range);
    signal res_observe          : std_logic_vector(xlen_range);
    signal pc_enable_observe    : std_logic;
    signal alu_op_observe        :  alu_func;                    
    signal alu_reg2_mux_observe  :  op2_select;                  
    signal alu_operand_2_observe :  std_logic_vector(xlen_range);   
    signal alu_operand_1_observe :  std_logic_vector(xlen_range);
    signal reset                 : std_logic;


begin

    DUT : entity work.processor_single_cycle
		port map (
		clock => clock,
		reset => reset,                           
        pc_observe           => pc_observe           ,
        instr_observe        => instr_observe        ,
        mem_we_observe       => mem_we_observe       ,
        regfile_we_observe   => regfile_we_observe   ,
        alu_res_observe      => alu_res_observe      ,
        data_mem_out_observe => data_mem_out_observe ,
        res_observe          => res_observe          ,
        pc_enable_observe    => pc_enable_observe	
        );
		
   	gen_clk : process
	begin
		clock <= '1';
		wait for CLOCK_PERIOD / 2;
		clock <= '0';
		wait for CLOCK_PERIOD / 2;
	end process;
	
	simuli : process
	begin
	
	reset <= '0';
	wait for CLOCK_PERIOD/2;
	reset <= '1';
	wait for CLOCK_PERIOD/2;
	
	wait;
	end process;


end bh;
