-- This file combines the Q-Learning accelerator and the environment.

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.envconfig.ALL;


entity qlearning_system is
  Port ( 
    clk : in std_logic;                                             -- clock input
    enable : in std_logic;                                          -- enable input
    
    state_out : out std_logic_vector(env_state_width-1 downto 0);   -- state output
    value_out : out std_logic_vector(env_reward_width-1 downto 0)   -- value output
    
  );
end qlearning_system;

architecture Behavioral of qlearning_system is

    -- some signals used to connect the Q-Learning agent to the environment
    signal state : std_logic_vector(env_state_width-1 downto 0);
    signal reward : std_logic_vector(env_reward_width-1 downto 0);
    signal action : std_logic_vector(env_action_width-1 downto 0);
    signal value : std_logic_vector(env_reward_width-1 downto 0);
    
    signal state_valid : std_logic;
    signal reward_valid : std_logic;
    signal action_valid : std_logic;
    
begin

-- instantiation of the Q-Learning agent
qlearner : entity work.qlearning 
generic map (
    state_width => env_state_width,
    reward_width => env_reward_width,
    action_width => env_action_width,
    action_num => env_action_num,
    state_num => env_state_num
)
port map (
    clk => clk,
    enable => enable,
    value_out => value,
    next_state => state,
    state_valid => state_valid,
    reward => reward,
    reward_valid => reward_valid,
    action => action,
    action_valid => action_valid
);

-- instantiation of the Environment
env : entity work.blockworld_environment port map (
    clk => clk,
    enable => enable,
    action => action,
    action_valid => action_valid,
    state_out => state,
    state_valid => state_valid,
    reward => reward,
    reward_valid => reward_valid
);

state_out <= state;
value_out <= value;

end Behavioral;
