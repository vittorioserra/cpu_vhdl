----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/08/2023 07:15:19 PM
-- Design Name: 
-- Module Name: regfile - Behavioral
-- Project Name: 
-- Target Devices: 
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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity regfile is
--  Port ( );
    Generic(port_width : positive := 32;
            num_registers : positive := 32;
            address_width : positive := 5);
    Port(
        clock, enable : IN std_logic;
        async_read_address : IN std_logic_vector (address_width -1 downto 0);
        async_output : OUT std_logic_vector (port_width -1 downto 0);
        sync_write_address : IN std_logic_vector (address_width -1 downto 0);
        input_dataport : IN std_logic_vector (port_width -1 downto 0));
end regfile;

architecture bh of regfile is
    type t_register_battery is array (num_registers -1 downto 0) of std_logic_vector(port_width -1 downto 0);
    signal tmp_address_number : std_logic_vector(address_width -1 downto 0);
    signal tmp_reg_value_read : std_logic_vector(port_width -1 downto 0);
    signal registers : t_register_battery; 
begin
    
    process(async_read_address)
    begin   
        tmp_address_number <= (async_read_address);
        tmp_reg_value_read <= registers(to_integer(tmp_address_number));
        );
    end process;

end bh;
