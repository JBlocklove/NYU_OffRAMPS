library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity PULSE_GEN is
    Port ( 
            i_CLK       : in STD_LOGIC;
            i_PULSE_EN  : in STD_LOGIC;
            o_PULSE_SIG : out STD_LOGIC;
            o_COMPLETE  : out STD_LOGIC
            );
end PULSE_GEN;

architecture Behavioral of PULSE_GEN is

constant PULSE_WIDTH : std_logic_vector(6 downto 0) := "1100100"; -- 1 us --> 1000 ns --> 100 cycles @ 100 Mhz
constant PULSE_DIST : std_logic_vector(13 downto 0) := "11110010001100"; -- 155 us --> 155000 ns --> 15500 cycles @ 100 Mhz
constant PULSE_PERIOD : std_logic_vector(13 downto 0) := "11110011110000"; --156 us

-- Here, Pulse width is the High pulse width and Pulse dist is the distance between
-- Consecutive Pulses as shown:
--     _______________
-- -->|  Pulse width  |______________________|<--- 1 Period
--    |               |<-----Pulse Dist----->|

signal TIMER_COUNTER : std_logic_vector(13 downto 0) := (others=>'0');
signal TIMER_ENABLE : std_logic;

signal COMPLETE_BUFFER : std_logic := '0';
signal PULSE_BUFFER : std_logic:= '0';

begin

    o_PULSE_SIG <= PULSE_BUFFER;
    o_COMPLETE <= COMPLETE_BUFFER;

    enable_proc : process (i_CLK)
    begin
        if rising_edge(i_CLK) then
            if (i_PULSE_EN = '1') then
                TIMER_ENABLE <= '1';
            else
                TIMER_ENABLE <= '0';
            end if;
        end if;
    end process;


    counter_proc : process (i_CLK)
    begin
        if rising_edge(i_CLK) then
            if (TIMER_ENABLE = '1' and COMPLETE_BUFFER = '0') then
                TIMER_COUNTER <= TIMER_COUNTER + 1;
            elsif (TIMER_ENABLE = '1' and COMPLETE_BUFFER = '1') then
                TIMER_COUNTER <= '1';
            else              
                TIMER_COUNTER <= (others=>'0'); 
            end if;
        end if;
    end process;


    pulse_proc : process (i_CLK)
    begin
        if rising_edge(i_CLK) then
            if (TIMER_COUNTER = '1') then
                COMPLETE_BUFFER <= '0';
                PULSE_BUFFER <= '1';
            elsif (TIMER_COUNTER = PULSE_WIDTH) then 
                COMPLETE_BUFFER <= '0';
                PULSE_BUFFER <= '0'
            elsif (TIMER_COUNTER = PULSE_PERIOD) then
                COMPLETE_BUFFER <= '1';
                PULSE_BUFFER <= '0'
            else 
                COMPLETE_BUFFER <= COMPLETE_BUFFER;
                PULSE_BUFFER <= PULSE_BUFFER;
            end if;
        end if;
    end process;


end Behavioral;
