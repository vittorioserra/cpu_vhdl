----------------------------------------------------------------------------------
-- Company: FAU Erlangen - Nuernberg
-- Engineer: Cedric Donges and Vittorio Serra
--
-- Description: Dual port Memory for CPU, sync read port for instr, sync rw port for data
--              Memory can be initalized with file content.
--              The bytes of the block that will be written are selectable.
----------------------------------------------------------------------------------

-- TODO we can buildin a shadow-rom which holds the contents of the init-file
--      during reset this rom could be copied in the memory.
--      a copy_done signal should report the end of copying

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use STD.TEXTIO.ALL;

library work;
use work.utils.ALL;
use work.rv32i_defs.ALL;

entity mem is
    Generic(
        block_count : positive := 512;
        project_path : string := "";
        mem_init_file : string := "");
    Port(
        clock : IN std_logic;
        chip_addr : IN std_logic_vector(addr_range'high downto addr_range'low + get_bit_count(block_count));
        d_bus_in : IN d_bus_mosi_rec;
        d_bus_out : OUT d_bus_miso_rec;
        i_bus_in : IN i_bus_mosi_rec;
        i_bus_out : OUT i_bus_miso_rec);
end mem;

architecture bh of mem is
    type mem_block_t is array (0 to block_count - 1) of std_logic_vector(xlen_range);
    impure function file2mem(filename : string) return mem_block_t is
        file file_handler : text;
        variable file_status : file_open_status;
        variable ret : mem_block_t;
        variable row : line;
        variable char : character;
        variable nibble : std_logic_vector(3 downto 0);
    begin
        ret := (others => (others => '0'));
        
        if (filename = "") then
            return ret;
        end if;

        file_open(file_status, file_handler, project_path & filename, read_mode);
        if (file_status /= open_ok) then
            return ret;
        elsif (ends_with(filename, ".o")) then
            for block_index in ret'range loop
                if endfile(file_handler) then
                    exit;
                end if;
                readline(file_handler, row);
                for line_index in xlen / 4 - 1 downto 0 loop
                    if (row'length = 0) then
                        exit;
                    end if;
                    read(row, char);
                    if    (char = '0') then nibble := x"0";
                    elsif (char = '1') then nibble := x"1";
                    elsif (char = '2') then nibble := x"2";
                    elsif (char = '3') then nibble := x"3";
                    elsif (char = '4') then nibble := x"4";
                    elsif (char = '5') then nibble := x"5";
                    elsif (char = '6') then nibble := x"6";
                    elsif (char = '7') then nibble := x"7";
                    elsif (char = '8') then nibble := x"8";
                    elsif (char = '9') then nibble := x"9";
                    elsif (char = 'A' or char = 'a') then nibble := x"A";
                    elsif (char = 'B' or char = 'b') then nibble := x"B";
                    elsif (char = 'C' or char = 'c') then nibble := x"C";
                    elsif (char = 'D' or char = 'd') then nibble := x"D";
                    elsif (char = 'E' or char = 'e') then nibble := x"E";
                    elsif (char = 'F' or char = 'f') then nibble := x"F";
                    else nibble := x"0";
                    end if;
                    ret(block_index)(line_index * 4 + 3 downto line_index * 4) := nibble;
                end loop;
            end loop;
        end if;
        file_close(file_handler);
        return ret;
    end function;
    shared variable mem_block : mem_block_t := file2mem(mem_init_file);
    subtype mem_addr_range is natural range get_bit_count(block_count) + addr_range'low - 1 downto addr_range'low;
begin
    SYNC_PORT1 : process(clock)
    begin
        if (rising_edge(clock)) then
            if (is_selected(chip_addr, i_bus_in.addr)) then
                i_bus_out.data <= mem_block(vec2ui(i_bus_in.addr(mem_addr_range)));
            else
                i_bus_out.data <= (others => '0');
            end if;
        end if;
    end process;

    SYNC_PORT2 : process(clock)
    begin
        if (rising_edge(clock)) then
            if (is_selected(chip_addr, d_bus_in.addr)) then
                d_bus_out.data <= mem_block(vec2ui(d_bus_in.addr(mem_addr_range)));
                for i in d_bus_in.write_enable'range loop
                    if (d_bus_in.write_enable(i) = '1') then
                        mem_block(vec2ui(d_bus_in.addr(mem_addr_range)))(i * 8 + 7 downto i * 8)
                            := d_bus_in.data(i * 8 + 7 downto i * 8);
                    end if;
                end loop;
            end if;
        end if;
    end process;
end bh;
