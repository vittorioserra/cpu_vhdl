----------------------------------------------------------------------------------
-- Company: FAU Erlangen - Nuernberg
-- Engineer: Vittorio Serra and Cedric Donges
--
-- Description: testbench for the ALU
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.utils.ALL;
use work.alu_types.ALL;

entity alu_tb is
end alu_tb;

architecture tb of alu_tb is
    constant CLOCK_PERIOD : time := 10 ns;
    constant PORT_WIDTH : positive := 32;

    signal clock, reset_n : std_logic;
    signal func : alu_func;
    signal op1, op2 : std_logic_vector(PORT_WIDTH - 1 downto 0);
    signal async_lsb : std_logic;
    signal res : std_logic_vector(PORT_WIDTH - 1 downto 0);
begin
    DUT : entity work.alu
        generic map (
            port_width => PORT_WIDTH)
        port map (
            reset_n => reset_n,
            clock => clock,
            func => func,
            op1 => op1,
            op2 => op2,
            async_lsb => async_lsb,
            res => res);

    gen_clk : process
    begin
        clock <= '1';
        wait for CLOCK_PERIOD / 2;
        clock <= '0';
        wait for CLOCK_PERIOD / 2;
    end process;

    stimuli : process
    begin
        reset_n <= '1';
        wait for CLOCK_PERIOD;
        
        reset_n <= '0';
        wait for CLOCK_PERIOD;
        
        reset_n <= '1';
        op1 <= ui2vec(77, PORT_WIDTH);
        op2 <= ui2vec(55, PORT_WIDTH);
        func <= func_add;
        wait for CLOCK_PERIOD;
        
        wait;

    end process;
end tb;
