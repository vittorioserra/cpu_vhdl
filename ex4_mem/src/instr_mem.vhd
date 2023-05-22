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

entity instr_mem is
    Generic(
            port_width : positive := 32;
            block_length : positive := 256;
            addr_width : positive := 8);
    Port (clock : IN std_logic;                                       --clocking signal
          addr1, addr2 : IN std_logic_vector(addr_width -1 downto 0); --addresses
          ren1, ren2 : IN std_logic;                                  --port enable, for reading
          wen1, wen2 : IN std_logic;                                  --write enable
          wwrd1, wwrd2 : IN std_logic_vector(port_width -1 downto 0); --write_word (word that ha to be written to address)
          out1, out2 : OUT std_logic_vector(port_width -1 downto 0)   --output words
    );
end instr_mem;

architecture bh of instr_mem is
type memory_block is array (block_length-1 downto 0) of std_logic_vector(port_width -1 downto 0);
shared variable memory : memory_block;
begin

process(clock)
begin

    --access (write/read) only in synchronous manner, and when the pen/wen are actually addr1
    if(rising_edge(clock)) then
    
        --first address
    
        if(ren1 = '1') then --only read in this addr1
            out1 <= memory(to_integer(unsigned(addr1)));
        end if;
        
        if(ren1 = '1' and wen1 = '1') then --write in this addr1
            if(addr1 /= addr2) then
                memory(to_integer(unsigned(addr1))) := wwrd1;
            end if;         
        end if;
    end if;
        
    end process;    
    
    process(clock)
    begin

    if(rising_edge(clock)) then

        
        --second addres
        
        if(ren2 = '1') then --only read in this addr1
            out2 <= memory(to_integer(unsigned(addr2)));
        end if;
        
        if(ren2 = '1' and wen2 = '1') then --write in this addr1
            
            if(addr2 /= addr1) then
                memory(to_integer(unsigned(addr2))) := wwrd2;
            end if;
                
        end if;
        
    end if;

end process;

end bh;
