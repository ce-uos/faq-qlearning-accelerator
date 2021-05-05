-- This file implements a simple Linear Feedback Shift Register (LFSR) which can be used to generate pseudo-random numbers

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity lfsr_random is
  Generic (
    SEED : std_logic_vector(31 downto 0)    -- Seed for the random number sequence
  );
  Port (
    clk : in std_logic;                     -- clock inout
    rng : out std_logic_vector(31 downto 0) -- random number output
   );
end lfsr_random;

architecture Behavioral of lfsr_random is
    -- interal lfsr value register, initialized with the seed
    signal lfsr : std_logic_vector(31 downto 0) := SEED;
begin

    -- this process computes the next pseudo-random number
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
