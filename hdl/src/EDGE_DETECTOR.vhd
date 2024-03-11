library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Dual rising/falling edge detector
entity EDGE_DETECTOR is
    Port (
        i_clk       : in  std_logic;
        i_input     : in  std_logic;
        o_rising    : out std_logic;
        o_falling	: out std_logic
    );
end EDGE_DETECTOR;

architecture Behavioral of EDGE_DETECTOR is
    signal reg_inputs : std_logic_vector(1 downto 0) := "00";
begin

	-- Register input signal
	reg_proc : process (i_clk)
	begin
		if rising_edge(i_clk) then
			reg_inputs <= (reg_inputs(0) & i_input);
		end if;
	end process;

	o_rising <= reg_inputs(0) and not reg_inputs(1);
	o_falling <= not reg_inputs(0) and reg_inputs(1);

end Behavioral;
