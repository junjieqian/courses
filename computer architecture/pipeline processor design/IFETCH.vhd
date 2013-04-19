-- Computer Architecture Project
-- Spring 2012

-- Ifetch module (provides the PC and instruction 
-- memory for the MIPS computer)
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
LIBRARY altera_mf;
USE altera_mf.altera_mf_components.all;


--Fetches Instructions from IM
--At every rising edge a new value is read
--At every trailing edge the next PC value is computed
ENTITY Ifetch IS
	PORT(	
		pipe_clock			: IN 	STD_LOGIC;
		master_clock		: IN 	STD_LOGIC;
		reset					: IN 	STD_LOGIC;
		-- 32 bits instruction output
		Instruction_out 	: OUT	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
		PC_plus_4_out 		: OUT	STD_LOGIC_VECTOR( 9 DOWNTO 0 );
		Imem_Nok				: OUT STD_LOGIC;
		ICPerformance_out	: OUT STD_LOGIC_VECTOR( 63 downto 0 );

		
		--Forward Unit
		--Branch operation control
		Branch_freeze		: IN STD_LOGIC;
		Branch_addr			: IN STD_LOGIC_VECTOR( 7 DOWNTO 0 );
		Branch_enable		: IN STD_LOGIC
	);
END Ifetch;

ARCHITECTURE behavior OF Ifetch IS

    -- first define the instruction cache which used to store the instructions
	COMPONENT ICache 
		PORT(	
			clock,reset				: IN 	STD_LOGIC;
			mem_data_out			: OUT	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
			mem_Nok					: OUT	STD_LOGIC;
			ICPerformance_out		: OUT STD_LOGIC_VECTOR( 63 downto 0 );

			mem_address 			: IN 	STD_LOGIC_VECTOR( 7 DOWNTO 0 )
		);
	END COMPONENT;

	SIGNAL PC, PC_plus_4  	: STD_LOGIC_VECTOR( 7 DOWNTO 0 ) := X"01";
	SIGNAL IF_Instruction	: STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL IF_Nok				: STD_LOGIC := '0';
BEGIN

    -- READ in the instructions from icache
    -- PC number count
	PC_plus_4 		<= PC + 1;	
	PC_plus_4_out 	<= PC_plus_4 & B"00";	
	Imem_Nok 		<= IF_Nok;
	
	Instruction_out <= X"00000000" WHEN IF_Nok = '1' ELSE IF_Instruction;
	
	--Latches The next PC at the Trailing Edge
	--IMPORTANT for branching. Value must be ready by then.
	PROCESS(pipe_clock, reset) BEGIN
		IF( reset = '1' ) THEN
			PC <= X"00";
		ELSIF(pipe_clock'EVENT AND pipe_clock = '1') THEN
			IF(IF_Nok = '0') THEN
				IF(Branch_enable = '1' ) THEN
					PC <= Branch_addr;
				ELSIF(Branch_freeze = '0') THEN --If RAR then stall/branch
					PC  <= PC_plus_4;
				END IF;
			END IF;
		END IF;
	END PROCESS;	


	IC : ICache 
		PORT MAP(	
			clock					=> master_clock,
			reset					=>	reset,
			ICPerformance_out => ICPerformance_out,
			mem_data_out		=> IF_Instruction,
			mem_Nok				=> IF_Nok,
			mem_address			=> PC
		);
	
END behavior;


