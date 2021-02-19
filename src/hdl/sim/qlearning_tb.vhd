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
begin

    qlearner : entity work.qlearning 
    generic map (
        state_width => env_state_width,
        
        reward_width => env_reward_width,
        action_width => env_action_width
    )
    port map (
        clk => clk,
        state => state,
        state_valid => state_valid,
        reward => reward,
        reward_valid => reward_valid,
        action => action,
        action_valid => action_valid
    );
  
    
    process begin
        state <= b"0001";
        state_valid <= '1';
        --action <= b"10";
        reward <= X"0F";
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
