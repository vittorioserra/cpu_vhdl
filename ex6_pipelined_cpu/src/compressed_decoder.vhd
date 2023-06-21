----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 06/21/2023 01:02:45 PM
-- Design Name: 
-- Module Name: compressed_decoder - Behavioral
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

library work;
use work.utils.ALL;
use work.rv32i_defs.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity compressed_decoder is
 Port(
        clock, reset_n, enable : IN std_logic;

        comp_instr : IN std_logic_vector(15 downto 0);

        rs1_select : OUT std_logic_vector(reg_range);
        rs2_select : OUT std_logic_vector(reg_range);
        imm_value : OUT std_logic_vector(xlen_range);

        ex_mode : OUT ex_func_type;
        ex_op1_select : OUT ex_op1_type;
        ex_op2_select : OUT ex_op2_type;
        ex_addr_base : OUT addr_base_type;
        ex_jump_mode : OUT jump_mode_type;

        rd_select : OUT std_logic_vector(reg_range);
        mem_mode : OUT mem_mode_type);
        
end compressed_decoder;

architecture bh of compressed_decoder is


    function compressed_op_carve_out(instruction : std_logic_vector(15 downto 0)) return std_logic_vector is 
    variable compressed_op : std_logic_vector(2 downto 0);
    begin

    compressed_op := instruction(2 downto 0);

    return compressed_op;
    end function;
    
    function compressed_funct4_carve_out(instruction : std_logic_vector(15 downto 0)) return std_logic_vector is 
    variable compressed_funct4 : std_logic_vector(15 downto 12);
    begin

    compressed_funct4 := instruction(15 downto 12);

    return compressed_funct4;
    end function;
    
    function compressed_funct3_carve_out(instruction : std_logic_vector(15 downto 0)) return std_logic_vector is 
    variable compressed_funct3 : std_logic_vector(15 downto 13);
    begin

    compressed_funct3 := instruction(15 downto 13);

    return compressed_funct3;
    end function;
    
    function compressed_funct6_carve_out(instruction : std_logic_vector(15 downto 0)) return std_logic_vector is 
    variable compressed_funct6 : std_logic_vector(15 downto 10);
    begin

    compressed_funct6 := instruction(15 downto 10);

    return compressed_funct6;
    end function;
    
    function compressed_funct_carve_out(instruction : std_logic_vector(15 downto 0)) return std_logic_vector is 
    variable compressed_funct : std_logic_vector(11 downto 10);
    begin

    compressed_funct := instruction(11 downto 10);

    return compressed_funct;
    end function;
    
    function compressed_funct2_carve_out(instruction : std_logic_vector(15 downto 0)) return std_logic_vector is 
    variable compressed_funct2 : std_logic_vector(6 downto 5);
    begin

    compressed_funct2 := instruction(6 downto 5);

    return compressed_funct2;
    end function;
        

begin


    DECODE : process(clock) 
    
    variable compressed_op             :  std_logic_vector(2 downto 0);
    variable compressed_funct3         :  std_logic_vector(15 downto 13);
    variable compressed_funct6         :  std_logic_vector(15 downto 10);
    variable compressed_funct          :  std_logic_vector(11 downto 10);
    variable compressed_funct2         :  std_logic_vector(6 downto 5);       

    begin
    
    compressed_op     := compressed_op_carve_out(comp_instr);
    compressed_funct3 := compressed_funct3_carve_out(comp_instr);
    compressed_funct6 := compressed_funct6_carve_out(comp_instr);
    compressed_funct  := compressed_funct_carve_out(comp_instr);
    compressed_funct2 := compressed_funct2_carve_out(comp_instr);    
    
    
    case compressed_op is 
        when "00" => 
            case compressed_funct6 is
                when "000---" => -- c.addi4spn
                when "001---" => -- c.fld
                when "010---" => -- c.lw
                when "011---" => -- c.flw
                when "101---" => -- c.fsd
                when "110---" => -- c.sw
                when "111---" => -- c.fsw
        end case;
        
        when "01" => 
            case compressed_funct6 is
                when "000000" => --c.nop
                when "000---" => --c.addi
                when "001---" => --c.jal
                when "010---" => --c.li
                when "011---" => --c.lui
                when "011---" => --c.addi16sp -- TODO : make a way to keep it apart from c.lui
                when "100-00" => --c.srli
                when "100-01" => --c.srai
                when "100-10" => --c.andi
                when "101---" => --c.j
                when "110---" => --c.beqz
                when "111---" => --c.bnez
                when "100011" =>
                    case compressed_funct2 is
                        when "00" => --c.sub 
                        when "01" => --c.xor
                        when "10" => --c.or
                        when "11" => --c.and
                    end case;
            end case;
         
        when "10" => 
            case compressed_funct6 is
                when "000---" => --c.slli
                when "001---" => --c.fldp
                when "010---" => --c.lwsp
                when "011---" => --c.flwsp
                when "1000--" => --c.jr
                when "1000--" => --c.mv implement logic to tell them apart
                when "1001--" => --c.ebreak
                when "1001--" => --c.jalr
                when "1001--" => --c.add
                when "101---" => --c.fsdsp
                when "110---" => --c.swsp
                when "111---" => --c.fswsp           
            end case;  
            
          
        end case;
                
    
    
    end process;


end bh;
