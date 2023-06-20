----------------------------------------------------------------------------------
-- Company: FAU Erlangen - Nuernberg
-- Engineer: Cedric Donges and Vittorio Serra
--
-- Description: Reset, stall or flush the pipeline if needed.
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity pipeline_control is
    Port(
        reset_n : IN std_logic;

        shadow_copy_done : IN std_logic;
        jump_enable : IN std_logic;

        fe_ready : IN std_logic;
        de_ready : IN std_logic;
        ex_ready : IN std_logic;
        me_ready : IN std_logic;
        wb_ready : IN std_logic;

        fe_reset_n : OUT std_logic;
        de_reset_n : OUT std_logic;
        ex_reset_n : OUT std_logic;
        me_reset_n : OUT std_logic;
        wb_reset_n : OUT std_logic;

        fe_enable : OUT std_logic;
        de_enable : OUT std_logic;
        ex_enable : OUT std_logic;
        me_enable : OUT std_logic;
        wb_enable : OUT std_logic);
end pipeline_control;

architecture bh of pipeline_control is
begin
    -- stall (disable) a stage if it is ready but one of the following stages not
    fe_enable <= not fe_ready or (de_ready and ex_ready and me_ready and wb_ready);
    de_enable <= not de_ready or (             ex_ready and me_ready and wb_ready);
    ex_enable <= not ex_ready or (                          me_ready and wb_ready);
    me_enable <= not me_ready or (                                       wb_ready);
    wb_enable <= '1';

    -- reset processor while shadow copy is running
    -- flush (reset) de and ex stage if jumping
    fe_reset_n <= reset_n and shadow_copy_done;
    de_reset_n <= reset_n and shadow_copy_done and not jump_enable;
    ex_reset_n <= reset_n and shadow_copy_done and not jump_enable;
    me_reset_n <= reset_n and shadow_copy_done;
    wb_reset_n <= reset_n and shadow_copy_done;
end bh;