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
        clks_per_baud : positive := 10417 -- (100MHz/9600)
    );
    Port(
        clock : IN std_logic;
        data_tx : IN std_logic_vector(xlen_range);
        
        begin_tx : IN std_logic;
        tx_buffer_full : OUT std_logic := '0';
        
        serial_data_out : OUT std_logic := '1'; --it is held high
        
        data_rx : OUT std_logic_vector(xlen_range);
        rx_buffer_full : OUT std_logic := '0'
        
        );
end uart;

architecture bh of uart is

    type reg_t is array (word_count - 1 downto 0) of std_logic_vector(xlen_range);
    signal input_buffer : reg_t := (others => (others => '0'));
    signal output_reg   : std_logic_vector(xlen_range) := (others => '0');
    
    shared variable tx_stack_ptr : positive := positive(0);     
    shared variable rx_stack_ptr : positive := positive(0);     


begin

    GATHER_TX : process(clock)
        
    begin
        if (rising_edge(clock)) then 
            if(tx_stack_ptr /= positive(word_count -1)) then
                input_buffer(to_integer(unsigned(tx_stack_ptr))) <= data_tx;
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
    
    TRANSMIT_TX : process(clock)
    
    variable curr_bit : positive := 0;
    
    begin
        if (rising_edge(clock)) then 
            if(tx_stack_ptr >= 0) then
            
                --get word to be transmitted out
                output_reg <= input_buffer(tx_stack_ptr);

                for output_byte in 0 to 4 loop
                
                    --start bit
                    for tmr in 0 to clks_per_baud loop
                        
                       serial_data_out <= '0';
                        
                    end loop;               
                    
                    --payload
                    
                    for payload_bit in 0 to 8 loop
                    
                        for tmr in 0 to clks_per_baud loop
                            
                           serial_data_out <= output_reg(4*output_byte + payload_bit);
                            
                        end loop;
                        
                    end loop;
                        
                    --stop bit
                    for tmr in 0 to clks_per_baud loop
                        
                       serial_data_out <= '1';  --dive to high ???
                        
                    end loop;               
                        
                                    
                end loop;
                
                tx_stack_ptr := tx_stack_ptr -1 ; 
                
            end if;
        end if;
    end process;
    
    
end bh;
