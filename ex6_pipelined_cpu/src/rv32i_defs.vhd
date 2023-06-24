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
    constant xlen : positive := 32;                                             -- 32 bit busses and mem blocks
    constant xlen_subaddr_width : positive := get_bit_count(xlen / 8);          -- 2
    subtype xlen_range is natural range xlen - 1 downto 0;                      -- 31 downto 0
    subtype addr_range is natural range xlen - 1 downto xlen_subaddr_width;     -- 31 downto 2
    subtype instr_range is natural range 31 downto 0;                           -- 32 bits for instructions
    
    constant reg_count : positive := 32;                                        -- 32 registers
    subtype reg_range is natural range get_bit_count(reg_count) - 1 downto 0;   -- 4 downto 0
    constant reg_zero : std_logic_vector(reg_range) := (others => '0');
    constant reg_sp   : std_logic_vector(reg_range) := "00010"; --reg 2 is stack pointer
    constant compressed_offset : std_logic_vector   := "01000"; --compressed ISA registers have an offset which begins at x8

    type d_bus_mosi_rec is record
        addr            : std_logic_vector(addr_range);
        data            : std_logic_vector(xlen_range);
        write_enable    : std_logic_vector(xlen / 8 - 1 downto 0);
    end record;

    type d_bus_miso_rec is record
        data            : std_logic_vector(xlen_range);
    end record;

    type i_bus_mosi_rec is record
        addr            : std_logic_vector(addr_range);
    end record;

    type i_bus_miso_rec is record
        data            : std_logic_vector(xlen_range);
    end record;
    
    type ex_func_type is (
        f_add,      -- Addition
        f_sub,      -- Subtraction
        f_slts,     -- Set (lowest bit) when less than (signed)
        f_sltu,     -- Set (lowest bit) when less than (unsigned)
        f_seq,      -- Set (lowest bit) when equal
        f_xor,      -- bitwise XOR
        f_or,       -- bitwise OR
        f_and,      -- bitwise AND
        f_sll,      -- Shift left logically
        f_srl,      -- Shift right logically
        f_sra);     -- Shift right arithmetically
        
    type mem_mode_type is (
        m_pass,     -- data_out = data_in_reg
        m_rw,       -- read Word                 = 32 bits
        m_rhs,      -- read half Word (signed)   = 16 bits
        m_rhu,      -- read half Word (unsigned) = 16 bits
        m_rbs,      -- read Byte (signed)        =  8 bits
        m_rbu,      -- read Byte (unsigned)      =  8 bits
        m_ww,       -- write Word                = 32 bits
        m_wh,       -- write half Word           = 16 bits
        m_wb);      -- write Byte                =  8 bits

    type ex_op1_type is (
        sel_zero,   -- op1 is 0
        sel_rs1,    -- op1 is rs1
        sel_pc,     -- op1 is pc of the instr
        sel_pc_n);  -- op1 is pc of the next instr
        
    type ex_op2_type is (
        sel_rs2,    -- op2 is rs2
        sel_imm);   -- op2 is immediate value

    type addr_base_type is (
        sel_rs1,    -- jump base is rs1
        sel_pc);    -- jump base is pc of the instr
        
    type jump_mode_type is (
        j_n,        -- dont jump
        j_c,        -- jump if condition is true
        j_c_n,      -- jump if condition is false
        j_y);       -- jump definitive

end rv32i_defs;

package body rv32i_defs is
end rv32i_defs;
