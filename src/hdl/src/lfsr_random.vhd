----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07/02/2020 06:33:56 PM
-- Design Name: 
-- Module Name: lfsr_random - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity lfsr_random is
  Generic (
    SEED : std_logic_vector(31 downto 0)
  );
  Port (
    clk : in std_logic;
    rng : out std_logic_vector(31 downto 0)
   );
end lfsr_random;

architecture Behavioral of lfsr_random is
    signal lfsr : std_logic_vector(31 downto 0) := SEED;
begin

    process (clk) 
        variable newbit : std_logic;
    begin
        if rising_edge(clk) then
            newbit := lfsr(0) xor lfsr(10) xor lfsr(30) xor lfsr(31);
            lfsr <= newbit & lfsr(31 downto 1);
        end if;
    end process;

    rng <= lfsr;

end Behavioral;
