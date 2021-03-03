library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.MATH_REAL.ALL;

package config_constants is
    constant config_state_width : integer := 18;
    constant config_action_width : integer := 3;
    constant config_pipeline_stages : integer := 3;
    constant config_reward_width : integer := 16;
end config_constants;
