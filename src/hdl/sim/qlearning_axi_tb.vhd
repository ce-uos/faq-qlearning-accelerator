----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/23/2021 10:06:55 AM
-- Design Name: 
-- Module Name: qlearning_axi_tb - Behavioral
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

entity qlearning_axi_tb is
--  Port ( );
end qlearning_axi_tb;

architecture Behavioral of qlearning_axi_tb is
    signal clk : std_logic := '0';
    signal reset : std_logic := '1';
    
    constant C_S_AXI_ADDR_WIDTH : integer := 32;
    constant C_S_AXI_DATA_WIDTH : integer := 32;
    constant C_M_AXIS_TDATA_WIDTH : integer := 64;
    
    signal S_AXI_ACLK : std_logic;
    signal S_AXI_ARESETN : std_logic := '1';
    signal S_AXI_AWADDR	: std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
    signal S_AXI_AWPROT	: std_logic_vector(2 downto 0);
    signal S_AXI_AWVALID : std_logic := '0';
    signal S_AXI_AWREADY : std_logic;
    signal S_AXI_WDATA : std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
    signal S_AXI_WSTRB : std_logic_vector((C_S_AXI_DATA_WIDTH/8)-1 downto 0);
    signal S_AXI_WVALID	: std_logic;
    signal S_AXI_WREADY	: std_logic;
    
    signal S_AXI_BRESP	: std_logic_vector(1 downto 0);
    signal S_AXI_BVALID	: std_logic := '0';
    signal S_AXI_BREADY	: std_logic := '0';
    signal S_AXI_ARADDR	: std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
    signal S_AXI_ARPROT	: std_logic_vector(2 downto 0);
    signal S_AXI_ARVALID : std_logic := '0';
    signal S_AXI_ARREADY : std_logic;
    signal S_AXI_RDATA	: std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
    signal S_AXI_RRESP	: std_logic_vector(1 downto 0);
    signal S_AXI_RVALID	: std_logic;
    signal S_AXI_RREADY	: std_logic := '0';
    
    signal M_AXIS_ACLK : std_logic;
    signal M_AXIS_TVALID : std_logic;
    signal M_AXIS_TDATA : std_logic_vector(C_M_AXIS_TDATA_WIDTH-1 downto 0);
    signal M_AXIS_TLAST : std_logic;
    signal M_AXIS_TREADY : std_logic := '0';
    
begin

    clk <= not clk after 20 ns;
    S_AXI_ACLK <= clk;
    M_AXIS_ACLK <= clk;
    M_AXIS_TREADY <= '1' after 100ns;
    
    ql_axi : entity work.qlearning_axi port map (
        clk => clk,
    
        S_AXI_ACLK => S_AXI_ACLK,
        S_AXI_ARESETN	 => S_AXI_ARESETN,
        S_AXI_AWADDR	 => S_AXI_AWADDR,
        S_AXI_AWPROT	 => S_AXI_AWPROT,
        S_AXI_AWVALID	 => S_AXI_AWVALID,
        S_AXI_AWREADY	 => S_AXI_AWREADY,
        S_AXI_WDATA => S_AXI_WDATA,
        S_AXI_WSTRB => S_AXI_WSTRB,
        S_AXI_WVALID	 => S_AXI_WVALID,
        S_AXI_WREADY	 => S_AXI_WREADY,
        S_AXI_BRESP => S_AXI_BRESP,
        S_AXI_BVALID	 => S_AXI_BVALID,
        S_AXI_BREADY	 => S_AXI_BREADY,
        S_AXI_ARADDR	 => S_AXI_ARADDR,
        S_AXI_ARPROT	 => S_AXI_ARPROT,
        S_AXI_ARVALID	 => S_AXI_ARVALID,
        S_AXI_ARREADY	 => S_AXI_ARREADY,
        S_AXI_RDATA => S_AXI_RDATA,
        S_AXI_RRESP => S_AXI_RRESP,
        S_AXI_RVALID	 => S_AXI_RVALID,
        S_AXI_RREADY	 => S_AXI_RREADY,
        
        M_AXIS_ACLK => M_AXIS_ACLK,
        M_AXIS_TVALID => M_AXIS_TVALID,
        M_AXIS_TDATA  => M_AXIS_TDATA,
        M_AXIS_TLAST  => M_AXIS_TLAST,
        M_AXIS_TREADY => M_AXIS_TREADY
    );
    
    process (clk) begin
        if rising_edge(clk) then
--            if M_AXIS_TLAST = '1' then
--                M_AXIS_TREADY <= '0';
--            end if;
        end if;
    end process;
    
end Behavioral;
