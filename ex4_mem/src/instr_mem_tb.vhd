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
use work.utils.ALL;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity instr_mem_tb is
end instr_mem_tb;

architecture tb of instr_mem_tb is

    constant CLOCK_PERIOD : time := 10 ns;

    constant PORT_WIDTH : positive := 32;
    constant BLOCK_LENGTH : positive := 256;
    constant ADDR_WIDTH : positive := 8;

    signal clock : std_logic;                                       --clocking signal
    signal addr1, addr2 : std_logic_vector(addr_width -1 downto 0); --addresses
    signal ren1, ren2 : std_logic;                                  --port enable, for reading
    signal wen1, wen2 : std_logic;                                  --write enable
    signal wwrd1, wwrd2 : std_logic_vector(port_width -1 downto 0); --write_word (word that ha to be written to address)
    signal out1, out2 : std_logic_vector(port_width -1 downto 0);    --output words
                                                                     
begin

    DUT : entity work.instr_mem 
        generic map(port_width => PORT_WIDTH,
                    block_length => BLOCK_LENGTH,
                    addr_width => ADDR_WIDTH
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

    gen_clk : process
	begin
		clock <= '1';
		wait for CLOCK_PERIOD / 2;
		clock <= '0';
		wait for CLOCK_PERIOD / 2;
	end process;
	
	stimuli : process
	begin
	
	--wait one clock period at the beginning
	wait for CLOCK_PERIOD;
	
	--write some random words on port addr1
	ren1<='1';
	ren2<='0';
	wen1<='1';
	wen2<='0';
	addr1 <= x"00";
	addr2 <= x"FF";
	wwrd1 <= x"deadbeef";
	wait for CLOCK_PERIOD;
	
	ren1<='1';
	ren2<='0';
	wen1<='1';
	wen2<='0';
	addr1 <= x"01";
	addr2 <= x"FF";
	wwrd1 <= x"c01dcafe";
	wait for CLOCK_PERIOD;
	
	--read back from port 1
	ren1<='1';
	ren2<='0';
	wen1<='0';
	wen2<='0';
	addr1 <= x"00";
	addr2 <= x"FF";
	wait for CLOCK_PERIOD;
	
	ren1<='1';
	ren2<='0';
	wen1<='0';
	wen2<='0';
	addr1 <= x"01";
	addr2 <= x"FF";
	wait for CLOCK_PERIOD;
	
	--write some random words on port addr2
	ren1<='0';
	ren2<='1';
	wen1<='0';
	wen2<='1';
	addr1 <= x"00";
	addr2 <= x"FF";
	wwrd2 <= x"a5a5a5a5";
	wait for CLOCK_PERIOD;
	
	ren1<='0';
	ren2<='1';
	wen1<='0';
	wen2<='1';
	addr1 <= x"01";
	addr2 <= x"FE";
	wwrd2 <= x"5a5a5a5a";
	wait for CLOCK_PERIOD;
	
	--read back from port 2
	ren1<='0';
	ren2<='1';
	wen1<='0';
	wen2<='0';
	addr1 <= x"00";
	addr2 <= x"FF";
	wait for CLOCK_PERIOD;
	
	ren1<='0';
	ren2<='1';
	wen1<='0';
	wen2<='0';
	addr1 <= x"01";
	addr2 <= x"FE";
	wait for CLOCK_PERIOD;

	wait;
	
	end process;

end tb;