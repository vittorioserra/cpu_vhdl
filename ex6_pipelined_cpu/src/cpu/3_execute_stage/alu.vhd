----------------------------------------------------------------------------------
-- Company:     FAU Erlangen - Nuernberg
-- Engineer:    Vittorio Serra and Cedric Donges
--
-- Description: alu for RISC-V 32I
--              More optimal resource utilization by reusing logic.
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.utils.ALL;
use work.rv32i_defs.ALL;

entity alu is
    Port(
        clock, reset_n, enable : IN std_logic;
        func : IN ex_func_type;
        op1, op2 : IN std_logic_vector(xlen_range);
        res : OUT std_logic_vector(xlen_range));
end alu;

architecture bh of alu is
    type unit_select is (arithmetic, shift, logic);
    type op_reg_t is array (unit_select) of std_logic_vector(xlen_range);
    type func_reg_t is array (unit_select) of ex_func_type;
    type enable_reg_t is array (unit_select) of std_logic;
    signal op1_reg : op_reg_t;
    signal op2_reg : op_reg_t;
    signal res_int : op_reg_t;
    signal func_reg : func_reg_t;
    signal enable_reg : enable_reg_t;
begin
    res <= res_int(arithmetic) or res_int(shift) or res_int(logic);

    INPUT_REGISTER : process (clock)
    begin
        if (rising_edge(clock)) then
            if (reset_n = '0') then
                op1_reg <= (others => (others => '0'));
                op2_reg <= (others => (others => '0'));
                func_reg <= (arithmetic => f_add, shift => f_sll, logic => f_and);
                enable_reg <= (others => '0');
            elsif (enable = '1') then
                enable_reg <= (others => '0');
                case func is
                    when f_add | f_sub | f_slts | f_sltu | f_seq =>
                        op1_reg(arithmetic)  <= op1;
                        op2_reg(arithmetic)  <= op2;
                        func_reg(arithmetic) <= func;
                        enable_reg(arithmetic) <= '1';
                    when f_sll | f_srl | f_sra =>
                        op1_reg(shift)  <= op1;
                        op2_reg(shift)  <= op2;
                        func_reg(shift) <= func;
                        enable_reg(shift) <= '1';
                    when f_xor | f_or | f_and =>
                        op1_reg(logic)  <= op1;
                        op2_reg(logic)  <= op2;
                        func_reg(logic) <= func;
                        enable_reg(logic) <= '1';
                end case;
            end if;
        end if;
    end process;

    ARITHMETIC_UNIT : process (op1_reg, op2_reg, func_reg, enable_reg)
        variable op1_int : unsigned(xlen_range);
        variable op2_int : unsigned(xlen_range);
        variable carry_out_res_int : unsigned(xlen downto 0);
        variable carry_in : unsigned(0 downto 0);
    begin
        op1_int := unsigned(op1_reg(arithmetic));
        op2_int := unsigned(op2_reg(arithmetic));

        -- negate the old MSB for signed compare (can then be treated as unsigned compare)
        if (func_reg(arithmetic) = f_slts) then
            op1_int(op1_int'high) := not op1_int(op1_int'high);
            op2_int(op2_int'high) := not op2_int(op2_int'high);
        end if;

        -- 2's complement if subtraction is needed
        case func_reg(arithmetic) is
            when f_sub | f_slts | f_sltu | f_seq =>
                op2_int := not op2_int;
                carry_in := to_unsigned(1, 1);
            when others =>
                carry_in := to_unsigned(0, 1);
        end case;

        -- add the two operands together with carry in (append a zero msb for carry out)
        carry_out_res_int := '0' & op1_int + op2_int + carry_in;

        -- calculate the result
        -- an overflow occurs if the carry_out xor carry_in is true
        -- when we test less_than the carry_in is always set (to do an subtraction)
        -- so the comparision less_than is true if the carry_out is not set
        case func_reg(arithmetic) is
            when f_add  | f_sub  => res_int(arithmetic) <= std_logic_vector(carry_out_res_int(xlen_range));
            when f_slts | f_sltu => res_int(arithmetic) <= bool2vec(carry_out_res_int(carry_out_res_int'high) = '0', xlen);
            when f_seq           => res_int(arithmetic) <= bool2vec(std_logic_vector(carry_out_res_int(xlen_range)) = ui2vec(0, xlen), xlen);
            when others          => res_int(arithmetic) <= (others => '0');
        end case;

        if (enable_reg(arithmetic) = '0') then
            res_int(arithmetic) <= (others => '0');
        end if;
    end process;

    SHIFT_UNIT : process (op1_reg, op2_reg, func_reg, enable_reg)
        variable sign : std_logic;
        variable op1_int : std_logic_vector(xlen_range);
        variable shamt : integer range 0 to xlen - 1;
    begin
        -- barrel shifter
        op1_int := op1_reg(shift);
        sign := op1_int(op1_int'high);
        for s in 0 to get_bit_count(xlen) - 1 loop
            if (op2_reg(shift)(s) = '1') then
                shamt := 2 ** s;
                case func_reg(shift) is
                    when f_sll => op1_int := op1_int(op1_int'high - shamt downto 0) & (shamt downto 1 => '0');
                    when f_srl => op1_int := (shamt downto 1 => '0')  & op1_int(op1_int'high downto shamt);
                    when f_sra => op1_int := (shamt downto 1 => sign) & op1_int(op1_int'high downto shamt);
                    when others   => op1_int := (others => '0');
                end case;
            end if;
        end loop;

        if (enable_reg(shift) = '1') then
            res_int(shift) <= op1_int;
        else
            res_int(shift) <= (others => '0');
        end if;
    end process;

    LOGIC_UNIT : process (op1_reg, op2_reg, func_reg, enable_reg)
    begin
        case func_reg(logic) is
            when f_xor => res_int(logic) <= op1_reg(logic) xor op2_reg(logic);
            when f_or  => res_int(logic) <= op1_reg(logic)  or op2_reg(logic);
            when f_and => res_int(logic) <= op1_reg(logic) and op2_reg(logic);
            when others   => res_int(logic) <= (others => '0');
        end case;

        if (enable_reg(logic) = '0') then
            res_int(logic) <= (others => '0');
        end if;
    end process;
end bh;
