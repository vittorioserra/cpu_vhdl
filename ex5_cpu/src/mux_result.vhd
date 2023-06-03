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

entity mux_result is
    Port(
        reg_selection : IN result_ctrl;
        
        alures_in : IN std_logic_vector(xlen_range);
        data_mem_in : IN std_logic_vector(xlen_range);
        --pc_up_in : IN std_logic_vector(xlen_range);
        
        muxed_out : OUT std_logic_vector(xlen_range)
    );
end mux_result;

architecture bh of mux_result is

begin

process(reg_selection, alures_in, data_mem_in) begin

    case (reg_selection) is
    
        when alu_res =>
            muxed_out <= alures_in;
        when data_mem =>
            muxed_out <= data_mem_in;
        --when prog_ctr_up =>
            --muxed_out <= pc_up_in;
        when others => 
            muxed_out <= (xlen_range => '-');
    
    end case;
    
end process;

end bh;
