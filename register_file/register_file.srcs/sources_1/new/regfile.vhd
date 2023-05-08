----------------------------------------------------------------------------------
-- Company: FAU Erlangen - Nuernberg
-- Engineer: Vittorio Serra and Cedric Donges
--
-- Description: register file, version 1.0, single async port
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
    signal tmp_address_number_read : std_logic_vector(address_width -1 downto 0) := b"00000";
    signal tmp_reg_value_read : std_logic_vector(port_width -1 downto 0) := x"00000000";
    signal tmp_address_number_write : std_logic_vector(address_width -1 downto 0) := b"00000";
    signal tmp_reg_value_write : std_logic_vector(port_width -1 downto 0) := x"00000000";
    signal register_array : t_register_battery := (others=>(x"a5a5a5a5")); 
begin
    
    async_read : process(async_read_address)
    begin   
        tmp_address_number_read <= b"00001";--async_read_address;
        tmp_reg_value_read <= register_array(to_integer(unsigned(tmp_address_number_read)));
        async_output <= tmp_reg_value_read;
    end process;

    sync_write : process(clock)
    begin
    if(rising_edge(clock) and enable = '1') then
        tmp_address_number_write <= sync_write_address;
        tmp_reg_value_write <= input_dataport;
        register_array(to_integer(unsigned(tmp_address_number_write)))<=tmp_reg_value_write;    
    end if;
    
    end process;

end bh;
