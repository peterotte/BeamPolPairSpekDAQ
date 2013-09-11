----------------------------------------------------------------------------------
-- Company: GSI
-- Engineer: S.Minami
-- 
-- Create Date:    12:31:16 08/07/2008 
-- Design Name: 
-- Module Name:    delay_by_shiftregister - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--   Delay = DELAY times clock cycle
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


entity delay_by_shiftregister is
	Generic (
		DELAY : integer  -- not less than 1!
	);
    Port ( CLK : in  STD_LOGIC;
           SIG_IN : in  STD_LOGIC;
           DELAY_OUT : out  STD_LOGIC);
end delay_by_shiftregister;

architecture Behavioral of delay_by_shiftregister is

signal sr : std_logic_vector ( (DELAY-1) downto 0);

begin

	process (CLK, SIG_IN)
	begin
		if(rising_edge(CLK)) then
			sr(0) <= SIG_IN;
			for i in 1 to (DELAY-1) loop
				sr(i)<=sr(i-1);				
			end loop;	
		end if;
	end process;
	
	DELAY_OUT <= sr(DELAY-1);
	
end Behavioral;

