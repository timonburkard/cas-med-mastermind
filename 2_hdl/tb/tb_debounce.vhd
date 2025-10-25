-----------------------------------------------------
-- Testbench for debounce module
-- Tests synchronization, debouncing, and edge detection
-----------------------------------------------------
library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

entity debounce_tb is
end debounce_tb;

architecture sim of debounce_tb is
    
    -- Component declaration
    component debounce is
        port(
            rst              : in  std_ulogic;
            clk              : in  std_ulogic;
            p1khz            : in  std_ulogic;
            guess_enter      : in  std_ulogic;
            guess_enter_sync : out std_ulogic
        );
    end component;
    
    -- Clock period definitions
    constant C_CLK_PERIOD  : time := 10 ns;  -- 100 MHz clock
    constant C_1KHZ_PERIOD : time := 1 ms;   -- 1 kHz pulse period
    
    -- Signals
    signal rst              : std_ulogic := '1';
    signal clk              : std_ulogic := '0';
    signal p1khz            : std_ulogic := '0';
    signal guess_enter      : std_ulogic := '0';
    signal guess_enter_sync : std_ulogic;
    
    -- Control signals
    signal sim_done : boolean := false;
    
begin

    -- Instantiate the Unit Under Test (UUT)
    uut: debounce
        port map (
            rst              => rst,
            clk              => clk,
            p1khz            => p1khz,
            guess_enter      => guess_enter,
            guess_enter_sync => guess_enter_sync
        );

    -- Clock generation
    clk_process : process
    begin
        while not sim_done loop
            clk <= '0';
            wait for C_CLK_PERIOD / 2;
            clk <= '1';
            wait for C_CLK_PERIOD / 2;
        end loop;
        wait;
    end process;

    -- 1 kHz pulse generation (every 1 ms)
    p1khz_process : process
    begin
        while not sim_done loop
            p1khz <= '0';
            wait for C_1KHZ_PERIOD - C_CLK_PERIOD;
            p1khz <= '1';
            wait for C_CLK_PERIOD;
        end loop;
        wait;
    end process;

    -- Stimulus process
    stim_process : process
    begin
        -- Initial reset
        rst <= '1';
        guess_enter <= '0';
        wait for 100 ns;
        wait until rising_edge(clk);
        rst <= '0';
        wait for 100 ns;
        
        report "=== Test 1: Clean button press (no bouncing) ===";
        wait until rising_edge(clk);
        guess_enter <= '1';
        -- Wait for the pulse to occur (should happen within a few clock cycles)
        wait until rising_edge(clk) and guess_enter_sync = '1' for 100 us;
        assert guess_enter_sync = '1' 
            report "Expected pulse on guess_enter_sync after clean press" 
            severity error;
        wait for 15 ms;  -- Hold button for 15ms
        guess_enter <= '0';
        wait for 15 ms;  -- Wait for debounce
        
        report "=== Test 2: Button press with bouncing ===";
        -- Simulate bouncing on press
        guess_enter <= '1';
        wait for 100 us;
        guess_enter <= '0';
        wait for 50 us;
        guess_enter <= '1';
        wait for 80 us;
        guess_enter <= '0';
        wait for 30 us;
        guess_enter <= '1';  -- Finally stable high
        wait for 20 ms;
        guess_enter <= '0';
        wait for 15 ms;
        
        report "=== Test 3: Button release with bouncing ===";
        guess_enter <= '1';
        wait for 20 ms;
        -- Simulate bouncing on release
        guess_enter <= '0';
        wait for 100 us;
        guess_enter <= '1';
        wait for 50 us;
        guess_enter <= '0';
        wait for 80 us;
        guess_enter <= '1';
        wait for 30 us;
        guess_enter <= '0';  -- Finally stable low
        wait for 15 ms;
        
        report "=== Test 4: Short glitch (should be filtered) ===";
        guess_enter <= '0';
        wait for 5 ms;
        guess_enter <= '1';
        wait for 500 us;  -- Very short pulse (< debounce time)
        guess_enter <= '0';
        wait for 15 ms;
        
        report "=== Test 5: Multiple rapid presses ===";
        for i in 1 to 3 loop
            guess_enter <= '1';
            wait for 15 ms;
            guess_enter <= '0';
            wait for 15 ms;
        end loop;
        
        report "=== Test 6: Reset during button press ===";
        guess_enter <= '1';
        wait for 5 ms;
        rst <= '1';
        wait for 200 ns;
        rst <= '0';
        wait for 15 ms;
        guess_enter <= '0';
        wait for 15 ms;
        
        report "=== Test 7: Very long button press ===";
        guess_enter <= '1';
        wait for 50 ms;  -- Hold for 50ms
        guess_enter <= '0';
        wait for 15 ms;
        
        report "=== All tests completed ===";
        wait for 10 ms;
        sim_done <= true;
        wait;
    end process;

    -- Monitor process to report key events
    monitor_process : process(clk)
    begin
        if rising_edge(clk) then
            if guess_enter_sync = '1' then
                report ">>> PULSE DETECTED: guess_enter_sync went high at " & time'image(now);
            end if;
        end if;
    end process;

end architecture sim;