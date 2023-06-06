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
    port(
        clock, reset    : IN std_logic;
        pc_observe      : OUT std_logic_vector(xlen_range);
        instr_observe   : OUT std_logic_vector(xlen_range);
        mem_we_observe,  regfile_we_observe   : OUT std_logic;
        alu_res_observe, data_mem_out_observe : OUT std_logic_vector(xlen_range);
        res_observe     : OUT std_logic_vector(xlen_range)
        );
end processor_single_cycle;

architecture bh of processor_single_cycle is

--constants
constant CLOCK_PERIOD : time := 10 ns;
--signals

--general signals

--instr_mem
--ingoing
    signal pc_value : std_logic_vector(xlen_range);
--outgoing
    signal instr_mem_out : std_logic_vector(xlen_range);

--regfile
--ingoing
    --clock, already there
    --reset_n, pegged to '1' as not used in design for now
    signal dest_reg_we_ctrl : std_logic;
    --register_select(s) --> carved out from instr_mem_out
    signal result : std_logic_vector(xlen_range);
--outgoing
    signal rs1_regfile_out : std_logic_vector(xlen_range);
    signal rs2_regfile_out : std_logic_vector(xlen_range);
    
--alu
--ingoing
    --clock, already there
    --reset_n, pegged to '1', unused
    signal alu_func_ctrl : alu_func;
    --op1 is the out value from the regfile
    signal op2_mux_out : std_logic_vector(xlen_range);
--outgoing
    signal alu_res_out : std_logic_vector(xlen_range);
    signal zero_flag_out : std_logic;

--data memory
--ingoing 
    --clock, already there
    --p1_enable, pegged to 0, not used
    --p2_enable, pegged to 1, not used for now
    signal data_mem_we : std_logic; 
 --outgoing
    signal data_mem_out : std_logic_vector(xlen_range);
    
--alu reg_b mux
--ingoing
    signal alu_regb_sel : op2_select;
    --rs2_regfile_out
    signal extended_unit_out : std_logic_vector(xlen_range);
--outgoing
    --op2_muxed_out, already existing
    
--result_ctrl_mux
--ingoing
    signal result_select_mux : result_ctrl;
    
--extension unit
--ingoing
    signal extension_selection : extension_control_type;
    
--jump unit
    signal jump_out : std_logic_vector(xlen_range);
 
--pc
    signal jump_enable : std_logic;
    signal pc_next : std_logic_vector(xlen_range);
    signal clock_divided : std_logic;
    signal pc_enable_int : std_logic;
    
--signals for simulation purposes, mapped to a port
    --instr_mem_addr (pc)
    --instr_mem_out
    --extension_unit_out
    --result
    --alu_res
 
--the following things are just there for the testbench
--    variable pc_observe : std_logic_vector(xlen_range);
--    variable instr_observe:  std_logic_vector(xlen_range);
--    variable mem_we_observe, regfile_we_observe : std_logic;
--    variable alu_res_observe, data_mem_out_observe : std_logic_vector(xlen_range);
--    variable res_observe : std_logic_vector(xlen_range);
 
 
begin 

    INSTR_MEM : entity work.mem
        port map(
            clock => clock,
            p1_enable => '1',
            p2_enable => '0',
            p2_write_enable => '0',            
            p1_addr => pc_value(8 downto 0),
            p2_addr => (8 downto 0 => '0'),
            p2_val_in => x"00000000",
            p1_val_out => instr_mem_out,
            p2_val_out => open
        );

    REGFILE : entity work.regfile
        port map(
            clock => clock,
            reset_n=> '1', --unused, pegged to '1'
            rd_write_enable => dest_reg_we_ctrl,
            rs1_select => instr_mem_out(19 downto 15),
            rs2_select => instr_mem_out(24 downto 20),
            rd_select  => instr_mem_out(11 downto  7),
            rs1_value  => rs1_regfile_out,
            rs2_value  => rs2_regfile_out,
            rd_value   => result
        );
        
    ALU : entity work.alu
        port map(
            reset_n   => '1', --unused, pegged to '1'
            clock     => clock,
            func      => alu_func_ctrl,
            op1       => rs1_regfile_out,
            op2       => op2_mux_out,
            res       => alu_res_out,
            zero_flag => zero_flag_out
        );
     
     DATA_MEM : entity work.mem
        port map(
            clock => clock,
            p1_enable => '0',
            p2_enable => '1',
            p2_write_enable => data_mem_we,            
            p1_addr    => (8 downto 0 => '0'),
            p2_addr    => alu_res_out(8 downto 0),
            p2_val_in  => rs2_regfile_out,
            p1_val_out => open,
            p2_val_out => data_mem_out
        );

    ALU_MUX : entity work.mux_alu_reg_b
        port map(
            reg_selection => alu_regb_sel,
        
            rs2_in       => rs2_regfile_out,
            immediate_in => extended_unit_out,
        
            muxed_out    => op2_mux_out
        );
        
     DATA_OUT_MUX : entity work.mux_result
        port map(
            reg_selection => result_select_mux,
            alures_in     => alu_res_out,
            data_mem_in   => data_mem_out,
            muxed_out     => result,
            pc_up_in      => pc_next
        );
        
     EXTENSION_UNIT : entity work.extension_unit
        port map(
            select_extension => extension_selection,
            input_to_extend => instr_mem_out(31 downto 7),
            extended_output => extended_unit_out
        );
     
     JUMP_UNIT : entity work.jump_unit
        port map(
            pc_in => pc_value,
            immediate_extended_in => extended_unit_out,
            jump_addr_out => jump_out
        ); 
     
     PROG_CTR : entity work.program_counter
        port map(
            clock => clock,--clock_divided,
            enable=> pc_enable_int,--'1', 
            reset_n=> '0',
            load => jump_enable,
		    load_value => jump_out,
		    pc_value => pc_value,
		    pc_value_next => pc_next
        );
        
     CTRL_UNIT : entity work.ctrl_u_v2
        port map(
            pc_jmp_en => jump_enable,
            data_mem_we => data_mem_we,
            alu_ctrl => alu_func_ctrl,
            alu_op2_mux_sel => alu_regb_sel,
            extension_unit_ctrl => extension_selection,
            regfile_wen => dest_reg_we_ctrl,
            result_out_mux_sel => result_select_mux,
                        
            opcode => instr_mem_out(6 downto 0),
            funct3_field => instr_mem_out(14 downto 12),
            funct7b5_field => instr_mem_out(20),
            funct7_field => instr_mem_out(31 downto 25),
            zero_flag_from_alu => zero_flag_out -- added for consistency, as of now, quite useless
        );
        
     --CLK_DIVIDER : entity work.clock_divider
     --   port map(
     --   divider => x"00000100",
     --   clock_in => clock,
     --   clock_out => clock_divided
     --   );
        
     CLK_HOLDER : entity work.clock_hold_em
        port map(
        clock => clock,
        pc_en => pc_enable_int,
        result => result
        );

    --general observing signals
    pc_observe <= pc_value;    
    instr_observe <= instr_mem_out;  
    mem_we_observe <= data_mem_we;
    alu_res_observe <= alu_res_out;
    res_observe <= result;
    regfile_we_observe <= dest_reg_we_ctrl;
    data_mem_out_observe <= data_mem_out;
    

end bh;
