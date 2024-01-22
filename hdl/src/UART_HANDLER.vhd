library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

use IEEE.std_logic_unsigned.all;

entity UART_HANDLER is
    Port ( 
           i_CLK 			: in  STD_LOGIC;
           o_UART_TXD 	: out  STD_LOGIC
		  );
end UART_HANDLER;

architecture Behavioral of UART_HANDLER is

component UART_TX
Port(
	SEND : in std_logic;
	DATA : in std_logic_vector(7 downto 0);
	CLK : in std_logic;          
	READY : out std_logic;
	UART_TX : out std_logic
	);
end component;

-- State Machine Related:
type UART_STATE_TYPE is (RESET, INIT, SEND_CHAR, RDY_LOW, WAIT_RDY, WAIT_EVENT, EVENT_EXEC);
signal STATE : UART_STATE_TYPE := RESET;

-- This value indictates reset wait time
constant RESET_COUNTER_MAX : std_logic_vector(17 downto 0) := "110000110101000000";-- 100,000,000 * 0.002 = 200,000 = clk cycles per 2 ms
constant ONE_SECOND : std_logic_vector(26 downto 0) := "101111101011110000100000000";


type CHAR_ARRAY is array (integer range<>) of std_logic_vector(7 downto 0);
constant MAX_BIT_LEN : integer := 31;
constant WELCOME_STR_LEN : natural := 31;
constant BUTTON_STR_LEN : natural := 24;

constant WELCOME_STR : CHAR_ARRAY(0 to 30) := (X"0A",  --\n
															  X"0D",  --\r
															  X"43",  --C
															  X"4D",  --M
															  X"4F",  --O
															  X"44",  --D
															  X"20",  -- 
															  X"41",  --A
															  X"37",  --7
                                                              X"20",  -- 
                                                              X"47",  --G
                                                              X"50",  --P 
															  X"49",  --I
															  X"4F",  --O
															  X"2F",  --/
															  X"55",  --U
															  X"41",  --A
															  X"52",  --R
															  X"54",  --T
															  X"20",  -- 
															  X"44",  --D
															  X"45",  --E
															  X"4D",  --M
															  X"4F",  --O
															  X"21",  --!
															  X"20",  -- 
															  X"20",  -- 
															  X"20",  -- 
															  X"0A",  --\n
															  X"0A",  --\n
															  X"0D"); --\r
															  
--Button press string definition.
constant BTN_STR : CHAR_ARRAY(0 to 23) :=     (X"42",  --B
															  X"75",  --u
															  X"74",  --t
															  X"74",  --t
															  X"6F",  --o
															  X"6E",  --n
															  X"20",  -- 
															  X"70",  --p
															  X"72",  --r
															  X"65",  --e
															  X"73",  --s
															  X"73",  --s
															  X"20",  --
															  X"64",  --d
															  X"65",  --e
															  X"74",  --t
															  X"65",  --e
															  X"63",  --c
															  X"74",  --t
															  X"65",  --e
															  X"64",  --d
															  X"21",  --!
															  X"0A",  --\n
															  X"0D"); --\r


signal DATA_VALUE : CHAR_ARRAY(0 to (MAX_BIT_LEN - 1));
signal DATA_LEN : natural;
signal DATA_IDX : natural;

signal RESET_COUNTER : std_logic_vector (17 downto 0) := (others=>'0');


-- UART TX Control Signals
signal uartRdy : std_logic;
signal uartSend : std_logic := '0';
signal uartData : std_logic_vector (7 downto 0):= "00000000";
signal uartTX : std_logic;

-- Set this val to 1 to trigger a uart send
signal EVENT_DET : std_logic := '0';

-- EXample counter related
signal EXAMPLE_COUNTER : std_logic_vector (26 downto 0) := (others=>'0');
signal EXAMPLE_COUNT_EN : std_logic := '0';

begin

o_UART_TXD <= uartTX;

--Component used to send a byte of data over a UART line.
Inst_UART_TX_CTRL: UART_TX port map(
		SEND => uartSend,
		DATA => uartData,
		CLK => i_CLK,
		READY => uartRdy,
		UART_TX => uartTX 
	);


example_counter_proc : process (i_CLK)
begin
	if (RISING_EDGE(i_CLK)) then
		if(EXAMPLE_COUNT_EN = '1') then
			if(EXAMPLE_COUNTER = ONE_SECOND) then
				EXAMPLE_COUNTER <= (others=>'0');
				EVENT_DET <= '1';
			else
				EXAMPLE_COUNTER <= EXAMPLE_COUNTER + 1;
			end if;
		else
			EVENT_DET <= '0';
			EXAMPLE_COUNTER <= (others=>'0');
		end if;
	end if;
end process;

next_UART_STATE_process : process (i_CLK)
begin
	if (RISING_EDGE(i_CLK)) then
			
		case STATE is 
			when RESET =>
				if (RESET_COUNTER = RESET_COUNTER_MAX) then
					STATE <= INIT;
				end if;

			when INIT =>
				STATE <= SEND_CHAR;

			when SEND_CHAR =>
				STATE <= RDY_LOW;

			when RDY_LOW =>
				STATE <= WAIT_RDY;

			when WAIT_RDY =>
				if (uartRdy = '1') then
					if (DATA_LEN = DATA_IDX) then
						STATE <= WAIT_EVENT;
					else
						STATE <= SEND_CHAR;
					end if;
				end if;
				
			when WAIT_EVENT =>
				EXAMPLE_COUNT_EN <= '1';
				if (EVENT_DET = '1') then
					STATE <= EVENT_EXEC;
				end if;

			when EVENT_EXEC =>
				EXAMPLE_COUNT_EN <= '0';
				STATE <= SEND_CHAR;

			when others=> 
				STATE <= RESET;

		end case;
		
	end if;
end process;

hold_reset_proc : process(i_CLK)
begin
	if (RISING_EDGE(i_CLK)) then
		if ((RESET_COUNTER = RESET_COUNTER_MAX) or (STATE /= RESET)) then
			RESET_COUNTER <= (others=>'0');
		else
			RESET_COUNTER <= RESET_COUNTER + 1;
		end if;
	end if;
end process;

uart_data_load_proc : process (i_CLK)
begin
	if (RISING_EDGE(i_CLK)) then
		if (STATE = INIT) then
			DATA_VALUE <= WELCOME_STR;
			DATA_LEN <= WELCOME_STR_LEN;
		elsif (STATE = EVENT_EXEC) then
			DATA_VALUE(0 to 23) <= BTN_STR;
			DATA_LEN <= BUTTON_STR_LEN;
		end if;
	end if;
end process;

increment_index_proc : process (i_CLK)
begin
	if (RISING_EDGE(i_CLK)) then
		if (STATE = INIT or STATE = EVENT_EXEC) then
			DATA_IDX <= 0;
		elsif (STATE = SEND_CHAR) then
			DATA_IDX <= DATA_IDX + 1;
		end if;
	end if;
end process;

load_string_to_uart : process (i_CLK)
begin
	if (RISING_EDGE(i_CLK)) then
		if (STATE = SEND_CHAR) then
			uartSend <= '1';
			uartData <= DATA_VALUE(DATA_IDX);
		else
			uartSend <= '0';
		end if;
	end if;
end process;



end Behavioral;
