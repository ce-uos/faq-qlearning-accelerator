library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.MATH_REAL.ALL;

package envconfig is
    constant env_state_width : integer := 4;
    constant env_state_num : integer := 2**env_state_width;
    constant env_action_width : integer := 2;
    constant env_addr_width : integer := env_action_width + env_state_width;
    constant env_reward_width : integer := 16;
    constant env_action_num : integer := 2**env_action_width;
    constant env_memsize : integer := env_action_num * env_state_num;
    constant env_rowcol : integer := integer(sqrt(real(env_state_num)));
    constant env_pipeline_stages : integer := 3;

    type transition_mem_type is array(0 to env_memsize-1) of std_logic_vector(env_state_width-1 downto 0);
    type reward_mem_type is array(0 to env_memsize-1) of std_logic_vector(env_reward_width-1 downto 0);
    
    function INIT_TRANSITION_RAM (rows : integer; cols : integer) return transition_mem_type;
    function INIT_REWARD_RAM (rows : integer; cols : integer) return reward_mem_type;
    
    constant initial_transition_ram_example : transition_mem_type := (
        -- state 0
        X"0", X"1", X"4", X"0", 
        -- state 1
        X"1", X"2", X"5", X"0", 
        -- state 2
        X"2", X"3", X"6", X"1", 
        -- state 3
        X"3", X"3", X"7", X"2", 
        -- state 4
        X"0", X"5", X"8", X"4", 
        -- state 5
        X"1", X"6", X"9", X"4", 
        -- state 6
        X"2", X"7", X"A", X"5", 
        -- state 7
        X"3", X"7", X"B", X"6", 
        -- state 8
        X"4", X"9", X"C", X"8", 
        -- state 9
        X"5", X"A", X"D", X"8", 
        -- state 10
        X"6", X"B", X"9", X"E", 
        -- state 11
        X"7", X"B", X"F", X"A", 
        -- state 12
        X"8", X"D", X"C", X"C", 
        -- state 13
        X"9", X"E", X"D", X"C", 
        -- state 14
        X"A", X"F", X"E", X"D", 
        -- state 15 -> return to start
        X"0", X"0", X"0", X"0"
     );
     
--     constant initial_reward_ram_example : reward_mem_type := (
--        -- state 0
--        X"00", X"00", X"00", X"00", 
--        -- state 1
--        X"00", X"00", X"00", X"00", 
--        -- state 2
--        X"00", X"00", X"00", X"00", 
--        -- state 3
--        X"00", X"00", X"00", X"00", 
--        -- state 4
--        X"00", X"00", X"00", X"00", 
--        -- state 5
--        X"00", X"00", X"00", X"00", 
--        -- state 6
--        X"00", X"00", X"00", X"00", 
--        -- state 7
--        X"00", X"00", X"00", X"00", 
--        -- state 8
--        X"00", X"00", X"00", X"00", 
--        -- state 9
--        X"00", X"00", X"00", X"00", 
--        -- state 10
--        X"00", X"00", X"00", X"00", 
--        -- state 11
--        X"00", X"00", X"00", X"00", 
--        -- state 12
--        X"00", X"00", X"00", X"00", 
--        -- state 13
--        X"00", X"00", X"00", X"00", 
--        -- state 14
--        X"00", X"00", X"00", X"00", 
--        -- state 15
--        X"0F", X"0F", X"0F", X"0F"
--     );
    
end envconfig;

package body envconfig is

    function INIT_TRANSITION_RAM (rows : integer; cols : integer) return transition_mem_type is
        variable initial_ram : transition_mem_type := (others => (others => '0'));
    begin
        for x in 0 to rows * cols - 1 loop
            -- 00 = up action
            if x < cols then
                initial_ram(x * 4 + 0) := std_logic_vector(to_unsigned(x, env_state_width));
            else
                initial_ram(x * 4 + 0) := std_logic_vector(to_unsigned(x - cols, env_state_width));
            end if;
            
            -- 01 = right action
            if x + 1 mod rows = 0 then
                initial_ram(x * 4 + 1) := std_logic_vector(to_unsigned(x, env_state_width));
            else
                initial_ram(x * 4 + 1) := std_logic_vector(to_unsigned(x + 1, env_state_width));
            end if;
            
            -- 10 = down action
            if x >= cols * (rows - 1) then
                initial_ram(x * 4 + 2) := std_logic_vector(to_unsigned(x, env_state_width));
            else
                initial_ram(x * 4 + 2) := std_logic_vector(to_unsigned(x + cols, env_state_width));
            end if;
            
            -- 11 = left action
            if x mod rows = 0 then
                initial_ram(x * 4 + 3) := std_logic_vector(to_unsigned(x, env_state_width));
            else
                initial_ram(x * 4 + 3) := std_logic_vector(to_unsigned(x - 1, env_state_width));
            end if;
         
        end loop;
        
        initial_ram((rows * cols - 1) * 4 + 0) := (others => '0');
        initial_ram((rows * cols - 1) * 4 + 1) := (others => '0');
        initial_ram((rows * cols - 1) * 4 + 2) := (others => '0');
        initial_ram((rows * cols - 1) * 4 + 3) := (others => '0');
    
        return initial_ram;
    end INIT_TRANSITION_RAM;
    
    function INIT_REWARD_RAM (rows : integer; cols : integer) return reward_mem_type is
        variable initial_ram : reward_mem_type := (others => (others => '0'));
    begin
        initial_ram((rows * cols - 1) * 4 + 0) := X"00FF";
        initial_ram((rows * cols - 1) * 4 + 1) := X"00FF";
        initial_ram((rows * cols - 1) * 4 + 2) := X"00FF";
        initial_ram((rows * cols - 1) * 4 + 3) := X"00FF";
        return initial_ram;
    end INIT_REWARD_RAM;

end envconfig;
