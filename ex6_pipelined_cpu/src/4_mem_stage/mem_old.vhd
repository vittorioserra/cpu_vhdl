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

package mem_types is
    type mem_mask is (
        mask_d,     -- mask for double Word = 64 bits
        mask_w,     -- mask for Word        = 32 bits
        mask_h,     -- mask for half Word   = 16 bits
        mask_b);    -- mask for Byte        =  8 bits
end mem_types;

package body mem_types is
end mem_types;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.utils.ALL;
use work.mem_types.ALL;

entity mem is
    Generic(
        port_width : positive := 32;
        block_count : positive := 512;
        mem_init_file : string := "");
    Port(
        clock : IN std_logic;
        p1_enable, p2_enable, p2_write_enable : IN std_logic;
        p2_mask : IN mem_mask;
        p2_signed : IN std_logic;
        p1_addr, p2_addr : IN std_logic_vector(get_bit_count(block_count * port_width / 8) - 1 downto 0);
        p2_val_in : IN std_logic_vector(port_width - 1 downto 0);
        p1_val_out, p2_val_out : OUT std_logic_vector(port_width - 1 downto 0);
        p1_misalign, p2_misalign : OUT std_logic
    );
end mem;

architecture bh of mem is
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
        variable block_addr, block_bit_offset : integer;
        variable mask_width, block_shift_left, block_shift_right : integer;
        variable block_value : std_logic_vector(port_width - 1 downto 0);
    begin
        block_addr := vec2ui(p2_addr(addr_width - 1 downto get_bit_count(port_width / 8)));
        block_bit_offset := vec2ui(p2_addr(get_bit_count(port_width / 8) downto 0)) * 8;
        case p2_mask is
            when mask_d => mask_width := 64;
            when mask_w => mask_width := 32;
            when mask_h => mask_width := 16;
            when mask_b => mask_width :=  8;
            when others => mask_width :=  0;
        end case;
        block_shift_left := port_width - mask_width - block_bit_offset;
        block_shift_right := port_width - mask_width;

        if (rising_edge(clock) and p2_enable = '1') then
            if port_width < mask_width + block_bit_offset then
                p2_misalign <= '1';
            else
                p2_misalign <= '0';
                if (p2_write_enable = '1') then
                    mem_block(block_addr)(block_bit_offset + mask_width downto block_bit_offset)
                        := p2_val_in(block_bit_offset + mask_width downto block_bit_offset);
                else
                    block_value := std_logic_vector(shift_left(unsigned(mem_block(block_addr)), block_shift_left));
                    case p2_signed is
                        when '0' => p2_val_out <= std_logic_vector(shift_right(unsigned(block_value), block_shift_right));
                        when '1' => p2_val_out <= std_logic_vector(shift_right(signed(block_value), block_shift_right));
                    end case;
                end if;
            end if;
        end if;
    end process;
end bh;
