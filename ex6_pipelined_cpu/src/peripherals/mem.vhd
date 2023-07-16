----------------------------------------------------------------------------------
-- Company: FAU Erlangen - Nuernberg
-- Engineer: Cedric Donges and Vittorio Serra
--
-- Description: Dual port Memory for CPU, sync read port for instr, sync read then write port for data
--              Memory can be initalized with file content.
--              The data bytes in a block, that will be written are selectable.
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use STD.TEXTIO.ALL;

library work;
use work.utils.ALL;
use work.rv32i_defs.ALL;

entity mem is
    Generic(
        project_path : string := "";
        mem_init_file : string := "";
        chip_addr : std_logic_vector(xlen_range);
        block_count : positive);
    Port(
        clock : IN std_logic;
        d_bus_in : IN d_bus_mosi_rec;
        d_bus_out : OUT d_bus_miso_rec;
        i_bus_in : IN i_bus_mosi_rec;
        i_bus_out : OUT i_bus_miso_rec);
end mem;

architecture bh of mem is
    constant chip_addr_int : std_logic_vector(addr_range'high downto addr_range'low + get_bit_count(block_count))
        := chip_addr(addr_range'high downto addr_range'low + get_bit_count(block_count));
    type mem_block_t is array (0 to block_count - 1) of std_logic_vector(xlen_range);

    procedure readHexByte(row : in string; cursor : inout integer; value : out std_logic_vector) is
        variable char : character;
        variable nibble : std_logic_vector(3 downto 0);
    begin
        value := (others => '0');
        for i in 1 downto 0 loop
            char := row(cursor);
            cursor := cursor + 1;
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
            value(i * 4 + 3 downto i * 4) := nibble;
        end loop;
    end procedure;

    procedure writeByte(value : in std_logic_vector; addr : inout integer; mem : inout mem_block_t) is
        constant blockSize : integer := xlen / 8;
        variable blockIndex : integer;
        variable bitIndex : integer;
    begin
        blockIndex := (addr - vec2ui(chip_addr)) / blockSize;
        if (blockIndex >= 0 and blockIndex < block_count) then
            bitIndex := (addr mod blockSize) * 8;
            mem(blockIndex)(bitIndex + 7 downto bitIndex) := value;
        end if;
        addr := addr + 1;
    end procedure;
    
    procedure parseIntelHex(row : in string; rowCursor : inout integer; baseAddr : inout integer; mem : inout mem_block_t) is
        variable dataLength : integer;
        variable memAddr : integer;
        variable tempByte : std_logic_vector(7 downto 0);
    begin
        -- RECLEN
        readHexByte(row, rowCursor, tempByte);
        dataLength := vec2ui(tempByte);

        -- LOAD OFFSET
        memAddr := baseAddr;
        readHexByte(row, rowCursor, tempByte);
        memAddr := memAddr + vec2ui(tempByte) * 256;
        readHexByte(row, rowCursor, tempByte);
        memAddr := memAddr + vec2ui(tempByte);

        -- RECTYP
        readHexByte(row, rowCursor, tempByte);
        case tempByte is
            when x"00"  => -- Data Record
                for i in 1 to dataLength loop
                    readHexByte(row, rowCursor, tempByte);
                    writeByte(tempByte, memAddr, mem);
                end loop;

            when x"02"  => -- Extended Segment Address Record
                readHexByte(row, rowCursor, tempByte);
                baseAddr := vec2ui(tempByte) * 256 * 16;
                readHexByte(row, rowCursor, tempByte);
                baseAddr := baseAddr + vec2ui(tempByte) * 16;
                
            when x"04"  => -- Extended Linear Address Record
                readHexByte(row, rowCursor, tempByte);
                baseAddr := vec2ui(tempByte) * 256 * 256 * 256;
                readHexByte(row, rowCursor, tempByte);
                baseAddr := baseAddr + vec2ui(tempByte) * 256 * 256;
            
            when x"01"  => -- End of File Record (ignore)
            when x"03"  => -- Start Segment Address Record (ignore)
            when x"05"  => -- Start Linear Address Record (ignore)
            when others => -- unknown type (ignore)
        end case;
    end procedure;

    impure function file2mem(filename : string) return mem_block_t is
        file file_handler : text;
        variable file_status : file_open_status;
        variable ret : mem_block_t;
        variable memAddr : integer;
        variable rowCursor : integer;
        variable rowLine : line;
        variable rowString : string(1 to 64);
        variable tempByte : std_logic_vector(7 downto 0);
        variable tempChar : character;
    begin
        ret := (others => (others => '0'));
        
        if (filename = "") then
            return ret;
        end if;

        file_open(file_status, file_handler, project_path & filename, read_mode);
        if (file_status /= open_ok) then
            return ret;
        elsif (ends_with(filename, ".hex")) then
            -- reads Intel Hex and Simple Hex
            memAddr := 0;
            while not endfile(file_handler) loop
                -- read the line and convert it to string
                readline(file_handler, rowLine);
                for i in 1 to rowLine'length - 1 loop
                    read(rowLine, tempChar);
                    rowString(i) := tempChar;
                end loop;
                
                rowCursor := 1;
                if (rowLine'length = 0) then
                    -- rowLine is empty -> skip
                    next;
                elsif (rowString(rowCursor) = ':') then
                    -- Intel Hex Format
                    rowCursor := rowCursor + 1;
                    parseIntelHex(rowString, rowCursor, memAddr, ret);
                else
                    -- Simple Hex Format
                    while rowCursor < rowLine'length loop
                        readHexByte(rowString, rowCursor, tempByte);
                        writeByte(tempByte, memAddr, ret);
                    end loop;
                end if;
            end loop;
        end if;
        file_close(file_handler);
        return ret;
    end function;

    shared variable mem_block : mem_block_t := file2mem(mem_init_file);
    subtype mem_addr_range is natural range get_bit_count(block_count) + addr_range'low - 1 downto addr_range'low;
begin
    -- check if the chip_addr is aligned with the block_count
    assert vec2ui(chip_addr(chip_addr_int'low - 1 downto 0)) = 0 report "RAM origin must be aligned with the RAM size." severity FAILURE;

    SYNC_PORT1 : process(clock)
    begin
        if (rising_edge(clock)) then
            if (is_selected(chip_addr_int, i_bus_in.addr)) then
                i_bus_out.data <= mem_block(vec2ui(i_bus_in.addr(mem_addr_range)));
            else
                i_bus_out.data <= (others => '0');
            end if;
        end if;
    end process;

    SYNC_PORT2 : process(clock)
    begin
        if (rising_edge(clock)) then
            if (is_selected(chip_addr_int, d_bus_in.addr)) then
                d_bus_out.data <= mem_block(vec2ui(d_bus_in.addr(mem_addr_range)));
                for i in d_bus_in.write_enable'range loop
                    if (d_bus_in.write_enable(i) = '1') then
                        mem_block(vec2ui(d_bus_in.addr(mem_addr_range)))(i * 8 + 7 downto i * 8)
                            := d_bus_in.data(i * 8 + 7 downto i * 8);
                    end if;
                end loop;
            else
                d_bus_out.data <= (others => '0');
            end if;
        end if;
    end process;
end bh;
