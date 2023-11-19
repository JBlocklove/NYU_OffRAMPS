library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Edge_Detector is
    Port (
        clk              : in  std_logic;
        input_signal     : in  std_logic;
        edge_control     : in  std_logic; -- '0' for falling edge, '1' for rising edge
        edge_detected    : out std_logic
    );
end Edge_Detector;

architecture Behavioral of Edge_Detector is
    signal prev_input_signal : std_logic := '0';
begin
    process (clk)
    begin
        if rising_edge(clk) then
            prev_input_signal <= input_signal;
        end if;
        
        if edge_control = '1' then
            -- Rising Edge Detection
            if input_signal = '1' and prev_input_signal = '0' then
                edge_detected <= '1';
            else
                edge_detected <= '0';
            end if;
        else
            -- Falling Edge Detection
            if input_signal = '0' and prev_input_signal = '1' then
                edge_detected <= '1';
            else
                edge_detected <= '0';
            end if;
        end if;
    end process;
end Behavioral;