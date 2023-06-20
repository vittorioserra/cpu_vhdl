----------------------------------------------------------------------------------
-- Company: FAU Erlangen - Nuernberg
-- Engineer: Vittorio Serra and Cedric Donges
--
-- Description: Testbench for the ALU
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.utils.ALL;
use work.rv32i_defs.ALL;

entity alu_tb is
    Generic(PROJECT_PATH : string);
end alu_tb;

architecture tb of alu_tb is
    constant CLOCK_PERIOD : time := 10 ns;

    signal clock: std_logic;
    signal reset_n : std_logic;
    signal enable : std_logic;
    signal func : ex_func_type;
    signal op1, op2 : std_logic_vector(xlen_range);
    signal res : std_logic_vector(xlen_range);
begin

    DUT : entity work.alu
        port map(
			clock => clock,
			enable => enable,
			reset_n => reset_n,
			func => func,
			op1 => op1, op2 => op2,
			res => res);

    gen_clk : process
	begin
		clock <= '0';
		wait for CLOCK_PERIOD / 2;
		clock <= '1';
		wait for CLOCK_PERIOD / 2;
	end process;
	
	stimuli : process
	begin
		-- general reset
		reset_n <= '0';
		enable <= '0';
		wait for CLOCK_PERIOD;
		reset_n <= '1';
		wait for CLOCK_PERIOD;
		enable <= '1';
		
		-- addition
		func <= f_add;
		for i in -4 to 4 loop
			op1 <= si2vec(i, xlen);
			op2 <= si2vec(2, xlen);
			wait for CLOCK_PERIOD;
		end loop;
		
		-- subtraction
		func <= f_sub;
		for i in -4 to 4 loop
			op1 <= si2vec(2, xlen);
			op2 <= si2vec(i, xlen);
			wait for CLOCK_PERIOD;
		end loop;
		
		-- slts
		func <= f_slts;
		for i in -4 to 4 loop
			op1 <= si2vec(i, xlen);
			op2 <= si2vec(0, xlen);
			wait for CLOCK_PERIOD;
		end loop;
		
		-- sltu
		func <= f_sltu;
		for i in -4 to 4 loop
			op1 <= si2vec(2 + i, xlen);
			op2 <= si2vec(2, xlen);
			wait for CLOCK_PERIOD;
		end loop;
		
		-- seq
		func <= f_seq;
		for i in -4 to 4 loop
			op1 <= si2vec(i, xlen);
			op2 <= si2vec(2, xlen);
			wait for CLOCK_PERIOD;
		end loop;
		
		func <= f_seq;
		for i in -4 to 4 loop
			op1 <= si2vec(i, xlen);
			op2 <= si2vec(-1, xlen);
			wait for CLOCK_PERIOD;
		end loop;
		
		-- xor
		op1 <= x"a5a5a5a5";
		op2 <= x"5a5a5a5a";
		func <= f_xor;
		wait for CLOCK_PERIOD;
		
		-- or
		op1 <= x"DEAD0000";
		op2 <= x"0000BEEF";
		func <= f_or;
		wait for CLOCK_PERIOD;
		
		-- and
		op1 <= x"a5a5a5a5";
		op2 <= x"5a5a5a5a";
		func <= f_and;
		wait for CLOCK_PERIOD;
		
		-- sll
		func <= f_sll;
		op1 <= x"DEADBEEF";
		for i in 0 to 4 loop
			op2 <= si2vec(i, xlen);
			wait for CLOCK_PERIOD;
		end loop;
		
		-- srl
		func <= f_srl;
		op1 <= x"C01DCAFE";
		for i in 0 to 4 loop
			op2 <= si2vec(i, xlen);
			wait for CLOCK_PERIOD;
		end loop;
		
		-- sra
		func <= f_sra;
		op1 <= x"FEEBDAED";
		for i in 0 to 4 loop
			op2 <= si2vec(i, xlen);
			wait for CLOCK_PERIOD;
		end loop;
		
		-- disable
		enable <= '0';
		wait for CLOCK_PERIOD;

		wait;
	end process;
end tb;
