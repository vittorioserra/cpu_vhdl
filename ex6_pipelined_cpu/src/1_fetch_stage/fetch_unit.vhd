----------------------------------------------------------------------------------
-- Company: FAU Erlangen - Nuernberg
-- Engineer: Cedric Donges and Vittorio Serra
--
-- Description: Instruction fetch unit which holds the program counter.
--              Reads 16/32 bit instructions from memory and outputs them.
--              Fetch of multiple misaligned 32 bit instructions can be streamlined,
--              without additional penalty. Only jump to a misaligned 32 bit instruction
--              has an one cycle penalty.
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.utils.ALL;
use work.rv32i_defs.ALL;

entity fetch_unit is
    Generic (
        pc_of_entry : std_logic_vector(xlen_range) := (others => '0'));
    Port(
        clock, reset_n, enable : IN std_logic;

        i_bus_in : IN i_bus_miso_rec;
        i_bus_out : OUT i_bus_mosi_rec;

		jump_enable : IN std_logic;
		jump_target : IN std_logic_vector(xlen_range);

		pc_now : OUT std_logic_vector(xlen_range);
		pc_next : OUT std_logic_vector(xlen_range);
        instr : OUT std_logic_vector(instr_range);
        ready : OUT std_logic);
end fetch_unit;

architecture bh of fetch_unit is
    signal combine_this_low_half_with_last_high_half_reg, misaligned, instr_prefetched_reg : std_logic;
	signal pc_now_reg : std_logic_vector(xlen_range);
	signal pc_next_int : std_logic_vector(xlen_range);
	signal i_bus_out_pc_reg : std_logic_vector(xlen_range);
	signal pc_plus_2 : std_logic_vector(xlen_range);
	signal pc_plus_4 : std_logic_vector(xlen_range);
	signal i_bus_out_pc_plus_4 : std_logic_vector(xlen_range);
	signal last_i_bus_data_high_half_reg : std_logic_vector(15 downto 0);
begin
	pc_now <= pc_now_reg;
	pc_next <= pc_next_int;

    pc_plus_2 <= std_logic_vector(unsigned(pc_now_reg) + 2);
    pc_plus_4 <= std_logic_vector(unsigned(pc_now_reg) + 4);
    i_bus_out_pc_plus_4 <= std_logic_vector(unsigned(i_bus_out_pc_reg) + 4);

    instr_processing : process(combine_this_low_half_with_last_high_half_reg, last_i_bus_data_high_half_reg,
        pc_plus_2, pc_plus_4, i_bus_in, pc_now_reg)
    begin
        if (combine_this_low_half_with_last_high_half_reg = '1') then
            -- the second half of an misaligned 32bit instruction was loaded
            pc_next_int <= pc_plus_4;
            instr <= i_bus_in.data(15 downto 0) & last_i_bus_data_high_half_reg;
            ready <= '1';

            -- check if the next instruction is misaligned
            misaligned <= sel(i_bus_in.data(17 downto 16) = "11", '1', '0');
        elsif (pc_now_reg(1) = '0') then
            if (i_bus_in.data(1 downto 0) = "11") then
                -- instruction is 32 bit long and aligned
                pc_next_int <= pc_plus_4;
                instr <= i_bus_in.data;
                ready <= '1';
                misaligned <= '0';
            else
                -- instruction is 16 bit long and in low half
                pc_next_int <= pc_plus_2;
                ready <= '1';
                instr <= (31 downto 16 => '0') & i_bus_in.data(15 downto 0);

                -- when the next instruction is 32 bit long, it is misaligned
                misaligned <= sel(i_bus_in.data(17 downto 16) = "11", '1', '0');
            end if;
        else
            if (i_bus_in.data(17 downto 16) = "11") then
                -- instruction is 32 bit long and misaligned
                pc_next_int <= pc_plus_4;
                instr <= "00000000000000000000000000010011"; -- nop (addi x0, x0, 0)
                ready <= '0';
                misaligned <= '1';
            else
                -- instruction is 16 bit long and in high half
                pc_next_int <= pc_plus_2;
                ready <= '1';
                instr <= (31 downto 16 => '0') & i_bus_in.data(31 downto 16);
                misaligned <= '0';
            end if;
        end if;
    end process;

	fetch_control : process(clock, reset_n, enable)
	begin
		if (rising_edge(clock)) then
            if (reset_n = '0') then
                -- load the entry point
                last_i_bus_data_high_half_reg <= (others => '0');
                pc_now_reg <= pc_of_entry(xlen - 1 downto 1) & '0';
                i_bus_out_pc_reg <= pc_of_entry(xlen - 1 downto 1) & '0';
                instr_prefetched_reg <= '0';
                combine_this_low_half_with_last_high_half_reg <= '0';
            elsif (enable = '1') then
                -- remember the high half of the current instruction for misaligned 32 bit access
                last_i_bus_data_high_half_reg <= i_bus_in.data(31 downto 16);
                if (jump_enable = '1') then
                    -- jump to the target address
                    pc_now_reg <= jump_target(xlen - 1 downto 1) & '0';
                    i_bus_out_pc_reg <= jump_target(xlen - 1 downto 1) & '0';
                    instr_prefetched_reg <= '0';
                    combine_this_low_half_with_last_high_half_reg <= '0';
                elsif (misaligned = '1') then
                    -- the current 32 bit instruction is misaligned
                    -- fetch the second half of the current instruction and combine the instruction
                    i_bus_out_pc_reg <= i_bus_out_pc_plus_4;
                    combine_this_low_half_with_last_high_half_reg <= '1';
                    instr_prefetched_reg <= '1';

                    -- when the high half of the current instruction was not fetched in the last cycle
                    -- we were not able to output the current instruction in this cycle
                    -- so we should not advance the program counter
                    pc_now_reg <= sel(instr_prefetched_reg = '0', pc_now_reg, pc_next_int);
                else
                    -- the current instruction (16 or 32 bit) is not misaligned, so operate normal
                    pc_now_reg <= pc_next_int;
                    i_bus_out_pc_reg <= pc_next_int;
                    instr_prefetched_reg <= '1';
                    combine_this_low_half_with_last_high_half_reg <= '0';
                end if;
            end if;
		end if;
	end process;

	i_bus_addr_generate : process(reset_n, enable, jump_enable, jump_target, misaligned, i_bus_out_pc_plus_4, pc_next_int)
	begin
        -- this generates the address for the memory without the register stage
        -- because mem has its own registers (to be able to infer BRAM)
		if (reset_n = '0') then
            i_bus_out.addr <= pc_of_entry(addr_range);
        else
            if (jump_enable = '1') then
                i_bus_out.addr <= jump_target(addr_range);
            elsif (misaligned = '1') then
                i_bus_out.addr <= i_bus_out_pc_plus_4(addr_range);
            else
                i_bus_out.addr <= pc_next_int(addr_range);
            end if;
        end if;
	end process;
end bh;
