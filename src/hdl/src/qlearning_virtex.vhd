----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/03/2021 02:23:52 PM
-- Design Name: 
-- Module Name: qlearning_virtex - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.envconfig.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity qlearning_virtex is
  Port ( 
    clk : in std_logic;
    dataout : out std_logic_vector(3 downto 0)
  
  );
end qlearning_virtex;

architecture Behavioral of qlearning_virtex is

    signal state : std_logic_vector(env_state_width-1 downto 0);
    signal value : std_logic_vector(env_reward_width-1 downto 0);

begin

qlearnings_sys : entity work.qlearning_system port map (
    clk => clk,
    enable => '1',
    state_out => state,
    value_out => value
);

dataout <= value(3 downto 0);


end Behavioral;
