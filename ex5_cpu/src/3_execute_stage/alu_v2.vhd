----------------------------------------------------------------------------------
-- Company: FAU Erlangen - Nuernberg
-- Engineer: Vittorio Serra and Cedric Donges
--
-- Description: alu_v2 for RISC-V 32I
--              More optimal resource utilization by reusing logic.
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.utils.ALL;
use work.rv32i_defs.ALL;

entity alu_v2 is
    Port(
        reset_n : IN std_logic;
        clock: IN std_logic;
        func : IN alu_func;
        op1, op2 : IN std_logic_vector(xlen_range);
        res : OUT std_logic_vector(xlen_range));
end alu_v2;

architecture bh of alu_v2 is
    type op_reg_select is (arithmetic, shift, logic);
    type op_reg_t is array (op_reg_select) of std_logic_vector(xlen_range);
    signal op1_reg : op_reg_t;
    signal op2_reg : op_reg_t;
    signal res_int : op_reg_t;
    signal func_reg : alu_func;
begin
    res <= res_int(arithmetic) or res_int(shift) or res_int(logic);

    INPUT_REGISTER : process (clock)
    begin
        if (rising_edge(clock)) then
            if (reset_n = '0') then
                op1_reg <= (others => (others => '0'));
                op2_reg <= (others => (others => '0'));
                func_reg <= func_and;
            else
                case func is
                    when func_add | func_sub | func_slts | func_sltu | func_seq =>
                        op1_reg(arithmetic) <= op1;
                        op2_reg(arithmetic) <= op2;
                    when func_sll | func_srl | func_sra =>
                        op1_reg(shift) <= op1;
                        op2_reg(shift) <= op2;
                    when func_xor | func_or | func_and =>
                        op1_reg(logic) <= op1;
                        op2_reg(logic) <= op2;
                end case;
                func_reg <= func;
            end if;
        end if;
    end process;

    ARITHMETIC_UNIT : process (op1_reg, op2_reg, func_reg)
        variable op1_var : unsigned(xlen_range);
        variable op2_var : unsigned(xlen_range);
        variable carry_out_res_var : unsigned(xlen downto 0);
        variable carry_in : unsigned(0 downto 0);
    begin
        op1_var := unsigned(op1_reg(arithmetic));
        op2_var := unsigned(op2_reg(arithmetic));

        -- negate the old MSB for signed compare (can then be treated as unsigned compare)
        if (func_reg = func_slts) then
            op1_var(op1_var'high) := not op1_var(op1_var'high);
            op2_var(op2_var'high) := not op2_var(op2_var'high);
        end if;

        -- 2's complement if subtraction is needed
        case func_reg is
            when func_sub | func_slts | func_sltu | func_seq =>
                op2_var := not op2_var;
                carry_in := to_unsigned(1, 1);
            when others =>
                carry_in := to_unsigned(0, 1);
        end case;

        -- add the two operands together with carry in (append a zero msb for carry out)
        carry_out_res_var := '0' & op1_var + op2_var + carry_in;

        -- calculate the result
        -- an overflow occurs if the carry_out xor carry_in is true
        -- when we test less_than the carry_in is always set (to do an subtraction)
        -- so the comparision less_than is true if the carry_out is not set
        case func_reg is
            when func_add  | func_sub  => res_int(arithmetic) <= std_logic_vector(carry_out_res_var(xlen_range));
            when func_slts | func_sltu => res_int(arithmetic) <= bool2vec(carry_out_res_var(carry_out_res_var'high) = '0', xlen);
            when func_seq              => res_int(arithmetic) <= bool2vec(std_logic_vector(carry_out_res_var(xlen_range)) = ui2vec(0, xlen), xlen);
            when others                => res_int(arithmetic) <= (others => '0');
        end case;
    end process;

    SHIFT_UNIT : process (op1_reg, op2_reg, func_reg)
        variable shift_amount : integer range 0 to xlen - 1;
    begin
        shift_amount := vec2ui(op2_reg(shift));
        case func_reg is
            when func_sll => res_int(shift) <= std_logic_vector(shift_left( unsigned(op1_reg(shift)), shift_amount));
            when func_srl => res_int(shift) <= std_logic_vector(shift_right(unsigned(op1_reg(shift)), shift_amount));
            when func_sra => res_int(shift) <= std_logic_vector(shift_right(  signed(op1_reg(shift)), shift_amount));
            when others   => res_int(shift) <= (others => '0');
        end case;
    end process;

    LOGIC_UNIT : process (op1_reg, op2_reg, func_reg)
    begin
        case func_reg is
            when func_xor => res_int(logic) <= op1_reg(logic) xor op2_reg(logic);
            when func_or  => res_int(logic) <= op1_reg(logic)  or op2_reg(logic);
            when func_and => res_int(logic) <= op1_reg(logic) and op2_reg(logic);
            when others   => res_int(logic) <= (others => '0');
        end case;
    end process;
end bh;
