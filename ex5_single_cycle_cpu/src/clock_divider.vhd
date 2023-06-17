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
    Generic (divider : IN integer);
    Port ( clock_in : IN std_logic;
           pc_ce_out : OUT std_logic;
           alu_en_out : OUT std_logic;
           regfile_we_out : OUT std_logic);
end clock_divider;

architecture bh of clock_divider is
    signal chain_int : std_logic_vector(0 to divider - 1) := (0 => '1', others => '0');
begin
    pc_ce_out <= chain_int(chain_int'right);
    alu_en_out <= chain_int(3);
    regfile_we_out <= chain_int(6);
    process (clock_in, chain_int)
    begin
        if (rising_edge(clock_in)) then
            for i in chain_int'range loop
                if (i = chain_int'right) then
                    chain_int(0) <= chain_int(i);
                else 
                    chain_int(i + 1) <= chain_int(i);
                end if; 
            end loop;
        end if;
    end process;
end bh;
