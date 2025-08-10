component gpio0 is
    port(
        gpi_o: out std_logic_vector(7 downto 0);
        gpo_o: out std_logic_vector(7 downto 0);
        int_o: out std_logic;
        ahbl_haddr_i: in std_logic_vector(31 downto 0);
        ahbl_hburst_i: in std_logic_vector(2 downto 0);
        ahbl_hrdata_o: out std_logic_vector(31 downto 0);
        ahbl_hsize_i: in std_logic_vector(2 downto 0);
        ahbl_htrans_i: in std_logic_vector(1 downto 0);
        ahbl_hwdata_i: in std_logic_vector(31 downto 0);
        ahbl_hclk_i: in std_logic;
        ahbl_hresetn_i: in std_logic;
        ahbl_hready_i: in std_logic;
        ahbl_hreadyout_o: out std_logic;
        ahbl_hresp_o: out std_logic;
        ahbl_hsel_i: in std_logic;
        ahbl_hwrite_i: in std_logic;
        gpio_io: inout std_logic_vector(7 downto 0)
    );
end component;

__: gpio0 port map(
    gpi_o=>,
    gpo_o=>,
    int_o=>,
    ahbl_haddr_i=>,
    ahbl_hburst_i=>,
    ahbl_hrdata_o=>,
    ahbl_hsize_i=>,
    ahbl_htrans_i=>,
    ahbl_hwdata_i=>,
    ahbl_hclk_i=>,
    ahbl_hresetn_i=>,
    ahbl_hready_i=>,
    ahbl_hreadyout_o=>,
    ahbl_hresp_o=>,
    ahbl_hsel_i=>,
    ahbl_hwrite_i=>,
    gpio_io=>
);
