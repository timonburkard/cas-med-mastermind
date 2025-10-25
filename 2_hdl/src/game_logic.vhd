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
    type values_t is array (3 downto 0) of std_logic_vector(3 downto 0);
    type bool_array_t is array (3 downto 0) of boolean;

    signal current_state : state_t := STATE_RESET;
    signal next_state    : state_t := STATE_RESET;

    signal round_counter : integer range 0 to 15 := 0;

    signal code : std_logic_vector(15 downto 0);

    signal guess_value : values_t;
    signal code_value  : values_t;

    -- calc_hits
    -- returns (5 downto 0): exact hits is (5 downto 3) & partial hits is (2 downto 0)
    function calc_hits(
        guess : values_t; -- User's guess
        code  : values_t  -- Correct code
    ) return std_logic_vector is
        variable counter_exact   : integer range 0 to 4 := 0;                 -- Counter for the number of exact hits
        variable counter_partial : integer range 0 to 4 := 0;                 -- Counter for the number of partial hits
        variable guess_matched   : bool_array_t         := (others => false); -- Which guess digits have already been matched
        variable code_matched    : bool_array_t         := (others => false); -- Which code digits have already been matched
    begin
        -- check for exact hits
        for i in 0 to 3 loop
            if guess(i) = code(i) then
                guess_matched(i) := true;
                code_matched(i)  := true;
                counter_exact    := counter_exact + 1;
            end if;
        end loop;

        -- check for partial hits
        for i in 0 to 3 loop
            if not guess_matched(i) then
                for j in 0 to 3 loop
                    if not code_matched(j) then
                        if guess(i) = code(j) then
                            guess_matched(i) := true;
                            code_matched(j)  := true;
                            counter_partial  := counter_partial + 1;
                        end if;
                    end if;
                end loop;
            end if;
        end loop;

        return std_logic_vector(to_unsigned(counter_exact, 3)) & std_logic_vector(to_unsigned(counter_partial, 3));
    end function;
begin
    round <= std_logic_vector(to_unsigned(round_counter, round'length));

    -- adapters for easy handling
    guess_value(3) <= guess(15 downto 12); -- Guess digit 3 (most significant digit)
    guess_value(2) <= guess(11 downto 8);  -- Guess digit 2
    guess_value(1) <= guess(7 downto 4);   -- Guess digit 1
    guess_value(0) <= guess(3 downto 0);   -- Guess digit 0 (least significant digit)

    code_value(3) <= code(15 downto 12); -- Code digit 3 (most significant digit)
    code_value(2) <= code(11 downto 8);  -- Code digit 2
    code_value(1) <= code(7 downto 4);   -- Code digit 1
    code_value(0) <= code(3 downto 0);   -- Code digit 0 (least significant digit)

    sequential : process (all)
        variable hits : std_logic_vector(5 downto 0);
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

                        hits := calc_hits(guess_value, code_value);
                        exact_hits   <= hits(5 downto 3);
                        partial_hits <= hits(2 downto 0);
                    end if;

                    if to_integer(unsigned(exact_hits)) = 4 then
                        next_state <= STATE_END;
                    end if;

                    if round_counter >= 7 then
                        next_state <= STATE_END;
                    end if;

                when STATE_END =>
                    -- nothing to do, game is over, we just wait for reset

                when others =>
                    next_state <= STATE_RESET; -- error, should never happen

            end case;

            if rst = '1' then
                current_state <= STATE_RESET;
                next_state    <= STATE_RESET;
                round_counter <= 0;
                exact_hits    <= (others => '0');
                partial_hits  <= (others => '0');
            end if;
        end if;
    end process;
end architecture;
