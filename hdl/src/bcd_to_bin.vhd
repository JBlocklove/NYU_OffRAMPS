library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity BCD_to_binary is
	port (
		i_clk : in std_logic;
		i_rst : in std_logic;
		i_ready : in std_logic;
		o_done : out std_logic;

		i_BCD_6_digit : in std_logic_vector(23 downto 0);
		o_binary : out std_logic_vector(19 downto 0)
	);
end entity BCD_to_binary;

architecture behavioral of BCD_to_binary is




--type uarray is array(0 to 5) of unsigned(19 downto 0);
--signal digits_mult : uarray;

type iarray is array(0 to 5) of integer;
signal digits_mult : iarray;

type digitarray is array(0 to 5) of unsigned(3 downto 0);
signal digits : iarray;

-- signal s_sum : unsigned (19 downto 0);
signal s_sum : integer;

signal s_digit_conv_done : std_logic;
signal s_mult_done : std_logic;

begin

	digit_conv_proc : process(i_clk, i_rst)
	begin
		if i_rst = '1' then
--			digits(0) <= (others => '0');
--			digits(1) <= (others => '0');
--			digits(2) <= (others => '0');
--			digits(3) <= (others => '0');
--			digits(4) <= (others => '0');
--			digits(5) <= (others => '0');
			digits(0) <= 0;
			digits(1) <= 0;
			digits(2) <= 0;
			digits(3) <= 0;
			digits(4) <= 0;
			digits(5) <= 0;
		elsif rising_edge(i_clk) then
			if i_ready = '1' then
				digits(0) <= to_integer(unsigned(i_BCD_6_digit(23 downto 20)));
				digits(1) <= to_integer(unsigned(i_BCD_6_digit(19 downto 16)));
				digits(2) <= to_integer(unsigned(i_BCD_6_digit(15 downto 12)));
				digits(3) <= to_integer(unsigned(i_BCD_6_digit(11 downto 8)));
				digits(4) <= to_integer(unsigned(i_BCD_6_digit(7 downto 4)));
				digits(5) <= to_integer(unsigned(i_BCD_6_digit(3 downto 0)));
			end if;
		end if;
	end process;

	
	mult_proc : process(i_clk, i_rst)
	begin
		if i_rst = '1' then
--			digits_mult(0) <= (others => '0');
--			digits_mult(1) <= (others => '0');
--			digits_mult(2) <= (others => '0');
--			digits_mult(3) <= (others => '0');
--			digits_mult(4) <= (others => '0');
--			digits_mult(5) <= (others => '0');
			digits_mult(0) <= 0;
			digits_mult(1) <= 0;
			digits_mult(2) <= 0;
			digits_mult(3) <= 0;
			digits_mult(4) <= 0;
			digits_mult(5) <= 0;
		elsif rising_edge(i_clk) then
		    if s_digit_conv_done = '1' then
                digits_mult(0) <= (digits(0) * 100000);
                digits_mult(1) <= (digits(1) * 10000);
                digits_mult(2) <= (digits(2) * 1000);
                digits_mult(3) <= (digits(3) * 100);
                digits_mult(4) <= (digits(4) * 10);
                digits_mult(5) <= (digits(5) * 1);

		    end if;
		end if;
	end process;

	sum_proc : process(i_clk, i_rst)
	begin
		if i_rst = '1' then
			s_sum <= 0;
		elsif rising_edge(i_clk) then
		    if s_mult_done = '1' then
			    s_sum <= (digits_mult(0) + digits_mult(1) + digits_mult(2) + digits_mult(3) + digits_mult(4) + digits_mult(5));
			end if;
		end if;
	end process;
	
	o_binary <= std_logic_vector(to_unsigned(s_sum,20));

    done_proc : process(i_clk, i_rst)
	begin
		if i_rst = '1' then
			s_digit_conv_done <= '0';
			s_mult_done <= '0';
			o_done <= '0';
		elsif rising_edge(i_clk) then
			s_digit_conv_done <= i_ready;
			s_mult_done <= s_digit_conv_done;
			o_done <= s_mult_done;
		end if;
	end process;
    

	-- binary <= std_logic_vector(digits(0) * 100000 + digits(1) * 10000 + digits(2) * 1000 + digits(3) * 100 + digits(4) * 10 + digits(5));

end behavioral;
