library IEEE;
use IEEE.STD_LOGIC_1164.ALL;																						
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
--Library UNISIM;
--use UNISIM.vcomponents.all; --  for bufg

entity trigger is
	port (
		clock50 : in STD_LOGIC;
		clock100 : in STD_LOGIC;
		clock200 : in STD_LOGIC;
		clock400 : in STD_LOGIC; 
		DebugSignals : in std_LOGIC_VECTOR(255 downto 0);
		Tagger_In : in STD_LOGIC_VECTOR (32*3-1 downto 0);
		EPTagger_In : in STD_LOGIC_VECTOR (31 downto 0);
		TaggerOR : in STD_LOGIC_VECTOR(7 downto 0);
		trig_out : out STD_LOGIC_VECTOR (63 downto 0);
		InputMaskOut : out std_logic_vector(32*4-1 downto 0);
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
	constant FirmwareType: integer := 2;
	constant FirmwareRevision: integer := 33;

	subtype sub_Address is std_logic_vector(11 downto 4);

	constant BASE_TRIG_FIXED : sub_Address 					:= x"f0" ; -- r
	constant BASE_TRIG_SelectedInput_Base : sub_Address 	:= "10000000" ; -- r/w, only bit 11 and bit 10 is used
	signal TRIG_FIXED : std_logic_vector(31 downto 0); 

	constant BASE_TRIG_InputChannelDebugLeftStart	 : sub_Address   		:= x"0b"; -- r/w left channel (lower energy) to start with
	constant BASE_TRIG_InputChannelDebugRightStart	 : sub_Address   		:= x"0c"; -- r/w right channel (higher energy) to start with

	--debug
	constant BASE_TRIG_Debug_ActualState : sub_Address							:= x"e0"; --r
	constant BASE_TRIG_SelectedDebugInput_1 : sub_Address						:= x"e1"; --r/w
	constant BASE_TRIG_SelectedDebugInput_2 : sub_Address						:= x"e2"; --r/w
	constant BASE_TRIG_SelectedDebugInput_3 : sub_Address						:= x"e3"; --r/w
	constant BASE_TRIG_SelectedDebugInput_4 : sub_Address						:= x"e4"; --r/w
	
	--IN1..IO1 Mask
	constant BASE_TRIG_IN1Mask : sub_Address    		:= x"10"; -- r/w
	constant BASE_TRIG_IN2Mask : sub_Address    		:= x"11"; -- r/w
	constant BASE_TRIG_IN3Mask : sub_Address    		:= x"12"; -- r/w
	constant BASE_TRIG_IO1Mask : sub_Address    		:= x"13"; -- r/w

	constant BASE_TRIG_ScalerGate : sub_Address    	:= x"20"; -- r/w

	signal IN1IN2IN3IO1Mask : std_logic_vector(32*4-1 downto 0) := x"ffffffffffffffffffffffffffffffff";
	
	constant SelectedChannelsCount : integer := 16; --32 for LVDS output plus 1 for NIM_OUT
	type TSelectedInputPattern is array(0 to SelectedChannelsCount-1) of std_logic_vector(32*2-1 downto 0);
	signal SelectedInputPattern : TSelectedInputPattern;

	signal Inter_trig_out, Inter_trig_out_Gated : std_logic_vector(SelectedChannelsCount-1 downto 0);

	--Signals For Moeller DAQ
	signal InputChannelDebugLeftStart, InputChannelDebugRightStart : std_logic_vector(7 downto 0);
	constant NumberOfTDCs : integer := 10+14;
   constant NumberOfLeftChannels : integer := 10;
	signal InputChannelDebugLeftGroup  : std_logic_vector(NumberOfLeftChannels-1 downto 0); --The find the matching Moeller Pairs in Debug Mode
	signal InputChannelDebugRightGroup : std_logic_vector(NumberOfTDCs-NumberOfLeftChannels-1 downto 0); --The find the matching Moeller Pairs in Debug Mode


	signal ScalerGate : std_logic;
	
	-- For all components
	constant NDebugSignalOutputs : integer := 4;
	signal SelectedDebugInput : std_logic_vector(8*NDebugSignalOutputs-1 downto 0);
	signal Debug_ActualState : std_logic_vector(NDebugSignalOutputs-1 downto 0);

	COMPONENT DebugChSelector
	PORT(
		DebugSignalsIn : IN std_logic_vector(255 downto 0);
		SelectedInput : IN std_logic_vector(7 downto 0);          
		SelectedOutput : OUT std_logic
		);
	END COMPONENT;

	------------------------------------------------------------------------------

	


begin
	TRIG_FIXED(31 downto 24) <= CONV_STD_LOGIC_VECTOR(FirmwareType, 8);
	TRIG_FIXED(23 downto 16) <= CONV_STD_LOGIC_VECTOR(0, 8);
	TRIG_FIXED(15 downto 0)  <= CONV_STD_LOGIC_VECTOR(FirmwareRevision, 16);

	NIM_OUT <= ScalerGate; --Open Scaler Gate send to NIM OUT and then to all other VUPROMs via NIM IN


	InputMaskOut <= IN1IN2IN3IO1Mask;

	------------------------------------------------------------------------------------------------
	-- show the actual status of the machine using leds
	led(6 downto 1) <= not x"0f";
	led(8 downto 7) <= "00";
	pgxled(8 downto 1) <= not x"33";


	------------------------------------------------------------------------------------------------
	
	
	------------------------------------------------------------------------------------------------
--	MySelector: for k in 0 to SelectedChannelsCount-1 generate
--		Inter_trig_out(k) <= '1' when (( (EPTagger_In&Tagger_In) and SelectedInputPattern(k)) /= "0") else '0';
--		--MyPreciseGateByCounter : PreciseGateByCounter GENERIC MAP (	WIDTH => 2 )
--		-- Port MAP ( Input => Inter_trig_out(k), Output => Inter_trig_out_Gated(k), DeadOut => open, clock => clock100);
--	end generate;
	MySelector_1: for k in 0 to 7 generate
		Inter_trig_out(k) <= '1' when (( Tagger_In(32*2-1 downto 0) and SelectedInputPattern(k)) /= "0") else '0';
	end generate;
	MySelector_2: for k in 8 to 15 generate
		Inter_trig_out(k) <= '1' when (( (EPTagger_In&Tagger_In(32*3-1 downto 32*2)) and SelectedInputPattern(k)) /= "0") else '0';
	end generate;
	--Inter_trig_out(32) <= '1' when (( (EPTagger_In&Tagger_In) and SelectedInputPattern(k)) /= "0") else '0';

	trig_out(15+32 downto 32) <= Inter_trig_out(15 downto 0);
	trig_out(23+32 downto 16+32) <= TaggerOR;
	------------------------------------------------------------------------------------------------
	
	
		
	------------------------------------------------------------------------------------------
	-- Select Left and Right Channels for Debug
	------------------------------------------------------------------------------------------
	InputChannelDebugLeftGroup <= 
		Tagger_In(0+NumberOfLeftChannels-1 downto 0) when InputChannelDebugLeftStart = x"00" else
		Tagger_In(1+NumberOfLeftChannels-1 downto 1) when InputChannelDebugLeftStart = x"01" else
		Tagger_In(2+NumberOfLeftChannels-1 downto 2) when InputChannelDebugLeftStart = x"02" else
		Tagger_In(3+NumberOfLeftChannels-1 downto 3) when InputChannelDebugLeftStart = x"03" else
		Tagger_In(4+NumberOfLeftChannels-1 downto 4) when InputChannelDebugLeftStart = x"04" else
		Tagger_In(5+NumberOfLeftChannels-1 downto 5) when InputChannelDebugLeftStart = x"05" else
		Tagger_In(6+NumberOfLeftChannels-1 downto 6) when InputChannelDebugLeftStart = x"06" else
		Tagger_In(7+NumberOfLeftChannels-1 downto 7) when InputChannelDebugLeftStart = x"07" else
		Tagger_In(8+NumberOfLeftChannels-1 downto 8) when InputChannelDebugLeftStart = x"08" else
		Tagger_In(9+NumberOfLeftChannels-1 downto 9) when InputChannelDebugLeftStart = x"09" else
		Tagger_In(10+NumberOfLeftChannels-1 downto 10) when InputChannelDebugLeftStart = x"0a" else
		Tagger_In(11+NumberOfLeftChannels-1 downto 11) when InputChannelDebugLeftStart = x"0b" else
		Tagger_In(12+NumberOfLeftChannels-1 downto 12) when InputChannelDebugLeftStart = x"0c" else
		Tagger_In(13+NumberOfLeftChannels-1 downto 13) when InputChannelDebugLeftStart = x"0d" else
		Tagger_In(14+NumberOfLeftChannels-1 downto 14) when InputChannelDebugLeftStart = x"0e" else
		Tagger_In(15+NumberOfLeftChannels-1 downto 15) when InputChannelDebugLeftStart = x"0f" else
		Tagger_In(16+NumberOfLeftChannels-1 downto 16) when InputChannelDebugLeftStart = x"10" else
		Tagger_In(17+NumberOfLeftChannels-1 downto 17) when InputChannelDebugLeftStart = x"11" else
		Tagger_In(18+NumberOfLeftChannels-1 downto 18) when InputChannelDebugLeftStart = x"12" else
		Tagger_In(19+NumberOfLeftChannels-1 downto 19) when InputChannelDebugLeftStart = x"13" else
		Tagger_In(20+NumberOfLeftChannels-1 downto 20) when InputChannelDebugLeftStart = x"14" else
		Tagger_In(21+NumberOfLeftChannels-1 downto 21) when InputChannelDebugLeftStart = x"15" else
		Tagger_In(22+NumberOfLeftChannels-1 downto 22) when InputChannelDebugLeftStart = x"16" else
		(others => '0');
	
	InputChannelDebugRightGroup <=
		Tagger_In(0+NumberOfTDCs-NumberOfLeftChannels-1+32 downto 0+32) when InputChannelDebugRightStart = x"00" else
		Tagger_In(1+NumberOfTDCs-NumberOfLeftChannels-1+32 downto 1+32) when InputChannelDebugRightStart = x"01" else
		Tagger_In(2+NumberOfTDCs-NumberOfLeftChannels-1+32 downto 2+32) when InputChannelDebugRightStart = x"02" else
		Tagger_In(3+NumberOfTDCs-NumberOfLeftChannels-1+32 downto 3+32) when InputChannelDebugRightStart = x"03" else
		Tagger_In(4+NumberOfTDCs-NumberOfLeftChannels-1+32 downto 4+32) when InputChannelDebugRightStart = x"04" else
		Tagger_In(5+NumberOfTDCs-NumberOfLeftChannels-1+32 downto 5+32) when InputChannelDebugRightStart = x"05" else
		Tagger_In(6+NumberOfTDCs-NumberOfLeftChannels-1+32 downto 6+32) when InputChannelDebugRightStart = x"06" else
		Tagger_In(7+NumberOfTDCs-NumberOfLeftChannels-1+32 downto 7+32) when InputChannelDebugRightStart = x"07" else
		Tagger_In(8+NumberOfTDCs-NumberOfLeftChannels-1+32 downto 8+32) when InputChannelDebugRightStart = x"08" else
		Tagger_In(9+NumberOfTDCs-NumberOfLeftChannels-1+32 downto 9+32) when InputChannelDebugRightStart = x"09" else
		Tagger_In(10+NumberOfTDCs-NumberOfLeftChannels-1+32 downto 10+32) when InputChannelDebugRightStart = x"0a" else
		Tagger_In(11+NumberOfTDCs-NumberOfLeftChannels-1+32 downto 11+32) when InputChannelDebugRightStart = x"0b" else
		Tagger_In(12+NumberOfTDCs-NumberOfLeftChannels-1+32 downto 12+32) when InputChannelDebugRightStart = x"0c" else
		Tagger_In(13+NumberOfTDCs-NumberOfLeftChannels-1+32 downto 13+32) when InputChannelDebugRightStart = x"0d" else
		Tagger_In(14+NumberOfTDCs-NumberOfLeftChannels-1+32 downto 14+32) when InputChannelDebugRightStart = x"0e" else
		Tagger_In(15+NumberOfTDCs-NumberOfLeftChannels-1+32 downto 15+32) when InputChannelDebugRightStart = x"0f" else
		Tagger_In(16+NumberOfTDCs-NumberOfLeftChannels-1+32 downto 16+32) when InputChannelDebugRightStart = x"10" else
		Tagger_In(17+NumberOfTDCs-NumberOfLeftChannels-1+32 downto 17+32) when InputChannelDebugRightStart = x"11" else
		Tagger_In(18+NumberOfTDCs-NumberOfLeftChannels-1+32 downto 18+32) when InputChannelDebugRightStart = x"12" else
		(others => '0');
		
	trig_out(9 downto 0) <= InputChannelDebugLeftGroup;
	trig_out(23 downto 10) <= InputChannelDebugRightGroup;
	trig_out(31 downto 24) <= TaggerOR;
	------------------------------------------------------------------------------------------

		
		
	-------------------------------------------------------------------------------------------------
	-- Debug Selector
	
	DebugChSelectors: for i in 0 to NDebugSignalOutputs-1 generate
	begin
		Inst_DebugChSelector: DebugChSelector PORT MAP(
			DebugSignalsIn => DebugSignals,
			SelectedInput => SelectedDebugInput((i+1)*8-1 downto i*8),
			SelectedOutput => Debug_ActualState(i)
		);
	end generate;
	trig_out(32+28+NDebugSignalOutputs-1 downto 32+28) <= Debug_ActualState;
	-------------------------------------------------------------------------------------------------


		
	

	---------------------------------------------------------------------------------------------------------	
	-- Code for VME handling / access
	-- handle read commands from vmebus
	---------------------------------------------------------------------------------------------------------	
	process(clock50, oecsr, u_ad_reg)
	begin
		if (clock50'event and clock50 = '1' and oecsr = '1') then
			u_data_o <= (others => '0');
			
			if (u_ad_reg(11 downto 4) = BASE_TRIG_FIXED) then     	u_data_o <= TRIG_FIXED; end if;

			-- SelectedInputPattern 0..SelectedChannelsCount readout
			for k in 0 to SelectedChannelsCount-1 loop 
				for i in 0 to 1 loop --for 2*32ch
				--for i in 0 to 3 loop --for 4*32ch
					if (u_ad_reg(11 downto 10) = BASE_TRIG_SelectedInput_Base(11 downto 10)) and (u_ad_reg(9 downto 4) = CONV_STD_LOGIC_VECTOR(k, 6)) and 
						(u_ad_reg(3 downto 2) = CONV_STD_LOGIC_VECTOR(i, 2)) then 
							u_data_o(31 downto 0) <= SelectedInputPattern(k)(32*i+31 downto 32*i);
					end if;
				end loop;
			end loop;

			if (u_ad_reg(11 downto 4) = BASE_TRIG_IN1Mask) then 	u_data_o <= IN1IN2IN3IO1Mask(31+32*0 downto 0+32*0); end if;
			if (u_ad_reg(11 downto 4) = BASE_TRIG_IN2Mask) then 	u_data_o <= IN1IN2IN3IO1Mask(31+32*1 downto 0+32*1); end if;
			if (u_ad_reg(11 downto 4) = BASE_TRIG_IN3Mask) then 	u_data_o <= IN1IN2IN3IO1Mask(31+32*2 downto 0+32*2); end if;
			if (u_ad_reg(11 downto 4) = BASE_TRIG_IO1Mask) then 	u_data_o <= IN1IN2IN3IO1Mask(31+32*3 downto 0+32*3); end if;
			
			--debug
			if (u_ad_reg(11 downto 4) =  BASE_TRIG_SelectedDebugInput_1) then 			u_data_o(7 downto 0) <= SelectedDebugInput(8*1-1 downto 8*0); end if;
			if (u_ad_reg(11 downto 4) =  BASE_TRIG_SelectedDebugInput_2) then 			u_data_o(7 downto 0) <= SelectedDebugInput(8*2-1 downto 8*1); end if;
			if (u_ad_reg(11 downto 4) =  BASE_TRIG_SelectedDebugInput_3) then 			u_data_o(7 downto 0) <= SelectedDebugInput(8*3-1 downto 8*2); end if;
			if (u_ad_reg(11 downto 4) =  BASE_TRIG_SelectedDebugInput_4) then 			u_data_o(7 downto 0) <= SelectedDebugInput(8*4-1 downto 8*3); end if;
			if (u_ad_reg(11 downto 4) =  BASE_TRIG_Debug_ActualState) then 				u_data_o(NDebugSignalOutputs-1 downto 0) <= Debug_ActualState; end if;
			
			--Moeller
			if (u_ad_reg(11 downto 4) = BASE_TRIG_InputChannelDebugLeftStart) then 	u_data_o(7 downto 0) <= InputChannelDebugLeftStart; end if;
			if (u_ad_reg(11 downto 4) = BASE_TRIG_InputChannelDebugRightStart) then u_data_o(7 downto 0) <= InputChannelDebugRightStart; end if;
			
			if (u_ad_reg(11 downto 4) = BASE_TRIG_ScalerGate) then u_data_o(0) <= ScalerGate; end if;
			
		end if;
	end process;


	---------------------------------------------------------------------------------------------------------	
	-- Code for VME handling / access
	-- decoder for data registers
	-- handle write commands from vmebus
	---------------------------------------------------------------------------------------------------------	
	process(clock50, ckcsr, u_ad_reg)
	begin
		if (clock50'event and clock50 ='1') then

			-- SelectedInputPattern 0..SelectedChannelsCount write
			for k in 0 to SelectedChannelsCount-1 loop
				for i in 0 to 1 loop --for 2*32ch loop to 1, for 4*32 loop to 3
					if (u_ad_reg(11 downto 10) = BASE_TRIG_SelectedInput_Base(11 downto 10)) and (u_ad_reg(9 downto 4) = CONV_STD_LOGIC_VECTOR(k, 6)) and (ckcsr = '1') 
						and (u_ad_reg(3 downto 2) = CONV_STD_LOGIC_VECTOR(i, 2)) then 
						SelectedInputPattern(k)(32*i+31 downto 32*i) <= u_dat_in(31 downto 0);
					end if;
				end loop;
			end loop;

			if (u_ad_reg(11 downto 4) = BASE_TRIG_IN1Mask) and (ckcsr = '1') then 
				IN1IN2IN3IO1Mask(32*0+31 downto 32*0+0) <= u_dat_in; end if;
			if (u_ad_reg(11 downto 4) = BASE_TRIG_IN2Mask) and (ckcsr = '1') then 
				IN1IN2IN3IO1Mask(32*1+31 downto 32*1+0) <= u_dat_in; end if;
			if (u_ad_reg(11 downto 4) = BASE_TRIG_IN3Mask) and (ckcsr = '1') then 
				IN1IN2IN3IO1Mask(32*2+31 downto 32*2+0) <= u_dat_in; end if;
			if (u_ad_reg(11 downto 4) = BASE_TRIG_IO1Mask) and (ckcsr = '1') then 
				IN1IN2IN3IO1Mask(32*3+31 downto 32*3+0) <= u_dat_in; end if;
				
			if (u_ad_reg(11 downto 4) = BASE_TRIG_InputChannelDebugLeftStart) and (ckcsr = '1') then 
				InputChannelDebugLeftStart <= u_dat_in(7 downto 0); end if;
			if (u_ad_reg(11 downto 4) = BASE_TRIG_InputChannelDebugRightStart) and (ckcsr = '1') then 
				InputChannelDebugRightStart <= u_dat_in(7 downto 0); end if;
				
			--debug
			if ( (ckcsr = '1') and (u_ad_reg(11 downto 4) =  BASE_TRIG_SelectedDebugInput_1) ) then 			SelectedDebugInput(8*1-1 downto 8*0) <= u_dat_in(7 downto 0); end if;
			if ( (ckcsr = '1') and (u_ad_reg(11 downto 4) =  BASE_TRIG_SelectedDebugInput_2) ) then 			SelectedDebugInput(8*2-1 downto 8*1) <= u_dat_in(7 downto 0); end if;
			if ( (ckcsr = '1') and (u_ad_reg(11 downto 4) =  BASE_TRIG_SelectedDebugInput_3) ) then 			SelectedDebugInput(8*3-1 downto 8*2) <= u_dat_in(7 downto 0); end if;
			if ( (ckcsr = '1') and (u_ad_reg(11 downto 4) =  BASE_TRIG_SelectedDebugInput_4) ) then 			SelectedDebugInput(8*4-1 downto 8*3) <= u_dat_in(7 downto 0); end if;
			
			if (u_ad_reg(11 downto 4) = BASE_TRIG_ScalerGate) and (ckcsr = '1') then 
				ScalerGate <= u_dat_in(0); end if;

		end if;
	end process;
	
end RTL;
