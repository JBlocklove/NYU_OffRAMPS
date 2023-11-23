library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity FALLING_EDGE_DETECTOR is
    Port (
        clk       : in  std_logic;
        input     : in  std_logic;
        output    : out std_logic
    );
end FALLING_EDGE_DETECTOR;

architecture Behavioral of FALLING_EDGE_DETECTOR is
    signal prev_input : std_logic := '0';
begin
    process (clk)
    begin
        if rising_edge(clk) then
            prev_input <= input;
        end if;
        
        -- Falling Edge Detection
        if input = '0' and prev_input = '1' then
            output <= '1';
        else
            output <= '0';
        end if;
    end process;
end Behavioral;