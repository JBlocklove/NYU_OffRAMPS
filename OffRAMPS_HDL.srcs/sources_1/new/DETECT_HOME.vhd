library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity DETECT_HOME is
    Port (
        i_CLK           : in std_logic;
        i_X_STEP        : in std_logic;
        i_Y_STEP        : in std_logic;
        i_Z_STEP        : in std_logic;
        i_X_MIN         : in std_logic;
        i_Y_MIN         : in std_logic;
        i_Z_MIN         : in std_logic;
        o_homing_complete : out std_logic
    );
end DETECT_HOME;

architecture Behavioral of DETECT_HOME is
    type State_Type is (WAIT_X, WAIT_Y, WAIT_Z, COMPLETE);
    signal state, next_state : State_Type := WAIT_X;
    signal s_homing_complete : std_logic :='0';

--    signal x_press_count : integer := 0;
--    signal y_press_count : integer := 0;
--    signal z_press_count : integer := 0;

    
--    COMPONENT FALLING_EDGE_DETECTOR
--	PORT(
--        clk       : in  std_logic;
--        input     : in  std_logic;
--        output    : out std_logic
--		);
--	END COMPONENT;

    -- Edge detection signals
--    signal s_x_min_edge, s_y_min_edge, s_z_min_edge : std_logic := '0';

begin

--    X_MIN_EDGE : FALLING_EDGE_DETECTOR PORT MAP(clk => i_CLK, input => i_X_MIN, output => s_x_min_edge);
--    Y_MIN_EDGE : FALLING_EDGE_DETECTOR PORT MAP(clk => i_CLK, input => i_Y_MIN, output => s_y_min_edge);
--    Z_MIN_EDGE : FALLING_EDGE_DETECTOR PORT MAP(clk => i_CLK, input => i_Z_MIN, output => s_z_min_edge);
    o_homing_complete <= s_homing_complete;
    
    -- State machine for handling the homing sequence
    process(i_CLK)
    begin
        if rising_edge(i_CLK) then
            case state is
                when WAIT_X =>
                    if i_X_MIN = '0' then
                        next_state <= WAIT_Y;
                    else
                        next_state <= WAIT_X;
                    end if;


                when WAIT_Y =>
                    if i_Y_MIN = '0' then
                        next_state <= WAIT_Z;

                    else
                        next_state <= WAIT_Y;
                    end if;
                    
                when WAIT_Z =>
                    if i_Z_MIN = '1' then
                        next_state <= COMPLETE;

                    else
                        next_state <= WAIT_Z;
                    end if;

                when COMPLETE =>
                    s_homing_complete <= '1';
                    next_state <= COMPLETE;
                    
                when others =>
                    next_state <= WAIT_X;
                    
            end case;
            state <= next_state;
        end if;
    end process;

end Behavioral;
