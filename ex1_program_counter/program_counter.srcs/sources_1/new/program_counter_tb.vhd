----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/01/2023 11:11:39 AM
-- Design Name: 
-- Module Name: program_counter_tb - Behavioral
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
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

--testbench, this must be empity

entity program_counter_tb is
end program_counter_tb;

architecture tb of program_counter_tb is

	constant CLOCK_PERIOD  : time := 10 ns;

    signal enable_tb, reset_tb, clock_tb, load_data_tb :  std_logic; --inputs, not all of them will be used
    signal jump_register_tb : std_logic_vector(0 to 31);
    signal program_ctr_tb :  std_logic_vector(0 to 31); --output, just one, so it is easy signal
    
begin

    DUT : entity work.program_counter port map (clock => clock_tb, 
                                                enable => enable_tb, 
                                                reset=>reset_tb,
                                                load_data => load_data_tb,
                                                jump_register => jump_register_tb,
                                                program_ctr=>program_ctr_tb);
    
    gen_sim_clk : process
    begin
        clock_tb <= '1';
        wait for CLOCK_PERIOD/2;
        clock_tb <= '0';
        wait for CLOCK_PERIOD/2;
    end process;
    
    stimuli : process
    begin
        enable_tb <= '1';
        reset_tb <= '1';
        load_data_tb <= '0';
        jump_register_tb <= x"00000000";
        wait for CLOCK_PERIOD *2;
        
        reset_tb <= '0';
        wait for CLOCK_PERIOD *2;
        
        for i in 0 to 255 loop
            reset_tb <= '0';
            enable_tb <= '1';
            load_data_tb <= '0';            
            jump_register_tb <= x"00000000";
            wait for CLOCK_PERIOD ;
        end loop;
        
        for i in 0 to 16 loop
            reset_tb <= '1';
            enable_tb <= '0';
            load_data_tb <= '0';            
            jump_register_tb <= x"00000000";
            wait for CLOCK_PERIOD;
        end loop;
        
        for i in 0 to 16 loop
            reset_tb <= '0';
            enable_tb <= '0';
            load_data_tb <= '0';            
            jump_register_tb <= x"00000000";        
            wait for CLOCK_PERIOD ;
        end loop;
             
        for i in 0 to 16 loop
            reset_tb <= '1';
            enable_tb<= '1';
            load_data_tb <= '0';            
            jump_register_tb <= x"00000000";
            wait for CLOCK_PERIOD ;
        end loop;
        
        reset_tb <= '0';
        enable_tb<= '1';
        load_data_tb <= '1';            
        jump_register_tb <= x"00000400";
        wait for CLOCK_PERIOD;
        
        for i in 0 to 4 loop
            reset_tb <= '0';
            enable_tb <= '1';
            load_data_tb <= '0';            
            jump_register_tb <= x"00000000";
            wait for CLOCK_PERIOD ;
        end loop;
        
        
    end process;

end tb;
