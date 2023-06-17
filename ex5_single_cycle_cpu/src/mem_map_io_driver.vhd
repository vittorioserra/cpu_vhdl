------------------------------------------------------------------------------------
-- Company: FAU Erlangen - Nuernberg
-- Engineer: Vittorio Serra and Cedric Donges
--
-- Description: Driver for mem-mapped peripehrials for RISC-V single cycle processor
------------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.utils.ALL;
use work.rv32i_defs.ALL;

entity mem_map_io_driver is
    Generic(
        leds_mem_pos   : unsigned := x"2000"
    );

    Port (
        clock                  : IN std_logic;
        data_qty               : IN mem_qty;
        is_s_type              : IN extension_control_type;
        address                : IN std_logic_vector(xlen_range);
        data_in                : IN std_logic_vector(xlen_range);
        
        leds_output            : OUT std_logic_vector(7 downto 0);
        inhibition_data_mem_we : OUT std_logic
    );
end mem_map_io_driver;

architecture bh of mem_map_io_driver is

begin

process(is_s_type, address, data_qty, data_in, clock) is 

begin

if (rising_edge(clock)) then

    if(is_s_type = s_type and unsigned(address) = unsigned(leds_mem_pos)) then
        inhibition_data_mem_we <= '1'; 
        leds_output(7 downto 0) <= data_in(7 downto 0);
    else
        inhibition_data_mem_we <= '0';
        --leds_output(7 downto 0) <= (others => '0');
    end if;
    
end if;

end process;


end bh;
