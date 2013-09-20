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
		scal_in : in STD_LOGIC_VECTOR (4*32-1 downto 0);
		ScalerGate_Delayed : in STD_LOGIC;
		ScalerGate_DelayedStreched : in STD_LOGIC;
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
	constant TRIG_FIXED : std_logic_vector(31 downto 0) := x"13091919"; 
	
	component InputStretcher is
	Generic (
		Duration : integer := 1		);
		PORT (
			Clock : in STD_LOGIC;
			Input : in STD_LOGIC;
			Output : out STD_LOGIC
		);
	end component;
	
	

	signal TaggerOR, TaggerOR_delayed : std_logic_vector(5 downto 0);
	
	---------------------------------------------------------------------------------
	-- Signals to/from MAMI to control the electron source
	---------------------------------------------------------------------------------
	signal MAMIElectronSourceSetting : std_logic_vector(3 downto 0);
	---------------------------------------------------------------------------------

	---------------------------------------------------------------------------------
	-- Signals for MAMI e- flux counting
	---------------------------------------------------------------------------------
	component Prescaler is
		 Generic (
				Factor : integer );
		 Port ( clock : in  STD_LOGIC;
				  Input : in  STD_LOGIC;
				Output : out  STD_LOGIC);
	end component;
	signal AdditionalCountersOut_Intermediate : std_logic_vector(31 downto 0);
	signal clock5 : std_logic;
	signal GateActive, GateActive1, OldClock5 : std_logic;
	---------------------------------------------------------------------------------
begin
	Prescaler_SlowClock: Prescaler GENERIC MAP (Factor => 25) 
		PORT MAP (clock=>clock100,INPUT=>clock50,OUTPUT=>clock5);

	------------------------------------------------------------------------------------------------
	-- show the actual status of the machine using leds
	led(6 downto 1) <= not x"0f";
	led(7) <= not GateActive1;
	led(8) <= not clock5;
	pgxled(8 downto 1) <= not x"33";

	---------------------------------------------------------------
	-- Detect whether a Gate signal occured and let the led blink
	---------------------------------------------------------------
	process (clock100, AdditionalCountersOut_Intermediate(31))
	begin
		if rising_edge(clock100) then
			if AdditionalCountersOut_Intermediate(31) = '1' then
				GateActive <= '1';
			end if;
			
			OldClock5 <= clock5;
			
			if (OldClock5 = '0') and (clock5 = '1') then
				GateActive <= '0';
			end if;
		end if;
	end process;
	process (clock5)
	begin
		if rising_edge(clock5) then
			GateActive1 <= GateActive;
		end if;
	end process;
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
	
	AdditionalCountersOut_Intermediate(3 downto 0) <= MAMIElectronSourceSetting;
	
	Counters: for i in 0 to 3 generate 
		begin
			Timer_1: AdditionalCountersOut_Intermediate(i+4) <= 
				clock100 when (MAMIElectronSourceSetting(i) = '1') else '0';

			Prescaler_1: Prescaler GENERIC MAP (Factor=>8) 
				PORT MAP (clock=>clock200,Input=>AdditionalCountersOut_Intermediate(i+4),Output=>AdditionalCountersOut_Intermediate(i+8));
	end generate;
	
	TaggerORs1: for i in 0 to 3 generate --IN1 and IN2
		begin
			TaggerOR_1: TaggerOR(i) <= '1' when (trig_in(i*16+15 downto i*16) /= "0") else '0';
	end generate;
	TaggerORs2: for i in 6 to 7 generate --INOUT1
		begin
			TaggerOR_2: TaggerOR(i-2) <= '1' when (trig_in(i*16+15 downto i*16) /= "0") else '0';
	end generate;

	TaggerORsDelayed1: for i in 0 to 5 generate --IN1 and IN2 and INOUT 1
		begin
			TaggerORDelayed_1: TaggerOR_delayed(i) <= '1' when (scal_in(i*16+15 downto i*16) /= "0") else '0';
	end generate;
	
	
	AdditionalCountersOut_Intermediate(17 downto 12) <= TaggerOR;
	AdditionalCountersOut_Intermediate(23 downto 18) <= TaggerOR_delayed;
	AdditionalCountersOut_Intermediate(28 downto 24) <= (others => '0');
	AdditionalCountersOut_Intermediate(29) <= trig_in(31+32*5);
	AdditionalCountersOut_Intermediate(30) <= ScalerGate_Delayed;
	AdditionalCountersOut_Intermediate(31) <= ScalerGate_DelayedStreched;

	AdditionalCountersOut <= AdditionalCountersOut_Intermediate;
	trig_out(31 downto 0) <= AdditionalCountersOut_Intermediate;
	
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
