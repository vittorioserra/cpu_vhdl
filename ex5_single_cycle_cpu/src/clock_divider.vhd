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
    Port ( divider   : IN integer;
           clock_in  : IN std_logic;
           clock_out : OUT std_logic);
end clock_divider;

architecture bh of clock_divider is

signal int_val: integer:=1;


begin

    process(clock_in, divider)
        
    begin
    
    if(rising_edge(clock_in) and int_val /= integer(divider)) then
        int_val <= int_val + 1;
        clock_out <='0';
    end if;    
    
    --else 
        if(rising_edge(clock_in) and int_val = integer(divider)) then
    
            int_val <= 0;
            clock_out <= '1';
            
            end if;
        --report "---sending clock to following units now---" severity warning;
        
    --end if;
    
    end process;

end bh;
