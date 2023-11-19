library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Z_Step_Mod is
    Port (
        clk                 : in  std_logic;
        enable              : in  std_logic;
        homing_complete     : in  std_logic;
        z_step              : in  std_logic;
        z_step_modified     : out std_logic
    );
end Z_Step_Mod;

architecture Behavioral of Z_Step_Mod is
    signal step_count : integer := 0;
    signal zedge : std_logic := '0';
    
    COMPONENT EDGE_DETECTOR
	PORT(
        clk              : in  std_logic;
        input_signal     : in  std_logic;
        edge_control     : in  std_logic; -- '0' for falling edge, '1' for rising edge
        edge_detected    : out std_logic
		);
	END COMPONENT;
    
begin

    edge_detect_z : EDGE_DETECTOR PORT MAP(
    clk           => clk,
    input_signal  => z_step,
    edge_control  => '1',
    edge_detected => zedge
    );

    process (clk)
    begin
        if enable = '1' and homing_complete = '1' then
            if zedge = '1' then
                step_count <= step_count + 1;
                if step_count = 10 then
                    z_step_modified <= '1';
                    step_count <= 0;
                else
                    z_step_modified <= '0';
                end if;
            else
                z_step_modified <= '0';
            end if;
        else
            z_step_modified <= '0';
            step_count <= 0;
        end if;
    end process;
end Behavioral;