library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity DETECT_HOME is
    Port (
        i_CLK    : in std_logic;
    
        -- Step signals
        i_X_STEP : in std_logic;
        i_Y_STEP : in std_logic;
        i_Z_STEP : in std_logic;

        -- Endstop switches
        i_X_MIN  : in std_logic;
        i_Y_MIN  : in std_logic;
        i_Z_MIN  : in std_logic;

        -- Output signal to signify homing completion
        o_homing_complete : out std_logic
    );
end DETECT_HOME;




architecture Behavioral of DETECT_HOME is
    signal x_homed : std_logic := '0';
    signal y_homed : std_logic := '0';
    signal z_homed : std_logic := '0';
    
--    signal x_step  : std_logic := '0';
--    signal y_step  : std_logic := '0';
--    signal z_step  : std_logic := '0';
    
    
--	COMPONENT EDGE_DETECTOR
--	PORT(
--        clk              : in  std_logic;
--        input_signal     : in  std_logic;
--        edge_control     : in  std_logic; -- '0' for falling edge, '1' for rising edge
--        edge_detected    : out std_logic
--		);
--	END COMPONENT;

begin

-- We need to test if edge detection is actually needed, otherwise just use input signals
-- We will definitly need edge detection if we decide to count the pulses

--    edge_detect_X : EDGE_DETECTOR PORT MAP(
--    clk           => i_CLK,
--    input_signal  => i_X_STEP,
--    edge_control  => '1',
--    edge_detected => x_step
--    );
    
--    edge_detect_Y : EDGE_DETECTOR PORT MAP(
--    clk           => i_CLK,
--    input_signal  => i_Y_STEP,
--    edge_control  => '1',
--    edge_detected => y_step
--    );
    
--    edge_detect_Z : EDGE_DETECTOR PORT MAP(
--    clk           => i_CLK,
--    input_signal  => i_Y_STEP,
--    edge_control  => '1',
--    edge_detected => z_step
--    );

    --- This may be OK, but we may want to do each axis in order Z --> Y --> X in order
    process (i_CLK) is
    begin
        if(rising_edge(i_CLK)) then
        
            if (i_X_STEP = '1' and i_X_MIN = '1') then x_homed <= '1'; end if;
            if (i_Y_STEP = '1' and i_Y_MIN = '1') then y_homed <= '1'; end if;
            if (i_Z_STEP = '1' and i_Z_MIN = '1') then z_homed <= '1'; end if;
            
            if (x_homed = '1' and y_homed = '1' and z_homed = '1') then
                o_homing_complete <= '1';
            else
                o_homing_complete <= '0';
            end if;
            
        end if;
    end process;
    
end Behavioral;