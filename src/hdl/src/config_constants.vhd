library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.MATH_REAL.ALL;

package config_constants is
    constant config_policy_random : integer := 1;
    constant config_action_rams : integer := 0;
    constant config_sarsa : integer := 0;
    constant config_state_width : integer := 4;
    constant config_action_width : integer := 2;
    constant config_reward_width : integer := 8;
    constant config_4stage : integer := 0;
end config_constants;
