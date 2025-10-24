-----------------------------------------------------
-- Copyright (c) FHNW 2021
-----------------------------------------------------
library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

entity debounce is
    port(
        rst              : in  std_ulogic;
        clk              : in  std_ulogic;
        p1khz            : in  std_ulogic;
        guess_enter      : in  std_ulogic;
        guess_enter_sync : out std_ulogic
    );
end debounce;


architecture rtl of debounce is
    constant C_DEB_LEN        : natural := 10;
    signal guess_enter_sync1  : std_ulogic;
    signal guess_enter_sync2  : std_ulogic;
    signal guess_enter_d1      : std_ulogic;
    signal guess_enter_d2      : std_ulogic;
begin

    -----------------------------------------------------
    -- Synchronize and debounce start_stop
    -- 1. synchronize with double stage synchronizer
    -- 2. shift in new value after 1 ms
    -- 3. debounce: rising edge immediately, falling edge debounced
    -- 4. delayed debounced button by one clock cycle
    -- 5. puls for positive edge of debounced button
    -----------------------------------------------------
    p_start_stop : process (clk, rst)
        variable shift_reg : std_ulogic_vector(C_DEB_LEN-1 downto 0);
    begin
        if rising_edge (clk) then
            -- 1
            guess_enter_sync1 <= guess_enter;
            guess_enter_sync2 <= guess_enter_sync1;
            -- 2
            if p1khz = '1' then
                shift_reg := shift_reg(shift_reg'high-1 downto 0) & guess_enter_sync2;
            end if;

            -- 3
            if guess_enter_sync2 = '1' then
                guess_enter_d1 <= '1';           -- button pressed
            elsif shift_reg = std_ulogic_vector(to_unsigned(0, C_DEB_LEN)) then
                guess_enter_d1 <= '0';           -- button released
            end if;

            -- 4
            guess_enter_d2 <= guess_enter_d1;

            -- reset
            if rst = '1' then
                guess_enter_sync1 <= '0';
                guess_enter_sync2 <= '0';
                guess_enter_d1    <= '0';
                guess_enter_d2    <= '0';
                shift_reg     := (others => '0');
            end if;
        end if;
    end process p_start_stop;

    -- 5
    guess_enter_sync <= guess_enter_d1 and not guess_enter_d2;

end architecture rtl;

