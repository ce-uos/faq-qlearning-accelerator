----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/01/2021 12:31:08 AM
-- Design Name: 
-- Module Name: blockworld_tb - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.envconfig.ALL;


-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity blockworld_tb is
--  Port ( );
end blockworld_tb;

architecture Behavioral of blockworld_tb is
    signal clk : std_logic := '0';
    signal action : std_logic_vector(env_action_width-1 downto 0) := b"01";
    signal state : std_logic_vector(env_state_width-1 downto 0) := b"0000";
    signal reward : std_logic_vector(env_reward_width-1 downto 0) := X"0000";
    
    signal action_valid : std_logic;
    signal state_valid : std_logic;
    signal reward_valid : std_logic;
begin
    
    env : entity work.blockworld_environment port map (
        clk => clk,
        enable => '1',
        action => action,
        action_valid => action_valid,
        state_out => state,
        state_valid => state_valid,
        reward => reward,
        reward_valid => reward_valid
    );


    process begin
    
        clk <= '0';
        action <= b"00";
        action_valid <= '1';
        
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
