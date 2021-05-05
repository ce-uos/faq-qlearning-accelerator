-- This file implements a simple BRAM memory

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity simple_bram is
    Generic (
        memsize : integer := 1024;                          -- amount of data stored in BRAM
        addr_width : integer := 32;                         -- width of BRAM addresses
        data_width : integer := 32                          -- width of data stored in BRAM
    );
    Port ( 
        clk : in std_logic;                                 -- clock input
        wen : in std_logic;                                 -- write enable
        ren : in std_logic;                                 -- read enable
        waddr : in std_logic_vector(addr_width-1 downto 0); -- write address
        raddr : in std_logic_vector(addr_width-1 downto 0); -- read address
        dout : out std_logic_vector(data_width-1 downto 0); -- data out
        din : in std_logic_vector(data_width-1 downto 0)    -- data in
      );
end simple_bram;

architecture Behavioral of simple_bram is

    -- this defines a large array used as BRAM memory
    type mem_type is array(0 to memsize-1) of std_logic_vector(data_width-1 downto 0);
    signal mem : mem_type := (others => (others => '0'));
    
    -- these attributes force vivado to use block RAM
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
