----------------------------------------------------------------------------------
-- Company: FAU Erlangen - Nuernberg
-- Engineer: Vittorio Serra and Cedric Donges
--
-- Description: Global Definitions (Types, Constants) for the RV32I CPU
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

package rv32i_defs is
    constant xlen : positive := 32;
    subtype xlen_range is natural range xlen - 1 downto 0;
    
    type d_bus_mosi is record
        addr            : std_logic_vector(xlen_range);
        data            : std_logic_vector(xlen_range);
        write_enable    : std_logic_vector(xlen / 8 - 1 downto 0);
    end record;

    type d_bus_miso is record
        data            : std_logic_vector(xlen_range);
    end record;

    type i_bus_mosi is record
        addr            : std_logic_vector(xlen_range);
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
end rv32i_defs;

package body rv32i_defs is
end rv32i_defs;
