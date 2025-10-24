-- Project : mastermind
-----------------------------------------------------
-- File    : prescaler.vhd
-- Library : mastermind_lib
-- Author  : matthias.schaer1@students.fhnw.ch
-- Company : Institute of Microelectronics (IME) FHNW
-- Copyright(C) IME
-----------------------------------------------------
-- Description : 1kHz prescaler which outputs a pulse
-----------------------------------------------------
library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

-- import constant definitions
library work;
    use work.mastermind_pkg.ALL;

entity prescaler is
    generic (
        g_max : natural := C_MAX1_SIM;
    );
    port (
        clk     : in std_ulogic;
        rst     : in std_ulogic;
        p1khz   : out std_ulogic
    );
end prescaler;


architecture rtl of prescaler is
  signal count       : natural range 0 to g_max;
begin

    prescale_reg : process (clk, rst)
        variable v_max : natural;
    begin
        if rising_edge (clk) then
            -- default values
            p1khz  <= '0';
            v_max := g_max;
            -- synthesis translate_off
            v_max := g_max;
            -- synthesis translate_on
            -- cascaded counter
            if count = v_max then
                -- set p1khz
                p1khz  <= '1';
                count <= 0;
            else
                count <= count + 1;
            end if;

            -- reset
            if rst = '1' then
                count <= 0;
                p1khz  <= '0';
            end if;
        end if;
    end process;

end architecture rtl;