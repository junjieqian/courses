-- Computer Architecture Project
-- Spring 2012


--  ICache module
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_SIGNED.ALL;
USE WORK.LCSTYPES.ALL;

LIBRARY altera_mf;
USE altera_mf.altera_mf_components.all;


-- Load/Store data at Rising edge
-- Data is available almost immediately

ENTITY ICache IS
	PORT(	
		clock,reset				: IN 	STD_LOGIC;
		mem_data_out			: OUT	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
		mem_Nok					: OUT	STD_LOGIC;
		ICPerformance_out		: OUT STD_LOGIC_VECTOR( 63 downto 0 );

		mem_address 			: IN 	STD_LOGIC_VECTOR( 7 DOWNTO 0 )
	);
END ICache;

ARCHITECTURE behavior OF ICache IS

SIGNAL cache_clock			: STD_LOGIC;
SIGNAL IC						: cache_struct;
SIGNAL ICPerformance			: STD_LOGIC_VECTOR( 63 downto 0 );
SIGNAL cache_mem_data_out	: STD_LOGIC_VECTOR( 31 DOWNTO 0 );
SIGNAL cache_mem_address 	: STD_LOGIC_VECTOR(  7 DOWNTO 0 );
SIGNAL ABC					 	: STD_LOGIC_VECTOR(  1 DOWNTO 0 ) := "00";
SIGNAL Nok						: STD_LOGIC := '0';
SIGNAL int_index				: integer := 0;

SIGNAL mem_address_offset	: STD_LOGIC_VECTOR(1 downto 0);
SIGNAL mem_address_tag		: STD_LOGIC_VECTOR(1 downto 0);
SIGNAL mem_address_index	: STD_LOGIC_VECTOR(3 downto 0);
BEGIN

ICPerformance_out <= ICPerformance;

mem_address_offset 	<= mem_address(1 downto 0);
mem_address_tag		<= mem_address(7 downto 6);
mem_address_index		<= mem_address(5 downto 2);

cache_clock	<= NOT clock; --Loads at falling
mem_Nok		<= Nok;
int_index	<= CONV_INTEGER( "0" & mem_address_index);

cache_mem_address <= mem_address_tag & mem_address_index & ABC;

PROCESS(clock, reset)
	VARIABLE frame_offset	: integer := 0;
BEGIN

	IF(reset = '1') THEN
		FOR i IN 0 TO 15 LOOP
			IC(i).valid <= '0';
		END LOOP;
		frame_offset := 0;
		ABC <= "00";
		Nok <= '0';
		ICPerformance <= X"0000000000000000";
		
	ELSIF(clock'event AND clock = '1') THEN
				
		IF(Nok = '1') THEN
				
			IC(int_index).cache_block(frame_offset) <= cache_mem_data_out;		
			frame_offset := frame_offset + 1;
			ABC <= CONV_STD_LOGIC_VECTOR(frame_offset, 2);
			
			IF(frame_offset = 4) THEN
				ABC <= "00";
				frame_offset := 0;							
				IC( int_index ).dirty	<= '0';
				IC( int_index ).tag		<= mem_address_tag;
				IC( int_index ).valid	<= '1';
			END IF;
		END IF;
		
	--Clock = 0
	ELSIF(clock'event AND clock = '0') THEN

		ICPerformance(31 downto 0) <= ICPerformance(31 downto 0) + 1;	--Mem Reads
		IF( IC(int_index).valid = '0' OR IC(int_index).tag /= mem_address_tag ) THEN
			Nok <= '1';
			ICPerformance(63 downto 32) <= ICPerformance(63 downto 32) + 1;	--Cache Misses
		ELSE
			Nok <= '0';	
		END IF;
		
		mem_data_out <= IC(int_index).cache_block( CONV_INTEGER("0" & mem_address_offset) );
	END IF;
END PROCESS;

--ROM for Instruction Memory
inst_memory: altsyncram
	GENERIC MAP (
		operation_mode => "ROM",
		width_a => 32,  --Word size (data output on port a)
		widthad_a => 8, --Address size (indexing length on port a)
		lpm_type => "altsyncram",
		outdata_reg_a => "UNREGISTERED",
		init_file => "LCS.MIF",
		intended_device_family => "Cyclone"
	)
	
	PORT MAP (
		clock0		=> cache_clock,
		address_a	=> cache_mem_address, 
		q_a			=> cache_mem_data_out 
	);
END behavior;

