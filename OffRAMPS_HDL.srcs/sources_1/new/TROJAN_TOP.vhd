library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity TROJAN_TOP is
    Port (
        i_CLK               : in  std_logic;
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

    COMPONENT PULSE_GEN
    PORT ( 
        i_CLK           : in  STD_LOGIC;
        i_PULSE_EN      : in  STD_LOGIC;
        i_PULSES_TO_SEND: in  std_logic_vector(4 downto 0);
        o_PULSE_SIG     : out STD_LOGIC;
        o_COMPLETE      : out STD_LOGIC
    );
    END COMPONENT;

    COMPONENT RISING_EDGE_DETECTOR
	PORT(
        i_CLK     : in  STD_LOGIC;
        input     : in  STD_LOGIC;
        output    : out STD_LOGIC
		);
	END COMPONENT;
	   
    -- Edge Detected signals
    signal s_edge_x_step : std_logic := '0';
    signal s_edge_y_step : std_logic := '0';
    signal s_edge_z_step : std_logic := '0';
    signal s_edge_e_step : std_logic := '0';

    -- Pulse Related Signals per Axis
    constant PULSES_PER_STEP : std_logic_vector(5 downto 0) := "10000";  -- 16 pulses per step --> 1.8 degrees (?)
    
    signal X_STEP_MOD : std_logic := '0';
    signal Y_STEP_MOD : std_logic := '0';
    signal Z_STEP_MOD : std_logic := '0';
    signal E_STEP_MOD : std_logic := '0';

    signal X_PULSE_EN : std_logic := '0';
    signal Y_PULSE_EN : std_logic := '0';
    signal Z_PULSE_EN : std_logic := '0';
    signal E_PULSE_EN : std_logic := '0';

    signal X_STEP_COMPLETE : std_logic := '0';
    signal Y_STEP_COMPLETE : std_logic := '0';
    signal Z_STEP_COMPLETE : std_logic := '0';
    signal E_STEP_COMPLETE : std_logic := '0';

    -- Temporarily we will set the enabled trojans here, hardcoded. Vivado will optimize out the unused ones.
    signal TROJ_T1_ENABLE : std_logic := '0'; -- Randomly adds or removes steps from X or Y axis
        
    signal TROJ_T2_ENABLE : std_logic := '0'; -- Constant over / under extrusion per print
    signal TROJ_T3_ENABLE : std_logic := '0'; -- Increases or decreases filament retraction between layers
    signal TROJ_T4_ENABLE : std_logic := '0'; -- Small Shift along X and Y axis on random Z layer increment
    signal TROJ_T5_ENABLE : std_logic := '0'; -- Denial of service via disabling D8/D10 heating element power
    signal TROJ_T6_ENABLE : std_logic := '0'; -- Spoofing of measured hot-end thermocouple temperatures via ADC
    signal TROJ_T7_ENABLE : std_logic := '0'; -- 
    signal TROJ_T8_ENABLE : std_logic := '0'; -- 
    
begin

    ------- Components--------- 
    -- Edge Detectors 
    X_STEP_EDGE : RISING_EDGE_DETECTOR PORT MAP(i_CLK => i_CLK, input => i_X_STEP, output => s_edge_x_step);
    Y_STEP_EDGE : RISING_EDGE_DETECTOR PORT MAP(i_CLK => i_CLK, input => i_Y_STEP, output => s_edge_y_step);
    Z_STEP_EDGE : RISING_EDGE_DETECTOR PORT MAP(i_CLK => i_CLK, input => i_Z_STEP, output => s_edge_z_step);
    E_STEP_EDGE : RISING_EDGE_DETECTOR PORT MAP(i_CLK => i_CLK, input => i_E0_STEP, output => s_edge_e_step);
    
    -- Pulse Generators
    X_PULSE_GEN : PULSE_GEN PORT MAP (i_CLK => i_CLK, i_PULSE_EN => X_PULSE_EN, i_PULSES_TO_SEND => PULSES_PER_STEP, o_PULSE_SIG => X_STEP_MOD, o_COMPLETE => X_STEP_COMPLETE);
    Y_PULSE_GEN : PULSE_GEN PORT MAP (i_CLK => i_CLK, i_PULSE_EN => Y_PULSE_EN, i_PULSES_TO_SEND => PULSES_PER_STEP, o_PULSE_SIG => Y_STEP_MOD, o_COMPLETE => Y_STEP_COMPLETE);
    Z_PULSE_GEN : PULSE_GEN PORT MAP (i_CLK => i_CLK, i_PULSE_EN => Z_PULSE_EN, i_PULSES_TO_SEND => PULSES_PER_STEP, o_PULSE_SIG => Z_STEP_MOD, o_COMPLETE => Z_STEP_COMPLETE);
    E_PULSE_GEN : PULSE_GEN PORT MAP (i_CLK => i_CLK, i_PULSE_EN => E_PULSE_EN, i_PULSES_TO_SEND => PULSES_PER_STEP, o_PULSE_SIG => E_STEP_MOD, o_COMPLETE => E_STEP_COMPLETE);
    


    --------------------------- Pulse Gen Test Start ---------------------------
    -- For testing the output of the pulse gen in trojan mode
    -- This part of the code should countinously move the X axis when bypass mode is turned off 
    -- TODO: Remove this part of the module after test
    o_X_DIR  <= i_X_DIR;  
    o_X_EN   <= i_X_EN;   
    o_X_MIN  <= i_X_MIN;  
    o_X_STEP <= X_STEP_MOD;

    Pulse_Test_proc : process (i_CLK)
    begin
        if rising_edge(i_CLK) then
            X_PULSE_EN <= '1'
        end if;
    end process;
    --------------------------- Pulse Gen Test End ---------------------------
 

    --------------------------- Trojan 1 Logic Start ---------------------------
    -- This trojan adds or removes steps form the X and Y 
    trojan_t1_proc : process (i_CLK)
    begin
        if rising_edge(i_CLK) then
            if (TROJ_T1_ENABLE = '1') then
            
            end if;
        end if;
    end process;
    --------------------------- Trojan 1 Logic End ---------------------------



end Behavioral;
