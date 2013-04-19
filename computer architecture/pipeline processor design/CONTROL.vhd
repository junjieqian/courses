-- Computer Architecture Project
-- Spring 2012

-- control module (implements MIPS control unit)
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_SIGNED.ALL;
USE WORK.LCSTYPES.ALL;

ENTITY Control IS
   PORT( 	
		ID_CPU_inst				: IN	LCSInstruction;
		Branch_freeze			: OUT STD_LOGIC;
		
		--Exec to InstDec Forwarding
		EX_CPU_inst				: IN	LCSInstruction;
		EX_ALU_Result 			: IN	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
		Ctrl_EX_isModReg		: OUT STD_LOGIC;
		Ctrl_EX_modRegAddr	: OUT STD_LOGIC_VECTOR( 4 DOWNTO 0 );
		Ctrl_EX_modRegValue	: OUT STD_LOGIC_VECTOR( 31 DOWNTO 0 );
	
		--From DM
		DM_CPU_inst				: IN	LCSInstruction;
		DM_dmem_data 			: IN	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
		Ctrl_DM_isLoading		: OUT STD_LOGIC;
		Ctrl_DM_modRegAddr	: OUT STD_LOGIC_VECTOR( 4 DOWNTO 0 );
		Ctrl_DM_modRegValue	: OUT STD_LOGIC_VECTOR( 31 DOWNTO 0 )		
	);

END Control;

ARCHITECTURE behavior OF Control IS
	
	SIGNAL Ctrl_RALD_Hazard, Ctrl_Branch_Hazard	: STD_LOGIC := '0';
	SIGNAL EX_isModReg, DM_isLoading					: STD_LOGIC := '0';
	SIGNAL EX_modRegAddr, DM_modRegAddr				: STD_LOGIC_VECTOR( 4 DOWNTO 0 );

BEGIN           

	Ctrl_EX_isModReg		<= EX_isModReg;
	Ctrl_EX_modRegAddr	<= EX_modRegAddr;
	Ctrl_DM_isLoading		<= DM_isLoading;
	Ctrl_DM_modRegAddr	<= DM_modRegAddr;
	
	--Execute
		EX_isModReg	<=  '1'
			WHEN ((EX_CPU_inst.alu = add) OR (EX_CPU_inst.alu = addi) OR (EX_CPU_inst.alu = subtract) OR (EX_CPU_inst.alu = slt))
			ELSE '0';
			
		--rd is the destination for Rtype, rt is the dest reg for the Itype
		EX_modRegAddr <= EX_CPU_inst.rd --rd  
			WHEN ((EX_CPU_inst.alu = add) OR (EX_CPU_inst.alu = subtract) OR (EX_CPU_inst.alu = slt)) --R-type instruction	
			ELSE EX_CPU_inst.rt;  

		Ctrl_EX_modRegValue <= EX_ALU_Result;

	--DataMemory
		DM_isLoading	<=  '1' WHEN DM_CPU_inst.alu = load ELSE '0';
			
		--rd is the destination for Rtype, rt is the dest reg for the Itype
		DM_modRegAddr <= DM_CPU_inst.rt;  --rt
		Ctrl_DM_modRegValue <= DM_dmem_data;

		--RAR Hazard (A lw instruction followed by a read on the load)
		Ctrl_RALD_Hazard <= '0'
			WHEN EX_CPU_inst.alu /= load
			ELSE '1' WHEN EX_CPU_inst.rt = ID_CPU_inst.rs OR EX_CPU_inst.rt = ID_CPU_inst.rt  --rt  --Conflict between lw register and read registers
			ELSE '0';
			
		--If id=branch  & Ex OR Ld proucing operands
		--ID Freeze
		--EX Bubble
		--IF Freeze
		Ctrl_Branch_Hazard <= '1' 
			WHEN 	(ID_CPU_inst.alu = brancheq) AND 
			(   ((EX_isModReg = '1') AND (EX_modRegAddr = ID_CPU_inst.rt OR EX_modRegAddr = ID_CPU_inst.rs)) OR	
			    ((DM_isLoading= '1') AND (DM_modRegAddr = ID_CPU_inst.rt OR DM_modRegAddr = ID_CPU_inst.rs))      )
			ELSE '0';
	
		Branch_freeze <= '1' WHEN (Ctrl_Branch_Hazard = '1' OR Ctrl_RALD_Hazard ='1')
			ELSE '0';
	
END behavior;


