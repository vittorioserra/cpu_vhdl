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
                                                   
    constant word_count : positive := 32;                              
    constant baud_rate  : positive := 9600;                            
    constant clks_per_baud : positive := 1; -- here changed from (100MHz/9600) to 1 solely for the purposes of simulation        
                                                    
                                                   
    signal clock           : std_logic;                                     
    signal data_tx         : std_logic_vector(xlen_range);                
                                                     
    signal begin_tx        : std_logic;                                  
    signal tx_buffer_full  : std_logic ;                    
                                                        
    signal serial_data_out : std_logic ; --it is held high 
    signal serial_data_in  : std_logic ; --it is held low        
                                                      
    signal data_rx         : std_logic_vector(xlen_range);               
    signal rx_buffer_full  : std_logic := '0';                     
                                                              
begin

    DUT : entity work.uart
    
        generic map(
            word_count => word_count,
            baud_rate  => baud_rate,
            clks_per_baud => clks_per_baud
            )    
        port map(
			clock            =>          clock          ,
            data_tx          =>          data_tx        ,
                                                        
            begin_tx         =>          begin_tx       ,
            tx_buffer_full   =>          tx_buffer_full ,
                                                        
            serial_data_out  =>          serial_data_out,
            serial_data_in   =>          serial_data_in ,
                                                        
            data_rx          =>          data_rx        ,
            rx_buffer_full   =>          rx_buffer_full 
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
	
	data_tx <= x"a5a5a5a5";
	begin_tx <= '0';
	wait for clock_period;
	data_tx <= x"00000000";
	begin_tx <= '1';
    wait;
    wait;
    
	end process;
end tb;
