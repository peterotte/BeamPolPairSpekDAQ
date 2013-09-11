----------------------------------------------------------------------------------
-- Create Date:    16:59:32 12/04/2010 
-- Module Name:    Prescaler - Behavioral 
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity Prescaler is
    Generic (
			Factor : integer );
    Port ( clock : in  STD_LOGIC;
           Input : in  STD_LOGIC;
           Output : out  STD_LOGIC);
end Prescaler;

architecture Behavioral of Prescaler is
	signal Counter : std_logic_vector(Factor-1 downto 0);
	signal Last0, Last1 : std_logic;
begin
	process (clock)
	begin
		if rising_edge(clock) then
			Last0 <= Input;
			Last1 <= Last0;
		end if;
	end process;
	
	process (clock)
	begin
		if rising_edge(clock) then
			if (Last0 = '1') and (Last1 = '0') then
				Counter <= Counter +1;
			end if;
		end if;
	end process;
	
	Output <= Counter(Factor-1);

end Behavioral;
