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
    rseed1 : integer := 21314;
    pipeline_stages : integer := 3
  );
  Port ( 
    clk : in std_logic;
    enable : in std_logic;
    
    next_state : in std_logic_vector(state_width-1 downto 0);
    state_valid : in std_logic;
    reward : in std_logic_vector(reward_width-1 downto 0);
    reward_valid : in std_logic;
    action : out std_logic_vector(action_width-1 downto 0);
    action_valid : out std_logic;
    
    alpha_in : in std_logic_vector(31 downto 0);
    alpha_out : out std_logic_vector(31 downto 0);
    gamma_in : in std_logic_vector(31 downto 0);
    gamma_out : out std_logic_vector(31 downto 0);
    
    axis_read : in std_logic;
    axis_pointer : in std_logic_vector(state_width-1 downto 0);
    axis_data : out std_logic_vector(action_num*reward_width-1 downto 0)
  
  );
end qlearning;

architecture Behavioral of qlearning is
    constant epsilon : unsigned(7 downto 0) := to_unsigned(repsilon, 8);
    constant seed0 : unsigned(31 downto 0) := to_unsigned(rseed0, 32);
    constant seed1 : unsigned(31 downto 0) := to_unsigned(rseed1, 32);
    
    signal alpha : integer := 1;
    signal gamma : integer := 1;
    
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
begin

    qmax_value <= next_qmax_read(reward_width-1 downto 0);
    qmax_action <= next_qmax_read((reward_width+action_width-1) downto reward_width);
    
    qmax_write <= new_qmax_action & new_qmax;

    lfsr0 : entity work.lfsr_random generic map (std_logic_vector(seed0)) port map (clk, rng0);
    lfsr1 : entity work.lfsr_random generic map (std_logic_vector(seed1)) port map (clk, rng1);

    action_rams_ren <= state_valid or axis_read;    
    action_rams_ra <= next_state when axis_read = '0' else axis_pointer;

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
            ren => action_rams_ren,
            waddr => action_rams_wa,
            raddr => action_rams_ra,
            dout => r_avalue(i),
            din => w_avalue(i)
        );
    end generate gen_qtables;
    
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
        waddr => action_rams_wa,
        raddr => next_state,
        dout => next_qmax_read,
        din => qmax_write
    );
    
    axis_out : process (r_avalue) begin
        for i in 0 to action_num-1 loop
            axis_data(((i+1)*reward_width-1) downto (i*reward_width)) <= r_avalue(i);
        end loop;
    end process;
    
    single_stage_gen : if pipeline_stages = 1 generate
        action_rams_wa <= last_state;
        qlearning_update_one : process (enable, r_avalue, next_state, state_valid, last_reward, reward_valid, last_action, last_value, last_state, qmax_value, rng0, rng1, gamma, alpha) 
            variable newval : std_logic_vector(reward_width-1 downto 0);
        begin
            qmax_update <= '0';
            awen <= (others => '0');
            w_avalue <= (others => (others => '0'));
            newval := std_logic_vector(signed(last_value) + signed(shift_right(signed(last_reward) + signed(shift_right(signed(qmax_value), gamma)) - signed(last_value), alpha)));
            w_avalue(to_integer(unsigned(last_action))) <= newval;
            awen(to_integer(unsigned(last_action))) <= reward_valid and enable;
            
            if unsigned(newval) > unsigned(last_qmax_value) then
                qmax_update <= '1';
                new_qmax <= newval;
                new_qmax_action <= last_action;
            end if;
        end process;
    end generate;
    
    two_stage_gen : if pipeline_stages = 2 generate
        action_rams_wa <= s1_last_state;
        qlearning_update_two : process (enable, s1_last_action, s1_last_value, s1_last_reward, s1_qmax_value, s1_last_qmax_value, s1_last_reward_valid, alpha, gamma) 
            variable newval : std_logic_vector(reward_width-1 downto 0);
        begin      
            qmax_update <= '0';
            new_qmax <= (others => '0');
            new_qmax_action <= (others => '0');
            awen <= (others => '0');
            w_avalue <= (others => (others => '0'));
            newval := std_logic_vector(signed(s1_last_value) + signed(shift_right(signed(s1_last_reward) + signed(shift_right(signed(s1_qmax_value), gamma)) - signed(s1_last_value), alpha)));
            w_avalue(to_integer(unsigned(s1_last_action))) <= newval;
            awen(to_integer(unsigned(s1_last_action))) <= s1_last_reward_valid and enable;
       
            if unsigned(newval) > unsigned(s1_last_qmax_value) then
                qmax_update <= '1';
                new_qmax <= newval;
                new_qmax_action <= s1_last_action;
            end if;
       
        end process;
        
        pipeline_registers : process (clk) begin
            if rising_edge(clk) then
                s1_last_reward_valid <= last_reward_valid;
                s1_last_action <= last_action;
                s1_last_value <= last_value;
                s1_last_reward <= last_reward;
                s1_qmax_value <= qmax_value;
                s1_last_qmax_value <= last_qmax_value;
                s1_last_state <= last_state;
            end if;
        end process; 
    end generate;
    
    three_stage_gen : if pipeline_stages = 3 generate
        action_rams_wa <= s2_last_state;
        qlearning_update_three : process (enable, s1_last_action, s1_last_value, s1_last_reward, s1_qmax_value, s1_last_qmax_value, s1_last_reward_valid, alpha, gamma,
                                    s2_last_action, s2_last_value, s2_rsubv, s2_maxvshifted, s2_last_reward_valid, s2_qmax_value, s2_last_qmax_value)                 
            variable newval : std_logic_vector(reward_width-1 downto 0);
        begin      
            qmax_update <= '0';
            new_qmax <= (others => '0');
            new_qmax_action <= (others => '0');
            awen <= (others => '0');
            w_avalue <= (others => (others => '0'));
            
            -- pipeline stage 1
            rsubv <= std_logic_vector(signed(s1_last_reward) - signed(s1_last_value));
            maxvshifted <= std_logic_vector(shift_right(signed(s1_qmax_value), gamma));
            
            -- pipeline stage 2
            newval := std_logic_vector(signed(s2_last_value) + signed(shift_right(signed(s2_rsubv) + signed(s2_maxvshifted), alpha)));
            w_avalue(to_integer(unsigned(s2_last_action))) <= newval;
            awen(to_integer(unsigned(s2_last_action))) <= s2_last_reward_valid and enable;
            
            if unsigned(newval) > unsigned(s2_last_qmax_value) then
                qmax_update <= '1';
                new_qmax <= newval;
                new_qmax_action <= s2_last_action;
            end if;
        end process;
        
        pipeline_registers : process (clk) begin
            if rising_edge(clk) then
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
            end if;
        end process; 
    end generate;
    
    actor : process (enable, last_value, last_action, rng0, rng1, r_avalue, qmax_value, qmax_action) begin
        this_value <= last_value;
        this_action <= last_action;
        
        if unsigned(rng0(7 downto 0)) < epsilon then
            this_action <= rng1(action_width-1 downto 0);
            this_value <= r_avalue(to_integer(unsigned(rng1(action_width-1 downto 0))));
        else
            this_action <= qmax_action;
            this_value <= qmax_value;
        end if;
    end process;
    
    registers : process (clk) 
    begin
        if rising_edge(clk) then
            if enable = '1' then
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
            end if;
            alpha <= to_integer(unsigned(alpha_in));
            gamma <= to_integer(unsigned(gamma_in));
        end if;
    end process;
    
    alpha_out <= std_logic_vector(to_unsigned(alpha, 32));
    gamma_out <= std_logic_vector(to_unsigned(gamma, 32));
    
    action <= this_action;
    action_valid <= this_action_valid;

end Behavioral;
