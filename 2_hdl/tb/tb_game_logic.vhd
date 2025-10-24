library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.std_logic_textio.all;

entity tb_game_logic is
end tb_game_logic;

architecture sim of tb_game_logic is

    --------------------------------------------------------------------
    -- Komponentendeklaration für DUT (Design Under Test)
    --------------------------------------------------------------------
    component game_logic is
        port (
            partial_hits        : out  std_logic_vector (2 downto 0);
            exact_hits          : out  std_logic_vector (2 downto 0);
            round               : out  std_logic_vector (3 downto 0);
            rst                 : in std_logic;
            clk                 : in std_logic;
            guess               : in std_logic_vector (15 downto 0);
            guess_enter_sync    : in std_logic;
            random_number       : in std_logic_vector (15 downto 0)
        );
    end component;

    --------------------------------------------------------------------
    -- Signaldeklarationen zur Verbindung mit der DUT
    --------------------------------------------------------------------
    signal partial_hits     : std_logic_vector (2 downto 0) := (others => '0');
    signal exact_hits       : std_logic_vector (2 downto 0) := (others => '0');
    signal round            : std_logic_vector (3 downto 0) := (others => '0');
    signal rst              : std_logic := '0';
    signal clk              : std_logic := '0';
    signal guess            : std_logic_vector (15 downto 0);
    signal guess_enter_sync : std_logic := '0';
    signal random_number    : std_logic_vector (15 downto 0);

begin

    --------------------------------------------------------------------
    -- Instanziierung des DUT
    --------------------------------------------------------------------
    UUT : game_logic
        port map (
            partial_hits      => partial_hits,        
            exact_hits        => exact_hits,
            round             => round,
            rst               => rst,
            clk               => clk,
            guess             => guess,
            guess_enter_sync  => guess_enter_sync,
            random_number     => random_number
        );

    --------------------------------------------------------------------
    -- Prozess: Reset und Taktsignal
    --------------------------------------------------------------------

    -- Clock-Prozess
    clk_process : process
    begin
        while true loop
            clk <= '0';
            wait for 4 ns;
            clk <= '1';
            wait for 4 ns;
        end loop;
    end process clk_process;

    -- Reset-Prozess
    rst_process : process
    begin
        rst <= '1';
        wait for 20 ns;
        rst <= '0';
        report "Reset released";
        wait;
    end process rst_process;

    --------------------------------------------------------------------
    -- Stimulus Prozess
    --------------------------------------------------------------------

    stimulus_process : process
    begin
        -- Warte auf Ende des Resets
        wait for 25 ns;

        ----------------------------------------------------------------
        -- Runde 1
        ----------------------------------------------------------------
        
        guess           <= "0000000000000000"; -- 0000
        random_number   <= "0000010011010010"; -- 1234
        guess_enter_sync <= '1';
        wait for 10 ns;
        guess_enter_sync <= '0';

        assert exact_hits = "000"
            report "exact_hits, erwartet 000, bekommen " & to_string(exact_hits)
            severity error;

        assert partial_hits = "000"
            report "partial_hits, erwartet 000, bekommen " & to_string(partial_hits)
            severity error;
                
        assert round = "0001"
            report "round, erwartet 0001, bekommen " & to_string(round)
            severity error;
        
        report "Runde 1 beendet" severity note;
        wait for 10 ns;

        ----------------------------------------------------------------
        -- Runde 2
        ----------------------------------------------------------------
        guess           <= "0000000000000011"; -- 0003
        random_number   <= "0000010011010010"; -- 1234
        guess_enter_sync <= '1';
        wait for 10 ns;
        guess_enter_sync <= '0';

        assert exact_hits = "000"
            report "exact_hits, erwartet 000, bekommen " & to_string(exact_hits)
            severity error;

        assert partial_hits = "001"
            report "partial_hits, erwartet 001, bekommen " & to_string(partial_hits)
            severity error;
                
        assert round = "0010"
            report "round, erwartet 0010, bekommen " & to_string(round)
            severity error;
        
        report "Runde 2 beendet" severity note;
        wait for 10 ns;

        ----------------------------------------------------------------
        -- Runde 3
        ----------------------------------------------------------------
        guess           <= "0000000000001101"; -- 0013
        random_number   <= "0000010011010010"; -- 1234
        guess_enter_sync <= '1';
        wait for 10 ns;
        guess_enter_sync <= '0';

        assert exact_hits = "000"
            report "exact_hits, erwartet 000, bekommen " & to_string(exact_hits)
            severity error;

        assert partial_hits = "010"
            report "partial_hits, erwartet 010, bekommen " & to_string(partial_hits)
            severity error;
                
        assert round = "0011"
            report "round, erwartet 0011, bekommen " & to_string(round)
            severity error;
        
        report "Runde 3 beendet" severity note;
        wait for 10 ns;        

        ----------------------------------------------------------------
        -- Runde 4
        ----------------------------------------------------------------
        guess           <= "0000010100001001"; -- 1289
        random_number   <= "0000010011010010"; -- 1234
        guess_enter_sync <= '1';
        wait for 10 ns;
        guess_enter_sync <= '0';

        assert exact_hits = "010"
            report "exact_hits, erwartet 010, bekommen " & to_string(exact_hits)
            severity error;

        assert partial_hits = "000"
            report "partial_hits, erwartet 000, bekommen " & to_string(partial_hits)
            severity error;
                
        assert round = "0100"
            report "round, erwartet 0100, bekommen " & to_string(round)
            severity error;
        
        report "Runde 4 beendet" severity note;  
        wait for 10 ns;

        ----------------------------------------------------------------
        -- Runde 5
        ----------------------------------------------------------------
        guess           <= "0000010011011101"; -- 1245
        random_number   <= "0000010011010010"; -- 1234
        guess_enter_sync <= '1';
        wait for 10 ns;
        guess_enter_sync <= '0';

        assert exact_hits = "010"
            report "exact_hits, erwartet 010, bekommen " & to_string(exact_hits)
            severity error;

        assert partial_hits = "001"
            report "partial_hits, erwartet 001, bekommen " & to_string(partial_hits)
            severity error;
                
        assert round = "0101"
            report "round, erwartet 0101, bekommen " & to_string(round)
            severity error;
        
        report "Runde 5 beendet" severity note;
        wait for 10 ns;

        ----------------------------------------------------------------
        -- Runde 6
        ----------------------------------------------------------------
        guess           <= "0000010100001110"; -- 1294
        random_number   <= "0000010011010010"; -- 1234
        guess_enter_sync <= '1';
        wait for 10 ns;
        guess_enter_sync <= '0';

        assert exact_hits = "101"
            report "exact_hits, erwartet 101, bekommen " & to_string(exact_hits)
            severity error;

        assert partial_hits = "000"
            report "partial_hits, erwartet 000, bekommen " & to_string(partial_hits)
            severity error;
                
        assert round = "0110"
            report "round, erwartet 0110, bekommen " & to_string(round)
            severity error;
        
        report "Runde 6 beendet" severity note;
        wait for 10 ns;

        ----------------------------------------------------------------
        -- Runde 7
        ----------------------------------------------------------------
        guess           <= "0000010011011100"; -- 1244
        random_number   <= "0000010011010010"; -- 1234
        guess_enter_sync <= '1';
        wait for 10 ns;
        guess_enter_sync <= '0';

        assert exact_hits = "101"
            report "exact_hits, erwartet 101, bekommen " & to_string(exact_hits)
            severity error;

        assert partial_hits = "000"
            report "partial_hits, erwartet 000, bekommen " & to_string(partial_hits)
            severity error;
                
        assert round = "0111"
            report "round, erwartet 0111, bekommen " & to_string(round)
            severity error;
        
        report "Runde 7 beendet" severity note;
        wait for 10 ns;

        ----------------------------------------------------------------
        -- Runde 8
        ----------------------------------------------------------------
        guess           <= "0000010011010010"; -- 1234
        random_number   <= "0000010011010010"; -- 1234
        guess_enter_sync <= '1';
        wait for 10 ns;
        guess_enter_sync <= '0';

        assert exact_hits = "100"
            report "exact_hits, erwartet 100, bekommen " & to_string(exact_hits)
            severity error;

        assert partial_hits = "000"
            report "partial_hits, erwartet 000, bekommen " & to_string(partial_hits)
            severity error;
                
        assert round = "1000"
            report "round, erwartet 1000, bekommen " & to_string(round)
            severity error;
        
        report "Runde 8 beendet, aber nach 7 sollte Schluss sein" severity error;


        wait;
    end process stimulus_process;


end architecture sim;

