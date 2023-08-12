----------------------------------------------------------------------------------
-- Company: FAU Erlangen - Nuernberg
-- Engineer: Cedric Donges and Vittorio Serra
--
-- Description: UART module for CPU
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.utils.ALL;
use work.rv32i_defs.ALL;

entity uart is
    Generic(
        word_count : positive := 32;
        baud_rate  : positive := 9600;
        clks_per_baud : positive := 4 --10417 -- (100MHz/9600)
    );
    Port(
        clock : IN std_logic;
        data_tx : IN std_logic_vector(xlen_range);
        
        begin_tx : IN std_logic;
        tx_buffer_full : OUT std_logic ;
        
        serial_data_out : OUT std_logic ; --it is held high
		serial_data_in  : IN  std_logic ; --it is held low
        
        data_rx : OUT std_logic_vector(xlen_range);
        rx_buffer_full : OUT std_logic := '0'
        
        );
end uart;

architecture bh of uart is

    type reg_t is array (word_count - 1 downto 0) of std_logic_vector(xlen_range);
    signal input_buffer : reg_t := (others => (others => '0'));
    signal output_reg   : std_logic_vector(xlen_range) := (others => '0');

	signal output_buffer : reg_t := (others => (others => '0'));
    signal input_reg   : std_logic_vector(xlen_range) := (others => '0');

    signal baud_now : std_logic;

    shared variable tx_stack_ptr : integer := integer(0);     
    shared variable rx_stack_ptr : integer := integer(0);     


begin

    GATHER_TX : process(clock)
        
    begin
        if (rising_edge(clock) and begin_tx = '0') then 
            if(tx_stack_ptr /= integer(word_count -1)) then
                input_buffer(tx_stack_ptr) <= data_tx;
                tx_stack_ptr := tx_stack_ptr +1;
            end if;
        end if;
    end process;
    
    CHECK_IB_FULL : process(clock)
   
    begin 
        
        if(rising_edge(clock)) then
            
            if(tx_stack_ptr = 31) then
            
                tx_buffer_full <= '1';
            else
            
                tx_buffer_full <= '0';
                
            end if;
        
    end if;
      
    end process;
    
    CHECK_OB_FULL : process(clock)
   
    begin 
        
        if(rising_edge(clock)) then
            
            if(rx_stack_ptr = 31) then
            
                rx_buffer_full <= '1';
            else
            
                rx_buffer_full <= '0';
                
            end if;
        
        end if;
    
    end process;    
    
    BAUD_CNT : process(clock)
    
    variable loc_cntr :positive := 0;
    
    begin
    
        if(rising_edge(clock)) then
        
            if(loc_cntr < clks_per_baud) then
            
                loc_cntr := loc_cntr +1;
                baud_now <= '0';
            
            else
            
                loc_cntr := 0;
                baud_now <= '1';
                
            end if;
        
        end if;
    
    end process;
    
    TRANSMIT_TX : process(clock)
    
    variable curr_bit : positive := 0;
    variable stage : positive := 0;
    variable out_word : std_logic_vector(31 downto 0) := x"00ff00ff";
    
    
    --modify to state machine 
    
    begin
        if (rising_edge(clock)) then 
        
            if(tx_stack_ptr >= 0 and begin_tx = '1') then
                
                for byte_offset in 0 to 4 loop
                
                    --hold on start bit
                    if(stage = 0 ) then 
                    
                        serial_data_out <= '1';
                        stage := stage +1;
    
    
                    end if;
                    
                    --payload
                    if(stage >= 1 and stage <= 8) then
                    
                        serial_data_out <= out_word(4*byte_offset + stage -1);
                        stage := stage +1;
                    
                    end if;
                    
                    --end bit                
                    if (stage = 9) then
                    
                        serial_data_out <= '0';
                        stage := stage +1;
    
                        
                    end if;
     
     
                    if(stage = 10 and baud_now = '1') then
                    
                        stage := 0;
                    
                    end if;
                    

                end loop;
                
            end if;
            
            --tx_stack_ptr := tx_stack_ptr -1;
            
        end if;
    end process;


    
    
end bh;
