library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;

entity elevate is
		port(
		  clk : in std_logic;
        rst : in std_logic;
        SW : in std_logic_vector(9 downto 0);  -- Floor selection switches (9 switches)
        key1 : in std_logic;  -- Increment button (active low)
        LEDR : out std_logic_vector(9 downto 0); -- led matching switch
        current_display : out std_logic_vector(6 downto 0);  -- Seven-segment display for floor
        target_display : out std_logic_vector(6 downto 0);  -- Seven-segment display for floor
		  direction_display : out std_logic_vector(6 downto 0)  -- Seven-segment display for direction
    );

end entity;

architecture Behavioural of elevate is
	 type ElevatorStates is (idle, moving, arrival);
    signal pres_state, next_state : ElevatorStates;
    signal current_floor : integer := 0;
    signal target_floor : integer := 0;
	 signal clk_div : STD_LOGIC;
	 constant N : integer := 25e6; -- Divide by 10 for example
    signal counter : integer range 0 to N-1 := 0; -- N is the desired division factor

	 -- Constants for seven-segment display segment patterns
    
    constant dash    : std_logic_vector(6 downto 0) := "0111111";
    constant zero    : std_logic_vector(6 downto 0) := "1000000";
    constant one     : std_logic_vector(6 downto 0) := "1111001";
    constant two     : std_logic_vector(6 downto 0) := "0100100";
    constant three   : std_logic_vector(6 downto 0) := "0110000";
    constant four    : std_logic_vector(6 downto 0) := "0011001";
    constant five    : std_logic_vector(6 downto 0) := "0010010";
    constant six     : std_logic_vector(6 downto 0) := "0000010";
    constant seven   : std_logic_vector(6 downto 0) := "1111000";
    constant eight   : std_logic_vector(6 downto 0) := "0000000";
    constant nine    : std_logic_vector(6 downto 0) := "0011000";
    -- Define constants for other digits...

    constant UP : std_logic_vector(6 downto 0) := "1011100";
    constant DOWN : std_logic_vector(6 downto 0) := "1100011";
    constant AR : std_logic_vector(6 downto 0) := "0001000";
	 
begin
    -- Clock divider process
    process(clk)
    begin
        if rising_edge(clk) then
            if counter = N-1 then
                counter <= 0;
                clk_div <= not clk_div; -- Toggle the divided clock
            else
                counter <= counter + 1;
            end if;
        end if;
    end process;

	sync_state_transition: process(clk_div, rst)
	
	begin
		if (rst = '0') then
			pres_state <= idle;
		elsif rising_edge(clk_div) then
			pres_state <= next_state;
		end if;
	end process;
	
	state_transition_logic: process(clk, clk_div, pres_state, rst,target_floor,current_floor)
	
	begin
	
	--	if rst = '0' then
	--		next_state <= idle; -- to ensure that the value in next_state is also changed to reset
			-- if this is not done, the FSM may return to its previous state once the reset
			-- button is released.
			
		if rising_edge(clk_div) then
		
			case SW is 
				when "0000000001"=> target_floor <= 1;
				when "0000000010"=> target_floor <= 2;
				when "0000000100"=> target_floor <= 3;
				when "0000001000"=> target_floor <= 4;
				when "0000010000"=> target_floor <= 5;
				when "0000100000"=> target_floor <= 6;
				when "0001000000"=> target_floor <= 7;
				when "0010000000"=> target_floor <= 8;
				when "0100000000"=> target_floor <= 9;
				when "1000000000"=> target_floor <= 10;
				when "0000000000"=> target_floor <= 0; 
				when others		  => target_floor <= 11;
	 
			end case;
		
			case pres_state is
			
				when idle =>
					next_state <= moving;
					
				when moving =>
					if key1 = '1' then
							if target_floor = current_floor then
								next_state<= arrival;
							elsif target_floor > current_floor then
								current_floor<= current_floor+1;
							elsif target_floor < current_floor then
								current_floor<= current_floor-1;	
							else
								
						  end if;
				   end if;
				when arrival=>
						if key1 = '1' then
							next_state<= moving;
						else
							next_state<= arrival;
						end if;
				end case;
			end if;
		end process;
			
	output_logic: process(pres_state,clk,target_floor,current_floor)
		begin
			case pres_state is
				when idle =>
					
						target_display<= dash;
					direction_display<= dash;
					
						
				when moving =>
						if target_floor < current_floor then
								direction_display<= down;
							elsif target_floor > current_floor then
								direction_display<= up;
							else 
								direction_display<= dash;

						end if;
						case target_floor is
							when 0 => target_display <= dash;
							when 1 => target_display <= one;
							when 2 => target_display <= two;
							when 3 => target_display <= three;
							when 4 => target_display <= four;
							when 5 => target_display <= five;
							when 6 => target_display <= six;
							when 7 => target_display <= seven;
							when 8 => target_display <= eight;
							when 9 => target_display <= nine;
							when others => target_display <= dash;
						end case;
						case current_floor is
							when 0 => current_display <= zero;
							when 1 => current_display <= one;
							when 2 => current_display <= two;
							when 3 => current_display <= three;
							when 4 => current_display <= four;
							when 5 => current_display <= five;
							when 6 => current_display <= six;
							when 7 => current_display <= seven;
							when 8 => current_display <= eight;
							when 9 => current_display <= nine;
							when others => target_display <= dash;
						end case;
				when arrival =>
							
							direction_display<= AR;
							
						case target_floor is
							when 0 => target_display <= dash;
							when 1 => target_display <= one;
							when 2 => target_display <= two;
							when 3 => target_display <= three;
							when 4 => target_display <= four;
							when 5 => target_display <= five;
							when 6 => target_display <= six;
							when 7 => target_display <= seven;
							when 8 => target_display <= eight;
							when 9 => target_display <= nine;
							when others => target_display <= dash;
						end case;
						case current_floor is
							when 0 => current_display <= zero;
							when 1 => current_display <= one;
							when 2 => current_display <= two;
							when 3 => current_display <= three;
							when 4 => current_display <= four;
							when 5 => current_display <= five;
							when 6 => current_display <= six;
							when 7 => current_display <= seven;
							when 8 => current_display <= eight;
							when 9 => current_display <= nine;
							when others => current_display <= dash;
						end case;
				end case;
		end process;
		
		LEDR <= SW; -- Connect LED states to the LED outputs
		
end Behavioural;		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		