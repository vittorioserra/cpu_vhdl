----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/10/2023 01:14:56 PM
-- Design Name: 
-- Module Name: alu - bh
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity alu is
    Generic(
        port_width : positive := 32;
        reg_count : positive := 2;
        instruction_width : positive  := 4
        );
    Port(
        clock: IN std_logic;
        r1_operand, r2_operand : IN std_logic_vector(port_width - 1 downto 0);
        r_result : OUT std_logic_vector(port_width - 1 downto 0);
        r_opcode : IN std_logic_vector(instruction_width - 1 downto 0)
        );
end alu;

architecture bh of alu is

begin
    computation : process(clock)
    
    variable operand_1 : unsigned(port_width -1 downto 0) := unsigned(r1_operand);
    variable operand_2 : unsigned(port_width -1 downto 0) := unsigned(r2_operand);

    
    begin
        case r_opcode is
            when b"0000" =>--amd
                r_result <= r1_operand and r2_operand;
            when b"0001" =>--or
                r_result <= r1_operand or r2_operand;
            when b"0010" =>--add
                r_result <= std_logic_vector(operand_1 + operand_2);
            when b"0100" =>--lui
                 r_result <= std_logic_vector(operand_1 + operand_2);
            end case;
    end process;
end bh;
