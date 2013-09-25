library IEEE;
use IEEE.STD_LOGIC_1164.ALL;																						
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
Library UNISIM;
use UNISIM.vcomponents.all; --  for bufg

entity trigger is
	port (
		clock50 : in STD_LOGIC;
		clock100 : in STD_LOGIC;
		clock200 : in STD_LOGIC;
		clock400 : in STD_LOGIC; 
		trig_in : in STD_LOGIC_VECTOR (191 downto 0);
		trig_out : out STD_LOGIC_VECTOR (63 downto 0);
		nim_in   : in  STD_LOGIC;
		nim_out  : out STD_LOGIC;
		led	     : out STD_LOGIC_VECTOR(8 downto 1); -- 8 LEDs onboard
		pgxled   : out STD_LOGIC_VECTOR(8 downto 1); -- 8 LEDs on PIG board
		Global_Reset_After_Power_Up : in std_logic;
		VN2andVN1 : in std_logic_vector(7 downto 0);
		AdditionalCountersOut : out std_logic_vector(31 downto 0); --0..3 for e- Flux Mesaurement
		-- VME interface ------------------------------------------------------
		u_ad_reg :in std_logic_vector(11 downto 2);
		u_dat_in :in std_logic_vector(31 downto 0);
		u_data_o :out std_logic_vector(31 downto 0);
		oecsr, ckcsr:in std_logic
	);
end trigger;


architecture RTL of trigger is

	subtype sub_Adress is std_logic_vector(11 downto 4);

	constant BASE_TRIG_DebugTrigIn : sub_Adress    		:= x"0f"; -- r/w
	signal DebugTrigIn : std_logic_vector(31 downto 0);
	constant BASE_TRIG_FIXED : sub_Adress 					:= x"f0" ; -- r
	constant TRIG_FIXED : std_logic_vector(31 downto 0) := x"1309201b"; 

	
	---------------------------------------------------------------------------------
	-- Signals to/from MAMI to control the electron source
	---------------------------------------------------------------------------------
	signal MAMIElectronSourceSetting : std_logic_vector(3 downto 0);
	---------------------------------------------------------------------------------

begin
	------------------------------------------------------------------------------------------------
	-- show the actual status of the machine using leds
	led(6 downto 1) <= not x"0f";
	led(8 downto 7) <= "00";
	pgxled(8 downto 1) <= not x"33";


	------------------------------------------------------------------------------------------------
	
	---------------------------------------------------------------------------------
	-- Signals to/from MAMI to control the electron source
	---------------------------------------------------------------------------------
	-- Pin 0 = mami response (+)
	-- Pin 1 = output from generator (+)
	-- Pin 2 = inverted output from generator (-)
	-- Pin 3 = inhibit, if set, status of source is indetermined
	MAMIElectronSourceSetting <= trig_in(3+32*5 downto 0+32*5); 
	---------------------------------------------------------------------------------
		
	
	---------------------------------------------------------------------------------------------------------	
	-- Code for VME handling / access
	-- decoder for data registers
	-- handle write commands from vmebus
	---------------------------------------------------------------------------------------------------------	
	process(clock50, ckcsr, u_ad_reg)
	begin
		if (clock50'event and clock50 ='1') then

			if (u_ad_reg(11 downto 4) = BASE_TRIG_DebugTrigIn) and (ckcsr = '1') then 
				DebugTrigIn <= u_dat_in; end if;
		end if;
	end process;
	

	---------------------------------------------------------------------------------------------------------	
	-- Code for VME handling / access
	-- handle read commands from vmebus
	---------------------------------------------------------------------------------------------------------	
	process(clock50, oecsr, u_ad_reg)
	begin
		if (clock50'event and clock50 = '1' and oecsr = '1') then
			u_data_o <= (others => '0');
			
			if (u_ad_reg(11 downto 4) = BASE_TRIG_FIXED) then 
				u_data_o <= TRIG_FIXED; end if;
			if (u_ad_reg(11 downto 4) = BASE_TRIG_DebugTrigIn) then 
				u_data_o <= DebugTrigIn; end if;
		end if;
	end process;

end RTL;
