-- This is the top level file used to synthesize the design for a large virtex FPGA.


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.envconfig.ALL;

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
