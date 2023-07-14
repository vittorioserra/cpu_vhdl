----------------------------------------------------------------------------------
-- Company:     FAU Erlangen - Nuernberg
-- Engineer:    Vittorio Serra and Cedric Donges
--
-- Description: Data access control unit. Connects MEM and IO to the CPU.
--              Selects read and written data byte, half or wordwise.
--              Supports misaligned access.
----------------------------------------------------------------------------------

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
        d_bus_out : OUT d_bus_mosi_rec;
        data_out : OUT std_logic_vector(xlen_range);
        ready : OUT std_logic);
end data_control;

architecture bh of data_control is
    signal next_d_bus_out_int : d_bus_mosi_rec;
    signal next_d_bus_out_reg : d_bus_mosi_rec;
    signal misaligned : std_logic;
    signal do_second_access_reg : std_logic;
    signal combine_second_access_reg : std_logic;
    signal last_d_bus_in_data_reg : std_logic_vector(xlen_range);
    signal data_in_reg : std_logic_vector(xlen_range);
    signal mode_reg : mem_mode_type;
    signal subaddr_reg : std_logic_vector(xlen_subaddr_width - 1 downto 0);
begin
    ready <= not misaligned;

    CONTROL : process (clock)
    begin
        if (rising_edge(clock)) then
            if (reset_n = '0') then
                next_d_bus_out_reg <= (others => (others => '0'));
                do_second_access_reg <= '0';
                combine_second_access_reg <= '0';
                last_d_bus_in_data_reg <= (others => '0');
                data_in_reg <= (others => '0');
                mode_reg <= m_pass;
                subaddr_reg <= (others => '0');
            elsif (enable = '1') then
                next_d_bus_out_reg <= next_d_bus_out_int;
                do_second_access_reg <= misaligned;
                combine_second_access_reg <= do_second_access_reg;
                last_d_bus_in_data_reg <= d_bus_in.data;
                data_in_reg <= data_in;
                mode_reg <= mode;
                subaddr_reg <= data_addr(xlen_subaddr_width - 1 downto 0);
            end if;
        end if;
    end process;
    
    D_BUS_OUT_PROCESSING : process (mode, data_addr, data_in, do_second_access_reg, next_d_bus_out_reg)
        variable temp_data : std_logic_vector(xlen * 2 - 1 downto 0);
        variable temp_we : std_logic_vector(7 downto 0);
        variable byte_select : std_logic_vector(3 downto 0);
        variable data_addr_next : std_logic_vector(addr_range);
    begin
        -- Generate byte select signals (for write_enable and misalign check)
        case mode is
            when m_wb | m_rbu | m_rbs => byte_select := "0001";
            when m_wh | m_rhu | m_rhs => byte_select := "0011";
            when m_ww | m_rw          => byte_select := "1111";
            when m_pass               => byte_select := "0000";
        end case;

        -- Generate shifted signals
        temp_data := (others => '0');
        temp_we := (others => '0');
        case data_addr(xlen_subaddr_width - 1 downto 0) is
            when "00"   => temp_data(31 downto  0) := data_in; temp_we(3 downto 0) := byte_select;
            when "01"   => temp_data(39 downto  8) := data_in; temp_we(4 downto 1) := byte_select;
            when "10"   => temp_data(47 downto 16) := data_in; temp_we(5 downto 2) := byte_select;
            when "11"   => temp_data(55 downto 24) := data_in; temp_we(6 downto 3) := byte_select;
            when others => -- do nothing
        end case;

        data_addr_next := std_logic_vector(unsigned(data_addr(addr_range)) + 1);
        if (do_second_access_reg = '0') then
            -- first access
            -- Generate (next) d_bus_out signals
            case mode is
                when m_pass =>
                    d_bus_out                       <= (others => (others => '0'));
                    next_d_bus_out_int              <= (others => (others => '0'));
                when m_rbu | m_rbs | m_rhu | m_rhs | m_rw =>
                    d_bus_out.data                  <= (others => '0');
                    d_bus_out.write_enable          <= (others => '0');
                    d_bus_out.addr                  <= data_addr(addr_range);
                    next_d_bus_out_int.data         <= (others => '0');
                    next_d_bus_out_int.write_enable <= (others => '0');
                    next_d_bus_out_int.addr         <= data_addr_next;
                when others =>
                    d_bus_out.data                  <= temp_data(31 downto 0);
                    d_bus_out.write_enable          <= temp_we(3 downto 0);
                    d_bus_out.addr                  <= data_addr(addr_range);
                    next_d_bus_out_int.data         <= temp_data(63 downto 32);
                    next_d_bus_out_int.write_enable <= temp_we(7 downto 4);
                    next_d_bus_out_int.addr         <= data_addr_next;
            end case;

            -- Check if access is misaligned (needs two accesses)
            misaligned <= sel(temp_we(7 downto 4) /= "0000", '1', '0');
        else
            -- second access
            -- Output next_d_bus_out signals
            d_bus_out <= next_d_bus_out_reg;
            next_d_bus_out_int <= (others => (others => '0'));

            -- misalign solved
            misaligned <= '0';
        end if;
    end process;

    D_BUS_IN_PROCESSING : process (d_bus_in, last_d_bus_in_data_reg, subaddr_reg, mode_reg, data_in_reg, combine_second_access_reg)
        variable temp_data : std_logic_vector(xlen * 2 - 1 downto 0);
    begin
        temp_data := d_bus_in.data & sel(combine_second_access_reg = '1', last_d_bus_in_data_reg, d_bus_in.data);
        case subaddr_reg is
            when "00"   => temp_data(31 downto 0) := temp_data(31 downto  0);
            when "01"   => temp_data(31 downto 0) := temp_data(39 downto  8);
            when "10"   => temp_data(31 downto 0) := temp_data(47 downto 16);
            when "11"   => temp_data(31 downto 0) := temp_data(55 downto 24);
            when others => -- do nothing;
        end case;
        case mode_reg is
            when m_rbu  => data_out <= (31 downto  8 => '0'          ) & temp_data( 7 downto 0);
            when m_rbs  => data_out <= (31 downto  8 => temp_data( 7)) & temp_data( 7 downto 0);
            when m_rhu  => data_out <= (31 downto 16 => '0'          ) & temp_data(15 downto 0);
            when m_rhs  => data_out <= (31 downto 16 => temp_data(15)) & temp_data(15 downto 0);
            when m_rw   => data_out <= temp_data(31 downto 0);
            when m_pass => data_out <= data_in_reg;
            when others => data_out <= (others => '0');
        end case;
    end process;
end bh;