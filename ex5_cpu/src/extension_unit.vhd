----------------------------------------------------------------------------------
-- Company: FAU Erlangen - Nuernberg
-- Engineer: Vittorio Serra and Cedric Donges
--
-- Description: Extension unit for RISC-V 32I
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.utils.ALL;
use work.rv32i_defs.ALL;

entity extension_unit is
    Port(
        select_extension : IN extension_control_type;
        input_to_extend : IN std_logic_vector(31 downto 7);
        extended_output : OUT std_logic_vector(xlen_range));
end extension_unit;

architecture bh of extension_unit is
begin
process(input_to_extend, select_extension) begin
    case select_extension is
    --I type
    when i_type =>
        extended_output<=(31 downto 12 => input_to_extend(31)) & input_to_extend(31 downto 20);
    -- i type immediate shift
    when i_type_shift =>
        extended_output <= (31 downto 26 => '0') & input_to_extend(24 downto 20);
    --S architecture
    when s_type =>
        extended_output<=(31 downto 12 => input_to_extend(31)) & input_to_extend(31 downto 25) & input_to_extend(11 downto 7);
    --B type
    when b_type =>
        extended_output<=(31 downto 12 => input_to_extend(31)) & input_to_extend(7) & input_to_extend(30 downto 25) & input_to_extend(11 downto 8) & '0';
    --J type
    when j_type =>
        extended_output<=(31 downto 20 => input_to_extend(31))& input_to_extend(19 downto 12) & input_to_extend(20) & input_to_extend(30 downto 21) & '0';
    when others =>
        extended_output<=(31 downto 0 => '-');
    end case;
end process;
end bh;