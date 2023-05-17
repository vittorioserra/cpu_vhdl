----------------------------------------------------------------------------------
-- Company: FAU Erlangen - Nuernberg
-- Engineer: Vittorio Serra and Cedric Donges
--
-- Description: ALU for RISC-V 32I
----------------------------------------------------------------------------------

package alu_types is
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
end alu_types;

package body alu_types is
end alu_types;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.utils.ALL;
use work.alu_types.ALL;

entity alu is
    Generic(
        port_width : positive := 32);
    Port(
        reset_n : IN std_logic;
        clock: IN std_logic;
        func : IN alu_func;
        op1, op2 : IN std_logic_vector(port_width - 1 downto 0);
        res : OUT std_logic_vector(port_width - 1 downto 0));
end alu;

architecture bh of alu is
    constant func_count : positive := alu_func'pos(alu_func'high) + 1;
    type op_reg_t is array (func_count - 1 downto 0) of std_logic_vector(port_width - 1 downto 0);
    signal op1_reg : op_reg_t;
    signal op2_reg : op_reg_t;
    signal func_reg : alu_func;
begin
    process (clock, reset_n)
    begin
        if (reset_n = '0') then
            op1_reg <= (others => (others => '0'));
            op2_reg <= (others => (others => '0'));
            func_reg <= func_add;
        elsif (rising_edge(clock)) then
            op1_reg(alu_func'pos(func)) <= op1;
            op2_reg(alu_func'pos(func)) <= op2;
            func_reg <= func;
        end if;
    end process;

    process (op1_reg, op2_reg, func_reg)
        function get_v(op: op_reg_t; index: alu_func) return std_logic_vector is
        begin
            return op(alu_func'pos(index));
        end function;
        function get_u(op: op_reg_t; index: alu_func) return unsigned is
        begin
            return unsigned(op(alu_func'pos(index)));
        end function;
        function get_s(op: op_reg_t; index: alu_func) return signed is
        begin
            return signed(op(alu_func'pos(index)));
        end function;
        function get_ui(op: op_reg_t; index: alu_func) return integer is
        begin
            return to_integer(unsigned(op(alu_func'pos(index))));
        end function;
    begin
        case func_reg is
            when func_add  => res <= std_logic_vector(get_u(op1_reg, func_add) + get_u(op2_reg, func_add));
            when func_sub  => res <= std_logic_vector(get_u(op1_reg, func_sub) - get_u(op2_reg, func_sub));
            when func_slts => res <= bool2vec(get_s(op1_reg, func_slts) < get_s(op2_reg, func_slts), port_width);
            when func_sltu => res <= bool2vec(get_u(op1_reg, func_sltu) < get_u(op2_reg, func_sltu), port_width);
            when func_seq  => res <= bool2vec(get_u(op1_reg, func_seq)  = get_u(op2_reg, func_seq),  port_width);
            when func_xor  => res <= get_v(op1_reg, func_xor) xor get_v(op2_reg, func_xor);
            when func_or   => res <= get_v(op1_reg, func_or)  or  get_v(op2_reg, func_or);
            when func_and  => res <= get_v(op1_reg, func_and) and get_v(op2_reg, func_and);
            when func_sll  => res <= std_logic_vector(shift_left( get_u(op1_reg, func_sll), get_ui(op2_reg, func_sll)));
            when func_srl  => res <= std_logic_vector(shift_right(get_u(op1_reg, func_srl), get_ui(op2_reg, func_srl)));
            when func_sra  => res <= std_logic_vector(shift_right(get_s(op1_reg, func_sra), get_ui(op2_reg, func_sra)));
            when others    => res <= (others => '0');
        end case;
    end process;
end bh;
