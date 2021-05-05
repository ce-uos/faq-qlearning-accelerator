-- This file contains constants to configure the design.

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.MATH_REAL.ALL;

package config_constants is
    -- Choose between random and e-greedy policy:
    -- 0 = e-greedy
    -- 1 = random
    constant config_policy_random : integer := 1;
    
    -- Choose the Q-Table memory configuration
    -- 0 = single memory
    -- 1 = one memory per possible action
    constant config_action_rams : integer := 0;
    
    -- Choose the algorithm
    -- 0 = Q-Learning
    -- 1 = SARSA
    constant config_sarsa : integer := 0;
    
    -- Configure the state width
    -- this will result in 2^(state_width) possible states (not all of them need to be used)
    constant config_state_width : integer := 4;
    
    -- Configure the action width
    -- this will result in 2^(action_width) possible actions
    constant config_action_width : integer := 2;
    
    -- Configure the reward width
    constant config_reward_width : integer := 16;
    
    -- Configure the number of pipeline stages
    -- 0 = 4 stages
    -- 1 = 3 stages
    constant config_4stage : integer := 0;
end config_constants;
