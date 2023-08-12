----------------------------------------------------------------------------------
-- Company: FAU Erlangen - Nuernberg
-- Engineer: Vittorio Serra and Cedric Donges
--
-- Description: Testbench for the ALU
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.utils.ALL;
use work.rv32i_defs.ALL;

entity uart_tb is
    Generic(PROJECT_PATH : string);
end uart_tb;

architecture tb of uart_tb is                                     
  
  constant CLOCK_PERIOD : time := 10 ns;
                                                   
    constant word_count    : positive := 32;                              
    constant baud_rate     : positive := 9600;                            
    constant clks_per_baud : positive := 4; -- here changed from (100MHz/9600) to 1 solely for the purposes of simulation        
                                                    
                                                   
   signal clock           :  std_logic;
   signal data_tx_in      :  std_logic_vector(7 downto 0);
   signal data_valid      :  std_logic;
   signal busy_tx         :  std_logic;
   signal serial_data_out :  std_logic;
   signal tx_done         :  std_logic;
   
   signal data_rx_out      :  std_logic_vector(7 downto 0);
   signal serial_data_in   :  std_logic;
                                                              
begin

--    DUT : entity work.uart_tx
    
--        generic map(
--            word_count => word_count,
--            baud_rate  => baud_rate,
--            clks_per_baud => clks_per_baud
--            )    
--        port map(
--            clock           =>   clock           ,
--            data_tx_in      =>   data_tx_in      ,
--	        data_valid      =>  data_valid         ,
--            busy_tx         =>   busy_tx         ,
--            serial_data_out =>   serial_data_out ,
--            tx_done         =>   tx_done         
--            );

    
    DUT : entity work.uart_rx                     
                                              
    generic map(                              
        word_count => word_count,             
        baud_rate  => baud_rate,              
        clks_per_baud => clks_per_baud        
        )                                     
    port map(                                 
        clock           =>  clock           ,
        data_rx_out     =>  data_rx_out     ,
	    data_valid      =>  data_valid      ,
        serial_data_in  =>  serial_data_in  
        );                                    
    
           
    gen_clk : process
	begin
		clock <= '0';
		wait for CLOCK_PERIOD / 2;
		clock <= '1';
		wait for CLOCK_PERIOD / 2;
	end process;
	
	stimuli : process
	begin
	
	serial_data_in <= '0';	
	wait for 4*clock_period;
	
	serial_data_in <= '1';
    wait for 4*clock_period;
    
    serial_data_in <= '0';
    wait for 4*clock_period;

	serial_data_in <= '1';
    wait for 4*clock_period;
    
    serial_data_in <= '0';
    wait for 4*clock_period;
    
    serial_data_in <= '1';
    wait for 4*clock_period;
    
    serial_data_in <= '0';
    wait for 4*clock_period;
    
    serial_data_in <= '1';
    wait for 4*clock_period;

    wait;
    
	end process;
end tb;
