library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.envconfig.ALL;


entity qlearning_system_tb is
--  Port ( );
end qlearning_system_tb;

architecture Behavioral of qlearning_system_tb is
    signal clk : std_logic := '0';
    
    signal enable : std_logic := '1';

    signal alpha_in : std_logic_vector(31 downto 0) := X"0000_0001";
    signal alpha_out : std_logic_vector(31 downto 0) := X"0000_0001";
    signal gamma_in : std_logic_vector(31 downto 0) := X"0000_0001";
    signal gamma_out : std_logic_vector(31 downto 0) := X"0000_0001";
    
    signal axis_read : std_logic := '0';
    signal axis_pointer : std_logic_vector(env_state_width-1 downto 0);
    signal axis_data : std_logic_vector(env_action_num*env_reward_width-1 downto 0); 
    
    signal episodes : std_logic_vector(31 downto 0);

begin

    qls : entity work.qlearning_system port map (
        clk => clk,
        enable => enable,
        alpha_in => alpha_in,
        alpha_out => alpha_out,
        gamma_in => gamma_in,
        gamma_out => gamma_out,
        episodes => episodes,
        axis_read => axis_read,
        axis_pointer => axis_pointer,
        axis_data => axis_data
    );
    
    clk <= not clk after 20 ns;

end Behavioral;