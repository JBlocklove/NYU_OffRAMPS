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

    signal x_press_count : integer := 0;
    signal y_press_count : integer := 0;
    signal z_press_count : integer := 0;

    
    COMPONENT FALLING_EDGE_DETECTOR
	PORT(
        clk       : in  std_logic;
        input     : in  std_logic;
        output    : out std_logic
		);
	END COMPONENT;

    -- Edge detection signals
    signal s_x_min_edge, s_y_min_edge, s_z_min_edge : std_logic := '0';

begin

    X_MIN_EDGE : FALLING_EDGE_DETECTOR PORT MAP(clk => i_CLK, input => i_X_MIN, output => s_x_min_edge);
    Y_MIN_EDGE : FALLING_EDGE_DETECTOR PORT MAP(clk => i_CLK, input => i_Y_MIN, output => s_y_min_edge);
    Z_MIN_EDGE : FALLING_EDGE_DETECTOR PORT MAP(clk => i_CLK, input => i_Z_MIN, output => s_z_min_edge);


    -- State machine for handling the homing sequence
    process(i_CLK)
    begin
        if rising_edge(i_CLK) then
            case state is
                when WAIT_X =>
                    if s_x_min_edge = '1' then
                        x_press_count <= x_press_count + 1;
                        if x_press_count = 2 then
                            next_state <= WAIT_Y;
                            x_press_count <= 0;  -- Reset the press count for next use
                        else
                            next_state <= WAIT_X;
                        end if;
                    end if;

                when WAIT_Y =>
                    if s_y_min_edge = '1' then
                        y_press_count <= y_press_count + 1;
                        if y_press_count = 2 then
                            next_state <= WAIT_Z;
                            y_press_count <= 0;  -- Reset the press count for next use
                        else
                            next_state <= WAIT_Y;
                        end if;
                    end if;

                when WAIT_Z =>
                    if s_z_min_edge = '1' then
                        z_press_count <= z_press_count + 1;
                        if z_press_count = 2 then
                            next_state <= COMPLETE;
                            z_press_count <= 0;  -- Reset the press count for next use
                        else
                            next_state <= WAIT_Z;
                        end if;
                    end if;

                when COMPLETE =>
                    o_homing_complete <= '1';
                    next_state <= COMPLETE;
                when others =>
                    next_state <= WAIT_X;
            end case;
            state <= next_state;
        end if;
    end process;

end Behavioral;
