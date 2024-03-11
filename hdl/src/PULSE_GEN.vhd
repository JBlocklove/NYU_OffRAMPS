
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Module to generate stepper motor pulses
entity PULSE_GEN is
    Port (
            i_CLK           : in  STD_LOGIC;
            i_PULSE_EN      : in  STD_LOGIC;
            i_PULSES_TO_SEND: in  std_logic_vector(4 downto 0);
            o_PULSE_SIG     : out STD_LOGIC;
            o_COMPLETE      : out STD_LOGIC
            );
end PULSE_GEN;

architecture Behavioral of PULSE_GEN is

    constant PULSE_WIDTH : std_logic_vector(6 downto 0) := "1100100";
    constant PULSE_PERIOD : std_logic_vector(13 downto 0) := "11110011110000";

    signal TIMER_COUNTER : std_logic_vector(13 downto 0) := (others=>'0');
    signal PULSE_COUNT : std_logic_vector (4 downto 0) := (others=>'0');

    type STATE_TYPE is (IDLE, PULSE_HIGH, PULSE_LOW, COMPLETE);
    signal current_state, next_state : STATE_TYPE := IDLE;

begin

    -- State Machine Logic
    state_machine: process(i_CLK)
    begin
        if rising_edge(i_CLK) then
            case current_state is
                when IDLE =>
                    if i_PULSE_EN = '1' then
                        next_state <= PULSE_HIGH;
                        TIMER_COUNTER <= (others=>'0');
                    end if;

                when PULSE_HIGH =>
                    if TIMER_COUNTER = PULSE_WIDTH then
                        next_state <= PULSE_LOW;
                        TIMER_COUNTER <= (others=>'0');
                    else
                        TIMER_COUNTER <= TIMER_COUNTER + 1;
                    end if;

                when PULSE_LOW =>
                    if TIMER_COUNTER = PULSE_PERIOD then
                        if PULSE_COUNT = i_PULSES_TO_SEND then
                            next_state <= COMPLETE;
                        else
                            next_state <= PULSE_HIGH;
                        end if;
                        PULSE_COUNT <= PULSE_COUNT + 1;
                        TIMER_COUNTER <= (others=>'0');
                    else
                        TIMER_COUNTER <= TIMER_COUNTER + 1;
                    end if;

                when COMPLETE =>
                    next_state <= IDLE;
                    PULSE_COUNT <= (others=>'0');

            end case;
        end if;
    end process;

    -- State Transitions
    transition_logic: process(i_CLK)
    begin
        if rising_edge(i_CLK) then
            current_state <= next_state;
        end if;
    end process;

    -- Output Logic
    output_logic: process(current_state)
    begin
        case current_state is
            when IDLE =>
                o_PULSE_SIG <= '0';
                o_COMPLETE <= '0';

            when PULSE_HIGH =>
                o_PULSE_SIG <= '1';
                o_COMPLETE <= '0';

            when PULSE_LOW =>
                o_PULSE_SIG <= '0';
                o_COMPLETE <= '0';

            when COMPLETE =>
                o_PULSE_SIG <= '0';
                o_COMPLETE <= '1';

        end case;
    end process;

end Behavioral;
