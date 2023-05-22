----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/15/2023 07:33:36 PM
-- Design Name: 
-- Module Name: alu_tb - bh
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

library work;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity memories_and_pc is
   Generic (
	    --program counter
		pc_width : positive := 32;
		--memory
		port_width : positive := 32;
        block_length : positive := 256;
        addr_width : positive := 8);
	Port ( 
	    --program counter
		clock, enable, reset_n, load : IN std_logic;
		load_value : IN std_logic_vector(pc_width - 1 downto 0);
		pc_value : OUT std_logic_vector(pc_width - 1 downto 0);
		--memory
        addr1, addr2 : IN std_logic_vector(addr_width -1 downto 0); --addresses
        ren1, ren2 : IN std_logic;                                  --port enable, for reading
        wen1, wen2 : IN std_logic;                                  --write enable
        wwrd1, wwrd2 : IN std_logic_vector(port_width -1 downto 0); --write_word (word that ha to be written to address)
        out1, out2 : OUT std_logic_vector(port_width -1 downto 0);   --output words
        read_from_mem : OUT std_logic_vector(port_width -1 downto 0)
    );

end memories_and_pc;

architecture bh of memories_and_pc is

signal memory_address : std_logic_vector(addr_width-1 downto 0);
signal pc_val : std_logic_vector(pc_width-1 downto 0);
                                                   
begin

    INSTR_MEM : entity work.instr_mem
        generic map(port_width => port_width,
                    block_length => block_length,
                    addr_width => addr_width
        )
        port map(clock=> clock,
                 addr1=>addr1,
                 addr2=>addr2,
                 ren1=>ren1,
                 ren2=>ren2,
                 wen1=>wen1,
                 wen2=>wen2,
                 out1=>out1,
                 out2=>out2,
                 wwrd1=>wwrd1,
                 wwrd2=>wwrd2);
                 
    PROG_CTR : entity work.program_counter 
        generic map(pc_width=>pc_width)
        port map(clock=>clock,
                 enable=>enable,
                 reset_n=>reset_n,
                 load=>load,
                 load_value=>load_value,
                 --pc_value=>pc_value,
                 pc_value=>pc_val);
                 
                 
    process(clock)
    begin
    
        --only take 8 bits from mem, put it in the read port, then read the output and put it in the read_from_mem port
    
    end process;
    
end bh;