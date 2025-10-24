-- Project : mastermind
-----------------------------------------------------
-- File    : mastermind_pkg.vhd
-- Library : mastermind_lib
-- Author  : matthias.schaer1@students.fhnw.ch
-- Company : Institute of Microelectronics (IME) FHNW
-- Copyright(C) IME
-----------------------------------------------------
-- Description : This design generates random numbers
--               using a linear feedback shift
--               register xoring several bits
-----------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity random_number_generator is
    Port ( clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           random_number : out STD_LOGIC_VECTOR(15 downto 0));
end random_number_generator;

architecture Behavioral of random_number_generator is
    constant SEED : STD_LOGIC_VECTOR(15 downto 0) := "1001011001110001";

    signal lfsr_reg : STD_LOGIC_VECTOR(15 downto 0) := SEED;
begin
    -- synchronous process for generating the next random number
    process(all)
    begin
        if rst = '1' then
            lfsr_reg <= SEED; -- seed value
            random_number <= "0000000000000000";
        elsif rising_edge(clk) then
            -- 16-bit LFSR with taps at 16,15,13,4
            lfsr_reg <= lfsr_reg(14 downto 0) &
                        (lfsr_reg(15) xor lfsr_reg(14) xor lfsr_reg(12) xor lfsr_reg(3));
        end if;
    end process;

    -- sequential process for updating random_number
    p_sequential: process(all)
    begin
        -- store lfsr value in random_number
        if lfsr_reg(15 downto 12) < "1010" then
            random_number(15 downto 12) <= lfsr_reg(15 downto 12);
        end if;
        if lfsr_reg(11 downto 8) < "1010" then
            random_number(11 downto 8) <= lfsr_reg(11 downto 8);
        end if;
        if lfsr_reg(7 downto 4) < "1010" then
            random_number(7 downto 4) <= lfsr_reg(7 downto 4);
        end if;
        if lfsr_reg(3 downto 0) < "1010" then
            random_number(3 downto 0) <= lfsr_reg(3 downto 0);
        end if;
    end process;

end Behavioral;