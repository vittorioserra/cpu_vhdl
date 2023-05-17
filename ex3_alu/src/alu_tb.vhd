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
package body alu_types is
end alu_types;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.utils.ALL;
use work.alu_types.ALL;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity alu_tb is
end alu_tb;

architecture tb of alu_tb is
    constant CLOCK_PERIOD : time := 10 ns;
	constant PORT_WIDTH : positive := 32;

    signal reset_n : std_logic;
    signal clock: std_logic;
    signal func : alu_func;
    signal op1, op2 : std_logic_vector(port_width - 1 downto 0);
    --signal async_lsb : std_logic;
    signal res : std_logic_vector(port_width - 1 downto 0);
begin

    DUT : entity work.alu 
        generic map(port_width => PORT_WIDTH)
        port map(reset_n => reset_n,
                 clock=> clock,
                 func => func,
                 op1=>op1, op2=>op2,
                 --async_lsb=>async_lsb,
                 res=>res);

    gen_clk : process
	begin
		clock <= '1';
		wait for CLOCK_PERIOD / 2;
		clock <= '0';
		wait for CLOCK_PERIOD / 2;
	end process;
	
	stimuli : process
	begin
	
	   --general reset
	   reset_n<='0';
	   wait for CLOCK_PERIOD;
	   
	   --addition
	   reset_n <= '1';
	   op1 <= x"00000042";
	   op2 <= x"00000042";
	   func<=func_add;
	   wait for CLOCK_PERIOD;
	   
	   --subtraction
	   reset_n <= '1';
	   op1 <= x"00000042";
	   op2 <= x"00000042";
	   func<=func_sub;
	   wait for CLOCK_PERIOD;
	   
	   --slts
	   reset_n <= '1';
	   op1 <= x"00000042";
	   op2 <= x"F0000042";
	   func<=func_slts;
	   wait for CLOCK_PERIOD;
	   
       reset_n <= '1';
	   op1 <= x"F0000042";
	   op2 <= x"00000042";
	   func<=func_slts;
	   wait for CLOCK_PERIOD;
	   
       --sltu
	   reset_n <= '1';
	   op1 <= x"00000042";
	   op2 <= x"00000041";
	   func<=func_sltu;
	   wait for CLOCK_PERIOD;
	   
	   reset_n <= '1';
	   op1 <= x"00000041";
	   op2 <= x"00000042";
	   func<=func_sltu;
	   wait for CLOCK_PERIOD;
	   
	   --seq 
	   reset_n <= '1';
	   op1 <= x"00000042";
	   op2 <= x"00000042";
	   func<=func_seq;
	   wait for CLOCK_PERIOD;
	   
	   reset_n <= '1';
	   op1 <= x"00000041";
	   op2 <= x"00000042";
	   func<=func_seq;
	   wait for CLOCK_PERIOD;
	   
	   
	   --xor
	   reset_n <= '1';
	   op1<= x"a5a5a5a5";
	   op2<= x"5a5a5a5a";
	   func<=func_xor;
	   wait for CLOCK_PERIOD;
	   
	   --or
	   reset_n <= '1';
	   op1<= x"DEAD0000";
	   op2<= x"0000BEEF";
	   func<=func_or;
	   wait for CLOCK_PERIOD;
	   
	   --and
	   reset_n <= '1';
	   op1 <= x"a5a5a5a5";
	   op2 <= x"5a5a5a5a";
	   func<=func_and;
	   wait for CLOCK_PERIOD;
	   
	   --sll
	   reset_n <= '1';
	   op1 <= x"FDEADBEE";
	   op2 <= x"00000004";
	   func<=func_sll;
	   wait for CLOCK_PERIOD;
	   
	   --srl
	   reset_n <= '1';
	   op1 <= x"C01DCAFE";
	   op2 <= x"00000008";
	   func<=func_srl;
	   wait for CLOCK_PERIOD;
	   
	   --sra
	   reset_n <= '1';
	   op1 <= x"FFFFFFF0";
	   op2 <= x"00000004";
	   func<=func_sra;
	   wait for CLOCK_PERIOD;
	   
       --general reset
       wait for CLOCK_PERIOD;
	   reset_n<='0';
	   wait for CLOCK_PERIOD;

	   
	wait;
	
	end process;

end tb;
