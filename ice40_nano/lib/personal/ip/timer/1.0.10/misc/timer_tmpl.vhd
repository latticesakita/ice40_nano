component timer is
    port(
        int_o: out std_logic;
        htrans_i: in std_logic_vector(1 downto 0);
        hsel_i: in std_logic;
        hwrite_i: in std_logic;
        haddr_i: in std_logic_vector(31 downto 0);
        hwdata_i: in std_logic_vector(31 downto 0);
        hready_i: in std_logic;
        hburst_i: in std_logic_vector(2 downto 0);
        hsize_i: in std_logic_vector(2 downto 0);
        hrdata_o: out std_logic_vector(31 downto 0);
        hresp_o: out std_logic;
        hready_o: out std_logic;
        clk_i: in std_logic;
        resetn_i: in std_logic
    );
end component;

__: timer port map(
    int_o=>,
    htrans_i=>,
    hsel_i=>,
    hwrite_i=>,
    haddr_i=>,
    hwdata_i=>,
    hready_i=>,
    hburst_i=>,
    hsize_i=>,
    hrdata_o=>,
    hresp_o=>,
    hready_o=>,
    clk_i=>,
    resetn_i=>
);
