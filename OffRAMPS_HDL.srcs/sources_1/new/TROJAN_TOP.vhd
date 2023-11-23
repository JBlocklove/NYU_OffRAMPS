library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity TROJAN_TOP is
    Port (
        clk                 : in  std_logic;
        enable_x_troj       : in  std_logic;
        enable_y_troj       : in  std_logic;
        enable_z_troj       : in  std_logic;
        homing_complete     : in  std_logic;
        
        -- Data Signals In
        i_E0_DIR    : in std_logic;
        i_E0_EN     : in std_logic;
        i_E0_STEP   : in std_logic;
        
        i_X_DIR     : in std_logic;  -- X Direction input
        i_X_EN      : in std_logic;  -- X Enable input
        i_X_MIN     : in std_logic;  -- X Min input
        i_X_STEP    : in std_logic;  -- X Step input  
        
        i_Y_DIR     : in std_logic;  -- Y Direction input
        i_Y_EN      : in std_logic;  -- Y Enable input
        i_Y_MIN     : in std_logic;  -- Y Min input
        i_Y_STEP    : in std_logic;  -- Y Step input
        
        i_Z_DIR     : in std_logic;  -- Z Direction input
        i_Z_EN      : in std_logic;  -- Z Enable input
        i_Z_MIN     : in std_logic;  -- Z Min input
        i_Z_STEP    : in std_logic;  -- Z Step input

        -- Data Signals Out
        o_E0_DIR    : out std_logic;
        o_E0_EN     : out std_logic;
        o_E0_STEP   : out std_logic;
        
        o_X_DIR     : out std_logic; --X_DIR  output
        o_X_EN      : out std_logic; --X_EN   output
        o_X_MIN     : out std_logic; --X_MIN  output
        o_X_STEP    : out std_logic; --X_STEP output
        
        o_Y_DIR     : out std_logic; --Y_DIR  output
        o_Y_EN      : out std_logic; --Y_EN   output
        o_Y_MIN     : out std_logic; --Y_MIN  output
        o_Y_STEP    : out std_logic; --Y_STEP output
        
        o_Z_DIR     : out std_logic; --Z_DIR  output
        o_Z_EN      : out std_logic; --Z_EN   output
        o_Z_MIN     : out std_logic; --Z_MIN  output
        o_Z_STEP    : out std_logic  --Z_STEP output
    );
end TROJAN_TOP;

architecture Behavioral of Trojan_TOP is
    signal step_count : integer := 0;
    
    -- Edge Detected signals
    signal s_edge_e_step : std_logic := '0';
    signal s_edge_x_step : std_logic := '0';
    signal s_edge_y_step : std_logic := '0';
    signal s_edge_z_step : std_logic := '0';
    
    COMPONENT RISING_EDGE_DETECTOR
	PORT(
        clk       : in  std_logic;
        input     : in  std_logic;
        output    : out std_logic
		);
	END COMPONENT;
    
begin

    ------- Components--------- 
    E_STEP_EDGE : RISING_EDGE_DETECTOR PORT MAP(
    clk    => clk,
    input  => i_E0_STEP,
    output => s_edge_e_step    );
    
    X_STEP_EDGE : RISING_EDGE_DETECTOR PORT MAP(
    clk    => clk,
    input  => i_X_STEP,
    output => s_edge_x_step    );
    
    Y_STEP_EDGE : RISING_EDGE_DETECTOR PORT MAP(
    clk    => clk,
    input  => i_Y_STEP,
    output => s_edge_y_step    );
    
    Z_STEP_EDGE : RISING_EDGE_DETECTOR PORT MAP(
    clk    => clk,
    input  => i_Z_STEP,
    output => s_edge_z_step    );



    ------- Logic -------------
    x_trojan_proc : process (clk)
    begin
        if rising_edge(clk) then
        

        end if;
    end process;


end Behavioral;