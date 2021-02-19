library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.envconfig.ALL;

entity environment_tb is
--  Port ( );
end environment_tb;

architecture Behavioral of environment_tb is

    component environment is
        Port (
            clk : in std_logic;
            action : in std_logic_vector(env_action_width-1 downto 0);
            state : out std_logic_vector(env_state_width-1 downto 0);
            reward : out std_logic_vector(env_reward_width-1 downto 0)
        );
    end component;

    signal clk : std_logic := '0';
    signal action : std_logic_vector(env_action_width-1 downto 0) := b"01";
    signal state : std_logic_vector(env_state_width-1 downto 0) := b"0000";
    signal reward : std_logic_vector(env_reward_width-1 downto 0) := b"00000000";
    
begin

    env : environment port map (clk, action, state, reward);
    
    process begin
    
        clk <= '0';
        action <= b"00";
        
        wait for 10ns;
        clk <= '1';
        wait for 10ns;
        clk <= '0';
        
        action <= b"01";
        
        -- go to state 1
        wait for 10ns;
        clk <= '1';
        wait for 10ns;
        clk <= '0';
        
        -- go to state 2
        wait for 10ns;
        clk <= '1';
        wait for 10ns;
        clk <= '0';
        
        -- go to state 3
        wait for 10ns;
        clk <= '1';
        wait for 10ns;
        clk <= '0';
        
        action <= b"10";
        
        -- go to state 7
        wait for 10ns;
        clk <= '1';
        wait for 10ns;
        clk <= '0';
        
        -- go to state B
        wait for 10ns;
        clk <= '1';
        wait for 10ns;
        clk <= '0';
        
        -- go to state F
        wait for 10ns;
        clk <= '1';
        wait for 10ns;
        clk <= '0';
        
        -- go back to state 0
        wait for 10ns;
        clk <= '1';
        wait for 10ns;
        clk <= '0';
        
        wait;
        
    end process;

end Behavioral;
