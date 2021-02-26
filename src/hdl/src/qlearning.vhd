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
    
    signal maxvalue : std_logic_vector(reward_width-1 downto 0);
    signal maxidx : std_logic_vector(action_width-1 downto 0);
    
    signal rng0 : std_logic_vector(31 downto 0);
    signal rng1 : std_logic_vector(31 downto 0);
    
    constant MAX_LEVELS : integer := integer(ceil(log2(real(action_num))));
    type leveltemps is array(0 to MAX_LEVELS) of value_array;
    signal maxdbg : leveltemps;
    signal maxidxdbg : leveltemps;
    
    signal ready : std_logic := '0';
    
    signal action_rams_ren : std_logic;
    signal action_rams_ra : std_logic_vector(state_width-1 downto 0);
begin

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
            waddr => last_state,
            raddr => action_rams_ra,
            dout => r_avalue(i),
            din => w_avalue(i)
        );
    end generate gen_qtables;
    
    axis_out : process (r_avalue) begin
        for i in 0 to action_num-1 loop
            axis_data(((i+1)*reward_width-1) downto (i*reward_width)) <= r_avalue(i);
        end loop;
    end process;

    pmax : process (r_avalue, maxvalue, maxidx) 
        variable temps : leveltemps;
        variable idxtemps : leveltemps;
    begin
    
        temps(MAX_LEVELS) := r_avalue;
        
        for i in 0 to (2**MAX_LEVELS)-1 loop
            idxtemps(MAX_LEVELS)(i) := std_logic_vector(to_unsigned(i, reward_width));
        end loop;
    
        for lvl in MAX_LEVELS-1 downto 1 loop
            for cmp in 0 to (2**lvl)-1 loop
                if signed(temps(lvl + 1)(cmp)) > signed(temps(lvl + 1)(cmp + 2**lvl)) then
                    temps(lvl)(cmp) :=  temps(lvl + 1)(cmp);
                    idxtemps(lvl)(cmp) := idxtemps(lvl + 1)(cmp);
                else 
                    temps(lvl)(cmp) :=  temps(lvl + 1)(cmp + 2**lvl);
                    idxtemps(lvl)(cmp) := idxtemps(lvl + 1)(cmp + 2**lvl);
                end if;
            end loop;
        end loop;
        
        if signed(temps(1)(0)) > signed(temps(1)(1)) then
            maxvalue <= temps(1)(0);
            maxidx <= idxtemps(1)(0)(action_width-1 downto 0);
        else
            maxvalue <= temps(1)(1);
            maxidx <= idxtemps(1)(1)(action_width-1 downto 0);
        end if;
        
        maxdbg <= temps;
        maxidxdbg <= idxtemps;
    
    end process;
    
    qlearning_update : process (enable, last_action, last_value, last_reward, maxvalue, reward_valid) begin      
        awen <= (others => '0');
        w_avalue <= (others => (others => '0'));
        w_avalue(to_integer(unsigned(last_action))) <= std_logic_vector(signed(last_value) + signed(shift_right(signed(last_reward) + signed(shift_right(signed(maxvalue), gamma)) - signed(last_value), alpha)));
        awen(to_integer(unsigned(last_action))) <= reward_valid and enable;
    end process;
    
    actor : process (enable, last_value, last_action, rng0, rng1, r_avalue, maxidx, maxvalue) begin
        this_value <= last_value;
        this_action <= last_action;
        
        if unsigned(rng0(7 downto 0)) < epsilon then
            this_action <= rng1(action_width-1 downto 0);
            this_value <= r_avalue(to_integer(unsigned(rng1(action_width-1 downto 0))));
        else
            this_action <= maxidx;
            this_value <= std_logic_vector(maxvalue);
        end if;
    end process;
    
    
--    qlearning_update_old : process (enable, r_avalue, next_state, state_valid, last_reward, reward_valid, last_action, last_value, last_state, maxvalue, maxidx, rng0, rng1, gamma, alpha) 
--    begin
--        awen <= (others => '0');
--        w_avalue <= (others => (others => '0'));
--        this_value <= last_value;
--        this_action <= last_action;
        
--        -- compute update
--        w_avalue(to_integer(unsigned(last_action))) <= std_logic_vector(signed(last_value) + signed(shift_right(signed(last_reward) + signed(shift_right(signed(maxvalue), gamma)) - signed(last_value), alpha)));
--        awen(to_integer(unsigned(last_action))) <= reward_valid and enable;
        
--        if unsigned(rng0(7 downto 0)) < epsilon then
--            this_action <= rng1(action_width-1 downto 0);
--            this_value <= r_avalue(to_integer(unsigned(rng1(action_width-1 downto 0))));
--        else
--            this_action <= maxidx;
--            this_value <= std_logic_vector(maxvalue);
--        end if;
--    end process;
    
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
                ready <= '1';
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
