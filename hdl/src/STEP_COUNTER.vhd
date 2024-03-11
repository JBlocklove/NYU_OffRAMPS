library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Module to count steps on each motor. Increasing when the motors move in a positive direction, decreasing when moving in a negative direction.
entity STEP_COUNTER is
    Port (
			i_CLK 			: in  STD_LOGIC;
		   	i_RST			: in  STD_LOGIC;
		   	i_HOMED			: in  STD_LOGIC;
		   	i_X_STEP		: in  STD_LOGIC;
			i_X_DIR			: in  STD_LOGIC;
		   	i_Y_STEP		: in  STD_LOGIC;
			i_Y_DIR			: in  STD_LOGIC;
		   	i_Z_STEP		: in  STD_LOGIC;
			i_Z_DIR			: in  STD_LOGIC;
		   	i_E_STEP		: in  STD_LOGIC;
			i_E_DIR			: in  STD_LOGIC;
			o_X_STEPS		: out STD_LOGIC_VECTOR(31 downto 0);
			o_Y_STEPS		: out STD_LOGIC_VECTOR(31 downto 0);
			o_Z_STEPS		: out STD_LOGIC_VECTOR(31 downto 0);
			o_E_STEPS		: out STD_LOGIC_VECTOR(31 downto 0);
			o_STEP			: out STD_LOGIC
		  );
end STEP_COUNTER;

architecture Behavioral of STEP_COUNTER is

component EDGE_DETECTOR is
    Port (
        i_clk       : in  std_logic;
        i_input     : in  std_logic;
        o_rising    : out std_logic;
        o_falling	: out std_logic
    );
end component;

signal s_X_STEP_RE : std_logic := '0';
signal s_Y_STEP_RE : std_logic := '0';
signal s_Z_STEP_RE : std_logic := '0';
signal s_E_STEP_RE : std_logic := '0';

signal s_X_STEP_COUNTER : unsigned(31 downto 0) := (others => '0');
signal s_Y_STEP_COUNTER : unsigned(31 downto 0) := (others => '0');
signal s_Z_STEP_COUNTER : unsigned(31 downto 0) := (others => '0');
signal s_E_STEP_COUNTER : unsigned(31 downto 0) := (others => '0');

begin

	edge_detector_X_STEP : EDGE_DETECTOR
		port map(
			i_clk		=> i_CLK,
			i_input		=> i_X_STEP,
			o_rising	=> s_X_STEP_RE,
			o_falling	=> open
	);

	edge_detector_Y_STEP : EDGE_DETECTOR
		port map(
			i_clk		=> i_CLK,
			i_input		=> i_Y_STEP,
			o_rising	=> s_Y_STEP_RE,
			o_falling	=> open
	);

	edge_detector_Z_STEP : EDGE_DETECTOR
		port map(
			i_clk		=> i_CLK,
			i_input		=> i_Z_STEP,
			o_rising	=> s_Z_STEP_RE,
			o_falling	=> open
	);

	edge_detector_E_STEP : EDGE_DETECTOR
		port map(
			i_clk		=> i_CLK,
			i_input		=> i_E_STEP,
			o_rising	=> s_E_STEP_RE,
			o_falling	=> open
	);


	counting_proc : process(i_RST, i_CLK)
	begin

		if (i_RST = '1') then
			s_X_STEP_COUNTER <= (others => '0');
			s_Y_STEP_COUNTER <= (others => '0');
			s_Z_STEP_COUNTER <= (others => '0');
			s_E_STEP_COUNTER <= (others => '0');
		elsif (rising_edge(i_CLK)) then
			if (i_HOMED = '1') then
				if (s_X_STEP_RE = '1') then
					if (i_X_DIR = '1') then
						s_X_STEP_COUNTER <= s_X_STEP_COUNTER + 1;
					else
						s_X_STEP_COUNTER <= s_X_STEP_COUNTER - 1;
					end if;
				end if;

				if (s_Y_STEP_RE = '1') then
					if (i_Y_DIR = '0') then
						s_Y_STEP_COUNTER <= s_Y_STEP_COUNTER + 1;
					else
						s_Y_STEP_COUNTER <= s_Y_STEP_COUNTER - 1;
					end if;
				end if;

				if (s_Z_STEP_RE = '1') then
					if (i_Z_DIR = '1') then
						s_Z_STEP_COUNTER <= s_Z_STEP_COUNTER + 1;
					else
						s_Z_STEP_COUNTER <= s_Z_STEP_COUNTER - 1;
					end if;
				end if;

				if (s_E_STEP_RE = '1') then
					if (i_E_DIR = '0') then
						s_E_STEP_COUNTER <= s_E_STEP_COUNTER + 1;
					else
						s_E_STEP_COUNTER <= s_E_STEP_COUNTER - 1;
					end if;
				end if;
			end if;
		end if;

	end process;

	o_X_STEPS <= std_logic_vector(s_X_STEP_COUNTER);
	o_Y_STEPS <= std_logic_vector(s_Y_STEP_COUNTER);
	o_Z_STEPS <= std_logic_vector(s_Z_STEP_COUNTER);
	o_E_STEPS <= std_logic_vector(s_E_STEP_COUNTER);

	o_STEP <= s_X_STEP_RE or s_Y_STEP_RE;-- or s_Z_STEP_RE or s_E_STEP_RE;

end Behavioral;

