library IEEE;
use IEEE.STD_LOGIC_1164.ALL;																						
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
Library UNISIM;
use UNISIM.vcomponents.all;



entity vuprom_TaggerScaler is
	Port (
--............................. VME Signals ............................................
		AD				: inout std_logic_vector(31 downto 0);	--VME Address-Data bus
		ASI	  			: in std_logic;			     -- Address strobe
		WRI	  			: in std_logic;			     -- Write
		BERRO	  			: out std_logic;		  -- bus error for chain block transfer
		DS0I, DS1I	  		: in std_logic;			  -- data strobe
		DACKP				: in std_logic;			-- acknowledge over CPLD (CON(0))
		IACKII, IACK			: in std_logic;			  -- interrupt acknowledge	chain
		IRBLO, IACKOU			: out std_logic;		  -- interrupt acknowledge	chain
--............................. DSP control signals ............................................
		AHOLD, ARDY	 	: out std_logic;	-- 	
		AHOLDA, AECKO           : in std_logic;		-- 	
		AOE, ARE, AWE		: in std_logic; --		
		AS	 		: in std_logic_vector(19 downto 0); -- address bus of EMIFA 
		DS			: inout std_logic_vector(31 downto 0); -- data bus
		DSPRS, NMI		: inout std_logic; --
		INT	 		: inout std_logic_vector(7 downto 4); --
		TINP	 		: out std_logic_vector(2 downto 0); -- 
		TOUT	 		: in std_logic_vector(2 downto 0); --
		AECKO1			: in std_logic; -- clock from DSP 100MHz for SDRAM
		CEL			: in std_logic_vector(3 downto 0); --
		BCLK, BHOLD, BRDY	: out std_logic;  -- EMIF_B, not used
		CLKR0, CLKS0, CLKX0, DX, FSR0, FSX0, DR0, DX0		: in std_logic; -- serial links
                AX                  : in std_logic_vector(19 downto 16);
		CKFPH				: in std_logic;			-- Clock from DSP 100 MHz 
--............................... HPI ..........................................................DSP
		 HCS, HRW		: inout std_logic; --
		 HD	  	  	: inout std_logic_vector(31 downto 0);	-- hpi data
		 HIA		  	: inout std_logic_vector(2 downto 0);	-- hpi address
		 HRDY			: in std_logic; --			
--............................. Buffer/Register Control Signals ............................................
		CAIV				: out std_logic;		-- 	Address buffer clock signal Int->VME
		CAVI, CDIV, CDVI		: in std_logic;			-- 	not used yet
		OAIV				: out std_logic;			-- 	Address  buffer OE   Int->VME
		OAVI, ODIV, ODVI  : in std_logic;			-- 	not used yet
--............................. Front panel Control Signals ............................................
		IN1X, IN2X, IN3X	  	:in std_logic_vector(32 downto 1);-- 	signals from LVDS inputs ch4
		OU1X				:inout std_logic_vector(32 downto 1);--
		PGIO1X, PGIO2X, PGIO3X, PGIO4X  :inout std_logic_vector(32 downto 1);-- 1:in, 2:i/o 3:i/o 4:o
		LED, PGXLED	  			: out std_logic_vector(8 downto 1);	-- Front panel LED on board, piggy back
                COD                             :in std_logic_vector(2 downto 1); -- piggy board 1I3O=b"00 3I1O=b"11"
		LEMIN1 				:in std_logic;	-- 	signal from LEMO NIM or TTL	
		LEMOE	  				:out std_logic;		-- 	/OE for LEMLEMOTTL output		
		LEMOTTL	  			:out std_logic;-- 	TTL output to LEMO, if JU1 is selected.		
		LEMONIM				:out std_logic;-- 	NIM output to LEMO, if JU2 is selected.				

--............................. SRAM Control Signals ............................................
		SAD	  					: inout std_logic_vector(17 downto 0);	-- address 
		SDA	  					: inout std_logic_vector(15 downto 0);	-- data 
		SCS	  					: inout std_logic;
		SOE	 					: inout std_logic;
		SWE	  					: inout std_logic;
--............................. DISPLAY
		AI	  				: inout std_logic_vector(1 downto 0);	-- display address ( use 1 and 2 only, 0 and 3 can't be seen)
		DI	  				: inout std_logic_vector(6 downto 0);	-- display data 
		WRDIS	  				: inout std_logic;	-- display write
		DOUTLCD					: out std_logic;
--............................. System  Signals ............................................
		PRES, SRESI	  			: in std_logic;	-- reset positive from reset IC	
		RES	  					: in std_logic_vector(2 downto 1);	-- reset from CPLD
		CKFNL, CKFPL	  		: in std_logic;			-- Clock from buffer 100 MHz 
		CON	  					: inout std_logic_vector(15 downto 0);		-- 	Connection between PROG and vupm_1
		HPV, HPW	  				: out std_logic_vector(15 downto 0)	  	-- 	Logic analyzer signals 
		);
end vuprom_TaggerScaler;


architecture rtl of vuprom_TaggerScaler is
   attribute keep : string;

	--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
	--     VME access 
	--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
	-- TOP level design                     --
	constant YEAR: integer :=9;
	constant MONTH: integer :=4;
	constant DATE: integer :=2;
	constant TRIAL: integer :=2;
	constant version: std_logic_vector ( 31 downto 0):=x"00030508";  -- v0003.00.10
	signal ymdt: std_logic_vector (31 downto 0);
	--signal tdcsetting : std_logic_vector (31 downto 0);
	constant vmead_clkstatus: std_logic_vector ( 11 downto 2) :=b"0000000000";
	constant vmead_ymdt: std_logic_vector ( 11 downto 2) :=b"0000000001";
	constant vmead_version: std_logic_vector ( 11 downto 2) :=b"0000000010";
	signal vme_clkrst : std_logic_vector ( 1 downto 0);
	signal vme_clkstatus: std_logic_vector(1 downto 0);
	signal top_data_o: std_logic_vector(31 downto 0);
	signal top_oecsr : std_logic;
	signal top_ckcsr : std_logic;

	------------------ VME address modifier ------------------------------
	-- CON(8) = am_b = Extended non-privileged  block transfer    
	-- CON(7) = am_9 = Extended non-privileged data access    
	------------------ VME addresses --------------------------------------
	--- address bus (23 downto 20)
	---  address bit 23 = 1 : access to CPLD
	---  XXC0 0000 0000 for Flash Memory Access from CPLD
	---  XX80 0000 0000 for Configure FPGA from Flash Memory
	constant csr_ad	:std_logic_vector(3 downto 0)    := b"0000"; -- vmeaddr=XX00 0000 - XX00 000C  a23-20
	-- constant dspcsr_ad :std_logic_vector(3 downto 0) := b"0100"; -- DSP CSR register  
	-- constant hpi_ad	: std_logic_vector(3 downto 0)   := b"0110"; -- DSP HPI access
	-- constant vmeram_ad : std_logic_vector(3 downto 0):= b"0001"; -- dual ported VME RAM in FPGA
	-- constant sram_ad: std_logic_vector(3 downto 0)   := b"0010"; -- SRAM memory
	-- constant sram_ad	:std_logic_vector(3 downto 2)  := x"01";----vmeaddr=XX40 0000 - XX40 FFFC    

	----- address sharing for vmecsr address bus (19 downto 12)
	constant scal_base_O    : std_logic_vector(7 downto 0) :=x"10";
	constant scal_base_D    : std_logic_vector(7 downto 0) :=x"12";
	constant scal_base_U    : std_logic_vector(7 downto 0) :=x"13";
	constant scal_base_Mon  : std_logic_vector(7 downto 0) :=x"14";
	constant scal_base_DAQMon  : std_logic_vector(7 downto 0) :=x"15";
	constant trig_base      : std_logic_vector(7 downto 0) :=x"02";
	constant top_base       : std_logic_vector(7 downto 0) :=x"04"; 
	constant disp_base      : std_logic_vector(7 downto 0) :=x"05"; 

	-- vme bus control signals
	signal ckcsr		: std_logic;	 -- internal CSR
	signal oecsr		: std_logic;	 -- internal CSR
	signal din		: std_logic_vector (31 downto 0);	 -- internal data bus, CSR
	signal u_ad_reg 		:std_logic_vector(31 downto 2);
	signal u_dat_in 		:std_logic_vector(31 downto 0);	
	signal u_data_o 		:std_logic_vector(31 downto 0);	
	signal ckaddr, ws		: std_logic;
	
	signal VN2andVN1 : std_logic_vector(7 downto 0); -- setting of VN1 and VN2 wheels for VMEbus address
	signal VMEAccess_Reset : std_logic;

	COMPONENT vme_access
	  generic (
		 BASE_AD : std_logic_vector( 23 downto 20) := csr_ad  -- VME base address D23 to D 20
		 );
	  Port ( AD : inout  STD_LOGIC_VECTOR (31 downto 0);
			VME_Reset : in std_logic;
			ASI : in  STD_LOGIC;
			WRI : in  STD_LOGIC;
			DS0I : in  STD_LOGIC;
			DS1I : in  STD_LOGIC;
			CON : inout  STD_LOGIC_VECTOR (15 downto 0);
			VN2andVN1 : out std_logic_vector(7 downto 0);
			CKADDR : out STD_LOGIC;
			WS : out STD_LOGIC;
			CKCSR : out  STD_LOGIC;
			OECSR : out  STD_LOGIC;
			U_AD_REG : out STD_LOGIC_VECTOR ( 31 downto 2);
			U_DAT_IN : in STD_LOGIC_VECTOR ( 31 downto 0);
			U_DAT_OUT : out STD_LOGIC_VECTOR ( 31 downto 0);
			CLK : in  STD_LOGIC
		);
	END COMPONENT;

	-------------------------------------------
	type TypeGlobal_Module_Step is (PreInit, Init, PostInit, Working);
	signal Global_Module_Step : TypeGlobal_Module_Step;
	signal Global_Reset_After_Power_Up_Delay_1msec : std_logic;

--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
--     CLOCK 
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
	signal clk50, clk100, clk200, clk400, clk1 : std_logic;
	signal clk_rst, clk_locked: std_logic_vector ( 3 downto 0);

	COMPONENT clock_boost
	PORT(
		CLKIN_N_IN : IN std_logic;
		CLKIN_P_IN : IN std_logic;
		CLK_RST_IN : IN std_logic_vector(3 downto 0);          
		CLK_LOCKED_OUT : OUT std_logic_vector(3 downto 0);
		CLK50MHz_OUT : OUT std_logic;
		CLK100MHz_OUT : OUT std_logic;
		CLK200MHz_OUT : OUT std_logic;
		CLK400MHz_OUT : OUT std_logic;
		clock1MHz_OUT : out  STD_LOGIC;
		clock0_5Hz_OUT : out  STD_LOGIC
		);
	END COMPONENT;
 


	--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
	--     Display
	--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--

	signal dispmem_in, dispmem_out	:std_logic_vector(7 downto 0);
	signal disp_data_o : std_logic_vector(31 downto 0);
	signal disp_oecsr : std_logic;
	signal disp_ckcsr : std_logic;
	signal disp_in : std_logic_vector(3 downto 0);

	component display_matrix is
		 Port (  
				VN2andVN1 : in std_logic_vector(7 downto 0);
				reset : in std_logic_vector(1 downto 0);
				  LCD_DIN : inout  STD_LOGIC;
				  LCD_LP : inout  STD_LOGIC;
				  LCD_FLM : inout  STD_LOGIC;
				  LCD_SCP : inout STD_LOGIC;
				  LCD_LED_GRN : inout  STD_LOGIC;
				  LCD_LED_RED : inout  STD_LOGIC;
					--		VME interface -------------------------
					clk50			: in std_logic;
					disp_in : in std_logic_vector(3 downto 0);
					u_ad_reg :in std_logic_vector(11 downto 2);
					u_dat_in :in std_logic_vector(31 downto 0);
					u_data_o :out std_logic_vector(31 downto 0);
					ckaddr, ws, oecsr, ckcsr:in std_logic	
			  );
	end component;

	--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
	--     I/O
	--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--


	signal vhdc_out : std_logic_vector ( 63 downto 0);
	signal vhdc_in	: std_logic_vector (191 downto 0);
	--
	signal count 	:	std_logic_vector (23 downto 0);
	signal counth 	:	std_logic_vector (27 downto 0);
	--signal gate_vhdl : std_logic_vector ( (8*10-1) downto 0);

	signal led_out : std_logic_vector(15 downto 0);

	--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
	--     SCALER
	--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--

	--Gates for Scalers
	signal scal_Gate_Open, scal_Gate_PairSpec : std_logic;
	attribute keep of scal_Gate_PairSpec : signal is "TRUE";
	--intermediate signals
	signal scal_data_o_O, scal_data_o_D, scal_data_o_U, scal_data_o_Mon, scal_data_o_DAQMon : std_logic_vector(31 downto 0);
	
	signal scal_oecsr_O, scal_oecsr_D, scal_oecsr_U, scal_oecsr_Mon, scal_oecsr_DAQMon : std_logic;
	signal scal_ckcsr_O, scal_ckcsr_D, scal_ckcsr_U, scal_ckcsr_Mon, scal_ckcsr_DAQMon : std_logic;
	
	constant SCBit: integer := 32;
	constant SCCH96: integer := 32*3; --For open Tagger, Pair Spec delayed, Pair Spec undelayed
	constant SCCH32: integer := 32; -- open EPT
	constant SCCHMon: integer := 16; -- Online Monitor
	signal scal_in_O, scal_in_D : std_logic_vector(SCCH96-1 downto 0);
	attribute keep of scal_in_O : signal is "TRUE";
	attribute keep of scal_in_D : signal is "TRUE";

	
	signal scal_in_Mon : std_logic_vector(SCCHMon-1 downto 0);
	attribute keep of scal_in_Mon : signal is "TRUE";
	
	component scaler
		generic ( 
			NCh : integer; -- := SCCH96
			NBit : integer := SCBit
			);  
		port (
			clkl : in STD_LOGIC;
			clkh : in STD_LOGIC;		
			--scal_in : in STD_LOGIC_VECTOR ( (SCCH96-1) downto 0);				
			scal_in : in STD_LOGIC_VECTOR ( (NCh-1) downto 0);				
			ScalerGate : in std_logic;
			--............. vme interface .............
			u_ad_reg :in std_logic_vector(11 downto 2);
			u_dat_in :in std_logic_vector(31 downto 0);
			u_data_o :out std_logic_vector(31 downto 0);
			oecsr, ckcsr:in std_logic
		);
	end component;


	--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
	--     TRIGGER
	--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
	signal trig_data_o : std_logic_vector(31 downto 0);
	signal trig_out : std_logic_vector( 63 downto 0);
	signal trig_oecsr : std_logic;
	signal trig_ckcsr : std_logic;
	signal DebugSignals : std_logic_vector(255 downto 0);
	signal AdditionalCountersOut : std_logic_vector(31 downto 0);
	signal PairSpecSignal, PairSpecSignal_Streched : std_logic;
	signal TaggerOR : std_logic_vector(7 downto 0);
	attribute keep of TaggerOR : signal is "TRUE";
	signal IN1IN2IN3IO1Mask : std_logic_vector(32*4-1 downto 0);
  signal TaggerInputs, RawTaggerInputs, TaggerInputs_Delayed : std_logic_vector(32*3-1 downto 0);
  signal EPTaggerInputs, EPTaggerInputs_Unordered, EPTaggerInputs_Delayed,
	  RawEPTaggerInputs, RawEPTaggerInputs_Unordered : std_logic_vector(31 downto 0);

  signal UseEPT : std_logic; -- set by trigger unit
   
	component trigger
		port (
			clock50 : in STD_LOGIC;
			clock100 : in STD_LOGIC;
			clock200 : in STD_LOGIC;
			clock400 : in STD_LOGIC;
			DebugSignals : in STD_LOGIC_VECTOR(255 downto 0);
			Tagger_In : in STD_LOGIC_VECTOR (32*3-1 downto 0);
			EPTagger_In : in STD_LOGIC_VECTOR (31 downto 0);
			TaggerOR : in STD_LOGIC_VECTOR(7 downto 0);
			trig_out : out STD_LOGIC_VECTOR ( 63 downto 0);
			InputMaskOut : out std_logic_vector(32*4-1 downto 0);
			nim_in   : in  STD_LOGIC;
			nim_out  : out STD_LOGIC;
			led	     : out STD_LOGIC_VECTOR(8 downto 1); -- 8 LEDs onboard
			pgxled   : out STD_LOGIC_VECTOR(8 downto 1); -- 8 LEDs on PIG board
			Global_Reset_After_Power_Up : in std_logic;
			VN2andVN1 : in std_logic_vector(7 downto 0);
			AdditionalCountersOut : out std_logic_vector(31 downto 0);
			UseEPT_out : out std_logic;
			--............................. vme interface ....................
			u_ad_reg :in std_logic_vector(11 downto 2);
			u_dat_in :in std_logic_vector(31 downto 0);
			u_data_o :out std_logic_vector(31 downto 0);
			oecsr, ckcsr:in std_logic
		);
	end component;

	------------------------------------------------------------------------------------------
	-- delay input signals
	------------------------------------------------------------------------------------------
	component delay_by_shiftregister is
		Generic (
			DELAY : integer
		);
		 Port ( CLK : in  STD_LOGIC;
				  SIG_IN : in  STD_LOGIC;
				  DELAY_OUT : out  STD_LOGIC);
	end component;
	
	signal scal_in_delayed : std_logic_vector(SCCH96-1 downto 0);
	
	component gate_by_shiftreg is
		Generic (
			WIDTH : integer
		);
		 Port ( CLK : in STD_LOGIC;
				  SIG_IN : in  STD_LOGIC;
				  GATE_OUT : out  STD_LOGIC);
	end component;



------------------------------------------------------------------------------------------
begin ---- BEGIN  BEGIN  BEGIN  BEGIN  BEGIN  BEGIN  BEGIN  BEGIN  BEGIN -----------------
------------------------------------------------------------------------------------------



--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
--     CLOCK 
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--

	clock_boost_1: clock_boost PORT MAP(
		CLKIN_N_IN => CKFNL,
		CLKIN_P_IN => CKFPL,
		CLK50MHz_OUT => clk50,
		CLK100MHz_OUT => clk100,
		CLK200MHz_OUT => clk200,
		CLK400MHz_OUT => clk400,
		CLK_LOCKED_OUT => clk_locked,
		CLK_RST_IN => clk_rst,
		clock1MHz_OUT => clk1,
		clock0_5Hz_OUT => open
	);

	------------------------------------------------------------------------------------------
	-- Reset after Power Up
	-- Needed e.g. for reset of PLL of clock boost 200 -> 200 MHz
	clk_rst(0) <= vme_clkrst(0);
	clk_rst(1) <= vme_clkrst(1) or Global_Reset_After_Power_Up_Delay_1msec;
	


--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
--     VME access 
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
	
	
	vme_access_1: vme_access PORT MAP(
		AD => AD,
		VME_Reset => VMEAccess_Reset,
		ASI => ASI,
		WRI => WRI,
		DS0I => DS0I,
		DS1I => DS1I,
		CON => CON,
		VN2andVN1 => VN2andVN1,
		CKADDR => ckaddr,
		WS => ws,
		CKCSR => ckcsr,
		OECSR => oecsr,
		U_AD_REG => u_ad_reg,
		U_DAT_IN => din,
		U_DAT_OUT => u_dat_in,
		CLK =>clk50
	);

	--VMEAccess_Reset <= LEMIN1;
	VMEAccess_Reset <= '0';
	BERRO		<= '1';  	-- H means inactive
	IACKOU	<= IACKII; 	-- interrupt acknowledge chain
--		SRESI				-- system reset
	CAIV		<=	'1';	-- clock for address ram0begister internal<-VME, disabled
	OAIV		<=	'1';	-- OE for address register internal<-VME, disabled, '1' means high
	IRBLO	<= '1';

	
---VME access for top level design 

	vme_clkstatus(1 downto 0) <= clk_locked(1 downto 0);
	ymdt(7 downto 0) <=  CONV_STD_LOGIC_VECTOR(TRIAL, 8);
	ymdt(15 downto 8) <=  CONV_STD_LOGIC_VECTOR(DATE, 8);
	ymdt(23 downto 16) <= CONV_STD_LOGIC_VECTOR(MONTH, 8);
	ymdt(31 downto 24) <= CONV_STD_LOGIC_VECTOR(YEAR, 8);

	process(clk50, oecsr, ckcsr, u_ad_reg)
	begin
		if (rising_edge(clk50)) then   
			if (oecsr ='1' and u_ad_reg(19 downto 12)=top_base) then 
				top_oecsr <='1';
			else
				top_oecsr <='0';
			end if;
			if (ckcsr ='1' and u_ad_reg(19 downto 12)=top_base) then 
				top_ckcsr <='1';
			else
				top_ckcsr <='0';
			end if;				
		end if;				
	end process;
-- Write cycle --
	process(clk50, top_ckcsr, u_ad_reg)
	begin
		if (clk50'event and clk50 ='1') then
			vme_clkrst(1) <='0';
			if (top_ckcsr='1' and u_ad_reg(11 downto 2)=vmead_clkstatus) then
					vme_clkrst(1) <= u_dat_in(1);
			end if;
		end if;
		vme_clkrst(0)<='0';
	end process; 

-----Read cycle ----
		process(clk50, top_oecsr, u_ad_reg)
		begin
   		if (clk50'event and clk50 ='1') then
				top_data_o <= (others => '0');
    			if (top_oecsr='1' and u_ad_reg(11 downto 2)=vmead_clkstatus) then 
							top_data_o <= EXT(vme_clkstatus,32); 
	    		elsif (top_oecsr='1' and u_ad_reg(11 downto 2)=vmead_ymdt) then 
							top_data_o <= ymdt;
	    		elsif (top_oecsr='1' and u_ad_reg(11 downto 2)=vmead_version) then 
							top_data_o <= version;
							
--	    		elsif (oecsr='1' and u_ad_reg(15 downto 4)=x"300" 
--					and u_ad_reg(3 downto 2)=b"10") then 
--							top_data_o <= tdcsetting;
--	    		elsif (oecsr='1' and u_ad_reg(15 downto 4)=x"300" 
--					and u_ad_reg(3 downto 2)=b"11") then 
--							top_data_o <= EXT(TDCOVF, 32);
				else top_data_o <=  (others =>'0');
				end if;    
			end if;
		end process;



----------------------- DATA  for OUTPUT to VME -------------------------------------------

		process(clk50, scal_oecsr_O, scal_oecsr_D, scal_oecsr_U, scal_oecsr_Mon, scal_oecsr_DAQMon, trig_oecsr, top_oecsr)
		begin
   			if (rising_edge(clk50)) then   
					if (scal_oecsr_O ='1' ) then
							din <= scal_data_o_O;
					elsif (scal_oecsr_D ='1' ) then
							din <= scal_data_o_D;
					elsif (scal_oecsr_U ='1' ) then
							din <= scal_data_o_U;
					elsif (scal_oecsr_Mon ='1' ) then
							din <= scal_data_o_Mon;
					elsif (scal_oecsr_DAQMon ='1' ) then
							din <= scal_data_o_DAQMon;
							
					elsif (trig_oecsr ='1' ) then
							din <= trig_data_o; 
					elsif (top_oecsr ='1') then
							din <= top_data_o; 
					elsif (disp_oecsr ='1') then
							din <= disp_data_o;
					else  	
						din <= (others => '0');
					end if;    
    			end if;
		end process;		
	

--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
--     Display
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
        DOUTLCD <= '0';
--		WRDIS	<= '1';

	disp_matrix1: display_matrix port map (
		VN2andVN1 => VN2andVN1,
		reset => res,
		lcd_din => DI(0),
		lcd_lp => DI(1), 
		lcd_flm => DI(2),
		lcd_scp => DI(3),
		lcd_led_grn => DI(4),
		lcd_led_red => DI(5),
		clk50 => clk50,
		disp_in => disp_in,
		u_ad_reg=>u_ad_reg(11 downto 2), 
		u_dat_in=>u_dat_in, 
		u_data_o=>disp_data_o,
		ckaddr=> ckaddr,
		ws=>ws,
		oecsr=>disp_oecsr, 
		ckcsr=>disp_ckcsr
	);
	-- vme_access --
	process(clk50, oecsr, ckcsr, u_ad_reg)
	begin
		if (rising_edge(clk50)) then   
			if (oecsr ='1' and u_ad_reg(19 downto 12)=disp_base) then 
				disp_oecsr <='1';
			else
				disp_oecsr <='0';
			end if;
			if (ckcsr ='1' and u_ad_reg(19 downto 12)=disp_base) then 
				disp_ckcsr <='1';
			else
				disp_ckcsr <='0';
			end if;				
		end if;				
	end process;

	disp_in(0)<= clk_locked(0) and clk_locked(1);
	disp_in(1)<= COD(1) or COD(2);
	disp_in(2)<= CON(7) or CON(8);
	disp_in(3)<= LEMIN1;
	
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
--     I/O
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
	vhdc_in( 31 downto 0)  <= IN1X ( 32 downto 1);
	vhdc_in( 63 downto 32) <= IN2X ( 32 downto 1);
	vhdc_in( 95 downto 64) <= IN3X ( 32 downto 1);
	vhdc_in( 127 downto 96) <= PGIO1X ( 32 downto 1);
	vhdc_in( 159 downto 128) <= PGIO2X ( 32 downto 1);
	vhdc_in( 191 downto 160) <= PGIO3X ( 32 downto 1);

	OU1X( 32 downto 1)   <= vhdc_out ( 31 downto 0);
	PGIO4X( 32 downto 1) <= vhdc_out ( 63 downto 32);

	vhdc_out <= trig_out;

-- scaler i/o

	-- Tagger
	RawTaggerInputs <= IN3X ( 32 downto 1) & IN2X ( 32 downto 1) & IN1X (32 downto 1); --free:PGIO2X ( 32 downto 1)
	TaggerInputs <= IN1IN2IN3IO1Mask(32*3-1 downto 0) and RawTaggerInputs;

	Delayboxes: for i in 0 to 3*32-1 generate --IN1, IN2, IN3
	begin
		delay_by_shiftregister_1: delay_by_shiftregister Generic MAP (	DELAY => 27 ) --Delay correct: 33, 9.10.2012
			 Port Map (
				 CLK => clk200,
				 SIG_IN => TaggerInputs(i),
				 DELAY_OUT => TaggerInputs_Delayed(i)
			);
	end generate;
	
	-- Tagger/EPT OR
	TaggerORs1: for i in 0 to 5 generate
		begin
			TaggerOR_1: TaggerOR(i) <= '1' when (TaggerInputs(i*16+15 downto i*16) /= "0") else '0';
	end generate;
	TaggerORsEPT: for i in 0 to 1 generate
		begin
			EPTTaggerOR_1: TaggerOR(i+6) <= '1' when (EPTaggerInputs(i*16+15 downto i*16) /= "0") else '0';
	end generate;

  -- invert EPT signals
	RawEPTaggerInputs_Unordered <= not PGIO1X;
	EPTaggerInputs_Unordered <= IN1IN2IN3IO1Mask(32*4-1 downto 32*3) and RawEPTaggerInputs_Unordered;
	
	-- EPT remapping
	EPTRemapping : for i in 0 to 15 generate
	begin
		RawEPTaggerInputs(i) <= RawEPTaggerInputs_Unordered(2*i);
		RawEPTaggerInputs(i+16) <= RawEPTaggerInputs_Unordered(2*i+1);
		EPTaggerInputs(i) <= EPTaggerInputs_Unordered(2*i);
		EPTaggerInputs(i+16) <= EPTaggerInputs_Unordered(2*i+1);
	end generate;

	DelayboxesEPT: for i in 0 to 31 generate 
	begin
		delay_by_shiftregister_1: delay_by_shiftregister
			Generic MAP (	DELAY => 22 ) -- measured with OsziHisto of Exptrigger vuprom  
			Port Map (
				CLK => clk200,
				SIG_IN => EPTaggerInputs(i),
				DELAY_OUT => EPTaggerInputs_Delayed(i)
			);
	end generate;

	
	-- debug signals
	DebugSignals(32*4-1 downto 0) <= RawEPTaggerInputs&RawTaggerInputs;
	DebugSignals(32*5-1 downto 32*4) <= PGIO3X;
	DebugSignals(15+32*5 downto 32*5) <= scal_in_D(15 downto 0);
	
	--PairSpec
	PairSpecSignal <= PGIO3X(7); --IO3, ch6
		
	gate_by_shiftreg_GateSignal_1: gate_by_shiftreg Generic MAP (
				WIDTH => 10 --9.10.2012: Value=15 (result: gate length of 12*5ns (with 1-2*5ns jitter))
			)
		 Port MAP ( CLK => clk200,
				  SIG_IN => PairSpecSignal,
				  GATE_OUT => PairSpecSignal_Streched
		);
		
	
	DebugSignals(253 downto 253-7) <= TaggerOR;
	DebugSignals(254) <= PairSpecSignal_Streched;
	DebugSignals(255) <= LEMIN1; --that's the NIM
	
	--Mon
	scal_in_Mon(7 downto 0) <= TaggerOR;
	scal_in_Mon(15 downto 8) <= clk1& PGIO3X(13 downto 7);
	
	--Gates
	scal_Gate_Open <= LEMIN1;
	scal_Gate_PairSpec <= scal_Gate_Open and PairSpecSignal_Streched;
	
	
	-- trigger i/o
	LEMOE <='1'; -- LEMTTL set to Z.
	LEMOTTL <='0'; 
	

	----- DSP ------
	BCLK	<= clk50;
	BHOLD	<= '0';
	BRDY	<= '1';
	ARDY	<= '1';
	AHOLD	<= '1';
	NMI	<=	'Z';
	TINP	<=	(others => '0');
	DS <= (others =>'Z');
	DSPRS <='Z';

	---- SRAM -----
	SCS	<= '1';
	SOE	<= '1';
	SWE	<= '1';
	SAD		<=	(others => 'Z');
	SDA		<=	(others => 'Z'); 
	--was: CON(15 downto 9)		<=	b"0000000";
	CON(11 downto 9)		<=	b"000"; -- because Con 15 downto 12 is used for reading of wheels VN1 and VN2


	--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
	--     SCALER
	--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--

	mux_tagger_or_EPT : process(UseEPT)
	begin
		if UseEPT = '1' then
			scal_in_O(31 downto 0)  <= EPTaggerInputs;
			scal_in_O(95 downto 32) <= (others =>'0');
			scal_in_D(31 downto 0)  <= EPTaggerInputs_Delayed;
			scal_in_D(95 downto 32) <= (others =>'0');
		else
			scal_in_O <= TaggerInputs;
			scal_in_D <= TaggerInputs_Delayed;
		end if;
	end process;	
	
	scaler_O : scaler
		generic map (NCh => SCCH96)
		port map (clkl		 => clk50, clkh => clk200, scal_in => scal_in_O, ScalerGate => scal_Gate_Open,
							u_ad_reg => u_ad_reg(11 downto 2), u_dat_in => u_dat_in, u_data_o => scal_data_o_O,
							oecsr		 => scal_oecsr_O, ckcsr => scal_ckcsr_O);
	scaler_D : scaler
		generic map (NCh => SCCH96)
		port map (clkl		 => clk50, clkh => clk200, scal_in => scal_in_D, ScalerGate => scal_Gate_PairSpec,
							u_ad_reg => u_ad_reg(11 downto 2), u_dat_in => u_dat_in, u_data_o => scal_data_o_D,
							oecsr		 => scal_oecsr_D, ckcsr => scal_ckcsr_D);

	scaler_U : scaler
		generic map (NCh => SCCH96)
		port map (clkl		 => clk50, clkh => clk200, scal_in => scal_in_O, ScalerGate => scal_Gate_PairSpec,
							u_ad_reg => u_ad_reg(11 downto 2), u_dat_in => u_dat_in, u_data_o => scal_data_o_U,
							oecsr		 => scal_oecsr_U, ckcsr => scal_ckcsr_U);

	scaler_Mon : scaler
		generic map (NCh => SCCHMon)
		port map (clkl		 => clk50, clkh => clk100, scal_in => scal_in_Mon, ScalerGate => '1',
							u_ad_reg => u_ad_reg(11 downto 2), u_dat_in => u_dat_in, u_data_o => scal_data_o_Mon,
							oecsr		 => scal_oecsr_Mon, ckcsr => scal_ckcsr_Mon);

	scaler_DAQMon : scaler
		generic map (NCh => SCCHMon)
		port map (clkl		 => clk50, clkh => clk100, scal_in => scal_in_Mon, ScalerGate => scal_Gate_Open,
							u_ad_reg => u_ad_reg(11 downto 2), u_dat_in => u_dat_in, u_data_o => scal_data_o_DAQMon,
							oecsr		 => scal_oecsr_DAQMon, ckcsr => scal_ckcsr_DAQMon);

	
	
	process(clk50, oecsr, ckcsr, u_ad_reg)
	begin
		if (rising_edge(clk50)) then   
		--scaler--
			if (oecsr = '1' and u_ad_reg(19 downto 12) = scal_base_O)    then scal_oecsr_O <='1'; else scal_oecsr_O <='0'; end if;
			if (ckcsr = '1' and u_ad_reg(19 downto 12) = scal_base_O)    then scal_ckcsr_O <='1'; else scal_ckcsr_O <='0';	end if;	

			if (oecsr = '1' and u_ad_reg(19 downto 12) = scal_base_D)    then scal_oecsr_D <='1'; else scal_oecsr_D <='0'; end if;
			if (ckcsr = '1' and u_ad_reg(19 downto 12) = scal_base_D)    then scal_ckcsr_D <='1'; else scal_ckcsr_D <='0';	end if;	

			if (oecsr = '1' and u_ad_reg(19 downto 12) = scal_base_U)    then scal_oecsr_U <='1'; else scal_oecsr_U <='0'; end if;
			if (ckcsr = '1' and u_ad_reg(19 downto 12) = scal_base_U)    then scal_ckcsr_U <='1'; else scal_ckcsr_U <='0';	end if;	

			if (oecsr = '1' and u_ad_reg(19 downto 12) = scal_base_Mon)  then scal_oecsr_Mon <='1'; else scal_oecsr_Mon <='0'; end if;
			if (ckcsr = '1' and u_ad_reg(19 downto 12) = scal_base_Mon)  then scal_ckcsr_Mon <='1'; else scal_ckcsr_Mon <='0';	end if;	

			if (oecsr = '1' and u_ad_reg(19 downto 12) = scal_base_DAQMon)  then scal_oecsr_DAQMon <='1'; else scal_oecsr_DAQMon <='0'; end if;
			if (ckcsr = '1' and u_ad_reg(19 downto 12) = scal_base_DAQMon)  then scal_ckcsr_DAQMon <='1'; else scal_ckcsr_DAQMon <='0';	end if;	
		end if;				
	end process;
		

	--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
	--     TRIGGER
	--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
	
	trigger_1: trigger port map (
			clock50=>clk50,
			clock100=>clk100,
			clock200=>clk200,
			clock400=>clk400,
			DebugSignals => DebugSignals,
			Tagger_In=>RawTaggerInputs,
			EPTagger_In=>RawEPTaggerInputs,
			TaggerOR => TaggerOR,
			trig_out=>trig_out,
			InputMaskOut => IN1IN2IN3IO1Mask,
			nim_in => LEMIN1,
			nim_out => LEMONIM,
			led => led,
			pgxled => pgxled,
			Global_Reset_After_Power_Up => Global_Reset_After_Power_Up_Delay_1msec,
			VN2andVN1 => VN2andVN1,
			AdditionalCountersOut => AdditionalCountersOut,
			UseEPT_out => UseEPT,
			u_ad_reg=>u_ad_reg(11 downto 2), 
			u_dat_in=>u_dat_in, 
			u_data_o=>trig_data_o,
			oecsr=>trig_oecsr, 
			ckcsr=>trig_ckcsr
		);									
	process(clk50, oecsr, ckcsr, u_ad_reg)
	begin
		if (rising_edge(clk50)) then   

			if (oecsr ='1' and u_ad_reg(19 downto 12)=trig_base) then 
				trig_oecsr <='1';
			else
				trig_oecsr <='0';
			end if;
			if (ckcsr ='1' and u_ad_reg(19 downto 12)=trig_base) then 
				trig_ckcsr <='1';
			else
				trig_ckcsr <='0';
			end if;						

		end if;				
	end process;
		
--======================================================================================================

------------------------------------------------------------------------------
-- * HPLA @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ Logic Analyzer @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
------------------------------------
-- 	odvi <= CON(4); 	cdvi	<=	CON(3); 	odiv <= CON(2);	cdiv <= CON(1); 	ack_csr <= CON(0);	-- from fpga to cpld
--		odvi <= '1'; 		cdvi	<=	'0'; 		odiv <= '1';		cdiv <= '1'; 		dack_i <= '1';			-- from fpga to cpld


--		hpv(15 downto 7) <= (others => '0');
	hpw(7 downto 0) <= x"00";
	hpw(8) <= '0' when led_out(15 downto 0)=x"0000" else '1';
	hpw(9) <= LEMIN1;
	hpw(15 downto 10) <= IN1X ( 6 downto 1);



	hpv(0)<=CON(7);
	hpv(1)<=CON(8);
	hpv(6 downto 2)<=CON(4 downto 0);
	hpv(7) <= clk50;
	hpv(15 downto 8 ) <= (others => '0');
	


	------------------------------------------------------------------------------------------

	------------------------------------------------------------------------------------------
	-- Reset after Power Up
	-- Needed e.g. for reset of PLL of clock boost 200 -> 400 MHz
	------------------------------------------------------------------------------------------
	process (clk50)
		variable ZaehlerGlobalModuleStep : integer;
	begin
		if rising_edge(Clk50) then	
			if Global_Module_Step /= Working then
				ZaehlerGlobalModuleStep := ZaehlerGlobalModuleStep + 1;
			end if;
			
			if ZaehlerGlobalModuleStep < 50000*1 then -- before 1 msecond
				Global_Module_Step <= PreInit;
			elsif ZaehlerGlobalModuleStep < 50000*2 then -- before 2 mseconds
				Global_Module_Step <= Init;
			elsif ZaehlerGlobalModuleStep < 50000*3 then -- before 3 mseconds
				Global_Module_Step <= PostInit;
			else
				Global_Module_Step <= Working;
			end if;

		end if;
	end process;


	process (Global_Module_Step)
	begin
		case Global_Module_Step is
			when PreInit => 
				Global_Reset_After_Power_Up_Delay_1msec <= '0';
			when Init =>
				Global_Reset_After_Power_Up_Delay_1msec <= '1';
			when PostInit =>
				Global_Reset_After_Power_Up_Delay_1msec <= '0';
			when Working => 
				Global_Reset_After_Power_Up_Delay_1msec <= '0';
		end case;
	end process;
	
end rtl;
