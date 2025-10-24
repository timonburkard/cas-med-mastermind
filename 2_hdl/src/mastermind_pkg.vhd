-----------------------------------------------------
-- Project : mastermind
-----------------------------------------------------
-- File    : mastermind_pkg.vhd
-- Library : mastermind_lib
-- Author  : matthias.schaer1@students.fhnw.ch
-- Company : Institute of Microelectronics (IME) FHNW
-- Copyright(C) IME
-----------------------------------------------------
-- Description : This file holds all known constants
--               and generics.
-----------------------------------------------------
library ieee;
    use ieee.std_logic_1164.all;

package mastermind_pkg is
  -- configure display constants
  constant C_NOF_SWAP_CYCLES_SIM : natural := 1;
  constant C_NOF_SWAP_CYCLES_SYN : natural := 124;

  -- LED Assignment: 6:0                            gfedcba
  constant C_0 : std_ulogic_vector (6 downto 0) := "0111111";
  constant C_1 : std_ulogic_vector (6 downto 0) := "0000110";
  constant C_2 : std_ulogic_vector (6 downto 0) := "1011011";
  constant C_3 : std_ulogic_vector (6 downto 0) := "1001111";
  constant C_4 : std_ulogic_vector (6 downto 0) := "1100110";
  constant C_5 : std_ulogic_vector (6 downto 0) := "1101101";
  constant C_6 : std_ulogic_vector (6 downto 0) := "1111101";
  constant C_7 : std_ulogic_vector (6 downto 0) := "0000111";
  constant C_8 : std_ulogic_vector (6 downto 0) := "1111111";
  constant C_9 : std_ulogic_vector (6 downto 0) := "1101111";
  constant C_R : std_ulogic_vector (6 downto 0) := "0001000";
end;
