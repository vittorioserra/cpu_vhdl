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

entity clock_hold_em is
    Port ( clock : in STD_LOGIC;
           result : in STD_LOGIC_VECTOR (31 downto 0);
           pc_en : out STD_LOGIC);
end clock_hold_em;

architecture bh of clock_hold_em is

signal old_result : std_logic_vector(xlen_range) := ( others => '0');

begin

process(clock, result)
begin

    if(rising_edge(clock)) then
        
        if(old_result = result) then
        
            old_result <= result;
            pc_en <= '1';
        
        else
        
            pc_en <= '0';
        
        end if;
        
    end if;

end process;

end bh;
