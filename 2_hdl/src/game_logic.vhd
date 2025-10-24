library ieee;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity game_logic is
    port (
        clk              : in std_logic;                     -- 125 MHz clock
        rst              : in std_logic;                     -- Synchronous high-active reset
        guess_3          : in std_logic_vector(3 downto 0);  -- Guess digit 3: most-significant digit
        guess_2          : in std_logic_vector(3 downto 0);  -- Guess digit 2
        guess_1          : in std_logic_vector(3 downto 0);  -- Guess digit 1
        guess_0          : in std_logic_vector(3 downto 0);  -- Guess digit 0: least-significant digit
        guess_enter_sync : in std_logic;                     -- Guess enter (single cycle pulse, synced/debounced)
        random_number_3  : in std_logic_vector(3 downto 0);  -- Random number digit 3: most-significant digit
        random_number_2  : in std_logic_vector(3 downto 0);  -- Random number digit 2
        random_number_1  : in std_logic_vector(3 downto 0);  -- Random number digit 1
        random_number_0  : in std_logic_vector(3 downto 0);  -- Random number digit 0: least-significant digit
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

    signal code_3 : std_logic_vector(3 downto 0);
    signal code_2 : std_logic_vector(3 downto 0);
    signal code_1 : std_logic_vector(3 downto 0);
    signal code_0 : std_logic_vector(3 downto 0);

    function calc_exact_hits(
        guess_3, guess_2, guess_1, guess_0, code_3, code_2, code_1, code_0 : std_logic_vector(3 downto 0)
    ) return std_logic_vector(2 downto 0) is
        variable counter : integer := 0;
    begin
        if guess_3 = code_3 then
            counter := counter + 1;
        end if;

        if guess_2 = code_2 then
            counter := counter + 1;
        end if;

        if guess_1 = code_1 then
            counter := counter + 1;
        end if;

        if guess_0 = code_0 then
            counter := counter + 1;
        end if;

        return std_logic_vector(to_unsigned(counter, 3));
    end function;

    function calc_partial_hits(
        guess_3, guess_2, guess_1, guess_0, code_3, code_2, code_1, code_0 : std_logic_vector(3 downto 0)
    ) return std_logic_vector(2 downto 0) is
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
                        code_3 <= random_number_3;
                        code_2 <= random_number_2;
                        code_1 <= random_number_1;
                        code_0 <= random_number_0;

                        next_state <= STATE_RUNNING;
                    end if;

                when STATE_RUNNING =>

                    if (round_counter = 0) or (guess_enter_sync = '1') then
                        round_counter <= round_counter + 1;

                        exact_hits   <= calc_exact_hits(guess_3, guess_2, guess_1, guess_0, code_3, code_2, code_1, code_0);
                        partial_hits <= calc_partial_hits(guess_3, guess_2, guess_1, guess_0, code_3, code_2, code_1, code_0);
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
