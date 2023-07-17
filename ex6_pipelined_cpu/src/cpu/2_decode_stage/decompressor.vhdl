----------------------------------------------------------------------------------
-- Company: FAU Erlangen - Nuernberg
-- Engineer: Vittorio Serra and Cedric Donges
--
-- Description: Instruction Decompressor for RV32C
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.utils.ALL;
use work.rv32i_defs.ALL;

entity decompressor is
    Port(
        instr_in : IN std_logic_vector(instr_range);
        instr_out : OUT std_logic_vector(instr_range));
end decompressor;

architecture bh of decompressor is
begin
    process(instr_in)
        constant reg_ra : std_logic_vector(reg_range) := "00001";
        constant reg_sp : std_logic_vector(reg_range) := "00010";
        alias iin : std_logic_vector(instr_range) is instr_in;
        alias iout : std_logic_vector(instr_range) is instr_out;

        variable rd_rs1_CR_CI : std_logic_vector(reg_range);
        variable rs2_CR_CSS : std_logic_vector(reg_range);
        variable rd_CIW_CL : std_logic_vector(reg_range);
        variable rs1_CL_CS : std_logic_vector(reg_range);
        variable rs2_CS_CA : std_logic_vector(reg_range);
        variable rd_rs1_CA_CB : std_logic_vector(reg_range);

        variable imm_z4_CIW_I : std_logic_vector(11 downto 0);
        variable imm_z8_CL_CS_I_S : std_logic_vector(11 downto 0);
        variable imm_z4_CL_CS_I_S : std_logic_vector(11 downto 0);
        variable imm_s_CI_CB_I_U : std_logic_vector(11 downto 0);
        variable imm_s16_CI_I : std_logic_vector(11 downto 0);
        variable imm_z8_CI_I : std_logic_vector(11 downto 0);
        variable imm_z4_CI_I : std_logic_vector(11 downto 0);
        variable imm_s_CB_B : std_logic_vector(11 downto 0);
        variable imm_s_CJ_J : std_logic_vector(19 downto 0);
        variable imm_z8_CSS_S : std_logic_vector(11 downto 0);
        variable imm_z4_CSS_S : std_logic_vector(11 downto 0);

        variable imm_nez_CIW : std_logic;
        variable imm_nez_CI : std_logic;
        variable rd_nesp_CI : std_logic;
        variable rd_rs1_nez_CI_CR : std_logic;
        variable rs2_nez_CR : std_logic;
    begin
        -- carve out building blocks (registers and immediates)
        rd_rs1_CR_CI :=        iin(11 downto 7);
        rs2_CR_CSS   :=        iin( 6 downto 2);
        rd_CIW_CL    := "01" & iin( 4 downto 2);
        rs1_CL_CS    := "01" & iin( 9 downto 7);
        rs2_CS_CA    := "01" & iin( 4 downto 2);
        rd_rs1_CA_CB := "01" & iin( 9 downto 7);

        imm_z4_CIW_I     :=  "00" & iin(10 downto 7) & iin(12 downto 11) & iin(5) & iin(6) & "00";                                                  -- uimm[5:4|9:6|2|3]+5
        imm_z8_CL_CS_I_S :=  "0000" & iin(6 downto 5) & iin(12 downto 10) & "000";                                                                  -- uimm[5:3]+10 uimm[7:6]+5
        imm_z4_CL_CS_I_S :=  "00000" & iin(5) & iin(12 downto 10) & iin(6) & "00";                                                                  -- uimm[5:3]+10 uimm[2|6]+5
        imm_s_CI_CB_I_U  :=  (11 downto 5 => iin(12)) & iin(6 downto 2);                                                                            -- imm[5]+12 imm[4:0]+2
        imm_s16_CI_I     :=  (11 downto 9 => iin(12)) & iin(4 downto 3) & iin(5) & iin(2) & iin(6) & "0000";                                        -- imm[9]+12 imm[4|6|8:7|5]+2
        imm_z8_CI_I      :=  "000" & iin(4 downto 2) & iin(12) & iin(6 downto 5) & "000";                                                           -- uimm[5]+12 uimm[4:3|8:6]+2
        imm_z4_CI_I      :=  "0000" & iin(3 downto 2) & iin(12) & iin(6 downto 4) & "00";                                                           -- uimm[5]+12 uimm[4:2|7:6]+2
        imm_s_CB_B       :=  (11 downto 8 => iin(12)) & iin(6 downto 5) & iin(2) & iin(11 downto 10) & iin(4 downto 3) & iin(12);                   -- imm[8|4:3]+10 imm[7:6|2:1|5]+2   - also scramble output [12|10:5] [4:1|11]
        imm_s_CJ_J       :=  iin(12) & iin(8) & iin(10 downto 9) & iin(6) & iin(7) & iin(2) & iin(11) & iin(5 downto 3) & (8 downto 0 => iin(12));  -- imm[11|4|9:8|10|6|7|3:1|5]+2     - also scramble output imm[20|10:1|11|19:12]
        imm_z8_CSS_S     :=  "000" & iin(9 downto 7) & iin(12 downto 10) & "000";                                                                   -- uimm[5:3|8:6]+7
        imm_z4_CSS_S     :=  "0000" & iin(8 downto 7) & iin(12 downto 9) & "00";                                                                    -- uimm[5:2|7:6]+7

        -- zero and sp checks
        imm_nez_CIW      := sel(           iin(12 downto 5)  /= "00000000", '1', '0');
        imm_nez_CI       := sel((iin(12) & iin( 6 downto 2)) /= "000000"  , '1', '0');
        rd_nesp_CI       := sel(           iin(11 downto 7)  /= reg_sp    , '1', '0');
        rd_rs1_nez_CI_CR := sel(           iin(11 downto 7)  /= reg_zero  , '1', '0');
        rs2_nez_CR       := sel(           iin( 6 downto 2)  /= reg_zero  , '1', '0');

        -- decompress instructions
        case? iin(15 downto 0) & imm_nez_CIW & imm_nez_CI & rd_nesp_CI & rd_rs1_nez_CI_CR & rs2_nez_CR is
            when "000--------000000----" => iout <= "00000000000000000000000000000000";                                                                       -- illegal instruction         => illegal instruction
            when "000-----------001----" => iout <= imm_z4_CIW_I & reg_sp & "000" & rd_CIW_CL & "0010011";                                                    -- CIW.ADDI4SPN (imm != 0)     => I.addi rd',  sp, zimm4
            when "001-----------00-----" => iout <= imm_z8_CL_CS_I_S & rs1_CL_CS & "011" & rd_CIW_CL & "0000111";                                             -- CL.FLD                      => I.fld  rd',  zimm8(rs1')
            when "010-----------00-----" => iout <= imm_z4_CL_CS_I_S & rs1_CL_CS & "010" & rd_CIW_CL & "0000011";                                             -- CL.LW                       => I.lw   rd',  zimm4(rs1')
            when "011-----------00-----" => iout <= imm_z4_CL_CS_I_S & rs1_CL_CS & "010" & rd_CIW_CL & "0000111";                                             -- CL.FLW                      => I.flw  rd',  zimm4(rs1')
            when "101-----------00-----" => iout <= imm_z8_CL_CS_I_S(11 downto 5) & rs2_CS_CA & rs1_CL_CS & "011" & imm_z8_CL_CS_I_S(4 downto 0) & "0100111"; -- CS.FSD                      => S.fsd  rs2', zimm8(rs1')
            when "110-----------00-----" => iout <= imm_z4_CL_CS_I_S(11 downto 5) & rs2_CS_CA & rs1_CL_CS & "010" & imm_z4_CL_CS_I_S(4 downto 0) & "0100011"; -- CS.SW                       => S.sw rs2', zimm4(rs1')
            when "111-----------00-----" => iout <= imm_z4_CL_CS_I_S(11 downto 5) & rs2_CS_CA & rs1_CL_CS & "010" & imm_z4_CL_CS_I_S(4 downto 0) & "0100111"; -- CS.FSW                      => S.fsw rs2', zimm4(rs1')
            when "000-----------01-----" => iout <= imm_s_CI_CB_I_U & rd_rs1_CR_CI & "000" & rd_rs1_CR_CI & "0010011";                                        -- CI.ADDI                     => I.addi rd, rd, simm
            when "001-----------01-----" => iout <= imm_s_CJ_J & reg_ra & "1101111";                                                                          -- CJ.JAL                      => J.jal ra, simm
            when "010-----------01-----" => iout <= imm_s_CI_CB_I_U & reg_zero & "000" & rd_rs1_CR_CI & "0010011";                                            -- CI.LI                       => I.addi rd, zero, simm
            when "011-----------01-10--" => iout <= imm_s16_CI_I & reg_sp & "000" & reg_sp & "0010011";                                                       -- CI.ADDI16SP (imm != 0)      => I.addi sp, sp, simm16
            when "011-----------01-11--" => iout <= (31 downto 24 => imm_s_CI_CB_I_U(11)) & imm_s_CI_CB_I_U & rd_rs1_CR_CI & "0110111";                       -- CI.LUI (imm != 0, rd != sp) => U.lui rd, simm
            when "100000--------01-----" => iout <= "0000000" & imm_s_CI_CB_I_U(4 downto 0) & rd_rs1_CA_CB & "101" & rd_rs1_CA_CB & "0010011";                -- CB.SRLI                     => I.srli rd', rd', simm
            when "100001--------01-----" => iout <= "0100000" & imm_s_CI_CB_I_U(4 downto 0) & rd_rs1_CA_CB & "101" & rd_rs1_CA_CB & "0010011";                -- CB.SRAI                     => I.srai rd', rd', simm
            when "100-10--------01-----" => iout <= imm_s_CI_CB_I_U & rd_rs1_CA_CB & "111" & rd_rs1_CA_CB & "0010011";                                        -- CB.ANDI                     => I.andi rd', rd', simm
            when "100011---00---01-----" => iout <= "0100000" & rs2_CS_CA & rd_rs1_CA_CB & "000" & rd_rs1_CA_CB & "0110011";                                  -- CA.SUB                      => R.sub rd', rd', rs2'
            when "100011---01---01-----" => iout <= "0000000" & rs2_CS_CA & rd_rs1_CA_CB & "100" & rd_rs1_CA_CB & "0110011";                                  -- CA.XOR                      => R.xor rd', rd', rs2'
            when "100011---10---01-----" => iout <= "0000000" & rs2_CS_CA & rd_rs1_CA_CB & "110" & rd_rs1_CA_CB & "0110011";                                  -- CA.OR                       => R.or rd', rd', rs2'
            when "100011---11---01-----" => iout <= "0000000" & rs2_CS_CA & rd_rs1_CA_CB & "111" & rd_rs1_CA_CB & "0110011";                                  -- CA.AND                      => R.and rd', rd', rs2'
            when "101-----------01-----" => iout <= imm_s_CJ_J & reg_zero & "1101111";                                                                        -- CJ.J                        => J.jal zero, simm
            when "110-----------01-----" => iout <= imm_s_CB_B(11 downto 5) & reg_zero & rd_rs1_CA_CB & "000" & imm_s_CB_B(4 downto 0) & "1100011";           -- CB.BEQZ                     => B.beq rs1', zero, simm
            when "111-----------01-----" => iout <= imm_s_CB_B(11 downto 5) & reg_zero & rd_rs1_CA_CB & "001" & imm_s_CB_B(4 downto 0) & "1100011";           -- CB.BNEZ                     => B.bne rs1', zero, simm
            when "0000----------10-----" => iout <= "0000000" & imm_s_CI_CB_I_U(4 downto 0) & rd_rs1_CR_CI & "001" & rd_rs1_CR_CI & "0010011";                -- CI.SLLI                     => I.slli rd, rd, simm
            when "001-----------10-----" => iout <= imm_z8_CI_I & reg_sp & "011" & rd_rs1_CR_CI & "0000111";                                                  -- CI.FLDSP                    => I.fld rd, zimm8(sp)
            when "010-----------10---1-" => iout <= imm_z4_CI_I & reg_sp & "010" & rd_rs1_CR_CI & "0000011";                                                  -- CI.LWSP (rd != zero)        => I.lw rd, zimm4(sp)
            when "011-----------10-----" => iout <= imm_z4_CI_I & reg_sp & "010" & rd_rs1_CR_CI & "0000111";                                                  -- CI.FLWSP                    => I.flw rd, zimm4(sp)
            when "1000----------10---10" => iout <= "000000000000" & rd_rs1_CR_CI & "000" & reg_zero & "1100111";                                             -- CR.JR (rs1 != zero)         => I.jalr zero, rs1, 0
            when "1000----------10----1" => iout <= "0000000" & rs2_CR_CSS & reg_zero & "000" & rd_rs1_CR_CI & "0110011";                                     -- CR.MV (rs2 != zero)         => R.add rd, zero, rs2
            when "1001----------10---00" => iout <= "00000000000100000000000001110011";                                                                       -- CR.EBREAK                   => I.ebreak
            when "1001----------10---10" => iout <= "000000000000" & rd_rs1_CR_CI & "000" & reg_ra & "1100111";                                               -- CR.JALR (rs1 != zero)       => I.jalr ra, rs1, 0
            when "1001----------10----1" => iout <= "0000000" & rs2_CR_CSS & rd_rs1_CR_CI & "000" & rd_rs1_CR_CI & "0110011";                                 -- CR.ADD (rs2 != zero)        => R.add rd, rd, rs2
            when "101-----------10-----" => iout <= imm_z8_CSS_S(11 downto 5) & rs2_CR_CSS & reg_sp & "011" & imm_z8_CSS_S(4 downto 0) & "0100111";           -- CSS.FSDSP                   => S.fsd rs2, zimm8(sp)
            when "110-----------10-----" => iout <= imm_z4_CSS_S(11 downto 5) & rs2_CR_CSS & reg_sp & "010" & imm_z4_CSS_S(4 downto 0) & "0100011";           -- CSS.SWSP                    => S.sw rs2, zimm4(sp)
            when "111-----------10-----" => iout <= imm_z4_CSS_S(11 downto 5) & rs2_CR_CSS & reg_sp & "010" & imm_z4_CSS_S(4 downto 0) & "0100111";           -- CSS.FSWSP                   => S.fsw rs2, zimm4(sp)
            when others                  => iout <= iin;                                                                                                      -- uncompressed or unknown     => passthrough
        end case?;
    end process;
end bh;
