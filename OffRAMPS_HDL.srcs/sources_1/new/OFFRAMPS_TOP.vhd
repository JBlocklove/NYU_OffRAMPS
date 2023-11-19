library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity OffRAMPS_top is
    Port (
        -- Board Specific IO
        sysclk   : in std_logic;   -- System clock
        led0_g   : out std_logic;  -- RGB LED 0 Green
        led0_r   : out std_logic;  -- RGB LED 0 Red
        btn0     : in std_logic;   -- Button[0]
        led_0    : out std_logic;  -- LED 0

        -- Thermocouple inputs
        i_THERM0_n_0 : in std_logic;  -- Thermocouple 0 Negative Single-ended input [0]
        i_THERM0_p_0 : in std_logic;  -- Thermocouple 0 Positive Single-ended input [0]
        i_THERM1_n_1 : in std_logic;  -- Thermocouple 1 Negative Single-ended input [1]
        i_THERM1_p_1 : in std_logic;  -- Thermocouple 1 Positive Single-ended input [1]

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
        o_E0_DIR    : out std_logic;  -- Extruder 0 Direction output
        o_E0_EN     : out std_logic;  -- Extruder 0 Enable output
        o_E0_STEP   : out std_logic;  -- Extruder 0 Step output
        o_THERM_EN  : out std_logic;  -- Thermocouple Enable output
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

    COMPONENT Z_Step_Mod
    PORT (
        clk                 : in  std_logic;
        enable              : in  std_logic;
        homing_complete     : in  std_logic;
        z_step              : in  std_logic;
        z_step_modified     : out std_logic
    );
    END COMPONENT;
    
    -- Bypass mode control signals
    signal bypass_mode_en : std_logic := '0';
    signal button_debounce : std_logic_vector(1 downto 0) := "00";
    signal button_press : std_logic;
    signal home_complete_buf :std_logic;
    
    -- Trojan Related Signals
    signal z_step_modified : std_logic;

begin

    -- Button Press Detection
    button_press <= not button_debounce(1) and button_debounce(0);

    process (sysclk)
    begin
        if rising_edge(sysclk) then
            button_debounce <= button_debounce(0) & btn0;
            if button_press = '1' then
                bypass_mode_en <= not bypass_mode_en;
            end if;
        end if;
    end process;

    led_0 <= home_complete_buf;
    
    -- Homing Sequence detection Component
    HomingDetector : DETECT_HOME PORT MAP(
        i_CLK       => sysclk,
        i_X_STEP    => i_X_STEP,
        i_Y_STEP    => i_Y_STEP,
        i_Z_STEP    => i_Z_STEP,
        i_X_MIN     => i_X_MIN,
        i_Y_MIN     => i_Y_MIN,
        i_Z_MIN     => i_Z_MIN,
        o_homing_complete => home_complete_buf
    );
    
    
    Z_mod : Z_Step_Mod PORT MAP (
        clk                 => sysclk,
        enable              => '1',
        homing_complete     => home_complete_buf,
        z_step              => i_Z_STEP,
        z_step_modified     => z_step_modified
    );

    -- BYPASS MUXs
    o_D10       <= 'Z' when bypass_mode_en = '0' else i_D10;
    o_D9        <= 'Z' when bypass_mode_en = '0' else i_D9;
    o_E0_DIR    <= 'Z' when bypass_mode_en = '0' else i_E0_DIR;
    o_E0_EN     <= 'Z' when bypass_mode_en = '0' else i_E0_EN;
    o_E0_STEP   <= 'Z' when bypass_mode_en = '0' else i_E0_STEP;
    o_UART_RX   <= 'Z' when bypass_mode_en = '0' else i_UART_RX;
    o_UART_TX   <= 'Z' when bypass_mode_en = '0' else i_UART_TX;
    o_X_DIR     <= 'Z' when bypass_mode_en = '0' else i_X_DIR;
    o_X_EN      <= 'Z' when bypass_mode_en = '0' else i_X_EN;
    o_X_MAX     <= 'Z' when bypass_mode_en = '0' else i_X_MAX;
    o_X_MIN     <= 'Z' when bypass_mode_en = '0' else i_X_MIN;
    o_X_STEP    <= 'Z' when bypass_mode_en = '0' else i_X_STEP;
    o_Y_DIR     <= 'Z' when bypass_mode_en = '0' else i_Y_DIR;
    o_Y_EN      <= 'Z' when bypass_mode_en = '0' else i_Y_EN;
    o_Y_MAX     <= 'Z' when bypass_mode_en = '0' else i_Y_MAX;
    o_Y_MIN     <= 'Z' when bypass_mode_en = '0' else i_Y_MIN;
    o_Y_STEP    <= 'Z' when bypass_mode_en = '0' else i_Y_STEP;
    o_Z_DIR     <= 'Z' when bypass_mode_en = '0' else i_Z_DIR;
    o_Z_EN      <= 'Z' when bypass_mode_en = '0' else i_Z_EN;
    o_Z_MAX     <= 'Z' when bypass_mode_en = '0' else i_Z_MAX;
    o_Z_MIN     <= 'Z' when bypass_mode_en = '0' else i_Z_MIN;
    o_Z_STEP    <= z_step_modified when bypass_mode_en = '0' else i_Z_STEP;

    -- Currently, We are jumping the termocouple from ramps --> arduino
    -- Thermometer Enable output might combine two inputs or have a default state                               
    o_THERM_EN  <= 'Z' when bypass_mode_en = '0' else (i_THERM0_SCL and i_THERM0_SDA);
end Behavioral;