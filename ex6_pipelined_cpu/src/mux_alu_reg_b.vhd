----------------------------------------------------------------------------------
-- Company: FAU Erlangen - Nuernberg
-- Engineer: Vittorio Serra and Cedric Donges
--
-- Description: Mux for the alu reg-b for RISC-V 32I, single cycle processor
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.utils.ALL;
use work.rv32i_defs.ALL;

entity mux_alu_reg_b is
    Port(
        reg_selection : IN op2_select;
        
        rs2_in : IN std_logic_vector(xlen_range);
        immediate_in : IN std_logic_vector(xlen_range);
        
        muxed_out : OUT std_logic_vector(xlen_range)
    );
end mux_alu_reg_b;

architecture bh of mux_alu_reg_b is

begin

process(reg_selection, rs2_in, immediate_in) begin

    if reg_selection = select_rs2 then
        muxed_out <= rs2_in;
    else 
        muxed_out <= immediate_in;
    end if;
    
end process;

end bh;
