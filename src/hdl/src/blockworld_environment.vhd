-- This file implements a simple Grid World Environment.

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.envconfig.ALL;

entity blockworld_environment is
Port (
    clk : in std_logic;                                           -- clock input
    enable : in std_logic;                                        -- enable input (not used)
    action : in std_logic_vector(env_action_width-1 downto 0);    -- action chosen by the agent
    action_valid : in std_logic;                                  -- whether or not the action is valid (not used)
    state_out : out std_logic_vector(env_state_width-1 downto 0); -- next state
    state_valid : out std_logic;                                  -- whether or not the next state is valid
    reward : out std_logic_vector(env_reward_width-1 downto 0);   -- reward given to the agent
    reward_valid : out std_logic                                  -- whether or not the reward is valid
);
end blockworld_environment;

architecture Behavioral of blockworld_environment is

    -- The destination state the agent should try to reach
    constant targetstate : std_logic_vector(env_state_width-1 downto 0) := (others => '1');
    
    -- current state
    signal state : std_logic_vector(env_state_width-1 downto 0) := (others => '0');  
    
    -- next state
    signal next_state : std_logic_vector(env_state_width-1 downto 0) := (others => '0');  
    
    -- constants for configurable rewards
    constant reward_zeros : std_logic_vector(env_reward_width-1 downto env_reward_width/2) := (others => '0');  
    constant reward_ones : std_logic_vector(env_reward_width/2-1 downto 0) := (others => '1');
begin

    -- This process generates the next state, if the environment is configured with 4 actions (i.e. action_width = 2)
    gen_next_state_process4 : if env_action_num = 4 generate
        next_state_process : process (action, action_valid, state) begin
            next_state <= state;
--            if action_valid = '1' then
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
--            end if;
        end process;
    end generate;
    
    -- This process generates the next state, if the environment is configured with 8 actions (i.e. action_width = 3)
    gen_next_state_process8 : if env_action_num = 8 generate
        next_state_process : process (action, action_valid, state) begin
            next_state <= state;
--            if action_valid = '1' then
                if state = targetstate then
                    next_state <= (others => '0');
                else
                    case (action) is
                        when b"000" => -- up action
                            if unsigned(state) < to_unsigned(env_rowcol, env_state_width) then
                                next_state <= state;
                            else
                                next_state <= std_logic_vector(unsigned(state) - to_unsigned(env_rowcol, env_state_width));
                            end if;
                        when b"001" => -- right action
                            if (to_integer(unsigned(state)) + 1) mod env_rowcol = 0 then
                                next_state <= state;
                            else
                                next_state <= std_logic_vector(unsigned(state) + 1);
                            end if;
                        when b"010" => -- down action
                            if unsigned(state) >= to_unsigned(env_rowcol * (env_rowcol -1), env_state_width) then
                                next_state <= state;
                            else
                                next_state <= std_logic_vector(unsigned(state) + to_unsigned(env_rowcol, env_state_width));
                            end if;
                        when b"011" => -- left action
                            if to_integer(unsigned(state)) mod env_rowcol = 0 then
                                next_state <= state;
                            else
                                next_state <= std_logic_vector(unsigned(state) - 1);
                            end if;
                        when b"100" => -- up-right action
                            if unsigned(state) < to_unsigned(env_rowcol, env_state_width) or (to_integer(unsigned(state)) + 1) mod env_rowcol = 0 then
                                next_state <= state;
                            else
                                next_state <= std_logic_vector(unsigned(state) - to_unsigned(env_rowcol, env_state_width) + 1);
                            end if;
                        when b"101" => -- down-right action
                            if unsigned(state) >= to_unsigned(env_rowcol * (env_rowcol -1), env_state_width) or (to_integer(unsigned(state)) + 1) mod env_rowcol = 0 then
                                next_state <= state;
                            else
                                next_state <= std_logic_vector(unsigned(state) + to_unsigned(env_rowcol, env_state_width) + 1);
                            end if;
                        when b"110" => -- down-left action
                            if unsigned(state) >= to_unsigned(env_rowcol * (env_rowcol -1), env_state_width) or to_integer(unsigned(state)) mod env_rowcol = 0 then
                                next_state <= state;
                            else
                                next_state <= std_logic_vector(unsigned(state) + to_unsigned(env_rowcol, env_state_width) - 1);
                            end if;
                        when b"111" => -- up-left action
                            if unsigned(state) < to_unsigned(env_rowcol, env_state_width) or to_integer(unsigned(state)) mod env_rowcol = 0 then
                                next_state <= state;
                            else
                                next_state <= std_logic_vector(unsigned(state) - to_unsigned(env_rowcol, env_state_width) - 1);
                            end if;
                        when others =>
                            next_state <= state;
                    end case;
                end if;
--            end if;
        end process;
    end generate;
    
    -- This process generates the reward
    reward_process : process (state) begin
        if state = targetstate then
            reward <= reward_zeros & reward_ones;
        else
            reward <= (others => '0');
        end if;
    end process;

    -- output the next state
    state_out <= next_state;

    -- this process handles the internal state register
    process (clk) begin
        if rising_edge(clk) then
--            if enable = '1' then
                reward_valid <= action_valid;
                state <= next_state;
--            end if;
        end if;
    end process;
    
    -- state is always valid
    state_valid <= '1';

end Behavioral;
