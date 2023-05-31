----------------------------------------------------------------------------------
-- Company: FAU Erlangen - Nuernberg
-- Engineer: Cedric Donges and Vittorio Serra
--
-- Description: Dual port Memory for CPU, read port for instr, rw port for data
--              Generates a misalign signal if the mask-address combination is not naturally aligned.
--              Data Port can be masked (the lowest n bits are selected):
--                  Reads the selected bits and extend it to port_width with 0 or sign extend it.
--                  Writes only the selected bits.
--              Memory can be initalized with file content.
----------------------------------------------------------------------------------

package mem32_types is
    type mem32_mask is (
        mask_w,      -- Word                 = 32 bits
        mask_hs,     -- half Word (signed)   = 16 bits
        mask_hu,     -- half Word (unsigned) = 16 bits
        mask_bs,     -- Byte (signed)        =  8 bits
        mask_bu);    -- Byte (unsigned)      =  8 bits
end mem32_types;

package body mem32_types is
end mem32_types;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.utils.ALL;
use work.mem32_types.ALL;

entity mem32 is
    Generic(
        block_count : positive := 512;
        mem_init_file : string := "");
    Port(
        clock : IN std_logic;
        p1_enable, p2_enable, p2_write_enable : IN std_logic;
        p2_mask : IN mem32_mask;
        p1_addr, p2_addr : IN std_logic_vector(get_bit_count(block_count * 4) - 1 downto 0);
        p2_val_in : IN std_logic_vector(31 downto 0);
        p1_val_out, p2_val_out : OUT std_logic_vector(31 downto 0);
        p1_misalign, p2_misalign : OUT std_logic
    );
end mem32;

architecture bh of mem32 is
    constant port_width : positive := 32;
    constant addr_width : positive := get_bit_count(block_count * port_width / 8);
    type mem_block_t is array (block_count - 1 downto 0) of std_logic_vector(port_width - 1 downto 0);
    shared variable mem_block : mem_block_t;-- := file2mem(mem_init_file, port_width / 8, block_count);
begin
    --PORT1 : process(clock)
    --begin
    --    -- TODO read von p2 kopieren
    --    if (rising_edge(clock) and p1_enable = '1') then
    --        if (p1_addr(1 downto 0) = b"00") then
    --            p1_val_out <= mem_block(vec2ui(p1_addr(addr_width - 1 downto get_bit_count(port_width / 8))));
    --            p1_misalign <= '0';
    --        else
    --            p1_val_out <= (others => '0');
    --            p1_misalign <= '1';
    --        end if;
    --    end if;
    --end process;

    PORT2 : process(clock)
        function mask2vec(mask : mem32_mask) return std_logic_vector is
        begin
            case mask is
                when mask_w  => return "100";
                when mask_hs => return "011";
                when mask_hu => return "010";
                when mask_bs => return "001";
                when mask_bu => return "000";
                when others  => return "100";
            end case;
        end function;
        function extract(vec : std_logic_vector; l : integer; r : integer; s : boolean)
            return std_logic_vector is
            variable ret : std_logic_vector(port_width - 1 downto 0);
        begin
            for i in ret'range loop
                if (i >= l - r and s) then
                    ret(i) := vec(l);
                elsif (i >= l - r and not s) then
                    ret(i) := '0';
                else
                    ret(i) := vec(l - i);
                end if;
            end loop;
            return ret;
        end function;
        variable block_addr : integer;
    begin
        if (rising_edge(clock) and p2_enable = '1') then
            block_addr := vec2ui(p2_addr(addr_width - 1 downto 2));
            p2_misalign <= '0';
            if (p2_write_enable = '1') then
                case std_logic_vector'(mask2vec(p2_mask) & p2_addr(1 downto 0)) is
                    when "10000" | "10100" => mem_block(block_addr)(31 downto  0) := p2_val_in(31 downto 0);
                    when "01000" | "01100" => mem_block(block_addr)(15 downto  0) := p2_val_in(15 downto 0);
                    when "01010" | "01110" => mem_block(block_addr)(31 downto 16) := p2_val_in(15 downto 0);
                    when "00000" | "00100" => mem_block(block_addr)( 7 downto  0) := p2_val_in( 7 downto 0);
                    when "00001" | "00101" => mem_block(block_addr)(15 downto  8) := p2_val_in( 7 downto 0);
                    when "00010" | "00110" => mem_block(block_addr)(23 downto 16) := p2_val_in( 7 downto 0);
                    when "00011" | "00111" => mem_block(block_addr)(31 downto 24) := p2_val_in( 7 downto 0);
                    when others  => p2_misalign <= '1';
                end case;
            else
                case std_logic_vector'(mask2vec(p2_mask) & p2_addr(1 downto 0)) is
                    when "10000" => p2_val_out <= extract(mem_block(block_addr), 31,  0, false);
                    when "01000" => p2_val_out <= extract(mem_block(block_addr), 15,  0, false);
                    when "01010" => p2_val_out <= extract(mem_block(block_addr), 31, 16, false);
                    when "00000" => p2_val_out <= extract(mem_block(block_addr),  7,  0, false);
                    when "00001" => p2_val_out <= extract(mem_block(block_addr), 15,  8, false);
                    when "00010" => p2_val_out <= extract(mem_block(block_addr), 23, 16, false);
                    when "00011" => p2_val_out <= extract(mem_block(block_addr), 31, 24, false);
                    
                    when "10100" => p2_val_out <= extract(mem_block(block_addr), 31,  0, true);
                    when "01100" => p2_val_out <= extract(mem_block(block_addr), 15,  0, true);
                    when "01110" => p2_val_out <= extract(mem_block(block_addr), 31, 16, true);
                    when "00100" => p2_val_out <= extract(mem_block(block_addr),  7,  0, true);
                    when "00101" => p2_val_out <= extract(mem_block(block_addr), 15,  8, true);
                    when "00110" => p2_val_out <= extract(mem_block(block_addr), 23, 16, true);
                    when "00111" => p2_val_out <= extract(mem_block(block_addr), 31, 24, true);

                    when others  => p2_misalign <= '1';
                end case;
            end if;
        end if;
    end process;
end bh;
