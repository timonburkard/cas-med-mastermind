-----------------------------------------------------
-- Project : stopwatch
-----------------------------------------------------
-- File    : pmod_ssd.vhd
-- Library : stop_watch_lib
-- Author  : matthias.schaer1@students.fhnw.ch
-- Company : Institute of Microelectronics (IME) FHNW
-- Copyright(C) IME
-----------------------------------------------------
-- Description : This design connects to two seven
--               segment displays and switches them
--               in rapid succession
-----------------------------------------------------
library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

-- import constant definitions
library work;
    use work.mastermind_pkg.ALL;

entity pmod_ssd is
    generic (
        g_clk_per_digit : natural := C_NOF_SWAP_CYCLES_SIM
    );
    port (
        reset_n        : in  std_ulogic;
        clk            : in  std_ulogic;
        exact_hits     : in  std_ulogic_vector (2 downto 0);
        partial_hits   : in  std_ulogic_vector (2 downto 0);
        digit          : out std_ulogic_vector (6 downto 0);
        digit_sel      : out std_ulogic
    );
end entity;

architecture rtl of pmod_ssd is
    -- update rate counter
    signal count      : natural range 0 to g_clk_per_digit;

    -- display selector
    signal selector   : std_ulogic;

    -- value to output
    signal pmod_value : integer;
begin
    p_output_switcher : process (all)
    begin
        if rising_edge(clk) then
            -- count up to display switch time
            if count < g_clk_per_digit then
                count <= count + 1;
            else
                count <= 0;
                -- update selector
                selector <= selector xor '1';
                digit_sel <= selector;

                -- store number to output
                if selector = '0' then
                    pmod_value <= to_integer(unsigned(exact_hits));
                else
                    pmod_value <= to_integer(unsigned(partial_hits));
                end if;

            end if;

            -- reset
            if reset_n = '0' then
                selector <= '0';
            end if;
        end if;

    end process;

    -----------------------------------------------------
    -- Combinational PROCESSES:
    -----------------------------------------------------
    p_sevenseg_comb : process (pmod_value)
    begin
        -- translate output number to ssd
        case pmod_value is
            when 0      => digit <= C_0;
            when 1      => digit <= C_1;
            when 2      => digit <= C_2;
            when 3      => digit <= C_3;
            when 4      => digit <= C_4;
            when 5      => digit <= C_5;
            when 6      => digit <= C_6;
            when 7      => digit <= C_7;
            when 8      => digit <= C_8;
            when 9      => digit <= C_9;
            when others => digit <= C_R;
        end case;
    end process p_sevenseg_comb;
end;
