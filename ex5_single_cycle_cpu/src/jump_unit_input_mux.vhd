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

entity jump_unit_input_mux is
 Port(
        input_sel : IN jump_reg_sel;
        
        rs1_in : IN std_logic_vector(xlen_range);
        immediate_in : IN std_logic_vector(xlen_range);
        
        muxed_out : OUT std_logic_vector(xlen_range)
    );
end jump_unit_input_mux;

architecture bh of jump_unit_input_mux is

begin

process(input_sel, rs1_in, immediate_in) begin

    if input_sel = select_rs1 then
        muxed_out <= rs1_in;
    else 
        muxed_out <= immediate_in;
    end if;
    
end process;

end bh;
