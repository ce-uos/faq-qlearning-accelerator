

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.envconfig.ALL;


entity qlearning_system is
  Port ( 
    clk : in std_logic;
    enable : in std_logic;
    state_out : out std_logic_vector(env_state_width-1 downto 0);
    action_out : out std_logic_vector(env_action_width-1 downto 0);
    
    alpha_in : in std_logic_vector(31 downto 0);
    alpha_out : out std_logic_vector(31 downto 0);
    gamma_in : in std_logic_vector(31 downto 0);
    gamma_out : out std_logic_vector(31 downto 0);
    
    episodes : out std_logic_vector(31 downto 0);
    
    axis_read : in std_logic;
    axis_pointer : in std_logic_vector(env_state_width-1 downto 0);
    axis_data : out std_logic_vector(env_action_num*env_reward_width-1 downto 0)
    
  );
end qlearning_system;

architecture Behavioral of qlearning_system is

    signal state : std_logic_vector(env_state_width-1 downto 0);
    signal reward : std_logic_vector(env_reward_width-1 downto 0);
    signal action : std_logic_vector(env_action_width-1 downto 0);
    
    signal state_valid : std_logic;
    signal reward_valid : std_logic;
    signal action_valid : std_logic;
    
    signal counter : std_logic_vector(31 downto 0) := (others => '0');

begin

qlearner : entity work.qlearning 
generic map (
    state_width => env_state_width,
    reward_width => env_reward_width,
    action_width => env_action_width,
    action_num => env_action_num
)
port map (
    clk => clk,
    enable => enable,
    next_state => state,
    state_valid => state_valid,
    reward => reward,
    reward_valid => reward_valid,
    action => action,
    action_valid => action_valid,
    
    alpha_in => alpha_in,
    alpha_out => alpha_out,
    gamma_in => gamma_in,
    gamma_out => gamma_out,
    
    axis_read => axis_read,
    axis_pointer => axis_pointer,
    axis_data => axis_data
);

env : entity work.environment port map (
    clk => clk,
    enable => enable,
    action => action,
    action_valid => action_valid,
    state_out => state,
    state_valid => state_valid,
    reward => reward,
    reward_valid => reward_valid
);

action_out <= action;
state_out <= state;
episodes <= counter;

process (clk) begin
    if rising_edge(clk) then
        if enable = '1' then
            counter <= std_logic_vector(unsigned(counter) + 1);
        end if;
    end if;
end process;

end Behavioral;
