-- This file contains configuration constants for the environment.
-- These constant don't need to be set by hand.
-- They are set based on the constants in config_constants.vhd

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.MATH_REAL.ALL;
use work.config_constants.ALL;

package envconfig is

    -- Configure the state width
    -- this will result in 2^(state_width) possible states (not all of them need to be used)
    constant env_state_width : integer := config_state_width;
    
    -- number of states
    constant env_state_num : integer := 2**env_state_width;
    
    -- Configure the action width
    -- this will result in 2^(action_width) possible actions
    constant env_action_width : integer := config_action_width;
    
    -- number of actions
    constant env_action_num : integer := 2**env_action_width;

    -- possibly unused.    
    constant env_addr_width : integer := env_action_width + env_state_width;
    
    -- Configure the reward width
    constant env_reward_width : integer := config_reward_width;
    
    -- number of rows and columns in a square grid world
    constant env_rowcol : integer := integer(sqrt(real(env_state_num)));
end envconfig;