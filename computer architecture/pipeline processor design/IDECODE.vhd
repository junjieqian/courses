-- Computer Architecture Project
-- Spring 2012


--  Idecode module (implements the register file for
-- the MIPS computer)
LIBRARY IEEE; 			
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE WORK.LCSTYPES.ALL;

--Decodes the instruction to be executed 
--Reads the RegisterFile at the TRAILING edge
--IF EX or DM are loading a value I need, I latch it at the trailing edge. Make sure it's ready by then

ENTITY Idecode IS
	PORT(	
		clock,reset			: IN 	STD_LOGIC;
		register_array		: IN register_file;
		read_data_1			: OUT STD_LOGIC_VECTOR( 31 DOWNTO 0 );
		read_data_2			: OUT STD_LOGIC_VECTOR( 31 DOWNTO 0 );
		CPU_inst_out		: OUT LCSInstruction;
		BrPerformance_out	: OUT STD_LOGIC_VECTOR( 63 downto 0 );

				
		--Write Through
		Instruction 		: IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );	
		PC_plus_4 			: IN 	STD_LOGIC_VECTOR( 9 DOWNTO 0 );

		--Forwarding Unit
		Branch_freeze			: IN STD_LOGIC;

		--From EX
		Ctrl_EX_isModReg		: IN STD_LOGIC;
		Ctrl_EX_modRegAddr	: IN STD_LOGIC_VECTOR( 4 DOWNTO 0 );
		Ctrl_EX_modRegValue	: IN STD_LOGIC_VECTOR( 31 DOWNTO 0 );
		
		Branch_enable_out		: OUT STD_LOGIC;
		Branch_addr_out		: OUT STD_LOGIC_VECTOR( 7 DOWNTO 0 )
	);
END Idecode;


ARCHITECTURE behavior OF Idecode IS

	SIGNAL CPU_inst			: LCSInstruction;
	SIGNAL opcode				: STD_LOGIC_VECTOR( 5 DOWNTO 0 );
	SIGNAL fnct_opcode		: STD_LOGIC_VECTOR( 5 DOWNTO 0 );
	SIGNAL immediate			: STD_LOGIC_VECTOR( 15 DOWNTO 0 );

	SIGNAL data_1, data_2	: STD_LOGIC_VECTOR( 31 DOWNTO 0 );
	SIGNAL ID_PC_plus_4		: STD_LOGIC_VECTOR( 9 DOWNTO 0 );

	SIGNAL Branch_enable		: STD_LOGIC := '0';

	--Latched
	SIGNAL ID_Instruction 	: STD_LOGIC_VECTOR( 31 DOWNTO 0 );
	SIGNAL ID_dmem_data		: STD_LOGIC_VECTOR( 31 DOWNTO 0 );
	SIGNAL ID_ALU_result		: STD_LOGIC_VECTOR( 31 DOWNTO 0 );	
	
	SIGNAL EX_isModReg		: STD_LOGIC;
	SIGNAL EX_modRegAddr		: STD_LOGIC_VECTOR( 4 DOWNTO 0 );
	SIGNAL EX_modRegValue	: STD_LOGIC_VECTOR( 31 DOWNTO 0 );
	
	--Performance
	SIGNAL BrPerformance		: STD_LOGIC_VECTOR( 63 downto 0 );

	
BEGIN

	BrPerformance_out	<= BrPerformance;

	opcode			<= ID_Instruction( 31 DOWNTO 26 );
	fnct_opcode		<= ID_Instruction( 5 DOWNTO 0 );
	immediate 		<= ID_Instruction( 15 DOWNTO 0 );
	
	CPU_inst.rs				<= ID_Instruction( 25 DOWNTO 21 );
	CPU_inst.rt				<= ID_Instruction( 20 DOWNTO 16 );
	CPU_inst.rd				<= ID_Instruction( 15 DOWNTO 11 );
	CPU_inst.immediate 	<= X"0000" & immediate WHEN immediate(15) = '0' ELSE	X"FFFF" & immediate;
	-- We make sure we keep the sign on the immediate value, since it's only 16bits
	
	CPU_inst_out	<= CPU_inst;
	
	CPU_inst.alu	<= 
		add 			WHEN ((opcode = "000000") AND (fnct_opcode = "100000")) ELSE	
		subtract 	WHEN ((opcode = "000000") AND (fnct_opcode = "100010")) ELSE	
		slt			WHEN ((opcode = "000000") AND (fnct_opcode = "101010")) ELSE	
		brancheq		WHEN  (opcode = "000100") ELSE  												
		addi 			WHEN  (opcode = "001000") ELSE								
		load 			WHEN  (opcode = "100011") ELSE									
		store			WHEN  (opcode = "101011") ELSE		
		transmit		WHEN  (opcode = "101010") ELSE				
		nop;		

	read_data_1 <= data_1;
	read_data_2 <= data_2;
	
	--We RELY on a ID Freeze Stalled Data that's being EXecuted OR LoaDed right now.
	--We use Exec Forwarding (done by default) to grab that new data from EX or just register read for LoaD after bubble.
	Branch_enable <= '1'
		WHEN ((CPU_inst.alu = brancheq) AND (data_1 = data_2) AND (Branch_freeze = '0'))
		ELSE '0';
	Branch_enable_out <= Branch_enable;
		
	-- Adder to compute Branch Address
	Branch_addr_out <= ID_PC_plus_4( 9 DOWNTO 2 ) + immediate( 7 DOWNTO 0 );
		
--TRAILING EDGE
process(clock) begin
	if(clock'event AND clock = '0') then	
	
		--IF EX just calculated a new value for Reg(rs) or Reg(rt)
		IF(EX_isModReg = '1' AND EX_modRegAddr = CPU_inst.rs) THEN
			data_1 <= EX_modRegValue;
			data_2 <= register_array( CONV_INTEGER( CPU_inst.rt ) ); -- Read Register 2 Operation		
		ELSIF(EX_isModReg = '1' AND EX_modRegAddr = CPU_inst.rt) THEN
			data_1 <= register_array( CONV_INTEGER( CPU_inst.rs ) ); -- Read Register 1 Operation
			data_2 <= EX_modRegValue;
				
		--No Structural Hazard with WB (writes RegArray at leading edge, ID reads at the trailing edge)
		ELSE
			data_1 <= register_array( CONV_INTEGER( CPU_inst.rs ) ); -- Read Register 1 Operation
			data_2 <= register_array( CONV_INTEGER( CPU_inst.rt ) ); -- Read Register 2 Operation		
		END IF;
	
	end if;
end process;		
		
		
process(clock, reset) begin

	IF(reset = '1') THEN
		BrPerformance <= X"0000000000000000";
	
	ELSIF(clock'event AND clock = '1') THEN
		--Performance measures
		IF(CPU_inst.alu = brancheq) THEN
			BrPerformance(31 downto 0) <= BrPerformance(31 downto 0) + 1;
		END IF;
		
		IF(Branch_enable = '1') THEN  --Insert a bubble (Fetched Inst is wrong)
			ID_Instruction		<= X"00000000";	
			ID_PC_plus_4		<= PC_plus_4;
			BrPerformance(63 downto 32) <= BrPerformance(63 downto 32) + 1;
			
		ELSIF(Branch_freeze = '0') THEN --If no hazard, grab the new instruction
			ID_Instruction		<= Instruction;	
			ID_PC_plus_4		<= PC_plus_4;
			
		END IF;
							
		--Freeze instruction in this pipe stage
		--If Branch_freeze is 1, we don't modify the instruction executing
		EX_isModReg			<= Ctrl_EX_isModReg;
		EX_modRegAddr		<= Ctrl_EX_modRegAddr;
		EX_modRegValue		<= Ctrl_EX_modRegValue;
		
	end if;
end process;
END behavior;


