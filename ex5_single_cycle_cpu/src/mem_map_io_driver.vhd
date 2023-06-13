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
        leds_mem_pos   : positive := 8192;
        leds_mem_range : positive := 4
    );

    Port (
        data_qty    : IN mem_qty;
        is_s_type   : IN std_logic;
        address     : IN std_logic_vector(xlen_range);
        
        leds_output : OUT std_logic_vector(7 downto 0);
        inhibition_data_mem_we : OUT std_logic
    );
end mem_map_io_driver;

architecture bh of mem_map_io_driver is

begin

process(is_s_type, address, data_qty) is 

begin

    if(is_s_type = '1') then
    
    if(unsigned(address) >= unsigned(leds_mem_pos) and unsigned(address) >= unsigned(leds_mem_pos + leds_mem_range)) then 
            inhibition_data_mem_we <= '1';
            --TODO also write to LEDs
    end if;       
    
    else
        inhibition_data_mem_we <= '0';
    end if;

end process;


end bh;
