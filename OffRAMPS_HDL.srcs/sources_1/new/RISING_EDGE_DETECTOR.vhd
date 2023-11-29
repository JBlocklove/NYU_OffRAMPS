library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity RISING_EDGE_DETECTOR is
    Port (
        clk       : in  std_logic;
        input     : in  std_logic;
        output    : out std_logic
    );
end RISING_EDGE_DETECTOR;

architecture Behavioral of RISING_EDGE_DETECTOR is
    signal prev_input : std_logic := '0';
begin
    process (clk)
    begin
        if rising_edge(clk) then
            prev_input <= input;
        end if;
        
        -- Rising Edge Detection
        if input = '1' and prev_input = '0' then
            output <= '1';
        else
            output <= '0';
        end if;
    end process;
end Behavioral;