
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity qlearning_axi is

generic (   
        -- Width of S_AXI data bus
        C_S_AXI_DATA_WIDTH	: integer	:= 32;
        -- Width of S_AXI address bus
        C_S_AXI_ADDR_WIDTH	: integer	:= 32
        
--        C_M_AXIS_TDATA_WIDTH	: integer	:= 32
    );
port (
        clk : in std_logic;
    
         -- Global Clock Signal
        S_AXI_ACLK	: in std_logic;
        -- Global Reset Signal. This Signal is Active LOW
        S_AXI_ARESETN	: in std_logic;
        -- Write address (issued by master, acceped by Slave)
        S_AXI_AWADDR	: in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
        -- Write channel Protection type. This signal indicates the
            -- privilege and security level of the transaction, and whether
            -- the transaction is a data access or an instruction access.
        S_AXI_AWPROT	: in std_logic_vector(2 downto 0);
        -- Write address valid. This signal indicates that the master signaling
            -- valid write address and control information.
        S_AXI_AWVALID	: in std_logic;
        -- Write address ready. This signal indicates that the slave is ready
            -- to accept an address and associated control signals.
        S_AXI_AWREADY	: out std_logic;
        -- Write data (issued by master, acceped by Slave) 
        S_AXI_WDATA	: in std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
        -- Write strobes. This signal indicates which byte lanes hold
            -- valid data. There is one write strobe bit for each eight
            -- bits of the write data bus.    
        S_AXI_WSTRB	: in std_logic_vector((C_S_AXI_DATA_WIDTH/8)-1 downto 0);
        -- Write valid. This signal indicates that valid write
            -- data and strobes are available.
        S_AXI_WVALID	: in std_logic;
        -- Write ready. This signal indicates that the slave
            -- can accept the write data.
        S_AXI_WREADY	: out std_logic;
        -- Write response. This signal indicates the status
            -- of the write transaction.
        S_AXI_BRESP	: out std_logic_vector(1 downto 0);
        -- Write response valid. This signal indicates that the channel
            -- is signaling a valid write response.
        S_AXI_BVALID	: out std_logic;
        -- Response ready. This signal indicates that the master
            -- can accept a write response.
        S_AXI_BREADY	: in std_logic;
        -- Read address (issued by master, acceped by Slave)
        S_AXI_ARADDR	: in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
        -- Protection type. This signal indicates the privilege
            -- and security level of the transaction, and whether the
            -- transaction is a data access or an instruction access.
        S_AXI_ARPROT	: in std_logic_vector(2 downto 0);
        -- Read address valid. This signal indicates that the channel
            -- is signaling valid read address and control information.
        S_AXI_ARVALID	: in std_logic;
        -- Read address ready. This signal indicates that the slave is
            -- ready to accept an address and associated control signals.
        S_AXI_ARREADY	: out std_logic;
        -- Read data (issued by slave)
        S_AXI_RDATA	: out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
        -- Read response. This signal indicates the status of the
            -- read transfer.
        S_AXI_RRESP	: out std_logic_vector(1 downto 0);
        -- Read valid. This signal indicates that the channel is
            -- signaling the required read data.
        S_AXI_RVALID	: out std_logic;
        -- Read ready. This signal indicates that the master can
            -- accept the read data and response information.
        S_AXI_RREADY	: in std_logic
        
--        M_AXIS_ACLK : in std_logic;
--        M_AXIS_TVALID : out std_logic;
--        M_AXIS_TDATA : out std_logic_vector(C_M_AXIS_TDATA_WIDTH-1 downto 0);
--        M_AXIS_TLAST : out std_logic;
--        M_AXIS_TREADY : in std_logic
    );
end qlearning_axi;

architecture Behavioral of qlearning_axi is

    signal alpha_axi2module : std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
    signal alpha_module2axi : std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
    signal gamma_axi2module : std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
    signal gamma_module2axi : std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
    signal episodes_axi2module : std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
    signal episodes_module2axi : std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
    signal enable_axi2module : std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
    signal enable_module2axi : std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);

    signal axis_read : std_logic;

begin

--axis_read <= M_AXIS_TREADY and (not enable_axi2module(0));


qlearnings_sys : entity work.qlearning_system port map (
    clk => clk,
    enable => enable_axi2module(0),
    alpha_in => alpha_axi2module,
    alpha_out => alpha_module2axi,
    gamma_in => gamma_axi2module,
    gamma_out => gamma_module2axi,
    episodes => episodes_module2axi
);

axi_control : entity work.axi_controller generic map (
    C_S_AXI_DATA_WIDTH	=> C_S_AXI_DATA_WIDTH,
    C_S_AXI_ADDR_WIDTH	=> C_S_AXI_ADDR_WIDTH
) port map (
    clk => clk,

    alpha_in => alpha_axi2module,
    alpha_out => alpha_module2axi,
    gamma_in => gamma_axi2module,
    gamma_out => gamma_module2axi,
    episodes_in => episodes_axi2module,
    episodes_out => episodes_module2axi,
    enable_in => enable_axi2module,
    enable_out => enable_module2axi,
    
    S_AXI_ACLK	  => S_AXI_ACLK,
    S_AXI_ARESETN => S_AXI_ARESETN,
    S_AXI_AWADDR  => S_AXI_AWADDR,
    S_AXI_AWPROT  => S_AXI_AWPROT,
    S_AXI_AWVALID => S_AXI_AWVALID,
    S_AXI_AWREADY => S_AXI_AWREADY,
    S_AXI_WDATA	  => S_AXI_WDATA,
    S_AXI_WSTRB	  => S_AXI_WSTRB,
    S_AXI_WVALID  => S_AXI_WVALID,
    S_AXI_WREADY  => S_AXI_WREADY,
    S_AXI_BRESP	  => S_AXI_BRESP,
    S_AXI_BVALID  => S_AXI_BVALID,
    S_AXI_BREADY  => S_AXI_BREADY,
    S_AXI_ARADDR  => S_AXI_ARADDR,
    S_AXI_ARPROT  => S_AXI_ARPROT,
    S_AXI_ARVALID => S_AXI_ARVALID,
    S_AXI_ARREADY => S_AXI_ARREADY,
    S_AXI_RDATA	  => S_AXI_RDATA,
    S_AXI_RRESP	  => S_AXI_RRESP,
    S_AXI_RVALID  => S_AXI_RVALID,
    S_AXI_RREADY  => S_AXI_RREADY
);

end Behavioral;