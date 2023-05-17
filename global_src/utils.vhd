----------------------------------------------------------------------------------
-- Company: FAU Erlangen - Nuernberg
-- Engineer: Vittorio Serra and Cedric Donges
--
-- Description: register file, double async read, single sync write, reg0 is always 0
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.MATH_REAL.ALL;

package utils is
    function get_bit_count(width : positive) return positive;
    function vec2ui(x : std_logic_vector) return integer;
    function ui2vec(x : integer; width : positive) return std_logic_vector;
end package utils;

package body utils is
    function get_bit_count(width : positive) return positive is
        begin
            return integer(ceil(log2(real(width))));
        end function;
    function vec2ui(x : std_logic_vector) return integer is
        begin
            return to_integer(unsigned(x));
        end function;
    function ui2vec(x : integer; width : positive) return std_logic_vector is
        begin
            return std_logic_vector(to_unsigned(x, width));
        end function;
end package body utils;
