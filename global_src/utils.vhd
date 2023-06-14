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
--library work;
--use work.rv32i_defs.ALL;

package utils is
    function get_bit_count(width : positive) return positive;
    function vec2ui(x : std_logic_vector) return integer;
    function ui2vec(x : integer; width : positive) return std_logic_vector;
    function si2vec(x : integer; width : positive) return std_logic_vector;
    function bool2vec(value : boolean; width : positive) return std_logic_vector;
    function ends_with(haystack : string; needle : string) return boolean;
    function is_selected(chip_addr : std_logic_vector; addr : std_logic_vector) return boolean;
    function sel(selector : boolean; res_true, res_false : std_logic_vector) return std_logic_vector;
    function sel(selector : boolean; res_true, res_false : std_logic) return std_logic;
    function sel(selector : boolean; res_true, res_false : integer) return integer;
    function opcode_carve_out(opcode : std_logic_vector(31 downto 0)) return std_logic_vector;
    function funct3_carve_out(opcode : std_logic_vector(31 downto 0)) return std_logic_vector;
    function funct7_carve_out(opcode : std_logic_vector(31 downto 0)) return std_logic_vector;
    --function align_in_word(address : std_logic_vector(31 downto 0)) return mem_alignment;
    --function mem_mask(alignment : mem_alignment; qty mem_read_qty; data_word : std_logic_vector(31 downto 0)) return std_logic_vector; 
--    function move_bits(src_vec : std_logic_vector; src_right : integer; length : integer; dst_right : integer; sign_ext : boolean) return std_logic_vector;
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
    function si2vec(x : integer; width : positive) return std_logic_vector is
    begin
        return std_logic_vector(to_signed(x, width));
    end function;
    function bool2vec(value: boolean; width: positive) return std_logic_vector is
    begin
        if (value) then
            return ui2vec(1, width);
        else
            return ui2vec(0, width);
        end if;
    end function;
    function ends_with(haystack: string; needle: string) return boolean is
        variable needle_cursor : integer := 1;
    begin
        if (haystack'length < needle'length or needle'length = 0) then
            return false;
        end if;
        for hay_cursor in haystack'range loop
            if (haystack(hay_cursor) = needle(needle_cursor)) then
                needle_cursor := needle_cursor + 1;
            else
                needle_cursor := 1;
            end if;
        end loop;
        return needle_cursor = needle'length + 1;
    end function;
    function is_selected(chip_addr : std_logic_vector; addr : std_logic_vector) return boolean is
    begin
        return addr(addr'high downto addr'high - chip_addr'length + 1) = chip_addr;
    end function;
    function sel(selector : boolean; res_true, res_false : std_logic_vector) return std_logic_vector is
    begin
        if (selector) then
            return res_true;
        else
            return res_false;
        end if;
    end function;
    function sel(selector : boolean; res_true, res_false : std_logic) return std_logic is
    begin
        if (selector) then
            return res_true;
        else
            return res_false;
        end if;
    end function;
    function sel(selector : boolean; res_true, res_false : integer) return integer is
    begin
        if (selector) then
            return res_true;
        else
            return res_false;
        end if;
    end function;
    
    --control unit instructions
    
    function opcode_carve_out(opcode : std_logic_vector(31 downto 0)) return std_logic_vector is 
    variable op_outcarved : std_logic_vector(6 downto 0);
    begin
    
    op_outcarved := opcode(6 downto 0);
    
    return op_outcarved;
    end function;
    
    function funct3_carve_out(opcode : std_logic_vector(31 downto 0)) return std_logic_vector is 
    variable funct3_outcarved : std_logic_vector(2 downto 0);
    begin
    
    funct3_outcarved := opcode(14 downto 12);
    
    return funct3_outcarved;
    end function;
    
    function funct7_carve_out(opcode : std_logic_vector(31 downto 0)) return std_logic_vector is 
    variable funct7_outcarved : std_logic_vector(31 downto 25);
    begin
    
    funct7_outcarved := opcode(31 downto 25);
    
    return funct7_outcarved;
    end function;
    
--    function align_in_word(address : std_logic_vector(31 downto 0)) return mem_alignment is
--    variable mem_align : mem_alignment;

--    begin
    
--    case address(1 downto 0) is
--        when "00" => mem_align:=lower_byte;
--        when "01" => mem_align:=medium_lower_byte;
--        when "01" => mem_align:=medium_upper_byte;
--        when "11" => mem_align:=upper_byte;
--    end case;
    
--    return mem_align;
--    end function;

--    function move_bits(src_vec : std_logic_vector; src_right : integer; length : integer; dst_right : integer; sign_ext : boolean)
--        return std_logic_vector is
--        variable dst_vec : std_logic_vector(xlen_range);
--        -- example
--        -- scr 3
--        -- dsr 2
--        -- len 3
--        -- sgn 1
--        -- src_vec 8 7 6 5 4 3 2 1
--        -- dst_vec 6 6 6 6 5 4 0 0
--        --       i 7 6 5 4 3 2 1 0
--    begin
--        for i in ret'range loop
--            if (i >= dst_right + length - 1) then
--                dst_vec(i) := src_vec(src_right + length - 1) when sign_ext else '0';
--            elsif (i >= dst_right) then
--                dst_vec(i) := src_vec(i - dst_right + src_right);
--            else
--                dst_vec(i) := '0';
--            end if;
--        end loop;
--        return dst_vec;
--    end function;
 
end package body utils;
