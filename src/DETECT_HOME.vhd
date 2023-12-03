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
    type State_Type is (WAIT_X, WAIT_Y, WAIT_Z1, WAIT_Z2, COMPLETE);
    signal state, next_state : State_Type := WAIT_X;
    signal s_homing_complete : std_logic :='0';
    
    signal Z_MIN_EDGE : std_logic := '0';

    COMPONENT RISING_EDGE_DETECTOR
	PORT(
        clk     : in  STD_LOGIC;
        input     : in  STD_LOGIC;
        output    : out STD_LOGIC
		);
	END COMPONENT;
	
begin

    Z_STEP_EDGE_DETECT : RISING_EDGE_DETECTOR PORT MAP(clk => i_CLK, input => i_Z_MIN,  output => Z_MIN_EDGE);
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
                        next_state <= WAIT_Z1;

                    else
                        next_state <= WAIT_Y;
                    end if;
                    
                when WAIT_Z1 =>
                    if Z_MIN_EDGE = '1' then
                        next_state <= WAIT_Z2;
                    else
                        next_state <= WAIT_Z1;
                    end if;

                when WAIT_Z2 =>
                    if Z_MIN_EDGE = '1' then
                        next_state <= COMPLETE;
                    else
                        next_state <= WAIT_Z2;
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
