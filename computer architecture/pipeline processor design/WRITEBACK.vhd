-- Computer Architecture Project
-- Spring 2012

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE WORK.LCSTYPES.ALL;

ENTITY WriteBack IS
	PORT(	
		register_array		: INOUT register_file;
		clock,reset			: IN STD_LOGIC;
		
		ICPerformance		: IN STD_LOGIC_VECTOR( 63 downto 0 );
		DCPerformance		: IN STD_LOGIC_VECTOR( 95 downto 0 );			
		BrPerformance		: IN STD_LOGIC_VECTOR( 63 downto 0 );

		--Latched
		CPU_inst				: IN LCSInstruction;
		dmem_data			: IN STD_LOGIC_VECTOR( 31 DOWNTO 0 );
		ALU_result			: IN STD_LOGIC_VECTOR( 31 DOWNTO 0 )
	);
END WriteBack;


ARCHITECTURE behavior OF WriteBack IS
BEGIN	
			
			
PROCESS(clock)	
	VARIABLE write_register_address 		: STD_LOGIC_VECTOR( 4 DOWNTO 0 );
	VARIABLE write_data						: STD_LOGIC_VECTOR( 31 DOWNTO 0 );
	VARIABLE regWrite							: STD_LOGIC;
	
	--Latched
	VARIABLE WB_CPU_inst	 			: LCSInstruction;
	VARIABLE WB_dmem_data			: STD_LOGIC_VECTOR( 31 DOWNTO 0 );
	VARIABLE WB_ALU_result			: STD_LOGIC_VECTOR( 31 DOWNTO 0 );	

BEGIN
	if(clock'EVENT AND clock = '1') then
	
		--
		--Preparation for RegisterFile Write
		--
		WB_dmem_data 	:= dmem_data;
		WB_ALU_result 	:= ALU_result;
		WB_CPU_inst 	:= CPU_inst;
		
		
		IF((WB_CPU_inst.alu = add) OR (WB_CPU_inst.alu = addi) OR 
		   (WB_CPU_inst.alu = subtract) OR (WB_CPU_inst.alu = slt) OR (WB_CPU_inst.alu = load)) THEN
			regWrite	:=  '1';
		ELSE
			regWrite	:=  '0';	
		END IF;
		
		--rd is the destination for Rtype, rt is the dest reg for the Itype
		IF((WB_CPU_inst.alu = add) OR (WB_CPU_inst.alu = subtract) OR (WB_CPU_inst.alu = slt)) THEN --Rtype Instruction
			write_register_address := WB_CPU_inst.rd; 
		ELSE
			write_register_address := WB_CPU_inst.rt;
		END IF;
		
		-- Mux to bypass data memory for Rformat instructions
		IF(WB_CPU_inst.alu = load) THEN
			write_data := WB_dmem_data;
		ELSE
			write_data := WB_ALU_result( 31 DOWNTO 0 );
		END IF;
		
		--
		--END Preparation
		--
		
		
		register_array(0) <= x"00000000";
		IF reset = '1' THEN  --Reset the register array
			FOR i IN 0 TO 31 LOOP
				register_array(i) <= X"00000000";
			END LOOP;
			
		-- Write back to register - don't write to register 0
		ELSE
			IF (regWrite = '1' AND write_register_address /= 0) THEN
				register_array( CONV_INTEGER( write_register_address)) <= write_data;
			END IF;
			
			register_array(25) <= BrPerformance(31 downto 0);
			register_array(26) <= BrPerformance(63 downto 32);
			
			register_array(27) <= ICPerformance(31 downto 0);
			register_array(28) <= ICPerformance(63 downto 32);
						
			register_array(29) <= DCPerformance(31 downto 0);
			register_array(30) <= DCPerformance(63 downto 32);
			register_array(31) <= DCPerformance(95 downto 64);
		END IF;
			

	END IF;
END PROCESS;
	
END behavior;


