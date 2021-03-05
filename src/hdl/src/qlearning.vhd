library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.math_real.ALL;
use IEEE.math_real.ALL;
use work.qconfig.ALL;

entity qlearning is
  Generic (
    state_width : integer := 32;
    reward_width : integer := 32;
    action_width : integer := 32;
    action_num : integer := 4;
    state_num : integer := 16;
    repsilon : integer := 80;
    rseed0 : integer := 12341;
    rseed1 : integer := 21314
  );
  Port ( 
    clk : in std_logic;
    enable : in std_logic;
    
    value_out : out std_logic_vector(reward_width-1 downto 0);
    
    next_state : in std_logic_vector(state_width-1 downto 0);
    state_valid : in std_logic;
    reward : in std_logic_vector(reward_width-1 downto 0);
    reward_valid : in std_logic;
    action : out std_logic_vector(action_width-1 downto 0);
    action_valid : out std_logic
  
  );
end qlearning;

architecture Behavioral of qlearning is
    constant epsilon : unsigned(7 downto 0) := to_unsigned(repsilon, 8);
    constant seed0 : unsigned(31 downto 0) := to_unsigned(rseed0, 32);
    constant seed1 : unsigned(31 downto 0) := to_unsigned(rseed1, 32);
    
    constant alpha : integer := 1;
    constant gamma : integer := 1;
    
    type enable_type is array (0 to action_num-1) of std_logic;
    signal awen : enable_type := (others => '0');
    
    type value_array is array (0 to action_num-1) of std_logic_vector(reward_width-1 downto 0);
    signal r_avalue : value_array := (others => (others => '0'));
    signal w_avalue : value_array := (others => (others => '0'));
    
    signal this_action : std_logic_vector(action_width-1 downto 0);
    signal this_action_valid : std_logic := '0';
    signal this_value : std_logic_vector(reward_width-1 downto 0);
    
    signal last_action : std_logic_vector(action_width-1 downto 0) := (others => '0');
    signal last_action_valid : std_logic;
    signal last_value : std_logic_vector(reward_width-1 downto 0) := (others => '0');
    signal state : std_logic_vector(state_width-1 downto 0);
    signal last_state : std_logic_vector(state_width-1 downto 0);
    signal last_reward : std_logic_vector(reward_width-1 downto 0);
    
    signal rng0 : std_logic_vector(31 downto 0);
    signal rng1 : std_logic_vector(31 downto 0);
        
    signal action_rams_ren : std_logic;
    signal action_rams_ra : std_logic_vector(state_width-1 downto 0);
    
    signal last_reward_valid : std_logic := '0';
    
    signal s1_last_reward_valid : std_logic := '0';
    signal s1_last_action : std_logic_vector(action_width-1 downto 0) := (others => '0');
    signal s1_last_value : std_logic_vector(reward_width-1 downto 0) := (others => '0');
    signal s1_last_reward : std_logic_vector(reward_width-1 downto 0);
    signal s1_qmax_value : std_logic_vector(reward_width-1 downto 0);
    signal s1_last_qmax_value : std_logic_vector(reward_width-1 downto 0);
    signal s1_last_state : std_logic_vector(state_width-1 downto 0);
    
    signal rsubv : std_logic_vector(reward_width-1 downto 0);
    signal maxvshifted : std_logic_vector(reward_width-1 downto 0);
    
    signal s2_rsubv : std_logic_vector(reward_width-1 downto 0);
    signal s2_maxvshifted : std_logic_vector(reward_width-1 downto 0);
    signal s2_last_state : std_logic_vector(state_width-1 downto 0);
    signal s2_last_reward_valid : std_logic := '0';
    signal s2_last_action : std_logic_vector(action_width-1 downto 0) := (others => '0');
    signal s2_last_value : std_logic_vector(reward_width-1 downto 0) := (others => '0');
    signal s2_qmax_value : std_logic_vector(reward_width-1 downto 0);
    signal s2_last_qmax_value : std_logic_vector(reward_width-1 downto 0);
    
    
--    signal s3_awen : enable_type := (others => '0');
--    signal s3_w_avalue : value_array := (others => (others => '0'));
--    signal s3_new_qvalue : std_logic_vector(reward_width-1 downto 0);
--    signal s3_qtable_write : std_logic;
--    signal s3_qmax_update : std_logic;
--    signal s3_new_qmax : std_logic_vector(reward_width-1 downto 0);
--    signal s3_new_qmax_action : std_logic_vector(action_width-1 downto 0) := (others => '0');
--    signal s3_last_action : std_logic_vector(action_width-1 downto 0) := (others => '0');
--    signal s3_last_value : std_logic_vector(reward_width-1 downto 0) := (others => '0');
--    signal s3_last_state : std_logic_vector(state_width-1 downto 0);
    
    signal action_rams_wa : std_logic_vector(state_width-1 downto 0);
    
    signal qmax_update : std_logic;
    signal next_qmax_read : std_logic_vector(reward_width+action_width-1 downto 0);
    signal qmax_value : std_logic_vector(reward_width-1 downto 0);
    signal qmax_action : std_logic_vector(action_width-1 downto 0);
    signal qmax_write : std_logic_vector(reward_width+action_width-1 downto 0);
    signal new_qmax : std_logic_vector(reward_width-1 downto 0);
    signal new_qmax_action : std_logic_vector(action_width-1 downto 0);
    
    signal last_qmax_value : std_logic_vector(reward_width-1 downto 0);
    signal last_qmax_action : std_logic_vector(action_width-1 downto 0);
    
    signal qtable_write : std_logic;
    signal qtable_ra : std_logic_vector(state_width+action_width-1 downto 0);
    signal qtable_wa : std_logic_vector(state_width+action_width-1 downto 0);
    signal qvalue : std_logic_vector(reward_width-1 downto 0);
    signal new_qvalue : std_logic_vector(reward_width-1 downto 0);
    signal next_random_action : std_logic_vector(action_width-1 downto 0);
    signal random_action : std_logic_vector(action_width-1 downto 0);
    signal last_random_action : std_logic_vector(action_width-1 downto 0);
begin

    

    lfsr0 : entity work.lfsr_random generic map (std_logic_vector(seed0)) port map (clk, rng0);
    lfsr1 : entity work.lfsr_random generic map (std_logic_vector(seed1)) port map (clk, rng1);

    action_rams1 : if qconf_action_rams = 1 generate
        gen_qtables : for i in 0 to action_num-1 generate
            u0 : entity work.simple_bram 
            generic map (
                memsize => state_num,
                addr_width => state_width,
                data_width => reward_width
            )
            port map (
                clk => clk,
                wen => awen(i),
                ren => state_valid,
                waddr => last_state,
                raddr => next_state,
                dout => r_avalue(i),
                din => w_avalue(i)
            );
        end generate gen_qtables;
    end generate;
    
    action_rams0 : if qconf_action_rams = 0 generate
        qtable_ra <= next_state & next_random_action;
        qtable_wa <= last_state & last_action;
        
        qtable : entity work.simple_bram 
        generic map (
            memsize => state_num * action_num,
            addr_width => state_width + action_width,
            data_width => reward_width
        )
        port map (
            clk => clk,
            wen => qtable_write,
            ren => '1',
            waddr => qtable_wa,
            raddr => qtable_ra,
            dout => qvalue,
            din => new_qvalue
        );
    end generate;
    
    qmax_write <= new_qmax_action & new_qmax;
    qmax_value <= next_qmax_read(reward_width-1 downto 0);
    qmax_action <= next_qmax_read((reward_width+action_width-1) downto reward_width);
    
    qmaxram : entity work.simple_bram
    generic map (
        memsize => state_num,
        addr_width => state_width,
        data_width => reward_width + action_width
    )
    port map (
        clk => clk,
        wen => qmax_update,
        ren => state_valid,
        waddr => last_state,
        raddr => next_state,
        dout => next_qmax_read,
        din => qmax_write
    );
    
    qlearning_update_three : process (enable, s1_last_action, s1_last_value, s1_last_reward, s1_qmax_value, s1_last_qmax_value, s1_last_reward_valid, 
                                s2_last_action, s2_last_value, s2_rsubv, s2_maxvshifted, s2_last_reward_valid, s2_qmax_value, s2_last_qmax_value, last_value)                 
        variable newval : std_logic_vector(reward_width-1 downto 0);
    begin      
        qmax_update <= '0';
        new_qmax <= (others => '0');
        new_qmax_action <= (others => '0');
        awen <= (others => '0');
        w_avalue <= (others => (others => '0'));
        new_qvalue <= (others => '0');
        
        -- pipeline stage 1
        rsubv <= std_logic_vector(signed(s1_last_reward) - signed(s1_last_value));
        
        if qconf_sarsa = 0 then
            maxvshifted <= std_logic_vector(shift_right(signed(s1_qmax_value), gamma));
        else
            maxvshifted <= std_logic_vector(shift_right(signed(last_value), gamma));
        end if;
        
        -- pipeline stage 2
        newval := std_logic_vector(signed(s2_last_value) + signed(shift_right(signed(s2_maxvshifted) + signed(s2_rsubv), alpha)));
        
        if qconf_action_rams = 1 then
            w_avalue(to_integer(unsigned(s2_last_action))) <= newval;
            awen(to_integer(unsigned(s2_last_action))) <= s2_last_reward_valid;
        else
            new_qvalue <= newval;
            qtable_write <= s2_last_reward_valid;
        end if;
        
        if unsigned(newval) > unsigned(s2_last_qmax_value) then
            qmax_update <= '1';
            new_qmax <= newval;
            new_qmax_action <= s2_last_action;
        end if;
    end process;
    
   
    
    epsilon_greedy_policy : if qconf_policy_random = 0 generate
        actor : process (last_value, last_action, rng0, rng1, qvalue, qmax_value, qmax_action, random_action) begin
            this_value <= last_value;
            this_action <= last_action;
            
            next_random_action <= rng1(action_width-1 downto 0);
            
            if unsigned(rng0(7 downto 0)) < epsilon then
                this_action <= random_action;
                if qconf_action_rams = 1 then
                    this_value <= r_avalue(to_integer(unsigned(random_action)));
                else
                    this_value <= qvalue;
                end if;
            else
                this_action <= qmax_action;
                this_value <= qmax_value;
            end if;
        end process;
    end generate;
    
    random_policy : if qconf_policy_random = 1 generate
        actor : process (rng1, random_action, qvalue) begin
            next_random_action <= rng1(action_width-1 downto 0);
            
            this_action <= random_action;
            if qconf_action_rams = 1 then
                this_value <= r_avalue(to_integer(unsigned(random_action)));
            else
                this_value <= qvalue;
            end if;
        end process;
    end generate;
    
    registers : process (clk) 
    begin
        if rising_edge(clk) then
            last_value <= this_value;
            last_action <= this_action;
            this_action_valid <= state_valid;
            last_action_valid <= this_action_valid;
            state <= next_state;
            last_state <= state;
            last_reward <= reward;
            last_reward_valid <= reward_valid;
            last_qmax_value <= qmax_value;
            last_qmax_action <= qmax_action;
            random_action <= next_random_action;
            
            s1_last_reward_valid <= last_reward_valid;
            s1_last_action <= last_action;
            s1_last_value <= last_value;
            s1_last_reward <= last_reward;
            s1_qmax_value <= qmax_value;
            s1_last_qmax_value <= last_qmax_value;
            s1_last_state <= last_state;
            
            s2_last_reward_valid <= s1_last_reward_valid;
            s2_last_action <= s1_last_action;
            s2_last_state <= s1_last_state;
            s2_rsubv <= rsubv;
            s2_maxvshifted <= maxvshifted;
            s2_last_value <= s1_last_value;
            s2_qmax_value <= s1_qmax_value;
            s2_last_qmax_value <= s1_last_qmax_value;
            
--            s3_awen <= awen;
--            s3_w_avalue <= w_avalue;
--            s3_new_qvalue <= new_qvalue;
--            s3_qtable_write <= qtable_write;
--            s3_qmax_update <= qmax_update;
--            s3_new_qmax <= new_qmax;
--            s3_new_qmax_action <= new_qmax_action;
--            s3_last_value <= s2_last_value;
--            s3_last_state <= s2_last_state;
--            s3_last_action <= s2_last_action;
        end if;
    end process;
    
    action <= this_action;
    action_valid <= this_action_valid;
    value_out <= this_value;

end Behavioral;
