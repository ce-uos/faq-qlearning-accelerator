library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.config_constants.ALL;

package qconfig is
    -- policy 0 = epsilon greedy --- policy 1 = random
    constant qconf_policy_random : integer := config_policy_random;
    
    -- action_rams 0 = only one BRAM --- action_rams 1 = one BRAM for each action
    constant qconf_action_rams : integer := config_action_rams;
    
    constant qconf_sarsa : integer := config_sarsa;
    
    type logic_vector_array is array(natural range <>) of std_logic_vector(31 downto 0);
end package;
