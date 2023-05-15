----------------------------------------------------------------------------------
-- Company: FAU Erlangen - Nuernberg
-- Engineer: Vittorio Serra and Cedric Donges
--
-- Description: ALU with sync result and async lowest bit of result
----------------------------------------------------------------------------------

package alu_types is
    type alu_func is (
        func_add,   -- Addition
        func_sub,   -- Subtraction
        func_slts,  -- Set (lowest bit) when less than (signed)
        func_sltu,  -- Set (lowest bit) when less than (unsigned)
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
        async_lsb : OUT std_logic;
        res : OUT std_logic_vector(port_width - 1 downto 0));
end alu;

architecture bh of alu is
    function set_lsb(value: boolean) return std_logic_vector is
    begin
        if (value) then
            return (port_width - 1 downto 1 => '0') & '1';
        else
            return (port_width - 1 downto 0 => '0');
        end if;
    end function;

    signal async_result : std_logic_vector(port_width - 1 downto 0);
    signal op1u : unsigned(port_width - 1 downto 0);
    signal op1s : signed(port_width - 1 downto 0);
    signal op2u : unsigned(port_width - 1 downto 0);
    signal op2s : signed(port_width - 1 downto 0);
    signal op2ui : integer;
begin
    op1u <= unsigned(op1);
    op1s <= signed(op1);
    op2u <= unsigned(op2);
    op2s <= signed(op2);
    op2ui <= vec2ui(op2);

    with func select async_result <=
        std_logic_vector(op1u + op2u)              when func_add,
        std_logic_vector(op1u - op2u)              when func_sub,
        set_lsb(op1s < op2s)                       when func_slts,
        set_lsb(op1u < op2u)                       when func_sltu,
        op1 xor op2                                when func_xor,
        op1 or op2                                 when func_or,
        op1 and op2                                when func_and,
        std_logic_vector(shift_left(op1u, op2ui))  when func_sll,
        std_logic_vector(shift_right(op1u, op2ui)) when func_srl,
        std_logic_vector(shift_right(op1s, op2ui)) when func_sra,
        (others => '0')                            when others;
    
    async_lsb <= async_result(0) when reset_n = '1' else '0';

    process(clock, reset_n)
    begin
        if (reset_n = '0') then
            res <= (others => '0');
        elsif (rising_edge(clock)) then
            res <= async_result;
        end if;
    end process;
end bh;
