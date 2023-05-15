----------------------------------------------------------------------------------
-- Company: FAU Erlangen - Nuernberg
-- Engineer: Cedric Donges and Vittorio Serra
--
-- Description: testbench for the ALU
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity data_mem is
    Generic(
            port_width : positive := 32;
            block_length : positive := 256;
            addr_width : positive := 8);
    Port (clock : IN std_logic;
          addr1, addr2 : IN std_logic_vector(addr_width -1 downto 0);
          pen1, pen2 : IN std_logic;
          wen1, wen2 : IN std_logic;
          wwrd1, wwrd2 : IN std_logic_vector(port_width -1 downto 0);
          out1, out2 : OUT std_logic_vector(port_width -1 downto 0)   
    );
end data_mem;

architecture bh of data_mem is
type memory_block is array (block_length-1 downto 0) of std_logic_vector(port_width -1 downto 0);
shared variable memory : memory_block;
begin

process(clock)
begin

    --access (write/read) only in synchronous manner, and when the pen/wen are actually addr1
    if(rising_edge(clock)) then
    
        --first address
    
        if(pen1 = '1' and wen1 = '0') then --only read in this addr1
            out1 <= memory(to_integer(unsigned(addr1)));
        end if;
        
        if(pen1 = '1' and wen1 = '1') then --write in this addr1
            memory(to_integer(unsigned(addr1))) := wwrd1;
        end if;
        
        --second addres
        
        if(pen2 = '1' and wen2 = '0') then --only read in this addr1
            out2 <= memory(to_integer(unsigned(addr2)));
        end if;
        
        if(pen1 = '1' and wen1 = '1') then --write in this addr1
            memory(to_integer(unsigned(addr2))) := wwrd2;
        end if;
        
    end if;

end process;

end bh;
