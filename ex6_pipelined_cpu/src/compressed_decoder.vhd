--------------------------------------------------------------------------------
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

        func : OUT ex_func_type;
        op1_select : OUT ex_op1_type;
        op2_select : OUT ex_op2_type;
        addr_base : OUT addr_base_type;
        jump_mode : OUT jump_mode_type;

        rd_select : OUT std_logic_vector(reg_range);
        mem_mode : OUT mem_mode_type;

	    ready : OUT std_logic);
        
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
    
    type instr_routing_type is ( -- instr-type op1  op2  addr_base
           cr_type      ,
           ci_type      ,
           cs_type    ,
           cs_comma_type,
           c_type       ,
           cb_comma_type,
           cj_type      ,
           css_type     ,
           ciw_type     ,
           cl_type ) ;
           
        variable ir_type : instr_routing_type;
        alias rs1    : std_logic_vector(reg_range) is rs1_select;
        alias rs2    : std_logic_vector(reg_range) is rs2_select;
        alias imm    : std_logic_vector(xlen_range) is imm_value;
        alias op1    : ex_op1_type is op1_select;
        alias op2    : ex_op2_type is op2_select;
        alias a_base : addr_base_type is addr_base;
        alias j_mode : jump_mode_type is jump_mode;
        alias rd     : std_logic_vector(reg_range) is rd_select;
        alias m_mode : mem_mode_type is mem_mode; 

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

				    --ir_type := ciw_type;
				    func <= f_add; 
				    op1 <= sel_rs1;  
				    rs1 <= reg_sp;  
				    op2 <= sel_imm;  --select immediate to add to sp                
				    rs2 <= reg_zero; 
				    imm <= (31 downto 0 => '0') & comp_instr(12 downto 5) & (1 downto 0 => '0'); --shift by four
				    rd  <= "01" & comp_instr(4 downto 2); 

                when "001---" => --c.fld --float
				-- TODO : map to NOP, we are not floating point capable
				
                when "010---" =>  -- c.lw

				    imm <= (31 downto 8  => '0') & comp_instr(12 downto 10) & comp_instr(6 downto 5) & ( 1 downto 0 => '0'); --imm, shifted by four
				    --ir_type := cl_type;
				    func <= f_add;
				    m_mode <= m_rw;
				    op1 <= sel_rs1; 
				    op2 <= sel_imm; 
				    rs1 <= "01" & comp_instr(9 downto 7); 
				    rs2 <= reg_zero;
                    rd  <= "01" & comp_instr(4 downto 2); 


                when "011---" => ir_type := cl_type; -- c.flw --float
				--TODO : map to nop

                when "101---" => ir_type := cs_type; -- c.fsd --float
				--TODO : map to nop

                when "110---" =>  -- c.sw

				    imm <= (31 downto 8  => '0') & comp_instr(12 downto 10) & comp_instr(6 downto 5) & ( 1 downto 0 => '0');
				    ir_type := cs_type;
				    func <= f_add;  
				    m_mode <= m_ww;
				    op1 <= sel_rs1; 
				    op2 <= sel_imm;
				    rs1 <= "01" & comp_instr(9 downto 7); 
                    rs2 <= reg_zero;
                    rd  <= "01" & comp_instr(4 downto 2); 

                when "111---" => ir_type := cs_type; -- c.fsw --float
				--TODO : map to  nop
				
        end case;
        
        when "01" => 
            case compressed_funct6 is
                
                when "000000" => ir_type := ci_type; func<=f_add; --c.nop
				
                when "000---" =>  --c.addi
                
				    ir_type := ci_type; 
				    func<=f_add;
				    if (comp_instr(6) = '1') then
				    	imm <= (31 downto 5 => '1') & comp_instr(6 downto 2);
				    else
				    	imm <= (31 downto 5 => '0') & comp_instr(6 downto 2);
				    end if;
				    op1  <= sel_rs1;  
				    rs1 <= comp_instr(11 downto 7);
				    op2  <= sel_imm; 
				    rs2  <= reg_zero;
				    rd   <= comp_instr(11 downto 7);
				

                when "001---" => ir_type := ci_type; --c.jal
				 
                when "010---" => ir_type := cj_type; --c.li

				    func<=f_add;
				    if (comp_instr(6) = '1') then
				    	imm <= (31 downto 5 => '1') & comp_instr(6 downto 2);
				    else
				    	imm <= (31 downto 5 => '0') & comp_instr(6 downto 2);
				    end if;
				    op1 <= sel_rs1;  
				    rs1 <= comp_instr(11 downto 7);
				    rd <= comp_instr(11 downto 7);
				    op2 <= sel_imm; 
				    rs2 <= reg_zero;

                when "011---" => ir_type := ci_type; --c.lui

				
                when "011---" => ir_type := ci_type; --c.addi16sp -- TODO : make a way to keep it apart from c.lui

				if (comp_instr(6) = '1') then
					imm <= (31 downto 9 => '1') & comp_instr(6 downto 2) & (3 downto 0 => '0'); --shifted by 16
				else
					imm <= (31 downto 9 => '0') & comp_instr(6 downto 2) & (3 downto 0 => '0');
				end if;
				func<=f_add;
				op1 <= sel_rs1;
				rs1 <= reg_sp;  
				op2 <= sel_imm; 
				rs2 <= reg_zero;
				rd <=  reg_sp;

                when "100-00" => ir_type := ci_type; func<=f_srl; --c.srli
				
				    imm <= (31 downto 5 => '0') & comp_instr(6 downto 2);
				    op1 <= sel_rs1;  
				    op2 <= sel_imm;                  
				    rs2 <= reg_zero;
				    rs1 <= comp_instr(11 downto 7);
				    rd  <= comp_instr(11 downto 7);

                when "100-01" => ir_type := cb_comma_type; func<= f_sra; --c.srai
				    imm <= (31 downto 5 => '0') & comp_instr(6 downto 2);
				    op1 <= sel_rs1;
				    rs1 <= comp_instr(11 downto 7);
				    rd  <= comp_instr(11 downto 7);  
				    op2 <= sel_imm;                  
				    rs2 <= reg_zero;

                when "100-10" => ir_type := cb_comma_type; func<=f_and; --c.andi

				    if (comp_instr(6) = '1') then
				    	imm <= (31 downto 5 => '1') & comp_instr(6 downto 2);
				    else
				    	imm <= (31 downto 5 => '1') & comp_instr(6 downto 2);
				    end if;	
				    op1 <= sel_rs1;  
				    op2 <= sel_imm;                  
				    rs2 <= reg_zero;
				    rs1 <= comp_instr(11 downto 7); 
                    rd  <= comp_instr(11 downto 7); 
                
                when "101---" => ir_type := cj_type; --c.j
                when "110---" => ir_type := cb_comma_type; func<=f_sltu; --c.beqz
                when "111---" => ir_type := cb_comma_type; func<=f_sltu; --c.bnez
                when "100011" => 
                    case compressed_funct2 is
                        when "00" => --c.sub 
                            ir_type := cs_comma_type; 
                            func<=f_sub;
				            op1 <= sel_rs1;  
				            op2 <= sel_rs2;
				            rs1 <= "01" & comp_instr(9 downto 7);
				            rs2 <= "01" & comp_instr(4 downto 2);
				            rd  <= "01" & comp_instr(9 downto 7);
				
                        when "01" => ir_type := cs_comma_type; func<=f_xor; --c.xor
				            op1 <= sel_rs1;  
				            op2 <= sel_rs2;
				            rs1 <= "01" & comp_instr(9 downto 7);
				            rs2 <= "01" & comp_instr(4 downto 2);
				            rd  <= "01" & comp_instr(9 downto 7);
                        when "10" => ir_type := cs_comma_type; func<=f_or;  --c.or
				            op1 <= sel_rs1;  
				            op2 <= sel_rs2;
				            rs1 <= "01" & comp_instr(9 downto 7);
				            rs2 <= "01" & comp_instr(4 downto 2);
				            rd  <= "01" & comp_instr(9 downto 7);
                        when "11" => ir_type := cs_comma_type; func<=f_and; --c.and
				            op1 <= sel_rs1;  
				            op2 <= sel_rs2;
				            rs1 <= "01" & comp_instr(9 downto 7);
				            rs2 <= "01" & comp_instr(4 downto 2);
				            rd  <= "01" & comp_instr(9 downto 7);
                    end case;
            end case;
         
        when "10" => 
            case compressed_funct6 is
                when "000---" =>ir_type := ci_type; func<=f_sll; --c.slli

				    if (comp_instr(6) = '1') then
				    	imm <= (31 downto 5 => '1') & comp_instr(6 downto 2);
				    else
				    	imm <= (31 downto 5 => '1') & comp_instr(6 downto 2);
				    end if;	
				    op1 <= sel_rs1;  
				    op2 <= sel_imm;                  
				    rs2 <= reg_zero;
				    rs1 <= comp_instr(11 downto 7);
				    rd  <= comp_instr(11 downto 7);		

                when "001---" =>ir_type := ci_type; --c.fldsp --float
                when "010---" =>ir_type := ci_type; --c.lwsp
                when "011---" =>ir_type := ci_type; --c.flwsp --float
                when "1000--" =>ir_type := cr_type; --c.jr

                when "1000--" =>ir_type := cr_type; --c.mv implement logic to tell them apart

                when "1001--" =>ir_type := cr_type; --c.ebreak

                when "1001--" =>ir_type := cr_type; --c.jalr

                when "1001--" =>ir_type := cr_type; func<=f_add; --c.add
				    op1 <= sel_rs1;  
			        op2 <= sel_rs2;
			        rs2 <= comp_instr(6 downto 2);
			        rs1 <= comp_instr(11 downto 7);
			        rd  <= comp_instr(11 downto 7);

                when "101---" =>ir_type := css_type; --c.fsdsp --float

                when "110---" =>ir_type := css_type; --c.swsp
				    imm <= (31 downto 8  => '0') & comp_instr(12 downto 10) & comp_instr(6 downto 5) & ( 1 downto 0 => '0');
				    func   <= f_add;  
				    m_mode <= m_ww;
				    op1    <= sel_rs1; 
				    op2    <= sel_imm;                                   
				    a_base <= sel_rs1;
				    rs2    <= reg_zero;
				    rs1    <= reg_sp; 
				    rd     <= comp_instr(6 downto 2);

                when "111---" =>ir_type := css_type; --c.fswsp --float   
            end case;  
            
          
        end case;
        
        
        -- route operands
        a_base <= sel_pc;
        --rs1    <= instr_reg(19 downto 15);
        --rs2    <= instr_reg(24 downto 20);
        --rd     <= instr_reg(11 downto  7);
--        case ir_type is
--            when cr_type        => op1 <= sel_zero; op2 <= sel_imm; rs1 <= reg_zero; rs2 <= reg_zero;
--            when ci_type        => op1 <= sel_rs1;  op2 <= sel_imm; rs1 <= reg_zero; rs2 <= reg_zero;
--            when cs_type        => op1 <= sel_pc_n; op2 <= sel_rs2; rs1 <= reg_zero; rs2 <= reg_zero; a_base <= sel_pc;
--            when cs_comma_type  => op1 <= sel_rs1;  op2 <= sel_rs2;                                   a_base <= sel_pc;  rd <= reg_zero;
--            when c_type         => op1 <= sel_zero; op2 <= sel_rs2;                                   a_base <= sel_rs1; rd <= reg_zero;
--            when cb_comma_type  => op1 <= sel_rs1;  op2 <= sel_rs2;
--            when cj_type        => op1 <= sel_pc_n; op2 <= sel_rs2;                  rs2 <= reg_zero; a_base <= sel_rs1;
--            when css_type       => op1 <= sel_zero; op2 <= sel_rs2;                  rs2 <= reg_zero; a_base <= sel_rs1;
--            when ciw_type       => op1 <= sel_rs1;  op2 <= sel_imm; rs1 <= reg_sp;   rs2 <= reg_zero, rd <= (5 downto 3 => '0') & comp_instr(4 downto 2);
--            when cl_type        => op1 <= sel_zero; op2 <= sel_rs2; rs1 <= reg_zero; rs2 <= reg_zero;
--        end case;

	--register numbers' : 000 001 010 011 100 101 110 111
 	--actual register   : x8  x9  x10 x11 x12 x13 x14 x15

        -- immediate extraction
--        case ir_type is
--            when ciw_type => imm <= (31 downto 0 => '0') & instr_reg(12 downto 5) & (1 downto 0 => '0'); --shift by four
            
--            when others => imm <= (31 downto 0);
--        end case;        
    
    
    end process;


end bh;
