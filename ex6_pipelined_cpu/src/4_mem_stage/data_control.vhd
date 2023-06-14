----------------------------------------------------------------------------------
-- Company:     FAU Erlangen - Nuernberg
-- Engineer:    Vittorio Serra and Cedric Donges
--
-- Description: Data access control unit. Connects MEM and IO to the CPU.
--              Selects read and written data byte, half or wordwise.
----------------------------------------------------------------------------------

-- TODO support unaligned access
--      add ready flag, remove misalign flag
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.utils.ALL;
use work.rv32i_defs.ALL;

entity data_control is
    Port(
        clock, reset_n, enable : IN std_logic;
        mode : IN mem_mode_type;
        data_addr : IN std_logic_vector(xlen_range);
        data_in : IN std_logic_vector(xlen_range);
        d_bus_in : IN d_bus_miso_rec;
        d_bus_out : OUT d_bus_mosi_rec
        data_out : OUT std_logic_vector(xlen_range);
        misaliged : OUT std_logic);
end data_control;

architecture bh of data_control is
    function mode2vec(m : mem_mode_type) return std_logic_vector is
    begin
        case m is
            when mem_read_bs => return "0000";
            when mem_read_hs => return "0001";
            when mem_read_w  => return "0010";
            when mem_read_bu => return "0100";
            when mem_read_hu => return "0101";
            when passthrough => return "0111";
            when mem_write_b => return "1000";
            when mem_write_h => return "1001";
            when mem_write_w => return "1010";
            when others      => return "0111";
        end case;
    end function;
    signal data_in_reg : std_logic_vector(xlen_range);
    signal mode_reg : mem_mode_type;
begin
    INPUT_REGISTER : process (clock)
    begin
        if (rising_edge(clock)) then
            if (reset_n = '0') then
                data_in_reg <= (others => '0');
                mode_reg <= passthrough;
            elsif (enable = '1') then
                data_in_reg <= data_in;
                mode_reg <= mode;
            end if;
        end if;
    end process;
    
    DATA_CONTROL : process (data_addr, mode, mode_reg, data_in, data_in_reg, d_bus_in)
    begin
        misaliged <= '0';
        d_bus_out.addr <= data_addr(addr_range);

        d_bus_out.data <= (others => '0');
        d_bus_out.write_enable <= (others => '0');
        case std_logic_vector'(mode2vec(mode) & data_addr(xlen_subaddr_width - 1 downto 0)) is
            when "1000_00" => d_bus_out.data <= move_bits(data_in, 0,  8,  0, false); d_bus_out.write_enable <= "0001"; -- write byte at  0
            when "1000_01" => d_bus_out.data <= move_bits(data_in, 0,  8,  8, false); d_bus_out.write_enable <= "0010"; -- write byte at  8
            when "1000_10" => d_bus_out.data <= move_bits(data_in, 0,  8, 16, false); d_bus_out.write_enable <= "0100"; -- write byte at 16
            when "1000_11" => d_bus_out.data <= move_bits(data_in, 0,  8, 24, false); d_bus_out.write_enable <= "1000"; -- write byte at 24
            when "1001_00" => d_bus_out.data <= move_bits(data_in, 0, 16,  0, false); d_bus_out.write_enable <= "0011"; -- write half at  0
            when "1001_10" => d_bus_out.data <= move_bits(data_in, 0, 16, 16, false); d_bus_out.write_enable <= "1100"; -- write half at 16
            when "1010_00" => d_bus_out.data <= move_bits(data_in, 0, 32,  0, false); d_bus_out.write_enable <= "1111"; -- write word at  0
            when "1001_-1" | "1010_01" | "1010_1-"  => misaliged <= '1';                                                -- write would cross word border
        end case;

        data_out <= data_in_reg; -- default passthrough
        case std_logic_vector'(mode2vec(mode_reg) & data_addr(xlen_subaddr_width - 1 downto 0)) is
            when "0000_00" => data_out <= move_bits(d_bus_in.data,  0,  8, 0,  true); -- read byte   signed at  0
            when "0000_01" => data_out <= move_bits(d_bus_in.data,  8,  8, 0,  true); -- read byte   signed at  8
            when "0000_10" => data_out <= move_bits(d_bus_in.data, 16,  8, 0,  true); -- read byte   signed at 16
            when "0000_11" => data_out <= move_bits(d_bus_in.data, 24,  8, 0,  true); -- read byte   signed at 24
            when "0001_00" => data_out <= move_bits(d_bus_in.data,  0, 16, 0,  true); -- read half   signed at  0
            when "0001_10" => data_out <= move_bits(d_bus_in.data, 16, 16, 0,  true); -- read half   signed at 16
            when "0010_00" => data_out <= move_bits(d_bus_in.data,  0, 32, 0, false); -- read word          at  0
            when "0100_00" => data_out <= move_bits(d_bus_in.data,  0,  8, 0, false); -- read byte unsigned at  0
            when "0100_01" => data_out <= move_bits(d_bus_in.data,  8,  8, 0, false); -- read byte unsigned at  8
            when "0100_10" => data_out <= move_bits(d_bus_in.data, 16,  8, 0, false); -- read byte unsigned at 16
            when "0100_11" => data_out <= move_bits(d_bus_in.data, 24,  8, 0, false); -- read byte unsigned at 24
            when "0101_00" => data_out <= move_bits(d_bus_in.data,  0, 16, 0, false); -- read half unsigned at  0
            when "0101_10" => data_out <= move_bits(d_bus_in.data, 16, 16, 0, false); -- read half unsigned at 16
            when "0-01_-1" | "0010_01" | "0010_1-" => misaliged <= '1';               -- read would cross word border
        end case;
    end process;
end bh;