library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.envconfig.ALL;

entity environment is
Port (
    clk : in std_logic;
    enable : in std_logic;
    action : in std_logic_vector(env_action_width-1 downto 0);
    action_valid : in std_logic;
    state_out : out std_logic_vector(env_state_width-1 downto 0);
    state_valid : out std_logic;
    reward : out std_logic_vector(env_reward_width-1 downto 0);
    reward_valid : out std_logic
);
end environment;

architecture Behavioral of environment is
    signal state : std_logic_vector(env_state_width-1 downto 0) := (others => '0');  
    signal next_state : std_logic_vector(env_state_width-1 downto 0) := (others => '0');    
    signal read_addr : std_logic_vector(env_addr_width-1 downto 0);
begin

    read_addr <= state & action;

    transition_ram : entity work.transition_bram 
    generic map (
        init => INIT_TRANSITION_RAM(rowcol,rowcol)
    ) 
    port map (
        clk => clk,
        ren => action_valid,
        raddr => read_addr,
        dout => next_state
    );
    
    reward_ram : entity work.reward_bram 
    generic map (
        init => INIT_REWARD_RAM(rowcol,rowcol)
    ) 
    port map (
        clk => clk,
        ren => action_valid,
        raddr => read_addr,
        dout => reward
    );

    state_out <= next_state;

    
    process (clk) begin
        if rising_edge(clk) then
            if enable = '1' then
                reward_valid <= action_valid;
                state <= next_state;
            end if;
        end if;
    end process;
    
    state_valid <= '1';

end Behavioral;
