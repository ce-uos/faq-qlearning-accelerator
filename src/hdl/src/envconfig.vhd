library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.MATH_REAL.ALL;
use work.config_constants.ALL;

package envconfig is
    constant env_state_width : integer := config_state_width;
    constant env_state_num : integer := 2**env_state_width;
    constant env_action_width : integer := config_action_width;
    constant env_addr_width : integer := env_action_width + env_state_width;
    constant env_reward_width : integer := config_reward_width;
    constant env_action_num : integer := 2**env_action_width;
    constant env_rowcol : integer := integer(sqrt(real(env_state_num)));
end envconfig;