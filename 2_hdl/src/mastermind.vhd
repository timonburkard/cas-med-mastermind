library ieee;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.mastermind_pkg.all;

entity mastermind is
    port (
        signal rst         : in std_logic; -- Synchronous high-active reset
        signal clk         : in std_logic; -- 125 MHz clock
        signal guess       : in std_logic_vector(15 downto 0);
        signal guess_enter : in std_logic;                     -- Guess enter (not yet synced/debounced)
        signal round       : out std_logic_vector(3 downto 0); -- Current round indicator
        signal digit       : out std_logic_vector(6 downto 0); -- 7 segment value
        signal digit_sel   : out std_logic                     -- 7 segment select
    );
end entity;

architecture struct of mastermind is
    signal guess_enter_sync : std_logic; -- Guess enter (single cycle pulse, synced/debounced)
    signal random_number    : std_logic_vector(15 downto 0);
    signal exact_hits       : std_logic_vector(2 downto 0);
    signal partial_hits     : std_logic_vector(2 downto 0);
    signal p1khz            : std_logic; -- 1 kHz pulse from prescaler
begin
    game_logic : entity work.game_logic
        generic map(
            G_MAX_ROUNDS => C_MAX_ROUNDS)
        port map(
            clk              => clk,
            rst              => rst,
            guess            => guess,
            guess_enter_sync => guess_enter_sync,
            random_number    => random_number,
            round            => round,
            exact_hits       => exact_hits,
            partial_hits     => partial_hits
        );

    random_number_generator : entity work.random_number_generator
        port map(
            clk           => clk,
            rst           => rst,
            random_number => random_number
        );

    pmod_ssd : entity work.pmod_ssd
        generic map(
            g_clk_per_digit => C_NOF_SWAP_CYCLES_SYN
        )
        port map(
            rst          => rst,
            clk          => clk,
            exact_hits   => exact_hits,
            partial_hits => partial_hits,
            digit        => digit,
            digit_sel    => digit_sel
        );

    prescaler : entity work.prescaler
        generic map(
            g_max => C_MAX1_SYN
        )
        port map(
            clk   => clk,
            rst   => rst,
            p1khz => p1khz
        );

    debounce : entity work.debounce
        port map(
            rst              => rst,
            clk              => clk,
            p1khz            => p1khz,
            guess_enter      => guess_enter,
            guess_enter_sync => guess_enter_sync
        );

end architecture;
