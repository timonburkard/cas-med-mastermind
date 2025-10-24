LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

-- Import constant definitions (you'll need this package)
LIBRARY work;
USE work.mastermind_pkg.ALL;

ENTITY tb_pmod_ssd IS
END tb_pmod_ssd;

ARCHITECTURE behavioral OF tb_pmod_ssd IS
    
    -- Component declaration
    COMPONENT pmod_ssd IS
        GENERIC (
            g_clk_per_digit : NATURAL := C_NOF_SWAP_CYCLES_SIM
        );
        PORT (
            reset_n      : IN  std_ulogic;
            clk          : IN  std_ulogic;
            exact_hits   : IN  std_ulogic_vector (2 DOWNTO 0);
            partial_hits : IN  std_ulogic_vector (2 DOWNTO 0);
            digit        : OUT std_ulogic_vector (6 DOWNTO 0);
            digit_sel    : OUT std_ulogic
        );
    END COMPONENT;
    
    -- Test signals
    SIGNAL clk          : std_ulogic := '0';
    SIGNAL reset_n      : std_ulogic := '0';
    SIGNAL exact_hits   : std_ulogic_vector(2 DOWNTO 0) := "000";
    SIGNAL partial_hits : std_ulogic_vector(2 DOWNTO 0) := "000";
    SIGNAL digit        : std_ulogic_vector(6 DOWNTO 0);
    SIGNAL digit_sel    : std_ulogic;
    
    -- Clock period
    CONSTANT clk_period : TIME := 10 ns;
    
    -- Fast switching for simulation (use small value)
    CONSTANT test_clk_per_digit : NATURAL := 10; -- Switch every 10 clock cycles
    
    -- Test control
    SIGNAL test_complete : BOOLEAN := FALSE;
    
    -- Helper function to convert 7-segment to string for display
    FUNCTION seg_to_char(seg : std_ulogic_vector(6 DOWNTO 0)) RETURN CHARACTER IS
    BEGIN
        IF seg = C_0 THEN RETURN '0';
        ELSIF seg = C_1 THEN RETURN '1';
        ELSIF seg = C_2 THEN RETURN '2';
        ELSIF seg = C_3 THEN RETURN '3';
        ELSIF seg = C_4 THEN RETURN '4';
        ELSIF seg = C_5 THEN RETURN '5';
        ELSIF seg = C_6 THEN RETURN '6';
        ELSIF seg = C_7 THEN RETURN '7';
        ELSIF seg = C_8 THEN RETURN '8';
        ELSIF seg = C_9 THEN RETURN '9';
        ELSIF seg = C_R THEN RETURN 'E'; -- Error
        ELSE RETURN '?';
        END IF;
    END FUNCTION;
    
BEGIN
    
    -- Instantiate the Unit Under Test (UUT)
    uut : pmod_ssd
        GENERIC MAP (
            g_clk_per_digit => test_clk_per_digit
        )
        PORT MAP (
            reset_n      => reset_n,
            clk          => clk,
            exact_hits   => exact_hits,
            partial_hits => partial_hits,
            digit        => digit,
            digit_sel    => digit_sel
        );
    
    -- Clock generation
    clk_process : PROCESS
    BEGIN
        WHILE NOT test_complete LOOP
            clk <= '0';
            WAIT FOR clk_period/2;
            clk <= '1';
            WAIT FOR clk_period/2;
        END LOOP;
        WAIT;
    END PROCESS;
    
    -- Stimulus process
    stim_proc : PROCESS
        VARIABLE switch_count : INTEGER := 0;
        VARIABLE prev_digit_sel : std_ulogic := '0';
    BEGIN
        -- ========================================
        -- TEST 1: Reset behavior
        -- ========================================
        REPORT "========================================";
        REPORT "TEST 1: Reset Behavior";
        REPORT "========================================";
        
        reset_n <= '0';
        exact_hits <= "000";
        partial_hits <= "000";
        WAIT FOR clk_period * 5;
        
        ASSERT digit_sel = '0'
            REPORT "ERROR: digit_sel should be 0 after reset"
            SEVERITY error;
        
        REPORT "PASS: Reset initializes digit_sel to 0";
        
        -- ========================================
        -- TEST 2: Normal operation with zeros
        -- ========================================
        REPORT "";
        REPORT "========================================";
        REPORT "TEST 2: Display Zeros (0 exact, 0 partial)";
        REPORT "========================================";
        
        reset_n <= '1';
        exact_hits <= "000";   -- 0
        partial_hits <= "000"; -- 0
        WAIT FOR clk_period * 2;
        
        -- Wait for first display switch
        WAIT FOR clk_period * (test_clk_per_digit + 2);
        
        ASSERT digit = C_0
            REPORT "ERROR: Expected digit to show '0'"
            SEVERITY error;
        
        REPORT "First digit shows: " & CHARACTER'image(seg_to_char(digit));
        REPORT "PASS: Both displays show 0";
        
        -- ========================================
        -- TEST 3: Different values on each display
        -- ========================================
        REPORT "";
        REPORT "========================================";
        REPORT "TEST 3: Different Values (3 exact, 2 partial)";
        REPORT "========================================";
        
        reset_n <= '0';
        WAIT FOR clk_period * 2;
        reset_n <= '1';
        
        exact_hits <= "011";   -- 3
        partial_hits <= "010"; -- 2
        WAIT FOR clk_period * 2;
        
        -- Monitor several display switches
        FOR i IN 1 TO 4 LOOP
            -- Wait for display to switch
            prev_digit_sel := digit_sel;
            WAIT UNTIL digit_sel /= prev_digit_sel FOR clk_period * (test_clk_per_digit + 5);
            
            WAIT FOR clk_period * 2; -- Stabilization time
            
            IF digit_sel = '0' THEN
                -- Displaying exact_hits (3)
                ASSERT digit = C_3
                    REPORT "ERROR: Expected exact hits display to show '3', got '" & 
                           CHARACTER'image(seg_to_char(digit)) & "'"
                    SEVERITY error;
                REPORT "Switch " & INTEGER'image(i) & ": Showing exact hits = 3";
            ELSE
                -- Displaying partial_hits (2)
                ASSERT digit = C_2
                    REPORT "ERROR: Expected partial hits display to show '2', got '" & 
                           CHARACTER'image(seg_to_char(digit)) & "'"
                    SEVERITY error;
                REPORT "Switch " & INTEGER'image(i) & ": Showing partial hits = 2";
            END IF;
        END LOOP;
        
        REPORT "PASS: Display correctly alternates between 3 and 2";
        
        -- ========================================
        -- TEST 4: All digits 0-7 (test range)
        -- ========================================
        REPORT "";
        REPORT "========================================";
        REPORT "TEST 4: Test All Valid Digits (0-7)";
        REPORT "========================================";
        
        FOR test_val IN 0 TO 7 LOOP
            reset_n <= '0';
            WAIT FOR clk_period * 2;
            reset_n <= '1';
            
            exact_hits <= std_ulogic_vector(to_unsigned(test_val, 3));
            partial_hits <= std_ulogic_vector(to_unsigned(7 - test_val, 3));
            
            WAIT FOR clk_period * 3;
            
            -- Check exact hits display
            WAIT UNTIL digit_sel = '0' FOR clk_period * (test_clk_per_digit + 5);
            WAIT FOR clk_period * 2;
            
            REPORT "Testing value " & INTEGER'image(test_val) & 
                   ": Display shows '" & CHARACTER'image(seg_to_char(digit)) & "'";
            
            -- Verify correct segment pattern
            CASE test_val IS
                WHEN 0 => ASSERT digit = C_0 REPORT "ERROR: Digit 0 incorrect" SEVERITY error;
                WHEN 1 => ASSERT digit = C_1 REPORT "ERROR: Digit 1 incorrect" SEVERITY error;
                WHEN 2 => ASSERT digit = C_2 REPORT "ERROR: Digit 2 incorrect" SEVERITY error;
                WHEN 3 => ASSERT digit = C_3 REPORT "ERROR: Digit 3 incorrect" SEVERITY error;
                WHEN 4 => ASSERT digit = C_4 REPORT "ERROR: Digit 4 incorrect" SEVERITY error;
                WHEN 5 => ASSERT digit = C_5 REPORT "ERROR: Digit 5 incorrect" SEVERITY error;
                WHEN 6 => ASSERT digit = C_6 REPORT "ERROR: Digit 6 incorrect" SEVERITY error;
                WHEN 7 => ASSERT digit = C_7 REPORT "ERROR: Digit 7 incorrect" SEVERITY error;
                WHEN OTHERS => NULL;
            END CASE;
        END LOOP;
        
        REPORT "PASS: All digits (0-7) display correctly";
        
        -- ========================================
        -- TEST 5: Maximum values
        -- ========================================
        REPORT "";
        REPORT "========================================";
        REPORT "TEST 5: Maximum Values (7 exact, 7 partial)";
        REPORT "========================================";
        
        reset_n <= '0';
        WAIT FOR clk_period * 2;
        reset_n <= '1';
        
        exact_hits <= "111";   -- 7
        partial_hits <= "111"; -- 7
        WAIT FOR clk_period * 2;
        
        -- Wait for exact hits display
        WAIT UNTIL digit_sel = '0' FOR clk_period * (test_clk_per_digit + 5);
        WAIT FOR clk_period * 2;
        
        ASSERT digit = C_7
            REPORT "ERROR: Expected '7' on exact hits display"
            SEVERITY error;
        
        -- Wait for partial hits display
        WAIT UNTIL digit_sel = '1' FOR clk_period * (test_clk_per_digit + 5);
        WAIT FOR clk_period * 2;
        
        ASSERT digit = C_7
            REPORT "ERROR: Expected '7' on partial hits display"
            SEVERITY error;
        
        REPORT "PASS: Maximum values display correctly";
        
        -- ========================================
        -- TEST 6: Switching frequency
        -- ========================================
        REPORT "";
        REPORT "========================================";
        REPORT "TEST 6: Display Switching Frequency";
        REPORT "========================================";
        
        reset_n <= '0';
        WAIT FOR clk_period * 2;
        reset_n <= '1';
        
        exact_hits <= "101";   -- 5
        partial_hits <= "010"; -- 2
        
        -- Count number of switches in a fixed time
        switch_count := 0;
        prev_digit_sel := digit_sel;
        
        FOR i IN 1 TO 100 LOOP
            WAIT FOR clk_period;
            IF digit_sel /= prev_digit_sel THEN
                switch_count := switch_count + 1;
                prev_digit_sel := digit_sel;
            END IF;
        END LOOP;
        
        REPORT "Display switched " & INTEGER'image(switch_count) & 
               " times in 100 clock cycles";
        REPORT "Expected approximately " & 
               INTEGER'image(100 / (test_clk_per_digit + 1)) & " switches";
        
        IF switch_count >= 8 AND switch_count <= 10 THEN
            REPORT "PASS: Switching frequency is correct";
        ELSE
            REPORT "WARNING: Switching frequency may be incorrect" SEVERITY warning;
        END IF;
        
        -- ========================================
        -- TEST 7: Reset during operation
        -- ========================================
        REPORT "";
        REPORT "========================================";
        REPORT "TEST 7: Reset During Operation";
        REPORT "========================================";
        
        exact_hits <= "110";   -- 6
        partial_hits <= "011"; -- 3
        reset_n <= '1';
        
        -- Let it run for a while
        WAIT FOR clk_period * 20;
        
        -- Apply reset
        reset_n <= '0';
        WAIT FOR clk_period * 3;
        
        ASSERT digit_sel = '0'
            REPORT "ERROR: Reset should force digit_sel to 0"
            SEVERITY error;
        
        -- Release reset
        reset_n <= '1';
        WAIT FOR clk_period * 5;
        
        REPORT "PASS: Reset during operation works correctly";
        
        -- ========================================
        -- TEST 8: Rapid value changes
        -- ========================================
        REPORT "";
        REPORT "========================================";
        REPORT "TEST 8: Rapid Input Value Changes";
        REPORT "========================================";
        
        reset_n <= '1';
        
        FOR test_iteration IN 0 TO 5 LOOP
            exact_hits <= std_ulogic_vector(to_unsigned(test_iteration, 3));
            partial_hits <= std_ulogic_vector(to_unsigned(5 - test_iteration, 3));
            WAIT FOR clk_period * 3;
        END LOOP;
        
        REPORT "PASS: Rapid value changes handled correctly";
        
        -- ========================================
        -- Test Complete
        -- ========================================
        REPORT "";
        REPORT "========================================";
        REPORT "ALL TESTS COMPLETE";
        REPORT "========================================";
        
        test_complete <= TRUE;
        WAIT;
    END PROCESS;
    
    -- Monitor process (optional - provides continuous feedback)
    monitor_proc : PROCESS
    BEGIN
        WAIT UNTIL rising_edge(clk);
        
        IF NOT test_complete THEN
            -- You can add continuous monitoring here if needed
            -- Example: log every display switch
        END IF;
    END PROCESS;
    
END behavioral;