----------------------------------------------------------------------------------
-- Company: FAU Erlangen - Nuernberg
-- Engineer: Vittorio Serra and Cedric Donges
--
-- Description: Control unit for RISC-V 32I, single cycle processor
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.utils.ALL;
use work.rv32i_defs.ALL;

entity clock_divider is
    Port ( divider   : IN std_logic_vector (31 downto 0);
           clock_in  : IN std_logic;
           clock_out : OUT std_logic);
end clock_divider;

architecture bh of clock_divider is

begin

    process(clock_in, divider)
    
    variable int_val : std_logic_vector(31 downto 0) := x"00000000";
    
    
    begin
    
    if(int_val /= divider) then
    
        int_val := std_logic_vector(unsigned(int_val) + 1);
        clock_out <='0';
    else 
    
        int_val := x"00000000";
        clock_out <= '1';
        
        report "---sending clock to following units now---" severity warning;
        
    end if;
    
    end process;

end bh;
