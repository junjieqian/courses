-- Computer Architecture Project
-- Spring 2012

--  Dmemory module (implements the data
--  memory for the MIPS computer)
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_SIGNED.ALL;
USE WORK.LCSTYPES.ALL;

LIBRARY altera_mf;
USE altera_mf.altera_mf_components.all;


-- Load/Store data at Rising edge
-- Data is available almost immediately

ENTITY dmemory IS
	PORT(	
		dmem_data				: OUT	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
		pipe_clock				: IN 	STD_LOGIC;
		master_clock			: IN 	STD_LOGIC;
		reset						: IN 	STD_LOGIC;
		dmem_address 			: IN 	STD_LOGIC_VECTOR( 7 DOWNTO 0 );
		dmem_write_data		: IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
		dmem_Nok					: OUT STD_LOGIC;
		DCPerformance_out		: OUT STD_LOGIC_VECTOR( 95 downto 0 );

		
		--WriteThrough
		CPU_inst				: IN 	LCSInstruction;
		CPU_inst_out		: OUT	LCSInstruction;
		ALU_result			: IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
		ALU_result_out		: OUT	STD_LOGIC_VECTOR( 31 DOWNTO 0 )		
	);
END dmemory;


ARCHITECTURE behavior OF dmemory IS


COMPONENT DCACHE
	PORT (
		clock,reset				: IN 	STD_LOGIC;
		mem_data_out			: OUT	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
		mem_Nok					: OUT	STD_LOGIC;
		DCPerformance_out		: OUT STD_LOGIC_VECTOR( 95 downto 0 );

		mem_data_in				: IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
		mem_address 			: IN 	STD_LOGIC_VECTOR( 7 DOWNTO 0 );
		mem_read					: IN	STD_LOGIC;
		mem_write				: IN	STD_LOGIC
	);
END COMPONENT;		

--Latched
SIGNAL DM_dmem_address 			: STD_LOGIC_VECTOR( 7 DOWNTO 0 );
SIGNAL DM_dmem_write_data		: STD_LOGIC_VECTOR( 31 DOWNTO 0 );
SIGNAL DM_CPU_inst 				: LCSInstruction;
SIGNAL DM_dmem_read				: STD_LOGIC;
SIGNAL DM_dmem_write				: STD_LOGIC;

BEGIN

DM_dmem_read  <= '1' WHEN DM_CPU_inst.alu = load ELSE '0';
DM_dmem_write <= '1' WHEN DM_CPU_inst.alu = store ELSE '0';
		
process(pipe_clock)  begin
	if(pipe_clock'event AND pipe_clock = '1') then
		--Latch used signals
		DM_dmem_address 		<= dmem_address;
		DM_dmem_write_data 	<= dmem_write_data;
		DM_CPU_inst 			<= CPU_inst;
	
		--Forward
		CPU_inst_out	 <= CPU_inst;
		ALU_result_out	 <= ALU_result;
	end if;
end process;


DC : DCACHE
	PORT MAP (	
		clock 				=> master_clock,
		reset 				=> reset,
		mem_data_out 		=> dmem_data,
		mem_Nok				=> dmem_Nok,
		DCPerformance_out	=> DCPerformance_out,
		mem_data_in			=> DM_dmem_write_data,
		mem_address			=> DM_dmem_address,
		mem_read				=> DM_dmem_read,
		mem_write			=> DM_dmem_write
	);

END behavior;

