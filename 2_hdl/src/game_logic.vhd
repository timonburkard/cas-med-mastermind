library ieee;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.mastermind_pkg.all;

entity game_logic is
    port (
        clk              : in std_logic;                     -- 125 MHz clock
        rst              : in std_logic;                     -- Synchronous high-active reset
        guess            : in std_logic_vector(15 downto 0); -- Guess digit
        guess_enter_sync : in std_logic;                     -- Guess enter (single cycle pulse, synced/debounced)
        random_number    : in std_logic_vector(15 downto 0); -- Random number digits
        round            : out std_logic_vector(3 downto 0); -- Current round indicator
        exact_hits       : out std_logic_vector(2 downto 0); -- Number of exact hits (asses)
        partial_hits     : out std_logic_vector(2 downto 0)  -- Number of partial hits (guts)
    );
end entity;

architecture fsm of game_logic is
    type state_t is (STATE_RESET, STATE_RUNNING, STATE_END);

    signal current_state : state_t := STATE_RESET;
    signal next_state    : state_t := STATE_RESET;

    signal round_counter : integer range 0 to 15 := 0;

    signal code : std_logic_vector(15 downto 0);

    function calc_exact_hits(
        guess : std_logic_vector(15 downto 0);
        code  : std_logic_vector(15 downto 0)
    ) return std_logic_vector is
        variable counter : integer range 0 to 4 := 0;
    begin
        if guess(15 downto 12) = code(15 downto 12) then
            counter := counter + 1;
        end if;

        if guess(11 downto 8) = code(11 downto 8) then
            counter := counter + 1;
        end if;

        if guess(7 downto 4) = code(7 downto 4) then
            counter := counter + 1;
        end if;

        if guess(3 downto 0) = code(3 downto 0) then
            counter := counter + 1;
        end if;

        return std_logic_vector(to_unsigned(counter, 3));
    end function;

    function calc_partial_hits(
        guess : std_logic_vector(15 downto 0);
        code  : std_logic_vector(15 downto 0)
    ) return std_logic_vector is
    begin
        return std_logic_vector(to_unsigned(0, 3)); -- TODO: implementation
    end function;
begin
    round <= std_logic_vector(to_unsigned(round_counter, round'length));

    sequential : process (all)
    begin
        if rising_edge(clk) then
            -- move to the next state
            current_state <= next_state;

            -- figure out what to do in the current state
            -- and in which state to go in next iteration
            case current_state is
                when STATE_RESET =>
                    round_counter <= 0;
                    exact_hits    <= (others => '0');
                    partial_hits  <= (others => '0');

                    if guess_enter_sync = '1' then
                        code <= random_number;

                        next_state <= STATE_RUNNING;
                    end if;

                when STATE_RUNNING =>

                    if (round_counter = 0) or (guess_enter_sync = '1') then
                        round_counter <= round_counter + 1;

                        exact_hits   <= calc_exact_hits(guess, code);
                        partial_hits <= calc_partial_hits(guess, code);
                    end if;

                    if to_integer(unsigned(exact_hits)) = 4 then
                        next_state <= STATE_END;
                    end if;

                    if round_counter >= 7 then
                        next_state <= STATE_END;
                    end if;

                when STATE_END =>
                    -- nothing to do

                when others =>
                    next_state <= STATE_RESET; -- error, should never happen

            end case;

            if rst = '1' then
                round_counter <= 0;
                exact_hits    <= (others => '0');
                partial_hits  <= (others => '0');
            end if;
        end if;
    end process;
end architecture;
