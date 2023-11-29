library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity UART_HANDLER is
    Port (
        user_clk : in STD_LOGIC; -- Assuming a common clock for both modules
        rst_n : in STD_LOGIC;
        start_tx : in STD_LOGIC;
        tx_data : in STD_LOGIC_VECTOR(7 downto 0);
        rx : in STD_LOGIC;
        tx_bit : out STD_LOGIC;
        tx_ready : out STD_LOGIC;
        rx_valid : out STD_LOGIC;
        rx_data : out STD_LOGIC_VECTOR(7 downto 0)
    );
end UART_HANDLER;

architecture Behavioral of UART_HANDLER is
    -- Component declaration for uart_tx
    component uart_tx
        port(
            user_clk : in STD_LOGIC;
            rst_n : in STD_LOGIC;
            start_tx : in STD_LOGIC;
            data : in STD_LOGIC_VECTOR(7 downto 0);
            tx_bit : out STD_LOGIC;
            ready : out STD_LOGIC;
            chipscope_clk : out STD_LOGIC
        );
    end component;

    -- Component declaration for uart_rx
    component uart_rx
        port(
            clk : in STD_LOGIC;
            rst_n : in STD_LOGIC;
            rx : in STD_LOGIC;
            valid : out STD_LOGIC;
            data : out STD_LOGIC_VECTOR(7 downto 0)
        );
    end component;

    -- Signals for internal connections
    signal internal_tx_bit, internal_ready, internal_valid : STD_LOGIC;
    signal internal_rx_data, internal_tx_data : STD_LOGIC_VECTOR(7 downto 0);

begin
    -- Instantiate uart_tx
    uart_tx_inst : uart_tx
        port map (
            user_clk => user_clk,
            rst_n => rst_n,
            start_tx => start_tx,
            data => tx_data,
            tx_bit => internal_tx_bit,
            ready => internal_ready,
            chipscope_clk => open  -- If not used, map to 'open'
        );

    -- Instantiate uart_rx
    uart_rx_inst : uart_rx
        port map (
            clk => user_clk,  -- Assuming the same clock
            rst_n => rst_n,
            rx => rx,
            valid => internal_valid,
            data => internal_rx_data
        );

    -- Map internal signals to outputs
    tx_bit <= internal_tx_bit;
    tx_ready <= internal_ready;
    rx_valid <= internal_valid;
    rx_data <= internal_rx_data;

end Behavioral;
