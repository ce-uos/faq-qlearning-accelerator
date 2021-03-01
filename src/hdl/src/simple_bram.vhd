library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity simple_bram is
    Generic (
        memsize : integer := 1024;
        addr_width : integer := 32;
        data_width : integer := 32
    );
    Port ( 
        clk : in std_logic;
        wen : in std_logic;
        ren : in std_logic;
        waddr : in std_logic_vector(addr_width-1 downto 0);
        raddr : in std_logic_vector(addr_width-1 downto 0);
        dout : out std_logic_vector(data_width-1 downto 0);
        din : in std_logic_vector(data_width-1 downto 0)
      );
end simple_bram;

architecture Behavioral of simple_bram is
    type mem_type is array(0 to memsize-1) of std_logic_vector(data_width-1 downto 0);
    signal mem : mem_type := (others => (others => '0'));
    attribute ram_style : string;
    attribute ram_style of mem : signal is "block";
begin

    process (clk) begin
        if rising_edge(clk) then
            if ren = '1' then
                dout <= mem(to_integer(unsigned(raddr)));
            end if;
            if wen = '1' then
                mem(to_integer(unsigned(waddr))) <= din;
            end if;
        end if;
    end process;


end Behavioral;
