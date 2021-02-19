library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.envconfig.ALL;

entity transition_bram is
    Generic (
        init : transition_mem_type := (others => (others => '0'))
    );
    Port ( 
        clk : in std_logic;
        ren : in std_logic;
        raddr : in std_logic_vector(env_addr_width-1 downto 0);
        dout : out std_logic_vector(env_state_width-1 downto 0)
      );
end transition_bram;

architecture Behavioral of transition_bram is
    signal mem : transition_mem_type := init;
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
