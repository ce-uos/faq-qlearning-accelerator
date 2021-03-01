library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.envconfig.ALL;

entity blockworld_environment is
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
end blockworld_environment;

architecture Behavioral of blockworld_environment is
    constant targetstate : std_logic_vector(env_state_width-1 downto 0) := (others => '1');
    signal state : std_logic_vector(env_state_width-1 downto 0) := (others => '0');  
    signal next_state : std_logic_vector(env_state_width-1 downto 0) := (others => '0');    
begin

    next_state_process : process (action, action_valid, state) begin
        next_state <= state;
        if action_valid = '1' then
            if state = targetstate then
                next_state <= (others => '0');
            else
                case (action) is
                    when b"00" => -- up action
                        if unsigned(state) < to_unsigned(env_rowcol, env_state_width) then
                            next_state <= state;
                        else
                            next_state <= std_logic_vector(unsigned(state) - to_unsigned(env_rowcol, env_state_width));
                        end if;
                    when b"01" => -- right action
                        if (to_integer(unsigned(state)) + 1) mod env_rowcol = 0 then
                            next_state <= state;
                        else
                            next_state <= std_logic_vector(unsigned(state) + 1);
                        end if;
                    when b"10" => -- down action
                        if unsigned(state) >= to_unsigned(env_rowcol * (env_rowcol -1), env_state_width) then
                            next_state <= state;
                        else
                            next_state <= std_logic_vector(unsigned(state) + to_unsigned(env_rowcol, env_state_width));
                        end if;
                    when b"11" => -- left action
                        if to_integer(unsigned(state)) mod env_rowcol = 0 then
                            next_state <= state;
                        else
                            next_state <= std_logic_vector(unsigned(state) - 1);
                        end if;
                    when others =>
                        next_state <= state;
                end case;
            end if;
        end if;
    end process;
    
    reward_process : process (state) begin
        if state = targetstate then
            reward <= X"00FF";
        else
            reward <= X"0000";
        end if;
    end process;


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
