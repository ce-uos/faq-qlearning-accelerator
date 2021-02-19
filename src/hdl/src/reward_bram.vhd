library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.envconfig.ALL;

entity reward_bram is
    Generic (
        init : reward_mem_type := (others => (others => '0'))
    );
    Port ( 
        clk : in std_logic;
        ren : in std_logic;
        raddr : in std_logic_vector(env_addr_width-1 downto 0);
        dout : out std_logic_vector(env_reward_width-1 downto 0)
      );
end reward_bram;

architecture Behavioral of reward_bram is
    signal mem : reward_mem_type := init;
begin
    
--    process (clk) begin
--        if rising_edge(clk) then
--            if ren = '1' then
--                dout <= mem(to_integer(unsigned(raddr)));
--            end if;
--        end if;
--    end process;
    
   process (ren, mem, raddr) begin
        if ren = '1' then
            dout <= mem(to_integer(unsigned(raddr)));
        else 
            dout <= (others => '0');
        end if;
    end process;


end Behavioral;
