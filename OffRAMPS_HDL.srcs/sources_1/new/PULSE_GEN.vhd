library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity PULSE_GEN is
    Port ( 
            i_CLK       : in STD_LOGIC;
            i_PULSE_EN  : in STD_LOGIC;
            o_PULSE_SIG : out STD_LOGIC;
            o_COMPLETE  : out STD_LOGIC;
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

signal TIMER_COUNTER : std_logic_vector(13 downto 0) 
signal TIMER_ENABLE : std_logic;

begin

    enable_proc : process (i_CLK)
    begin
        if rising_edge(i_CLK) then
            if (i_PULSE_EN = '1') then
                count_en = 1


            else


                
            end if;
        end if;
    end process;


    counter_proc : process (i_CLK)
    begin
        if rising_edge(i_CLK) then
            if (i_PULSE_EN = '1') then
                TIMER_ENABLE = '1'


            else
                TIMER_ENABLE = '0'                


                
            end if;
        end if;
    end process;

    pulse_proc : process (i_CLK)
    begin
        if rising_edge(i_CLK) then
            if (i_PULSE_EN = '1') then
                count_en = 1


            else


                
            end if;
        end if;
    end process;


end Behavioral;
