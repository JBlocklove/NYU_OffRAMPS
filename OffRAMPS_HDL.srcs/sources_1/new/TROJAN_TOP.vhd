library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity TROJAN_TOP is
    Port (
        i_CLK                 : in  std_logic;
        i_RESET                : in std_logic;
        enable_x_troj       : in  std_logic;
        enable_y_troj       : in  std_logic;
        enable_z_troj       : in  std_logic;
        homing_complete     : in  std_logic;
        
        -- Data Signals In
        i_E0_DIR    : in std_logic;
        i_E0_EN     : in std_logic;
        i_E0_STEP   : in std_logic;
        
        i_X_DIR     : in std_logic;  -- X Direction input
        i_X_EN      : in std_logic;  -- X Enable input
        i_X_MIN     : in std_logic;  -- X Min input
        i_X_STEP    : in std_logic;  -- X Step input  
        
        i_Y_DIR     : in std_logic;  -- Y Direction input
        i_Y_EN      : in std_logic;  -- Y Enable input
        i_Y_MIN     : in std_logic;  -- Y Min input
        i_Y_STEP    : in std_logic;  -- Y Step input
        
        i_Z_DIR     : in std_logic;  -- Z Direction input
        i_Z_EN      : in std_logic;  -- Z Enable input
        i_Z_MIN     : in std_logic;  -- Z Min input
        i_Z_STEP    : in std_logic;  -- Z Step input

        -- Data Signals Out
        o_E0_DIR    : out std_logic;
        o_E0_EN     : out std_logic;
        o_E0_STEP   : out std_logic;
        
        o_X_DIR     : out std_logic; --X_DIR  output
        o_X_EN      : out std_logic; --X_EN   output
        o_X_MIN     : out std_logic; --X_MIN  output
        o_X_STEP    : out std_logic; --X_STEP output
        
        o_Y_DIR     : out std_logic; --Y_DIR  output
        o_Y_EN      : out std_logic; --Y_EN   output
        o_Y_MIN     : out std_logic; --Y_MIN  output
        o_Y_STEP    : out std_logic; --Y_STEP output
        
        o_Z_DIR     : out std_logic; --Z_DIR  output
        o_Z_EN      : out std_logic; --Z_EN   output
        o_Z_MIN     : out std_logic; --Z_MIN  output
        o_Z_STEP    : out std_logic  --Z_STEP output
    );
end TROJAN_TOP;

architecture Behavioral of Trojan_TOP is
    
    -- Edge Detected signals
    signal s_edge_x_step : std_logic := '0';
    signal s_edge_y_step : std_logic := '0';
    signal s_edge_z_step : std_logic := '0';
    signal s_edge_e_step : std_logic := '0';


    -- Pulse Related Signals per Axis
    constant X_PULSES_PER_STEP : std_logic_vector(5 downto 0) := X"10";  -- 16 pulses per step --> 1.8 degrees (?)
    signal X_PULSE_COUNT : std_logic_vector (5 downto 0) := (others=>'0');
    signal X_PULSE_COUNT_EN : std_logic := '0';
    signal X_STEP_MOD : std_logic := '0';

    constant Y_PULSES_PER_STEP : std_logic_vector(5 downto 0) := X"10";  -- 16 pulses per step --> 1.8 degrees (?)
    signal Y_PULSE_COUNT : std_logic_vector (5 downto 0) := (others=>'0');
    signal Y_PULSE_COUNT_EN : std_logic := '0';
    signal Y_STEP_MOD : std_logic := '0';

    constant Z_PULSES_PER_STEP : std_logic_vector(5 downto 0) := X"10";  -- 16 pulses per step --> 1.8 degrees (?)
    signal Z_PULSE_COUNT : std_logic_vector (5 downto 0) := (others=>'0');
    signal Z_PULSE_COUNT_EN : std_logic := '0';
    signal Z_STEP_MOD : std_logic := '0';

    constant E_PULSES_PER_STEP : std_logic_vector(5 downto 0) := X"10";  -- 16 pulses per step --> 1.8 degrees (?)
    signal E_PULSE_COUNT : std_logic_vector (5 downto 0) := (others=>'0');
    signal E_PULSE_COUNT_EN : std_logic := '0';
    signal E_STEP_MOD : std_logic := '0';


    -- We will determine the time between pulses here, no acceleration config (yet)
-- We will send the pulses @ 6.5kHz. That is (at 100 Mhz):


    COMPONENT RISING_EDGE_DETECTOR
	PORT(
        i_CLK     : in  std_logic;
        input     : in  std_logic;
        output    : out std_logic
		);
	END COMPONENT;
    
begin

    ------- Components--------- 
    
    X_STEP_EDGE : RISING_EDGE_DETECTOR PORT MAP(i_CLK => i_CLK, input => i_X_STEP, output => s_edge_x_step);
    Y_STEP_EDGE : RISING_EDGE_DETECTOR PORT MAP(i_CLK => i_CLK, input => i_Y_STEP, output => s_edge_y_step);
    Z_STEP_EDGE : RISING_EDGE_DETECTOR PORT MAP(i_CLK => i_CLK, input => i_Z_STEP, output => s_edge_z_step);
    E_STEP_EDGE : RISING_EDGE_DETECTOR PORT MAP(i_CLK => i_CLK, input => i_E0_STEP, output => s_edge_e_step);
    ------- Logic -------------
    x_trojan_proc : process (i_CLK)
    begin
        if rising_edge(i_CLK) then
        

        end if;
    end process;


end Behavioral;