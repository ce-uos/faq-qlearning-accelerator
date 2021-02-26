library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.envconfig.ALL;


entity qlearning_tb is
--  Port ( );
end qlearning_tb;

architecture Behavioral of qlearning_tb is
    signal clk : std_logic := '0';
    
    signal state : std_logic_vector(env_state_width-1 downto 0);
    signal reward : std_logic_vector(env_reward_width-1 downto 0);
    signal action : std_logic_vector(env_action_width-1 downto 0);
    
    signal state_valid : std_logic := '0';
    signal reward_valid : std_logic := '0';
    signal action_valid : std_logic := '0';
    
    signal enable : std_logic := '1';
    
    signal alpha_in : std_logic_vector(31 downto 0) := X"0000_0001";
    signal alpha_out : std_logic_vector(31 downto 0) := X"0000_0001";
    signal gamma_in : std_logic_vector(31 downto 0) := X"0000_0001";
    signal gamma_out : std_logic_vector(31 downto 0) := X"0000_0001";
    
    signal axis_read : std_logic := '0';
    signal axis_pointer : std_logic_vector(env_state_width-1 downto 0);
    signal axis_data : std_logic_vector(env_action_num*env_reward_width-1 downto 0); 
begin

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
  
    
    process begin
        state <= b"0001";
        state_valid <= '1';
        --action <= b"10";
        reward <= X"00FF";
        wait for 10ns;
        clk <= '1';
        
        
        wait for 10ns;
        clk <= '0';
        wait for 10ns;
        clk <= '1';
        reward_valid <= '1';
        wait for 10ns;
        clk <= '0';
        wait for 10ns;
        clk <= '1';
        wait for 10ns;
        clk <= '0';
        wait for 10ns;
        clk <= '1';
        wait for 10ns;
        clk <= '0';
        wait for 10ns;
        clk <= '1';
        wait for 10ns;
        clk <= '0';
        wait for 10ns;
        clk <= '1';
        wait for 10ns;
        clk <= '0';
        wait for 10ns;
        clk <= '1';
        wait for 10ns;
        clk <= '0';
        wait for 10ns;
        clk <= '1';
        wait for 10ns;
        clk <= '0';
        wait for 10ns;
        clk <= '1';
        wait for 10ns;
        clk <= '0';
        wait for 10ns;
        clk <= '1';
        wait for 10ns;
        clk <= '0';
        
        wait;
    end process;

end Behavioral;
