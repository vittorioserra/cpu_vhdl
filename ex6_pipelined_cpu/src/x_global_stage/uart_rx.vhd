library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
 

entity uart_rx is
	Generic(
        word_count : positive := 32;
        baud_rate  : positive := 9600;
        clks_per_baud : positive := 4 --10417 -- (100MHz/9600)

    );
  Port (
    clock            : in  std_logic;
    data_rx_out      : out  std_logic_vector(7 downto 0);
	data_valid       : out  std_logic;
    serial_data_in  : in std_logic
    );
end uart_rx;
 
 
architecture bh of uart_rx is
 
  type t_steit_mascheen is (idle, start_bit, data_bits, stop_bit, done);

  signal uart_state : t_steit_mascheen := idle;

  signal rx_bit_buffer          : std_logic := '0';
  signal rx_sampled_data        : std_logic := '0';
 
  signal baud_clock             : integer range 0 to clks_per_baud-1 := 0;
  signal bit_index              : integer range 0 to 7 := 0;  -- 8 Bits Total
  signal rx_data_buffer         : std_logic_vector(7 downto 0) := (others => '0');
  signal rx_data_valid_reg      : std_logic := '0';
   
begin
 
   
  RX_sample : process (clock)
  begin 
	if(rising_edge(clock)) then 
		
		rx_sampled_data <= serial_data_in;
		rx_bit_buffer <= rx_sampled_data;

	end if;
  end process;

  RX : process(clock)
  begin
    if rising_edge(clock) then
         
      case uart_state is
 
        when idle =>  -- in idle state we keep the line high
          data_valid      <= '0';
          baud_clock      <= 0;
          bit_index       <= 0;
 
          if rx_bit_buffer = '0' then --if we have vald data, jump to the start_bit state
            uart_state <= start_bit;
          else
          	uart_state <= idle; 
		  end if; 

		when start_bit =>
          
          if baud_clock < clks_per_baud-1 then --start bit must finish, then jumo to the next state
          	baud_clock   <= baud_clock + 1;
            uart_state   <= start_bit;
          else
            baud_clock <= 0;
            uart_state   <= data_bits; 
		  end if; 

		when data_bits => 
  
          if baud_clock < clks_per_baud-1 then --just wait, keep in the data state
            baud_clock <= baud_clock + 1;
            uart_state   <= data_bits;
          else
            baud_clock <= 0;
            if bit_index < 7 then              --register is empity ? if yes go to rhe next state
			  rx_data_buffer(bit_index) <= rx_bit_buffer;
			  bit_index <= bit_index + 1;
              uart_state   <= data_bits;
            else
              bit_index <= 0;
              uart_state   <= stop_bit; 
			end if; 
          end if; 

		  --stop bit, go to next state
		  
		  when stop_bit =>
 
          if baud_clock < clks_per_baud-1 then
            baud_clock <= baud_clock + 1;
            uart_state   <= stop_bit;
          else
            baud_clock    <= 0;
            uart_state    <= done; --go in done state and reset stuff
			rx_data_valid_reg <= '1';
			data_rx_out <= rx_data_buffer;
		  end if;
      	  
		when done =>
      	  uart_state   <= idle; 
		  rx_data_valid_reg <= '0';

		when others =>
          uart_state <= idle;
 
      end case;
    end if;
  end process RX;
   
end bh;
