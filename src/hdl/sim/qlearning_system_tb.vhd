library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.envconfig.ALL;


entity qlearning_system_tb is
--  Port ( );
end qlearning_system_tb;

architecture Behavioral of qlearning_system_tb is
    signal clk : std_logic := '0';
    
    signal enable : std_logic := '1';
        
begin

    qls : entity work.qlearning_system port map (
        clk => clk,
        enable => enable
        
    );
    
    clk <= not clk after 20 ns;

end Behavioral;