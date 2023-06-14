----------------------------------------------------------------------------------
-- Company: FAU Erlangen - Nuernberg
-- Engineer: Cedric Donges and Vittorio Serra
--
-- Description: Dual port Memory for CPU, read port for instr, rw port for data
--              Memory can be initalized with file content.
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use STD.TEXTIO.ALL;

library work;
use work.utils.ALL;

entity mem is
    Generic(
        port_width : positive := 32;
        block_count : positive := 512;
        project_path : string := "";
        mem_init_file : string := "");
    Port(
        clock : IN std_logic;
        p1_enable, p2_enable, p2_write_enable : IN std_logic;
        p1_addr, p2_addr : IN std_logic_vector(get_bit_count(block_count) - 1 downto 0);
        p2_val_in : IN std_logic_vector(port_width - 1 downto 0);
        p1_val_out, p2_val_out : OUT std_logic_vector(port_width - 1 downto 0));
end mem;

architecture bh of mem is
    type mem_block_t is array (block_count - 1 downto 0) of std_logic_vector(port_width - 1 downto 0);
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
            for block_index in ret'low to ret'high loop
                if endfile(file_handler) then
                    exit;
                end if;
                readline(file_handler, row);
                for line_index in port_width / 4 - 1 downto 0 loop
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

begin    

    PORT1 : process(clock)
    begin
    
    mem_block(0) := x"00700093";
    mem_block(1) := x"00100513";
    mem_block(2) := x"00d51593";
    mem_block(3) := x"0015a023";
    mem_block(4) := x"ff1ff06f";
    
        if (rising_edge(clock) and p1_enable = '1') then
            p1_val_out <= mem_block(vec2ui(p1_addr));
        end if;
    end process;

    PORT2 : process(clock)
    begin
    
    
    
        if (rising_edge(clock) and p2_enable = '1') then
            if (p2_write_enable = '1') then
                mem_block(vec2ui(p2_addr)) := p2_val_in;
            else
                p2_val_out <= mem_block(vec2ui(p2_addr));
            end if;
        end if;
    end process;
end bh;