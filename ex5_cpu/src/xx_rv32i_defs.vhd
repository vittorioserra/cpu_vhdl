----------------------------------------------------------------------------------
-- Company: FAU Erlangen - Nuernberg
-- Engineer: Vittorio Serra and Cedric Donges
--
-- Description: Global Definitions (Types, Constants) for the RV32I CPU
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.utils.ALL;

package rv32i_defs is
    constant xlen : positive := 32;                                         -- 32
    constant xlen_addr_width : positive := get_bit_count(xlen / 8);         -- 2
    subtype xlen_range is natural range xlen - 1 downto 0;                  -- 31 downto 0
    subtype addr_range is natural range xlen - 1 downto xlen_addr_width;    -- 31 downto 2
    subtype pc_range is natural range xlen - 1 downto 1;                    -- 31 downto 1
    subtype instr_range is natural range 31 downto 0;                       -- 32 bits for instructions
    subtype reg_range is natural range 4 downto 0;                          -- 5 bits for register select

    constant oplen : positive := 7;
    subtype oplen_range is natural range oplen - 1 downto 0;
    
    constant funct3len : positive := 3;
    subtype funct3_range is natural range funct3len - 1 downto 0;
    
    type d_bus_mosi is record
        addr            : std_logic_vector(addr_range);
        data            : std_logic_vector(xlen_range);
        write_enable    : std_logic_vector(xlen / 8 - 1 downto 0);
    end record;

    type d_bus_miso is record
        data            : std_logic_vector(xlen_range);
    end record;

    type i_bus_mosi is record
        addr            : std_logic_vector(addr_range);
    end record;

    type i_bus_miso is record
        data            : std_logic_vector(xlen_range);
    end record;
    
    type alu_func is (
        func_add,   -- Addition
        func_sub,   -- Subtraction
        func_slts,  -- Set (lowest bit) when less than (signed)
        func_sltu,  -- Set (lowest bit) when less than (unsigned)
        func_seq,   -- Set (lowest bit) when equal
        func_xor,   -- bitwise XOR
        func_or,    -- bitwise OR
        func_and,   -- bitwise AND
        func_sll,   -- Shift left logically
        func_srl,   -- Shift right logically
        func_sra);  -- Shift right arithmetically
        
    type mem_ctrl is (
        none,           -- do nothing
        mem_write_w,    -- write Word                = 32 bits
        mem_write_h,    -- write half Word           = 16 bits
        mem_write_b,    -- write Byte                =  8 bits
        mem_read_w,     -- read Word                 = 32 bits
        mem_read_hs,    -- read half Word (signed)   = 16 bits
        mem_read_hu,    -- read half Word (unsigned) = 16 bits
        mem_read_bs,    -- read Byte (signed)        =  8 bits
        mem_read_bu);   -- read Byte (unsigned)      =  8 bits

    type op1_select is (
        select_rs1,         -- op1 is rs1
        select_pc_now,      -- op1 is pc of the instr
        select_pc_next);    -- op1 is pc of the next instr
        
    type op2_select is (
        select_rs2,         -- op2 is rs2 --0
        select_imm);        -- op2 is immediate value --1

    type jump_base_select is (
        select_rs1,         -- jump base is rs1
        select_pc_now);     -- jump base is pc of the instr
        
    type jump_control_type is (
        jump_none,          -- dont jump
        jump_branch,        -- jump if condition is true
        jump_branch_n,      -- jump if condition is false
        jump_definitive);   -- jump definitive
        
    type extension_control_type is (
        i_type,             --i type instrutcion --00
        b_type,             --b type instruction --10
        s_type,             --s type instruction --01
        j_type,             --j type instruction --11
        complement          -- this is equal to "--"
        );
        
     type result_ctrl is(
        alu_res,    --00
        data_mem   --01
        --prog_ctr_up --10
    );
    
    type internal_alu_op is (
        immediate_add,     --00
        immediate_sub,     --01
        decode_from_funct3 -- others
        );
    
end rv32i_defs;

package body rv32i_defs is
end rv32i_defs;
