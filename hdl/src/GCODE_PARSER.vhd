----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07/12/2024 10:09:57 PM
-- Design Name: 
-- Module Name: GCODE_PARSER - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity GCODE_PARSER is
  Port (
    i_clk : in std_logic;
    i_rst : in std_logic;
    
    i_gcode_byte : in std_logic_vector(7 downto 0);
    i_gcode_byte_valid : in std_logic;
    
    o_got_x : out std_logic;
    o_got_y : out std_logic;
    o_got_z : out std_logic;
    
    o_x_val : out std_logic_vector(23 downto 0);
    o_y_val : out std_logic_vector(23 downto 0);
    o_z_val : out std_logic_vector(23 downto 0);
    
    o_gcode_complete : out std_logic
  );
end GCODE_PARSER;

architecture Behavioral of GCODE_PARSER is

type gcode_state_type is (IDLE, CMD_NUM, CTRL_CMD, GET_CMD, AXIS, X_AXIS, Y_AXIS, Z_AXIS, DONE, LATCH_OUTPUT);
signal state, next_state : gcode_state_type;

signal s_gcode_cmd : std_logic_vector(23 downto 0) := X"000000"; -- 3 character shift reg
signal s_xval, s_yval, s_zval : std_logic_vector(39 downto 0) := (others => '0'); -- 7 characters ___.___

constant CHAR_SPACE : std_logic_vector := X"20";
constant CHAR_STAR : std_logic_vector := X"2A";
constant CHAR_PERIOD : std_logic_vector := X"2E";
constant CHAR_N : std_logic_vector(7 downto 0) := X"4E";
constant CHAR_G : std_logic_vector(7 downto 0) := X"47";
constant CHAR_0 : std_logic_vector(7 downto 0) := X"30";
constant CHAR_1 : std_logic_vector(7 downto 0) := X"31";
constant CHAR_2 : std_logic_vector(7 downto 0) := X"32";
constant CHAR_3 : std_logic_vector(7 downto 0) := X"33";
constant CHAR_4 : std_logic_vector(7 downto 0) := X"34";
constant CHAR_5 : std_logic_vector(7 downto 0) := X"35";
constant CHAR_6 : std_logic_vector(7 downto 0) := X"36";
constant CHAR_7 : std_logic_vector(7 downto 0) := X"37";
constant CHAR_8 : std_logic_vector(7 downto 0) := X"38";
constant CHAR_9 : std_logic_vector(7 downto 0) := X"39";
constant CHAR_X : std_logic_vector(7 downto 0) := X"58";
constant CHAR_Y : std_logic_vector(7 downto 0) := X"59";
constant CHAR_Z : std_logic_vector(7 downto 0) := X"5A";

signal x_whole : std_logic_vector(11 downto 0) := X"000";
signal x_frac : std_logic_vector(11 downto 0) := X"000";
signal u_x_frac : unsigned(11 downto 0) := X"000";

signal y_whole : std_logic_vector(11 downto 0) := X"000";
signal y_frac : std_logic_vector(11 downto 0) := X"000";
signal u_y_frac : unsigned(11 downto 0) := X"000";

signal z_whole : std_logic_vector(11 downto 0) := X"000";
signal z_frac : std_logic_vector(11 downto 0) := X"000";
signal u_z_frac : unsigned(11 downto 0) := X"000";

signal got_x : std_logic;
signal got_y : std_logic;
signal got_z : std_logic;

signal got_x_dec : std_logic;
signal got_y_dec : std_logic;
signal got_z_dec : std_logic;

signal x_dec_counter : integer;
signal y_dec_counter : integer;
signal z_dec_counter : integer;

begin

state_change_proc : process (i_clk, i_rst)
begin
    if (i_rst = '1') then
        state <= IDLE;
    elsif (rising_edge(i_clk)) then
        state <= next_state;
    end if;
end process;

next_state_proc : process (all)
begin
    next_state <= state;
        case state is
            when IDLE =>
                if (i_gcode_byte = CHAR_N and i_gcode_byte_valid = '1') then
                    next_state <= CMD_NUM;
                end if;
            ------------------------------------------------------------
            when CMD_NUM =>
                if (i_gcode_byte_valid = '1') then
                    if (i_gcode_byte = CHAR_SPACE) then -- wait for " "
                        next_state <= CTRL_CMD;
                    end if;
                end if;
            ------------------------------------------------------------    
            when CTRL_CMD =>
                if (i_gcode_byte_valid = '1') then
                    if (i_gcode_byte = CHAR_G) then -- wait for "G"
                        next_state <= GET_CMD;
                    else
                        next_state <= IDLE;
                    end if;
                end if;
            ------------------------------------------------------------    
            when GET_CMD =>
                if (i_gcode_byte_valid = '1') then
                    if (i_gcode_byte = CHAR_SPACE) then -- wait for " "
                        if (s_gcode_cmd = X"0000"&CHAR_0 or s_gcode_cmd = X"0000"&CHAR_1) then -- G0 or G1
                            next_state <= AXIS;
                        else
                            next_state <= IDLE;
                        end if;
                    end if;
                end if;
            ------------------------------------------------------------
            when AXIS =>
                if (i_gcode_byte_valid = '1') then
                    case i_gcode_byte is
                        when CHAR_X =>
                            next_state <= X_AXIS;
                        when CHAR_Y =>
                            next_state <= Y_AXIS;
                        when CHAR_Z =>
                            next_state <= Z_AXIS;
                        when CHAR_STAR =>
                            next_state <= DONE;
                        when others =>
                            next_state <= AXIS;
                    end case;
                end if;
            ------------------------------------------------------------
            when X_AXIS => -- next state logic same for X, Y, Z
                if (i_gcode_byte_valid = '1') then
                    if (i_gcode_byte = CHAR_SPACE) then
                        next_state <= AXIS;
                    elsif (i_gcode_byte = CHAR_STAR) then
                        next_state <= DONE;
                    end if;
                end if;
            ------------------------------------------------------------
            when Y_AXIS => -- next state logic same for X, Y, Z
                if (i_gcode_byte_valid = '1') then
                    if (i_gcode_byte = CHAR_SPACE) then
                        next_state <= AXIS;
                    elsif (i_gcode_byte = CHAR_STAR) then
                        next_state <= DONE;
                    end if;
                end if;
            ------------------------------------------------------------
            when Z_AXIS => -- next state logic same for X, Y, Z
                if (i_gcode_byte_valid = '1') then
                    if (i_gcode_byte = CHAR_SPACE) then
                        next_state <= AXIS;
                    elsif (i_gcode_byte = CHAR_STAR) then
                        next_state <= DONE;
                    end if;
                end if;
            ------------------------------------------------------------   
            when DONE =>
                    next_state <= LATCH_OUTPUT;
            ------------------------------------------------------------
            when LATCH_OUTPUT =>
                    next_state <= IDLE;
            ------------------------------------------------------------
            when OTHERS => next_state <= IDLE;
        end case;
    
end process;

gcode_cmd_proc : process (i_clk, i_rst) begin
    if (i_rst = '1') then
        s_gcode_cmd <= X"000000";
    elsif (rising_edge(i_clk)) then
        if (state = IDLE) then
            s_gcode_cmd <= x"000000";
        elsif (i_gcode_byte_valid = '1' and state = GET_CMD) then
            s_gcode_cmd <= s_gcode_cmd(15 downto 0) & i_gcode_byte;
        end if;
    end if;
end process;

got_val_proc : process (i_clk) begin
    if (rising_edge(i_clk)) then
        if (state = IDLE) then
            o_got_x <= '0';
            o_got_y <= '0';
            o_got_z <= '0';
        elsif (state = X_AXIS) then
            o_got_x <= '1';
        elsif (state = Y_AXIS) then
            o_got_y <= '1';
        elsif (state = Z_AXIS) then
            o_got_z <= '1';
        end if;
    end if;
end process;

x_axis_proc : process (i_clk, i_rst) begin
    if (i_rst = '1') then
        x_whole <= X"000";
        x_frac <= X"000";
        got_x_dec <= '0';
        x_dec_counter <= 0;
    elsif (rising_edge(i_clk)) then
        if (state = IDLE) then
            x_whole <= X"000";
            x_frac <= X"000";
            got_x_dec <= '0';
            x_dec_counter <= 0;
        elsif (state = X_AXIS) then
            if (i_gcode_byte_valid = '1') then
                if (i_gcode_byte = CHAR_PERIOD) then
                    got_x_dec <= '1';
                elsif (i_gcode_byte >= CHAR_0 and i_gcode_byte <= CHAR_9) then
                    if (got_x_dec = '0') then
                        x_whole <= x_whole(7 downto 0) & i_gcode_byte(3 downto 0);
                    elsif (got_x_dec = '1' and x_dec_counter < 3) then
                        x_frac <= x_frac(7 downto 0) & i_gcode_byte(3 downto 0);
                        x_dec_counter <= x_dec_counter + 1;
                    end if;
                end if;
            end if;
        end if;
    end if;
end process;

y_axis_proc : process (i_clk, i_rst) begin
    if (i_rst = '1') then
        y_whole <= X"000";
        y_frac <= X"000";
        got_y_dec <= '0';
        y_dec_counter <= 0;
    elsif (rising_edge(i_clk)) then
        if (state = IDLE) then
            y_whole <= X"000";
            y_frac <= X"000";
            got_y_dec <= '0';
            y_dec_counter <= 0;
        elsif (state = Y_AXIS) then
            if (i_gcode_byte_valid = '1') then
                if (i_gcode_byte = CHAR_PERIOD) then
                    got_y_dec <= '1';
                elsif (i_gcode_byte >= CHAR_0 and i_gcode_byte <= CHAR_9) then
                    if (got_y_dec = '0') then
                        y_whole <= y_whole(7 downto 0) & i_gcode_byte(3 downto 0);
                    elsif (got_y_dec = '1' and y_dec_counter < 3) then
                        y_frac <= y_frac(7 downto 0) & i_gcode_byte(3 downto 0);
                        y_dec_counter <= y_dec_counter + 1;
                    end if;
                end if;
            end if;
        end if;
    end if;
end process;

z_axis_proc : process (i_clk, i_rst) begin
    if (i_rst = '1') then
        z_whole <= X"000";
        z_frac <= X"000";
        got_z_dec <= '0';
        z_dec_counter <= 0;
    elsif (rising_edge(i_clk)) then
        if (state = IDLE) then
            z_whole <= X"000";
            z_frac <= X"000";
            got_z_dec <= '0';
            z_dec_counter <= 0;
        elsif (state = Z_AXIS) then
            if (i_gcode_byte_valid = '1') then
                if (i_gcode_byte = CHAR_PERIOD) then
                    got_z_dec <= '1';
                elsif (i_gcode_byte >= CHAR_0 and i_gcode_byte <= CHAR_9) then
                    if (got_z_dec = '0') then
                        z_whole <= z_whole(7 downto 0) & i_gcode_byte(3 downto 0);
                    elsif (got_z_dec = '1' and z_dec_counter < 3) then
                        z_frac <= z_frac(7 downto 0) & i_gcode_byte(3 downto 0);
                        z_dec_counter <= z_dec_counter + 1;
                    end if;
                end if;
            end if;
        end if;
    end if;
end process;

frac_cleanup_proc : process (i_clk) begin
    if (rising_edge(i_clk)) then
        if (state = DONE) then
            u_x_frac <= shift_left(unsigned(x_frac),(4*(3-x_dec_counter)));
            u_y_frac <= shift_left(unsigned(y_frac),(4*(3-y_dec_counter)));
            u_z_frac <= shift_left(unsigned(z_frac),(4*(3-z_dec_counter)));
        end if;
    end if;
end process;

output_proc : process (i_clk) begin
    if (rising_edge(i_clk)) then
        if (state = LATCH_OUTPUT) then
            o_x_val <= x_whole & std_logic_vector(u_x_frac);
            o_y_val <= y_whole & std_logic_vector(u_y_frac);
            o_z_val <= z_whole & std_logic_vector(u_z_frac);
        end if;
    end if;
end process;

gcode_complete_proc : process (i_rst, i_clk) begin
    if (i_rst = '1') then
        o_gcode_complete <= '0';
    elsif (rising_edge(i_clk)) then
        if (state = LATCH_OUTPUT) then
            o_gcode_complete <= '1';
        elsif (state = CMD_NUM) then
            o_gcode_complete <= '0';
        end if;
    end if;
end process;


end Behavioral;
