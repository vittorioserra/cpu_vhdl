library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
 
entity uart_tx is
	Generic(
        word_count : positive := 32;
        baud_rate  : positive := 9600;
        clks_per_baud : positive := 4 --10417 -- (100MHz/9600)

    );
  Port (
    clock           : in  std_logic;
    data_tx_in      : in  std_logic_vector(7 downto 0);
	data_valid      : in  std_logic;
    busy_tx        : out std_logic;
    serial_data_out : out std_logic;
    tx_done         : out std_logic
    );
end uart_tx;
 
 
architecture bh of UART_TX is
 
  type t_steit_mascheen is (idle, start_bit, data_bits, stop_bit, done);

  signal uart_state : t_steit_mascheen := idle;
 
  signal baud_clock       : integer range 0 to clks_per_baud-1 := 0;
  signal bit_index        : integer range 0 to 7 := 0;  -- 8 Bits Total
  signal tx_data_buffer   : std_logic_vector(7 downto 0) := (others => '0');
  signal tx_done_reg      : std_logic := '0';
   
begin
 
   
  TX : process (clock)
  begin
    if rising_edge(clock) then
         
      case uart_state is
 
        when idle =>               -- in idle state we keep the line high
          busy_tx        <= '0';
          serial_data_out <= '1';
          tx_done         <= '0';
          baud_clock      <= 0;
          bit_index       <= 0;
 
          if data_valid = '1' then -- if we have vald data, jump to the start_bit state
            tx_data_buffer <= data_tx_in;
            uart_state <= start_bit;
          else
          	uart_state <= idle; 
		  end if; 
          
		when start_bit =>
		  busy_tx         <= '1';
          serial_data_out <= '0';
 

          if baud_clock < clks_per_baud-1 then --start bit must finish, then jumo to the next state
          	baud_clock   <= baud_clock + 1;
            uart_state   <= start_bit;
          else
            baud_clock <= 0;
            uart_state   <= data_bits; 
		  end if; 

		when data_bits =>

          serial_data_out <= tx_data_buffer(bit_index);
           
          if baud_clock < clks_per_baud-1 then --just wait, keep in the data state
            baud_clock <= baud_clock + 1;
            uart_state   <= data_bits;
          else
            baud_clock <= 0;
            if bit_index < 7 then              --register is empity ? if yes go to rhe next state
              bit_index <= bit_index + 1;
              uart_state   <= data_bits;
            else
              bit_index <= 0;
              uart_state   <= stop_bit; 
			end if; 
          end if; 

		  --stop bit, go to next state
		when stop_bit =>		  

          serial_data_out <= '1';
 
          if baud_clock < clks_per_baud-1 then
            baud_clock <= baud_clock + 1;
            uart_state   <= stop_bit;
          else
            tx_done_reg   <= '1';
            baud_clock    <= 0;
            uart_state    <= done; --go in done state and reset stuff
		  end if;

		when done =>      	  

          busy_tx <= '0';
      	  tx_done   <= '1';
      	  uart_state   <= idle; 

		when others =>
          uart_state <= idle;
 
      end case;
    end if;
  end process TX;
 
  tx_done <= tx_done_reg;
   
end bh;
