library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity UART_STEP_COUNTER is
	Generic (
		SEND_TIMER : integer := 10000000 -- Frequency to send a transaction (in clock ticks)
	);
    Port (
		-- Control Signals
		i_CLK 			: in  STD_LOGIC;
		i_RST			: in  STD_LOGIC;

		-- Stepper motor signals
		i_X_STEP		: in  STD_LOGIC;
		i_X_DIR			: in  STD_LOGIC;
		i_Y_STEP		: in  STD_LOGIC;
		i_Y_DIR			: in  STD_LOGIC;
		i_Z_STEP		: in  STD_LOGIC;
		i_Z_DIR			: in  STD_LOGIC;
		i_E_STEP		: in  STD_LOGIC;
		i_E_DIR			: in  STD_LOGIC;

		-- Enable
		i_TX_COUNT_EN	: in  STD_LOGIC;

		-- UART output
        o_UART_TXD		: out  STD_LOGIC
	);
end UART_STEP_COUNTER;

architecture Behavioral of UART_STEP_COUNTER is

component UART_TX
Port(
	SEND : in std_logic;
	DATA : in std_logic_vector(7 downto 0);
	CLK : in std_logic;
	READY : out std_logic;
	UART_TX : out std_logic
	);
end component;


component STEP_COUNTER is
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
end component;


-- State Machine Related:
type UART_STATE_TYPE is (RESET, INIT, SEND_BYTE, READY_LOW, WAIT_READY, WAIT_EVENT, EVENT_EXEC);
signal STATE : UART_STATE_TYPE := RESET;

-- This value indictates reset wait time
constant RESET_COUNTER_MAX : std_logic_vector(17 downto 0) := "110000110101000000"; -- 100,000,000 * 0.002 = 200,000 = clk cycles per 2 ms

type BYTE_ARRAY is array (integer range<>) of std_logic_vector(7 downto 0);

-- Array for step counts to send. Each count is 4 bytes. 4 bytes * 4 motors = 16 bytes
--signal STEP_COUNTS : BYTE_ARRAY(0 to 15) := (others=>X"00");
signal STEP_COUNTS : BYTE_ARRAY(0 to 15) := (
    X"41",
    X"42",
    X"43",
    X"44",
    X"45",
    X"46",
    X"47",
    X"48",
    X"49",
    X"4A",
    X"4B",
    X"4C",
    X"4D",
    X"4E",
    X"0A",
    X"0D");
    
constant STEP_COUNTS_LENGTH : natural := 16;

signal X_STEPS, Y_STEPS, Z_STEPS, E_STEPS : std_logic_vector(31 downto 0);

constant SYNC_WORD : BYTE_ARRAY(0 to 3) := (
    X"CA",
    X"FE",
    X"BA",
    X"BE"
);

signal DATA_VALUE : BYTE_ARRAY(0 to (STEP_COUNTS_LENGTH - 1));

signal DATA_LEN : natural;
signal DATA_IDX : natural;

signal RESET_COUNTER : std_logic_vector (17 downto 0) := (others=>'0');

signal TX_ENABLE_LATCH : std_logic := '0';
signal STEP_FOUND : std_logic := '0';
signal FIRST_EDGE : std_logic := '0';
signal SEND_ENABLE : std_logic := '0';


-- UART TX Control Signals
signal uartRdy : std_logic;
signal uartSend : std_logic := '0';
signal uartData : std_logic_vector (7 downto 0):= "00000000";
signal uartTX : std_logic;

-- Set this val to 1 to trigger a uart send
signal EVENT_DET : std_logic := '0';

-- TX counter signals
signal TX_COUNTER : natural := 0;

signal SENT_SYNC : std_logic := '0';

begin

o_UART_TXD <= uartTX;

-- Instance to send a byte of data over a UART line.
UART_TX_CTRL_inst0: UART_TX port map(
		SEND => uartSend,
		DATA => uartData,
		CLK => i_CLK,
		READY => uartRdy,
		UART_TX => uartTX
);

-- Instance to count steps for each motor
STEP_COUNTER_inst0: STEP_COUNTER port map(
		i_CLK => i_CLK,
		i_RST => i_RST,
		i_HOMED => TX_ENABLE_LATCH,
		i_X_STEP => i_X_STEP,
		i_X_DIR => i_X_DIR,
		i_Y_STEP => i_Y_STEP,
		i_Y_DIR => i_Y_DIR,
		i_Z_STEP => i_Z_STEP,
		i_Z_DIR => i_Z_DIR,
		i_E_STEP => i_E_STEP,
		i_E_DIR => i_E_DIR,
		o_X_STEPS => X_STEPS,
		o_Y_STEPS => Y_STEPS,
		o_Z_STEPS => Z_STEPS,
		o_E_STEPS => E_STEPS,
		o_STEP => STEP_FOUND
);

STEP_COUNTS(0) <= X_STEPS(31 downto 24);
STEP_COUNTS(1) <= X_STEPS(23 downto 16);
STEP_COUNTS(2) <= X_STEPS(15 downto 8);
STEP_COUNTS(3) <= X_STEPS(7 downto 0);

STEP_COUNTS(4) <= Y_STEPS(31 downto 24);
STEP_COUNTS(5) <= Y_STEPS(23 downto 16);
STEP_COUNTS(6) <= Y_STEPS(15 downto 8);
STEP_COUNTS(7) <= Y_STEPS(7 downto 0);

STEP_COUNTS(8) <=  Z_STEPS(31 downto 24);
STEP_COUNTS(9) <=  Z_STEPS(23 downto 16);
STEP_COUNTS(10) <= Z_STEPS(15 downto 8);
STEP_COUNTS(11) <= Z_STEPS(7 downto 0);

STEP_COUNTS(12) <= E_STEPS(31 downto 24);
STEP_COUNTS(13) <= E_STEPS(23 downto 16);
STEP_COUNTS(14) <= E_STEPS(15 downto 8);
STEP_COUNTS(15) <= E_STEPS(7 downto 0);

-- Triggers a TX every SEND_TIMER ticks. Default is 0.001 seconds with a 100MHz clock
tx_timer_proc : process (i_RST, i_CLK)
begin
	if (i_RST = '1') then
		TX_COUNTER <= 0;
		EVENT_DET <= '0';
	elsif (RISING_EDGE(i_CLK)) then
		if (SEND_ENABLE = '1') then
			if (TX_COUNTER >= SEND_TIMER) then
				TX_COUNTER <= 0;
				EVENT_DET <= '1';
			else
				TX_COUNTER <= TX_COUNTER + 1;
			end if;
		else
			TX_COUNTER <= 0;
			EVENT_DET <= '0';
		end if;
	end if;
end process;

next_UART_STATE_process : process (i_RST, i_CLK)
begin
	if (i_RST = '1') then
		STATE <= RESET;
	elsif (RISING_EDGE(i_CLK)) then
		case STATE is
			when RESET =>
				if (RESET_COUNTER = RESET_COUNTER_MAX) then
					STATE <= INIT;
				end if;

			when INIT =>
				STATE <= WAIT_EVENT;

			when SEND_BYTE =>
				STATE <= READY_LOW;

			when READY_LOW =>
				STATE <= WAIT_READY;

			when WAIT_READY =>
				if (uartRdy = '1') then
					if (DATA_LEN = DATA_IDX) then
						STATE <= WAIT_EVENT;
					else
						STATE <= SEND_BYTE;
					end if;
				end if;

			when WAIT_EVENT =>
				if (EVENT_DET = '1') then
					STATE <= EVENT_EXEC;
				end if;

			when EVENT_EXEC =>
				STATE <= SEND_BYTE;

			when others=>
				STATE <= RESET;

		end case;

	end if;
end process;

tx_latch_proc : process(i_RST, i_CLK)
begin

	if(i_RST = '1') then
		TX_ENABLE_LATCH <= '0';
	elsif rising_edge(i_CLK) then
		if(i_TX_COUNT_EN = '1') then
			TX_ENABLE_LATCH <= '1';
		end if;
	end if;
end process;

first_edge_proc : process(i_RST,i_CLK)
begin
	if (i_RST = '1') then
		FIRST_EDGE <= '0';
	elsif rising_edge(i_CLK) then
		if (STEP_FOUND = '1' and i_TX_COUNT_EN = '1') then
			FIRST_EDGE <= '1';
		end if;
	end if;
end process;

send_enable_proc : process(STATE, TX_ENABLE_LATCH)
begin
	
    case STATE is
        when WAIT_EVENT =>
            if(TX_ENABLE_LATCH = '1' and FIRST_EDGE = '1') then
                SEND_ENABLE <= '1';
            else
            	SEND_ENABLE <= '0';
            end if;
        when others =>
            SEND_ENABLE <= '0';
     end case;
end process;

hold_reset_proc : process(i_RST, i_CLK)
begin
	if (i_RST = '1') then
		RESET_COUNTER <= (others=>'0');
	elsif (RISING_EDGE(i_CLK)) then
		if ((RESET_COUNTER = RESET_COUNTER_MAX) or (STATE /= RESET)) then
			RESET_COUNTER <= (others=>'0');
		else
			RESET_COUNTER <= std_logic_vector(unsigned(RESET_COUNTER) + 1);
		end if;
	end if;
end process;

uart_data_load_proc : process (i_RST, i_CLK)
begin
	if (i_RST = '1') then
		DATA_VALUE(0 to 3) <= SYNC_WORD;
		DATA_LEN <= 4;
	elsif (RISING_EDGE(i_CLK)) then
	   DATA_VALUE <= STEP_COUNTS;
	   DATA_LEN <= STEP_COUNTS_LENGTH;
	end if;
end process;

increment_index_proc : process (i_RST, i_CLK)
begin
	if (i_RST = '1') then
		DATA_IDX <= 0;
	elsif (RISING_EDGE(i_CLK)) then
		if (STATE = INIT or STATE = EVENT_EXEC) then
			DATA_IDX <= 0;
		elsif (STATE = SEND_BYTE) then
			DATA_IDX <= DATA_IDX + 1;
		end if;
	end if;
end process;

load_string_to_uart : process (i_RST, i_CLK)
begin
	if (i_RST = '1') then
		uartSend <= '0';
		uartData <= (others=>'0');
	elsif (RISING_EDGE(i_CLK)) then
		if (STATE = SEND_BYTE) then
			uartSend <= '1';
			uartData <= DATA_VALUE(DATA_IDX);
		else
			uartSend <= '0';
		end if;
	end if;
end process;

end Behavioral;
