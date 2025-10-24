LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE STD.TEXTIO.ALL;
USE IEEE.STD_LOGIC_TEXTIO.ALL;

ENTITY tb_generator IS
END tb_generator;

ARCHITECTURE Behavioral OF tb_generator IS
    -- Component declaration
    COMPONENT random_number_generator IS
        PORT (
            clk : IN STD_LOGIC;
            rst : IN STD_LOGIC;
            random_number : OUT STD_LOGIC_VECTOR(15 DOWNTO 0));
    END COMPONENT;

    -- Test signals
    SIGNAL clk : STD_LOGIC := '0';
    SIGNAL rst : STD_LOGIC := '1';
    SIGNAL random_number_test : STD_LOGIC_VECTOR(15 DOWNTO 0);

    -- Clock period
    CONSTANT clk_period : TIME := 8 ns;

    -- For storing generated values
    TYPE value_array IS ARRAY (0 TO 1000) OF STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL generated_values : value_array;
    SIGNAL value_count : INTEGER := 0;

    -- Digit distribution counters (0-9 for each digit)
    TYPE digit_count_array IS ARRAY (0 TO 9) OF INTEGER;
    SIGNAL digit_counts : digit_count_array := (OTHERS => 0);

    -- Test control
    SIGNAL test_complete : BOOLEAN := false;

BEGIN
    -- Instantiate the Unit Under Test (UUT)
    uut : random_number_generator
    PORT MAP(
        clk => clk,
        rst => rst,
        random_number => random_number_test
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
        VARIABLE duplicate_found : BOOLEAN := false;
        VARIABLE period_length : INTEGER := 0;
        VARIABLE first_value : STD_LOGIC_VECTOR(15 DOWNTO 0);
        VARIABLE digit0, digit1, digit2, digit3 : INTEGER RANGE 0 TO 15;
        VARIABLE temp_counts : digit_count_array := (OTHERS => 0);
        VARIABLE total_valid_digits : INTEGER := 0;
        VARIABLE total_invalid_digits : INTEGER := 0;
        VARIABLE min_count : INTEGER := 999999;
        VARIABLE max_count : INTEGER := 0;
        VARIABLE expected_count : INTEGER := 100;
        VARIABLE deviation : INTEGER;
        VARIABLE max_deviation : INTEGER := 0;
        VARIABLE zero_output_detected : BOOLEAN := false;
    BEGIN
        -- Test 1: rst behavior
        REPORT "========================================";
        REPORT "TEST 1: rst Behavior";
        REPORT "========================================";

        rst <= '1';
        WAIT FOR clk_period * 2;
        rst <= '0';
        WAIT FOR clk_period;

        ASSERT random_number_test = "1001011001110001"
            REPORT "ERROR: rst did not set correct seed value!"
            SEVERITY error;
        REPORT "PASS: rst sets correct seed value";

        WAIT FOR clk_period * 2;

        -- Test 2: Generate sequence and check for periodicity
        REPORT "========================================";
        REPORT "TEST 2: Sequence Generation and Period";
        REPORT "========================================";

        rst <= '1';
        WAIT FOR clk_period;
        rst <= '0';
        WAIT FOR clk_period;

        first_value := random_number_test;
        REPORT "First value: " & INTEGER'image(to_integer(unsigned(first_value)));

        -- Generate values and store them
        FOR i IN 0 TO 100 LOOP
            WAIT FOR clk_period;
            generated_values(i) <= random_number_test;
            value_count <= i + 1;

            -- Check if we've cycled back to the beginning
            IF i > 0 AND random_number_test = first_value THEN
                period_length := i;
                REPORT "LFSR period detected: " & INTEGER'image(period_length) & " cycles";
                EXIT;
            END IF;
        END LOOP;

        -- For a 16-bit LFSR, maximum period is 2^16 - 1 = 65535
        IF period_length > 0 AND period_length < 100 THEN
            REPORT "WARNING: Short period detected (" & INTEGER'image(period_length) & "). Check LFSR taps!" SEVERITY warning;
        END IF;

        -- Test 3: Check for duplicate values in short sequence
        REPORT "========================================";
        REPORT "TEST 3: Duplicate Detection (short sequence)";
        REPORT "========================================";

        duplicate_found := false;
        FOR i IN 0 TO 49 LOOP
            FOR j IN i + 1 TO 50 LOOP
                IF generated_values(i) = generated_values(j) THEN
                    duplicate_found := true;
                    REPORT "Duplicate found at positions " & INTEGER'image(i) &
                        " and " & INTEGER'image(j) &
                        " with value " & INTEGER'image(to_integer(unsigned(generated_values(i))));
                END IF;
            END LOOP;
        END LOOP;

        IF NOT duplicate_found THEN
            REPORT "PASS: No duplicates in first 50 values";
        ELSE
            REPORT "INFO: Duplicates found (expected for short sequences)";
        END IF;

        -- Test 4: Digit distribution test
        REPORT "========================================";
        REPORT "TEST 4: DIGIT DISTRIBUTION TEST";
        REPORT "========================================";
        REPORT "Testing 1000 generated 16-bit vectors";
        REPORT "Each vector contains 4 digits (4 bits each)";
        REPORT "Expected count per digit (0-9): ~100";
        REPORT "";

        -- Initialize
        rst <= '1';
        WAIT FOR clk_period * 2;
        rst <= '0';
        WAIT FOR clk_period;

        -- Generate 1000 vectors and count digit occurrences
        FOR vector_num IN 1 TO 1000 LOOP
            WAIT FOR clk_period;

            -- Extract the 4 digits (each 4 bits)
            digit3 := to_integer(unsigned(random_number_test(15 DOWNTO 12)));
            digit2 := to_integer(unsigned(random_number_test(11 DOWNTO 8)));
            digit1 := to_integer(unsigned(random_number_test(7 DOWNTO 4)));
            digit0 := to_integer(unsigned(random_number_test(3 DOWNTO 0)));

            -- Count each digit if it's in range 0-9
            IF digit3 >= 0 AND digit3 <= 9 THEN
                temp_counts(digit3) := temp_counts(digit3) + 1;
                total_valid_digits := total_valid_digits + 1;
            ELSE
                total_invalid_digits := total_invalid_digits + 1;
            END IF;

            IF digit2 >= 0 AND digit2 <= 9 THEN
                temp_counts(digit2) := temp_counts(digit2) + 1;
                total_valid_digits := total_valid_digits + 1;
            ELSE
                total_invalid_digits := total_invalid_digits + 1;
            END IF;

            IF digit1 >= 0 AND digit1 <= 9 THEN
                temp_counts(digit1) := temp_counts(digit1) + 1;
                total_valid_digits := total_valid_digits + 1;
            ELSE
                total_invalid_digits := total_invalid_digits + 1;
            END IF;

            IF digit0 >= 0 AND digit0 <= 9 THEN
                temp_counts(digit0) := temp_counts(digit0) + 1;
                total_valid_digits := total_valid_digits + 1;
            ELSE
                total_invalid_digits := total_invalid_digits + 1;
            END IF;

            -- Optional: Print first 10 vectors for verification
            IF vector_num <= 10 THEN
                REPORT "Vector " & INTEGER'image(vector_num) & ": " &
                    INTEGER'image(digit3) &
                    INTEGER'image(digit2) &
                    INTEGER'image(digit1) &
                    INTEGER'image(digit0) &
                    " (0x" & to_hstring(random_number_test) & ")";
            END IF;
        END LOOP;

        -- Store results in signal for waveform viewing
        digit_counts <= temp_counts;

        -- Print results
        REPORT "";
        REPORT "========================================";
        REPORT "DISTRIBUTION RESULTS";
        REPORT "========================================";
        REPORT "Total valid digits (0-9): " & INTEGER'image(total_valid_digits);
        REPORT "Total invalid digits (10-15): " & INTEGER'image(total_invalid_digits);
        REPORT "";
        REPORT "Digit | Count | Expected | Deviation | Percentage";
        REPORT "------|-------|----------|-----------|------------";

        FOR digit IN 0 TO 9 LOOP
            deviation := temp_counts(digit) - expected_count;

            REPORT "  " & INTEGER'image(digit) &
                "   |  " & INTEGER'image(temp_counts(digit)) &
                "  |   100    |    " & INTEGER'image(deviation) &
                "     |   " & INTEGER'image((temp_counts(digit) * 100) / (total_valid_digits / 10)) & "%";

            -- Track min and max
            IF temp_counts(digit) < min_count THEN
                min_count := temp_counts(digit);
            END IF;
            IF temp_counts(digit) > max_count THEN
                max_count := temp_counts(digit);
            END IF;

            -- Track maximum deviation
            IF ABS(deviation) > max_deviation THEN
                max_deviation := ABS(deviation);
            END IF;
        END LOOP;

        REPORT "";
        REPORT "========================================";
        REPORT "STATISTICAL SUMMARY";
        REPORT "========================================";
        REPORT "Minimum count: " & INTEGER'image(min_count);
        REPORT "Maximum count: " & INTEGER'image(max_count);
        REPORT "Range: " & INTEGER'image(max_count - min_count);
        REPORT "Maximum deviation from expected (100): " & INTEGER'image(max_deviation);
        REPORT "";

        -- Evaluation
        IF max_deviation <= 20 THEN
            REPORT "EXCELLENT: Distribution is very uniform (max deviation <= 20)";
        ELSIF max_deviation <= 30 THEN
            REPORT "GOOD: Distribution is acceptable (max deviation <= 30)";
        ELSIF max_deviation <= 50 THEN
            REPORT "WARNING: Distribution shows some bias (max deviation <= 50)" SEVERITY warning;
        ELSE
            REPORT "ERROR: Distribution is significantly biased (max deviation > 50)" SEVERITY error;
        END IF;

        -- Check for invalid digits
        IF total_invalid_digits > 0 THEN
            REPORT "";
            REPORT "NOTE: " & INTEGER'image(total_invalid_digits) &
                " invalid digits (10-15) were generated.";
            REPORT "These are not valid decimal digits and were excluded from counting.";
            REPORT "Percentage of invalid: " &
                INTEGER'image((total_invalid_digits * 100) / 4000) & "%";
        END IF;

        -- Test 5: Multiple rst cycles
        REPORT "";
        REPORT "========================================";
        REPORT "TEST 5: Multiple rst Cycles";
        REPORT "========================================";

        FOR i IN 1 TO 5 LOOP
            rst <= '1';
            WAIT FOR clk_period;
            rst <= '0';
            WAIT FOR clk_period;

            ASSERT random_number_test = "1001011001110001"
                REPORT "ERROR: rst " & INTEGER'image(i) & " failed!"
                SEVERITY error;
        END LOOP;

        REPORT "PASS: Multiple rsts work correctly";

        -- Test complete
        REPORT "";
        REPORT "========================================";
        REPORT "ALL TESTS COMPLETE";
        REPORT "========================================";

        test_complete <= true;
        WAIT;
    END PROCESS;

END Behavioral;
