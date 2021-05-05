-- This file contains configuration constants for the Q-Learning accelerator.
-- The constants do not need to be set by hand. They are set based on the constants in config_constants.vhd.

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.config_constants.ALL;

package qconfig is

    -- Choose between random and e-greedy policy:
    -- 0 = e-greedy
    -- 1 = random
    constant qconf_policy_random : integer := config_policy_random;
    
    -- Choose the Q-Table memory configuration
    -- 0 = single memory
    -- 1 = one memory per possible action
    constant qconf_action_rams : integer := config_action_rams;
    
    -- Choose the algorithm
    -- 0 = Q-Learning
    -- 1 = SARSA
    constant qconf_sarsa : integer := config_sarsa;
    
    -- Configure the number of pipeline stages
    -- 0 = 4 stages
    -- 1 = 3 stages
    constant qconf_4stage : integer := config_4stage;
    
    type logic_vector_array is array(natural range <>) of std_logic_vector(31 downto 0);
end package;
