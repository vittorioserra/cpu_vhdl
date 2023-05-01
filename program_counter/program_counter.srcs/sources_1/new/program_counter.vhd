----------------------------------------------------------------------------------
-- Company: FAU
-- Engineer: Cerdic + Vittorio
-- 
-- Create Date: 05/01/2023 10:52:38 AM
-- Design Name: 
-- Module Name: program_counter - Behavioral
-- Project Name: 
-- Target Devices: Zedboard
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity program_counter is
    Port ( 
        enable, reset, clock, load_data : IN std_logic;
        jump_register : IN std_logic_vector(0 to 31);
        program_ctr : OUT std_logic_vector(0 to 31));
end program_counter;

architecture Behavioral of program_counter is
signal pc_register : std_logic_vector(0 to 31);
begin
process(clock)
begin
if(rising_edge(clock)) then
    if(reset='1' and enable = '1') then
        pc_register <= x"00000000";
    end if; 
    if(reset = '0' and enable = '1'and load_data = '0') then
        pc_register <= pc_register + x"00000004";
    end if;
    if(reset = '0' and enable = '1' and load_data = '1') then
        pc_register <= jump_register;    
    end if;
end if;
end process;
    program_ctr <= pc_register ;    
end Behavioral;
