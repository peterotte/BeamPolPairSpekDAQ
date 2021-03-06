-- Peter-Bernd Otte
-- 2.9.2012

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity DebugChSelector is
    Port ( DebugSignalsIn : in  STD_LOGIC_VECTOR (255 downto 0);
           SelectedInput : in  STD_LOGIC_VECTOR (7 downto 0);
           SelectedOutput : out  STD_LOGIC);
end DebugChSelector;

architecture Behavioral of DebugChSelector is
begin
	SelectedOutput <= 
		DebugSignalsIn(0) when SelectedInput = x"00" else
		DebugSignalsIn(1) when SelectedInput = x"01" else
		DebugSignalsIn(2) when SelectedInput = x"02" else
		DebugSignalsIn(3) when SelectedInput = x"03" else
		DebugSignalsIn(4) when SelectedInput = x"04" else
		DebugSignalsIn(5) when SelectedInput = x"05" else
		DebugSignalsIn(6) when SelectedInput = x"06" else
		DebugSignalsIn(7) when SelectedInput = x"07" else
		DebugSignalsIn(8) when SelectedInput = x"08" else
		DebugSignalsIn(9) when SelectedInput = x"09" else
		DebugSignalsIn(10) when SelectedInput = x"0A" else
		DebugSignalsIn(11) when SelectedInput = x"0B" else
		DebugSignalsIn(12) when SelectedInput = x"0C" else
		DebugSignalsIn(13) when SelectedInput = x"0D" else
		DebugSignalsIn(14) when SelectedInput = x"0E" else
		DebugSignalsIn(15) when SelectedInput = x"0F" else
		DebugSignalsIn(16) when SelectedInput = x"10" else
		DebugSignalsIn(17) when SelectedInput = x"11" else
		DebugSignalsIn(18) when SelectedInput = x"12" else
		DebugSignalsIn(19) when SelectedInput = x"13" else
		DebugSignalsIn(20) when SelectedInput = x"14" else
		DebugSignalsIn(21) when SelectedInput = x"15" else
		DebugSignalsIn(22) when SelectedInput = x"16" else
		DebugSignalsIn(23) when SelectedInput = x"17" else
		DebugSignalsIn(24) when SelectedInput = x"18" else
		DebugSignalsIn(25) when SelectedInput = x"19" else
		DebugSignalsIn(26) when SelectedInput = x"1A" else
		DebugSignalsIn(27) when SelectedInput = x"1B" else
		DebugSignalsIn(28) when SelectedInput = x"1C" else
		DebugSignalsIn(29) when SelectedInput = x"1D" else
		DebugSignalsIn(30) when SelectedInput = x"1E" else
		DebugSignalsIn(31) when SelectedInput = x"1F" else
		DebugSignalsIn(32) when SelectedInput = x"20" else
		DebugSignalsIn(33) when SelectedInput = x"21" else
		DebugSignalsIn(34) when SelectedInput = x"22" else
		DebugSignalsIn(35) when SelectedInput = x"23" else
		DebugSignalsIn(36) when SelectedInput = x"24" else
		DebugSignalsIn(37) when SelectedInput = x"25" else
		DebugSignalsIn(38) when SelectedInput = x"26" else
		DebugSignalsIn(39) when SelectedInput = x"27" else
		DebugSignalsIn(40) when SelectedInput = x"28" else
		DebugSignalsIn(41) when SelectedInput = x"29" else
		DebugSignalsIn(42) when SelectedInput = x"2A" else
		DebugSignalsIn(43) when SelectedInput = x"2B" else
		DebugSignalsIn(44) when SelectedInput = x"2C" else
		DebugSignalsIn(45) when SelectedInput = x"2D" else
		DebugSignalsIn(46) when SelectedInput = x"2E" else
		DebugSignalsIn(47) when SelectedInput = x"2F" else
		DebugSignalsIn(48) when SelectedInput = x"30" else
		DebugSignalsIn(49) when SelectedInput = x"31" else
		DebugSignalsIn(50) when SelectedInput = x"32" else
		DebugSignalsIn(51) when SelectedInput = x"33" else
		DebugSignalsIn(52) when SelectedInput = x"34" else
		DebugSignalsIn(53) when SelectedInput = x"35" else
		DebugSignalsIn(54) when SelectedInput = x"36" else
		DebugSignalsIn(55) when SelectedInput = x"37" else
		DebugSignalsIn(56) when SelectedInput = x"38" else
		DebugSignalsIn(57) when SelectedInput = x"39" else
		DebugSignalsIn(58) when SelectedInput = x"3A" else
		DebugSignalsIn(59) when SelectedInput = x"3B" else
		DebugSignalsIn(60) when SelectedInput = x"3C" else
		DebugSignalsIn(61) when SelectedInput = x"3D" else
		DebugSignalsIn(62) when SelectedInput = x"3E" else
		DebugSignalsIn(63) when SelectedInput = x"3F" else
		DebugSignalsIn(64) when SelectedInput = x"40" else
		DebugSignalsIn(65) when SelectedInput = x"41" else
		DebugSignalsIn(66) when SelectedInput = x"42" else
		DebugSignalsIn(67) when SelectedInput = x"43" else
		DebugSignalsIn(68) when SelectedInput = x"44" else
		DebugSignalsIn(69) when SelectedInput = x"45" else
		DebugSignalsIn(70) when SelectedInput = x"46" else
		DebugSignalsIn(71) when SelectedInput = x"47" else
		DebugSignalsIn(72) when SelectedInput = x"48" else
		DebugSignalsIn(73) when SelectedInput = x"49" else
		DebugSignalsIn(74) when SelectedInput = x"4A" else
		DebugSignalsIn(75) when SelectedInput = x"4B" else
		DebugSignalsIn(76) when SelectedInput = x"4C" else
		DebugSignalsIn(77) when SelectedInput = x"4D" else
		DebugSignalsIn(78) when SelectedInput = x"4E" else
		DebugSignalsIn(79) when SelectedInput = x"4F" else
		DebugSignalsIn(80) when SelectedInput = x"50" else
		DebugSignalsIn(81) when SelectedInput = x"51" else
		DebugSignalsIn(82) when SelectedInput = x"52" else
		DebugSignalsIn(83) when SelectedInput = x"53" else
		DebugSignalsIn(84) when SelectedInput = x"54" else
		DebugSignalsIn(85) when SelectedInput = x"55" else
		DebugSignalsIn(86) when SelectedInput = x"56" else
		DebugSignalsIn(87) when SelectedInput = x"57" else
		DebugSignalsIn(88) when SelectedInput = x"58" else
		DebugSignalsIn(89) when SelectedInput = x"59" else
		DebugSignalsIn(90) when SelectedInput = x"5A" else
		DebugSignalsIn(91) when SelectedInput = x"5B" else
		DebugSignalsIn(92) when SelectedInput = x"5C" else
		DebugSignalsIn(93) when SelectedInput = x"5D" else
		DebugSignalsIn(94) when SelectedInput = x"5E" else
		DebugSignalsIn(95) when SelectedInput = x"5F" else
		DebugSignalsIn(96) when SelectedInput = x"60" else
		DebugSignalsIn(97) when SelectedInput = x"61" else
		DebugSignalsIn(98) when SelectedInput = x"62" else
		DebugSignalsIn(99) when SelectedInput = x"63" else
		DebugSignalsIn(100) when SelectedInput = x"64" else
		DebugSignalsIn(101) when SelectedInput = x"65" else
		DebugSignalsIn(102) when SelectedInput = x"66" else
		DebugSignalsIn(103) when SelectedInput = x"67" else
		DebugSignalsIn(104) when SelectedInput = x"68" else
		DebugSignalsIn(105) when SelectedInput = x"69" else
		DebugSignalsIn(106) when SelectedInput = x"6A" else
		DebugSignalsIn(107) when SelectedInput = x"6B" else
		DebugSignalsIn(108) when SelectedInput = x"6C" else
		DebugSignalsIn(109) when SelectedInput = x"6D" else
		DebugSignalsIn(110) when SelectedInput = x"6E" else
		DebugSignalsIn(111) when SelectedInput = x"6F" else
		DebugSignalsIn(112) when SelectedInput = x"70" else
		DebugSignalsIn(113) when SelectedInput = x"71" else
		DebugSignalsIn(114) when SelectedInput = x"72" else
		DebugSignalsIn(115) when SelectedInput = x"73" else
		DebugSignalsIn(116) when SelectedInput = x"74" else
		DebugSignalsIn(117) when SelectedInput = x"75" else
		DebugSignalsIn(118) when SelectedInput = x"76" else
		DebugSignalsIn(119) when SelectedInput = x"77" else
		DebugSignalsIn(120) when SelectedInput = x"78" else
		DebugSignalsIn(121) when SelectedInput = x"79" else
		DebugSignalsIn(122) when SelectedInput = x"7A" else
		DebugSignalsIn(123) when SelectedInput = x"7B" else
		DebugSignalsIn(124) when SelectedInput = x"7C" else
		DebugSignalsIn(125) when SelectedInput = x"7D" else
		DebugSignalsIn(126) when SelectedInput = x"7E" else
		DebugSignalsIn(127) when SelectedInput = x"7F" else
		DebugSignalsIn(128) when SelectedInput = x"80" else
		DebugSignalsIn(129) when SelectedInput = x"81" else
		DebugSignalsIn(130) when SelectedInput = x"82" else
		DebugSignalsIn(131) when SelectedInput = x"83" else
		DebugSignalsIn(132) when SelectedInput = x"84" else
		DebugSignalsIn(133) when SelectedInput = x"85" else
		DebugSignalsIn(134) when SelectedInput = x"86" else
		DebugSignalsIn(135) when SelectedInput = x"87" else
		DebugSignalsIn(136) when SelectedInput = x"88" else
		DebugSignalsIn(137) when SelectedInput = x"89" else
		DebugSignalsIn(138) when SelectedInput = x"8A" else
		DebugSignalsIn(139) when SelectedInput = x"8B" else
		DebugSignalsIn(140) when SelectedInput = x"8C" else
		DebugSignalsIn(141) when SelectedInput = x"8D" else
		DebugSignalsIn(142) when SelectedInput = x"8E" else
		DebugSignalsIn(143) when SelectedInput = x"8F" else
		DebugSignalsIn(144) when SelectedInput = x"90" else
		DebugSignalsIn(145) when SelectedInput = x"91" else
		DebugSignalsIn(146) when SelectedInput = x"92" else
		DebugSignalsIn(147) when SelectedInput = x"93" else
		DebugSignalsIn(148) when SelectedInput = x"94" else
		DebugSignalsIn(149) when SelectedInput = x"95" else
		DebugSignalsIn(150) when SelectedInput = x"96" else
		DebugSignalsIn(151) when SelectedInput = x"97" else
		DebugSignalsIn(152) when SelectedInput = x"98" else
		DebugSignalsIn(153) when SelectedInput = x"99" else
		DebugSignalsIn(154) when SelectedInput = x"9A" else
		DebugSignalsIn(155) when SelectedInput = x"9B" else
		DebugSignalsIn(156) when SelectedInput = x"9C" else
		DebugSignalsIn(157) when SelectedInput = x"9D" else
		DebugSignalsIn(158) when SelectedInput = x"9E" else
		DebugSignalsIn(159) when SelectedInput = x"9F" else
		DebugSignalsIn(160) when SelectedInput = x"A0" else
		DebugSignalsIn(161) when SelectedInput = x"A1" else
		DebugSignalsIn(162) when SelectedInput = x"A2" else
		DebugSignalsIn(163) when SelectedInput = x"A3" else
		DebugSignalsIn(164) when SelectedInput = x"A4" else
		DebugSignalsIn(165) when SelectedInput = x"A5" else
		DebugSignalsIn(166) when SelectedInput = x"A6" else
		DebugSignalsIn(167) when SelectedInput = x"A7" else
		DebugSignalsIn(168) when SelectedInput = x"A8" else
		DebugSignalsIn(169) when SelectedInput = x"A9" else
		DebugSignalsIn(170) when SelectedInput = x"AA" else
		DebugSignalsIn(171) when SelectedInput = x"AB" else
		DebugSignalsIn(172) when SelectedInput = x"AC" else
		DebugSignalsIn(173) when SelectedInput = x"AD" else
		DebugSignalsIn(174) when SelectedInput = x"AE" else
		DebugSignalsIn(175) when SelectedInput = x"AF" else
		DebugSignalsIn(176) when SelectedInput = x"B0" else
		DebugSignalsIn(177) when SelectedInput = x"B1" else
		DebugSignalsIn(178) when SelectedInput = x"B2" else
		DebugSignalsIn(179) when SelectedInput = x"B3" else
		DebugSignalsIn(180) when SelectedInput = x"B4" else
		DebugSignalsIn(181) when SelectedInput = x"B5" else
		DebugSignalsIn(182) when SelectedInput = x"B6" else
		DebugSignalsIn(183) when SelectedInput = x"B7" else
		DebugSignalsIn(184) when SelectedInput = x"B8" else
		DebugSignalsIn(185) when SelectedInput = x"B9" else
		DebugSignalsIn(186) when SelectedInput = x"BA" else
		DebugSignalsIn(187) when SelectedInput = x"BB" else
		DebugSignalsIn(188) when SelectedInput = x"BC" else
		DebugSignalsIn(189) when SelectedInput = x"BD" else
		DebugSignalsIn(190) when SelectedInput = x"BE" else
		DebugSignalsIn(191) when SelectedInput = x"BF" else
		DebugSignalsIn(192) when SelectedInput = x"C0" else
		DebugSignalsIn(193) when SelectedInput = x"C1" else
		DebugSignalsIn(194) when SelectedInput = x"C2" else
		DebugSignalsIn(195) when SelectedInput = x"C3" else
		DebugSignalsIn(196) when SelectedInput = x"C4" else
		DebugSignalsIn(197) when SelectedInput = x"C5" else
		DebugSignalsIn(198) when SelectedInput = x"C6" else
		DebugSignalsIn(199) when SelectedInput = x"C7" else
		DebugSignalsIn(200) when SelectedInput = x"C8" else
		DebugSignalsIn(201) when SelectedInput = x"C9" else
		DebugSignalsIn(202) when SelectedInput = x"CA" else
		DebugSignalsIn(203) when SelectedInput = x"CB" else
		DebugSignalsIn(204) when SelectedInput = x"CC" else
		DebugSignalsIn(205) when SelectedInput = x"CD" else
		DebugSignalsIn(206) when SelectedInput = x"CE" else
		DebugSignalsIn(207) when SelectedInput = x"CF" else
		DebugSignalsIn(208) when SelectedInput = x"D0" else
		DebugSignalsIn(209) when SelectedInput = x"D1" else
		DebugSignalsIn(210) when SelectedInput = x"D2" else
		DebugSignalsIn(211) when SelectedInput = x"D3" else
		DebugSignalsIn(212) when SelectedInput = x"D4" else
		DebugSignalsIn(213) when SelectedInput = x"D5" else
		DebugSignalsIn(214) when SelectedInput = x"D6" else
		DebugSignalsIn(215) when SelectedInput = x"D7" else
		DebugSignalsIn(216) when SelectedInput = x"D8" else
		DebugSignalsIn(217) when SelectedInput = x"D9" else
		DebugSignalsIn(218) when SelectedInput = x"DA" else
		DebugSignalsIn(219) when SelectedInput = x"DB" else
		DebugSignalsIn(220) when SelectedInput = x"DC" else
		DebugSignalsIn(221) when SelectedInput = x"DD" else
		DebugSignalsIn(222) when SelectedInput = x"DE" else
		DebugSignalsIn(223) when SelectedInput = x"DF" else
		DebugSignalsIn(224) when SelectedInput = x"E0" else
		DebugSignalsIn(225) when SelectedInput = x"E1" else
		DebugSignalsIn(226) when SelectedInput = x"E2" else
		DebugSignalsIn(227) when SelectedInput = x"E3" else
		DebugSignalsIn(228) when SelectedInput = x"E4" else
		DebugSignalsIn(229) when SelectedInput = x"E5" else
		DebugSignalsIn(230) when SelectedInput = x"E6" else
		DebugSignalsIn(231) when SelectedInput = x"E7" else
		DebugSignalsIn(232) when SelectedInput = x"E8" else
		DebugSignalsIn(233) when SelectedInput = x"E9" else
		DebugSignalsIn(234) when SelectedInput = x"EA" else
		DebugSignalsIn(235) when SelectedInput = x"EB" else
		DebugSignalsIn(236) when SelectedInput = x"EC" else
		DebugSignalsIn(237) when SelectedInput = x"ED" else
		DebugSignalsIn(238) when SelectedInput = x"EE" else
		DebugSignalsIn(239) when SelectedInput = x"EF" else
		DebugSignalsIn(240) when SelectedInput = x"F0" else
		DebugSignalsIn(241) when SelectedInput = x"F1" else
		DebugSignalsIn(242) when SelectedInput = x"F2" else
		DebugSignalsIn(243) when SelectedInput = x"F3" else
		DebugSignalsIn(244) when SelectedInput = x"F4" else
		DebugSignalsIn(245) when SelectedInput = x"F5" else
		DebugSignalsIn(246) when SelectedInput = x"F6" else
		DebugSignalsIn(247) when SelectedInput = x"F7" else
		DebugSignalsIn(248) when SelectedInput = x"F8" else
		DebugSignalsIn(249) when SelectedInput = x"F9" else
		DebugSignalsIn(250) when SelectedInput = x"FA" else
		DebugSignalsIn(251) when SelectedInput = x"FB" else
		DebugSignalsIn(252) when SelectedInput = x"FC" else
		DebugSignalsIn(253) when SelectedInput = x"FD" else
		DebugSignalsIn(254) when SelectedInput = x"FE" else
		DebugSignalsIn(255) when SelectedInput = x"FF" else
		'0';

end Behavioral;

