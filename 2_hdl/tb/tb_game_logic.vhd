library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.std_logic_textio.all;

entity tb_game_logic is
end tb_game_logic;

architecture sim of tb_game_logic is

    component game_logic is
    port    (
            partial_hits        : in std_logic_vector (2 downto 0);
            exact_hits          : in std_logic_vector (2 downto 0);
            round               : in std_logic_vector (3 downto 0);
            rst                 : out std_logic;
            clk                 : out std_logic;
            guess               : out std_logic_vector (15 downto 0);
            guess_enter_sync    : out std_logic;
            random_number       : out std_logic_vector (15 downto 0);
            );
    end component;


    begin

UUT: tb_game_logic;
    portmap    (
            partial_hits    => partial_hits,        
            exact_hits      => exact_hits,
            round           => round,
            rst             => rst,
            clk             => clk,
            guess           => guess,
            guess_enter_sync    => guess_enter_sync,
            random_number       => random_number,
            );


    clk_and_rst : process
    -- Reset Sequenz    
        begin
        rst <= '1';
        wait for 20 ns;
        rst <= '0';
        wait for 5 ns;
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


end architecture tb_game_logic;

random_number <= '1234';