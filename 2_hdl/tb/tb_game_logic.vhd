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


    clk_and_rst : process
    -- Reset Sequenz    
        begin
        rst <= '1';
        wait for 20 ns;
        rst <= '0';
        wait for 5 ns;
        report "Reset Sequenz abgeschlossen";
    -- clk erzeugung
    while round /= "1111" loop
        clk <= '0';
        wait for 4 ns;
        clk <= '1';
        wait for 4 ns;
    end loop;
        clk <= '0';
        report "End of clk_and_rst";
    end process clk_and_rst;

    --------------------------------------------------------------------
    -- Stimulus Prozess
    --------------------------------------------------------------------

 stimulus_process : process
    begin
        -- Warte auf Ende des Resets
        wait for 25 ns;

        ----------------------------------------------------------------
        -- Runde 1: keine Treffer
        ----------------------------------------------------------------
        
        guess           <= "0000000000000000"; -- 0000
        random_number   <= "0000010011010010"; -- 1234
        assert exact_hits = "000";
        assert partial_hits = "000";
        assert round = "0001";
        wait for 40 ns;
        report "Runde 1: keine Treffer" severity note;

       ----------------------------------------------------------------
        -- Runde 2: partial Treffer
        ----------------------------------------------------------------
        guess           <= "0000000000000011"; -- 0003
        random_number   <= "0000010011010010"; -- 1234
        assert exact_hits = "000";
        assert partial_hits = "001";
        assert round = "0010";
        wait for 40 ns;
        report "Runde 2: partial Treffer" severity note;

       ----------------------------------------------------------------
        -- Runde 3: partial Treffer
        ----------------------------------------------------------------
        guess           <= "0000000000001101"; -- 0013
        random_number   <= "0000010011010010"; -- 1234
        assert exact_hits = "000";
        assert partial_hits = "010";
        assert round = "0011";
        wait for 40 ns;
        report "Runde 3: partial Treffer" severity note;

        ----------------------------------------------------------------
        -- Runde 4: partial Treffer
        ----------------------------------------------------------------
        guess           <= "0000010100001001"; -- 1289
        random_number   <= "0000010011010010"; -- 1234
        assert exact_hits = "10";
        assert partial_hits = "00";
        assert round = "0100";
        wait for 40 ns;
        report "Runde 3: partial Treffer" severity note;

        ----------------------------------------------------------------
        -- Runde 5: partial Treffer
        ----------------------------------------------------------------
        guess           <= "0000010011011101"; -- 1245
        random_number   <= "0000010011010010"; -- 1234
        assert exact_hits = "10";
        assert partial_hits = "01";
        assert round = "0101";
        wait for 40 ns;
        report "Runde 3: partial Treffer" severity note;



        wait;
    end process stimulus_process;




end architecture sim;

