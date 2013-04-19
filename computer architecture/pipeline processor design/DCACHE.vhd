-- Computer Architecture Project
-- Spring 2012

--  DCACHE module
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_SIGNED.ALL;
USE WORK.LCSTYPES.ALL;

LIBRARY altera_mf;
USE altera_mf.altera_mf_components.all;

-- Load/Store data at Rising edge
-- Data is available almost immediately
ENTITY DCACHE IS
	PORT(	
		clock,reset				: IN 	STD_LOGIC;
		mem_data_out			: OUT	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
		mem_Nok					: OUT	STD_LOGIC;
		DCPerformance_out		: OUT STD_LOGIC_VECTOR( 95 downto 0 );

		mem_data_in				: IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
		mem_address 			: IN 	STD_LOGIC_VECTOR( 7 DOWNTO 0 );
		mem_read					: IN	STD_LOGIC;
		mem_write				: IN	STD_LOGIC
	);
END DCACHE;

ARCHITECTURE behavior OF DCACHE IS

SIGNAL cache_clock			: STD_LOGIC;
SIGNAL DC						: cache_struct;
SIGNAL DCPerformance			: STD_LOGIC_VECTOR( 95 downto 0 );

SIGNAL cache_mem_data_out	: STD_LOGIC_VECTOR( 31 DOWNTO 0 );
SIGNAL cache_mem_data_in	: STD_LOGIC_VECTOR( 31 DOWNTO 0 );
SIGNAL cache_mem_address 	: STD_LOGIC_VECTOR(  7 DOWNTO 0 );

SIGNAL cache_mem_write	 	: STD_LOGIC := '0';

SIGNAL ABC					 	: STD_LOGIC_VECTOR(  1 DOWNTO 0 ) := "00";
SIGNAL Nok						: STD_LOGIC := '0';
SIGNAL int_index				: integer := 0;
SIGNAL int_offset				: integer := 0;
SIGNAL write_tag				: STD_LOGIC_VECTOR(  1 downto 0 ) := B"00";

SIGNAL mem_address_offset	: STD_LOGIC_VECTOR(1 downto 0);
SIGNAL mem_address_tag		: STD_LOGIC_VECTOR(1 downto 0);
SIGNAL mem_address_index	: STD_LOGIC_VECTOR(3 downto 0);

BEGIN

DCPerformance_out <= DCPerformance;

--ALTERA RAM CLOCK
cache_clock <= NOT clock; --Loads at falling

--DEMUX THE PHYSICAL MEMORY ADDRESS 
mem_address_offset 	<= mem_address(1 downto 0);
mem_address_tag		<= mem_address(7 downto 6);
mem_address_index		<= mem_address(5 downto 2);


cache_mem_address <= 
	mem_address_tag & mem_address_index & ABC WHEN cache_mem_write = '0' ELSE 
	write_tag 		 & mem_address_index & ABC;

mem_data_out <= DC(int_index).cache_block(int_offset) 
	WHEN mem_read = '1' AND Nok = '0'
	ELSE X"00000000";
	
mem_Nok		<= Nok;
int_index	<= CONV_INTEGER( "0" & mem_address_index);
int_offset	<= CONV_INTEGER( "0" & mem_address_offset);

PROCESS(clock, reset)
	VARIABLE frame_offset	: integer := 0;
	VARIABLE onemore	: integer := 0;
BEGIN

	IF(reset = '1') THEN
		FOR i IN 0 TO 15 LOOP
			DC(i).valid <= '0';
			DC(i).dirty <= '0';
			DC(i).tag <= B"00";
		END LOOP;
		frame_offset := 0;
		ABC <= "00";
		Nok <= '0';
		DCPerformance <= X"000000000000000000000000";

		
	ELSIF(clock'event AND clock = '1') THEN
				
		IF( Nok = '1' AND mem_write = '1' AND DC(int_index).valid = '1' AND DC(int_index).tag = mem_address_tag ) THEN
			DC(int_index).dirty 							<= '1';
			DC(int_index).cache_block(int_offset)	<= mem_data_in;						
						
		--READ A BLOCK FROM MAIN MEM
		ELSIF(Nok = '1' AND ( mem_write = '1' OR mem_read = '1')) THEN

			IF( DC(int_index).dirty	= '0' OR DC(int_index).valid = '0' ) THEN
				
				DC(int_index).cache_block( frame_offset ) <= cache_mem_data_out;		
					
				IF(frame_offset = 3) THEN
					
					ABC 						<= "00";
					frame_offset 			:= 0;							
					DC(int_index).valid 	<= '1';
					DC(int_index).dirty 	<= '0';
					DC(int_index).tag		<= mem_address_tag;
				
                    --Cache Misses
					DCPerformance(63 downto 32) <= DCPerformance(63 downto 32) + 1;	
			
				ELSE
					frame_offset := frame_offset + 1;
					ABC <= CONV_STD_LOGIC_VECTOR(frame_offset, 2);
				
				END IF;
			
			ELSIF( DC(int_index).dirty	= '1' AND DC(int_index).valid	= '1') THEN--dirty=1
			--Bit's dirty, writting back
				
				IF(frame_offset = 4) THEN
					frame_offset 			:= 0;
					ABC 						<= "00";					
					cache_mem_write		<= '0';
					DC(int_index).dirty	<= '0';
					DC(int_index).valid 	<= '0';

                    --Cache Misses
					DCPerformance(95 downto 64) <= DCPerformance(95 downto 64) + 1;	

				ELSE
					cache_mem_write	<= '1';
					write_tag 			<= DC(int_index).tag;
					cache_mem_data_in <= DC(int_index).cache_block( frame_offset );
					ABC 					<= CONV_STD_LOGIC_VECTOR(frame_offset, 2);
					frame_offset		:= frame_offset + 1;
				
				END IF;
			
			END IF; --WriteBack
			
		END IF; --NOK=1
		
	--Clock = 0
	ELSIF(clock'event AND clock = '0') THEN

		IF (mem_read = '1') THEN
			
			IF( DC(int_index).valid = '1' AND DC(int_index).tag = mem_address_tag) THEN
				
				Nok <= '0';	
				DCPerformance(31 downto 0) <= DCPerformance(31 downto 0) + 1;	--Mem Reads/Writes
			
			ELSE
				Nok <= '1';
			
			END IF;
		
		ELSIF(mem_write = '1') THEN
			
			IF( DC(int_index).valid = '1' AND DC(int_index).tag = mem_address_tag AND DC(int_index).dirty = '1' AND DC(int_index).cache_block(int_offset) = mem_data_in) THEN
				Nok <= '0';
				DCPerformance(31 downto 0) <= DCPerformance(31 downto 0) + 1;	--Mem Reads/Writes
			ELSE
				Nok <= '1';
			END IF;
		
		END IF; --Read or Write
	END IF;
END PROCESS;

	data_memory : altsyncram
	GENERIC MAP  (
		operation_mode => "SINGLE_PORT",
		width_a 			=> 32,
		widthad_a 		=> 8,
		lpm_type 		=> "altsyncram",
		outdata_reg_a 	=> "UNREGISTERED",
		init_file 		=> "LCSData.MIF",
		intended_device_family => "Cyclone"
	)
	
	PORT MAP (
		wren_a 		=> cache_mem_write,
		clock0 		=> cache_clock,
		address_a 	=> cache_mem_address,
		data_a 		=> cache_mem_data_in,
		q_a 		=> cache_mem_data_out
	);
END behavior;

