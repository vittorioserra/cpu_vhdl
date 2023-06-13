library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.utils.ALL;
use work.rv32i_defs.ALL;

entity jump_unit is
    port (
    pc_in : IN std_logic_vector(xlen_range);
    immediate_extended_in : IN std_logic_vector(xlen_range);
    jump_addr_out : OUT std_logic_vector(xlen_range)
    );
end jump_unit;

architecture bh of jump_unit is

begin

    jump_addr_out <= std_logic_vector(unsigned(pc_in) + unsigned(immediate_extended_in));

end bh;
