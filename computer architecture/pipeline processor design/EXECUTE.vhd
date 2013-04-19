-- Computer Architecture Project
-- Spring 2012


--  Execute module (implements the data ALU and Branch Address Adder  
--  for the MIPS computer)
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_SIGNED.ALL;
USE WORK.LCSTYPES.ALL;

--Executes the instruction
--Starts at the Rising Edge of the clock.
--Output can change before the Trailing Edge if DM forwards some memory Data
--DM will have to have the data ready before Trailing, for the case when the Inst is a branch
--since IF expects to latch at the trailing edge


ENTITY  Execute IS
	PORT(	
		clock, reset		: IN 	STD_LOGIC;
		ALU_Result_out		: OUT	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
		Read_data_1 		: IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
		Read_data_2 		: IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
		write_data_out		: OUT STD_LOGIC_VECTOR( 31 DOWNTO 0);
		
		--WriteThrough
		CPU_inst				: IN 	LCSInstruction;
		CPU_inst_out		: OUT	LCSInstruction;		
		
		--Forwarding Unit
		Branch_freeze			: IN STD_LOGIC;
		Ctrl_DM_isLoading		: IN STD_LOGIC;
		Ctrl_DM_modRegAddr	: IN STD_LOGIC_VECTOR( 4 DOWNTO 0 );
		Ctrl_DM_modRegValue	: IN STD_LOGIC_VECTOR( 31 DOWNTO 0 );
		Ctrl_EX_isModReg		: IN STD_LOGIC;
		Ctrl_EX_modRegAddr	: IN STD_LOGIC_VECTOR( 4 DOWNTO 0 );
		Ctrl_EX_modRegValue	: IN STD_LOGIC_VECTOR( 31 DOWNTO 0 )
	);
END Execute;

ARCHITECTURE behavior OF Execute IS

SIGNAL Ainput, Binput 	: STD_LOGIC_VECTOR( 31 DOWNTO 0 );
SIGNAL ALU_output_mux	: STD_LOGIC_VECTOR( 31 DOWNTO 0 );

--Latched
SIGNAL EX_Read_data_1 		: STD_LOGIC_VECTOR( 31 DOWNTO 0 );
SIGNAL EX_Read_data_2 		: STD_LOGIC_VECTOR( 31 DOWNTO 0 );
SIGNAL EX_CPU_inst			: LCSInstruction;

		--Forwarding Unit
SIGNAL DM_isLoading			: STD_LOGIC := '0';
SIGNAL DM_modRegAddr			: STD_LOGIC_VECTOR( 4 DOWNTO 0 );
SIGNAL DM_modRegValue		: STD_LOGIC_VECTOR( 31 DOWNTO 0 );
SIGNAL Last_EX_isModReg		: STD_LOGIC := '0';
SIGNAL Last_EX_modRegAddr	: STD_LOGIC_VECTOR( 4 DOWNTO 0 );
SIGNAL Last_EX_modRegValue	: STD_LOGIC_VECTOR( 31 DOWNTO 0 );

BEGIN

		-- ALU input mux
	Ainput <= Last_EX_modRegValue WHEN (Last_EX_isModReg = '1' AND Last_EX_modRegAddr = EX_CPU_inst.rs)
		ELSE DM_modRegValue WHEN (DM_isLoading = '1' AND DM_modRegAddr = EX_CPU_inst.rs)
		ELSE EX_Read_data_1;
		
	Binput <= Last_EX_modRegValue WHEN (Last_EX_isModReg = '1' AND Last_EX_modRegAddr = EX_CPU_inst.rt)
		ELSE DM_modRegValue WHEN (DM_isLoading = '1' AND DM_modRegAddr = EX_CPU_inst.rt)
		ELSE EX_Read_data_2;
		
	write_data_out <= Binput;

	ALU_result_out <= ALU_output_mux;

	
	
PROCESS ( EX_CPU_inst, Ainput, Binput ) BEGIN

 	CASE EX_CPU_inst.alu IS
	 	WHEN add 								=>	ALU_output_mux 	<= Ainput + Binput;
		WHEN addi 								=>	ALU_output_mux 	<= Ainput + EX_CPU_inst.immediate;
 	 	WHEN subtract | brancheq			=>	ALU_output_mux 	<= Ainput - Binput;
 	 	WHEN slt									=>	IF (Ainput < Binput) THEN ALU_output_mux <= X"00000001"; ELSE ALU_output_mux <= X"00000000";  END IF;
		WHEN load | store						=>	ALU_output_mux 	<= Ainput + EX_CPU_inst.immediate;
		WHEN transmit							=>	ALU_output_mux 	<= Ainput;
 	 	WHEN OTHERS								=>	ALU_output_mux 	<= X"00000000";
  	END CASE;
	
END PROCESS;
  
PROCESS(clock) BEGIN

	IF(clock'event AND clock = '1') THEN
	
		IF(Branch_freeze = '1') THEN --Bubble
			EX_CPU_inst 		<= NOPConstant;
			CPU_inst_out 		<= NOPConstant;
		
		ELSE --Latch Past Exec events
			Last_EX_isModReg		<= Ctrl_EX_isModReg;
			Last_EX_modRegAddr	<= Ctrl_EX_modRegAddr;
			Last_EX_modRegValue	<= Ctrl_EX_modRegValue;
		
			--Latch
			EX_Read_data_1 		<= Read_data_1;
			EX_Read_data_2 		<= Read_data_2;
			EX_CPU_inst 			<= CPU_inst;
			
			DM_isLoading		<= Ctrl_DM_isLoading;
			DM_modRegAddr		<= Ctrl_DM_modRegAddr;
			DM_modRegValue		<= Ctrl_DM_modRegValue;
			
			--Forward
			CPU_inst_out 		<= CPU_inst;
		END IF;
		
	END IF;
	
END PROCESS;

END behavior;

