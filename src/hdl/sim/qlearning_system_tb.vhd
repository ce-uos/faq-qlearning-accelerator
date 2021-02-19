library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity qlearning_system_tb is
--  Port ( );
end qlearning_system_tb;

architecture Behavioral of qlearning_system_tb is
    signal clk : std_logic := '0';
begin

    qls : entity work.qlearning_system port map (clk => clk);
    
    clk <= not clk after 20 ns;

end Behavioral;