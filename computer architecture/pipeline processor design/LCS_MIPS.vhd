-- Computer Architecture Project
-- Spring 2012

-- Top Level Structural Model for MIPS Processor Core
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE WORK.LCSTYPES.ALL;

ENTITY LCS_MIPS IS

	PORT ( 
      OSC_50_CLK        : IN STD_LOGIC;			--	50 MHz
      RESET             : IN STD_LOGIC;			--	Button
      UART_D         	: OUT STD_LOGIC;			--	UART Transmitter Data
      UART_BUSY			: OUT STD_LOGIC;			--	UART Transmitter Status 

		PCOUT					:	OUT STD_LOGIC_VECTOR(9 downto 0);
		clockOUT				:	OUT STD_LOGIC
	);
		
END LCS_MIPS;

ARCHITECTURE structure OF LCS_MIPS IS

	COMPONENT uart
		PORT (
			OSC_50_CLK        : IN STD_LOGIC;								--	50 MHz
			clock					: IN 	STD_LOGIC;
			CPU_inst				: IN LCSInstruction;							-- Comes from the processor, is '1' when there is new data ready
			transmit_data		: IN STD_LOGIC_VECTOR( 31 DOWNTO 0 );  -- The data (This code latches it at the falling edge of clock)
			UART_D         	: OUT STD_LOGIC;								--	UART Transmitter Data
			UART_BUSY			: OUT STD_LOGIC								--	UART Transmitter Status 
		);
	END COMPONENT;
	
	COMPONENT Ifetch
		PORT(	
			pipe_clock			: IN 	STD_LOGIC;
			master_clock		: IN 	STD_LOGIC;
			reset					: IN 	STD_LOGIC;
			Instruction_out	: OUT	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
			PC_plus_4_out 		: OUT STD_LOGIC_VECTOR( 9 DOWNTO 0 );
			Imem_Nok				: OUT STD_LOGIC;
			ICPerformance_out	: OUT STD_LOGIC_VECTOR( 63 downto 0 );

			
			--Forwarding Signals
			Branch_addr			: IN STD_LOGIC_VECTOR( 7 DOWNTO 0 );
			Branch_enable		: IN STD_LOGIC;

			--Signals to stop fetching
			Branch_freeze		: IN STD_LOGIC

		);
	END COMPONENT; 

	COMPONENT Idecode
		PORT(	
			clock, reset			: IN 	STD_LOGIC;
			register_array			: IN register_file;
			read_data_1 			: OUT STD_LOGIC_VECTOR( 31 DOWNTO 0 );
			read_data_2 			: OUT STD_LOGIC_VECTOR( 31 DOWNTO 0 );
			CPU_inst_out			: OUT	LCSInstruction;
			BrPerformance_out		: OUT STD_LOGIC_VECTOR( 63 downto 0 );
			
			--WriteThrough
			Instruction 			: IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
			PC_plus_4		 		: IN STD_LOGIC_VECTOR( 9 DOWNTO 0 );
			
			--Forwarding Unit
			Branch_freeze			: IN STD_LOGIC;
					
			Ctrl_EX_isModReg		: IN STD_LOGIC;
			Ctrl_EX_modRegAddr	: IN STD_LOGIC_VECTOR( 4 DOWNTO 0 );
			Ctrl_EX_modRegValue	: IN STD_LOGIC_VECTOR( 31 DOWNTO 0 );
			
			Branch_enable_out		: OUT STD_LOGIC;
			Branch_addr_out		: OUT STD_LOGIC_VECTOR( 7 DOWNTO 0 )
	);
	END COMPONENT;

	COMPONENT Control
		PORT( 			
			--From ID
			ID_CPU_inst				: IN	LCSInstruction;
			Branch_freeze			: OUT STD_LOGIC;
		
			--From EX
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
	END COMPONENT;

	COMPONENT Execute
		PORT(	
			clock, reset		: IN 	STD_LOGIC;
			Read_data_1 		: IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
			Read_data_2 		: IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
			write_data_out		: OUT STD_LOGIC_VECTOR( 31 DOWNTO 0);
			ALU_Result_out		: OUT	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
			
			--Write Through
			CPU_inst				: IN 	LCSInstruction;			
			CPU_inst_out		: OUT	LCSInstruction;
			
			--Forwarding Unit
			Branch_freeze		: IN STD_LOGIC;
						
			Ctrl_DM_isLoading		: IN STD_LOGIC;
			Ctrl_DM_modRegAddr	: IN STD_LOGIC_VECTOR( 4 DOWNTO 0 );
			Ctrl_DM_modRegValue	: IN STD_LOGIC_VECTOR( 31 DOWNTO 0 );
			Ctrl_EX_isModReg		: IN STD_LOGIC;
			Ctrl_EX_modRegAddr	: IN STD_LOGIC_VECTOR( 4 DOWNTO 0 );
			Ctrl_EX_modRegValue	: IN STD_LOGIC_VECTOR( 31 DOWNTO 0 )
		);
	END COMPONENT;


	COMPONENT dmemory
		PORT(	
			pipe_clock			: IN 	STD_LOGIC;
			master_clock		: IN 	STD_LOGIC;
			reset					: IN 	STD_LOGIC;
			dmem_address		: IN 	STD_LOGIC_VECTOR( 7 DOWNTO 0 );
			dmem_write_data	: IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );			
			dmem_data			: OUT	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
			dmem_Nok				: OUT STD_LOGIC;
			DCPerformance_out	: OUT STD_LOGIC_VECTOR( 95 downto 0 );

			
			--Write Through
			CPU_inst				: IN 	LCSInstruction;
			CPU_inst_out		: OUT	LCSInstruction;
			ALU_result			: IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
			ALU_result_out		: OUT	STD_LOGIC_VECTOR( 31 DOWNTO 0 )
		);
	END COMPONENT;
	
	
	COMPONENT WriteBack IS
		PORT(	
			clock,reset			: IN 	STD_LOGIC;
			register_array		: INOUT register_file;

			--Performance counters
			ICPerformance		: IN STD_LOGIC_VECTOR( 63 downto 0 );
			DCPerformance		: IN STD_LOGIC_VECTOR( 95 downto 0 );
			BrPerformance		: IN STD_LOGIC_VECTOR( 63 downto 0 );

			--Latched
			CPU_inst				: IN LCSInstruction;
			dmem_data			: IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
			ALU_result			: IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 )
		);
	END COMPONENT;

	Constant DIVISOR	:	integer := 200;
	
	--Register File
	SIGNAL master_clock		: STD_LOGIC := '0';
	SIGNAL pipe_clock			: STD_LOGIC := '0';
	
	SIGNAL register_array	: register_file;
	SIGNAL Dmem_Nok			: STD_LOGIC := '0';
	SIGNAL Imem_Nok			: STD_LOGIC := '0';

	SIGNAL read_data_1 		: STD_LOGIC_VECTOR( 31 DOWNTO 0 );
	SIGNAL read_data_2 		: STD_LOGIC_VECTOR( 31 DOWNTO 0 );
	SIGNAL immediate_value 	: STD_LOGIC_VECTOR( 31 DOWNTO 0 );
	SIGNAL dmem_data			: STD_LOGIC_VECTOR( 31 DOWNTO 0 );
	SIGNAL Branch_addr 		: STD_LOGIC_VECTOR( 7 DOWNTO 0 ) := X"00";
	SIGNAL Branch_enable		: STD_LOGIC := '0';
	SIGNAL Branch_freeze		: STD_LOGIC := '0';
	
	SIGNAL EX_write_data		: STD_LOGIC_VECTOR( 31 DOWNTO 0 );
	
	-- declare signals used to connect VHDL components
	--Forwarding Signals
	SIGNAL Ctrl_EX_isModReg		: STD_LOGIC := '0';
	SIGNAL Ctrl_EX_modRegAddr	: STD_LOGIC_VECTOR( 4 DOWNTO 0 );
	SIGNAL Ctrl_EX_modRegValue	: STD_LOGIC_VECTOR( 31 DOWNTO 0 );
	SIGNAL Ctrl_DM_isLoading	: STD_LOGIC := '0';
	SIGNAL Ctrl_DM_modRegAddr	: STD_LOGIC_VECTOR( 4 DOWNTO 0 );
	SIGNAL Ctrl_DM_modRegValue	: STD_LOGIC_VECTOR( 31 DOWNTO 0 );

	--END Forwarding Signals
	
	--Pipe Transfer
	SIGNAL IF_PC_plus_4 			: STD_LOGIC_VECTOR( 9 DOWNTO 0 ) := B"0000000000";
	
	SIGNAL IF_Instruction		: STD_LOGIC_VECTOR( 31 DOWNTO 0 ) := X"00000000";
	
	SIGNAL ID_CPU_inst			: LCSInstruction := NOPConstant;	
	SIGNAL EX_CPU_inst			: LCSInstruction := NOPConstant;	
	SIGNAL DM_CPU_inst			: LCSInstruction := NOPConstant;	

	SIGNAL EX_ALU_result 		: STD_LOGIC_VECTOR( 31 DOWNTO 0 ) := X"00000000";
	SIGNAL DM_ALU_result 		: STD_LOGIC_VECTOR( 31 DOWNTO 0 ) := X"00000000";
	
	--Performance counters
	SIGNAL ICPerformance			: STD_LOGIC_VECTOR( 63 downto 0 );
	SIGNAL DCPerformance			: STD_LOGIC_VECTOR( 95 downto 0 );
	SIGNAL BrPerformance			: STD_LOGIC_VECTOR( 63 downto 0 );
		
BEGIN
	
	PCOUT <= IF_PC_plus_4;
	clockOUT <= master_clock;
	
	pipe_clock <= '0'
		WHEN Imem_Nok = '1' OR Dmem_Nok = '1'
		ELSE master_clock;
	
			
	RS : uart
		PORT MAP (	
			OSC_50_CLK		=>		OSC_50_CLK,
			clock				=>		pipe_clock,
			CPU_inst			=>		EX_CPU_inst,
			transmit_data	=>		EX_ALU_Result,
			UART_D			=> 	UART_D,
			UART_BUSY		=> 	UART_BUSY
		);
		
	IFE : Ifetch
		PORT MAP (	
			pipe_clock			=> pipe_clock,  
			master_clock		=> master_clock,  
			reset 				=> reset,
			Instruction_out	=> IF_Instruction,
			PC_plus_4_out 		=> IF_PC_plus_4,
			Imem_Nok				=> Imem_Nok,
			ICPerformance_out => ICPerformance,

			--Branching
			Branch_addr 		=> Branch_addr,
			Branch_enable		=> Branch_enable,
			
			--Forwarding Unit
			Branch_freeze		=> Branch_freeze
		);

   
	ID : Idecode
   	PORT MAP (	
        	clock 				=> pipe_clock,  
			reset 				=> reset,
			register_array		=> register_array,
			read_data_1 		=> read_data_1,
        	read_data_2 		=> read_data_2,

			PC_plus_4			=> IF_PC_plus_4,			
			Instruction 		=> IF_Instruction,
			CPU_inst_out		=> ID_CPU_inst,
			BrPerformance_out	=> BrPerformance,
			
			--Bubble			--Branching
			Branch_freeze		=> Branch_freeze,
			Branch_addr_out	=> Branch_addr,
			Branch_enable_out	=> Branch_enable,
						
			--Forwarding Unit					
			Ctrl_EX_isModReg		=> Ctrl_EX_isModReg,
			Ctrl_EX_modRegAddr	=> Ctrl_EX_modRegAddr,
			Ctrl_EX_modRegValue	=> Ctrl_EX_modRegValue
		);

   CTL:   Control
		PORT MAP ( 	
			--From ID
			ID_CPU_inst				=> ID_CPU_inst,
			Branch_freeze			=> Branch_freeze,
			
			--From EX	
			EX_CPU_inst				=> EX_CPU_inst,
			EX_ALU_Result			=> EX_ALU_Result,
			Ctrl_EX_isModReg		=> Ctrl_EX_isModReg,
			Ctrl_EX_modRegAddr	=> Ctrl_EX_modRegAddr,
			Ctrl_EX_modRegValue	=> Ctrl_EX_modRegValue,
	
			--From DM
			DM_CPU_inst				=> DM_CPU_inst,
			DM_dmem_data			=> dmem_data,
			Ctrl_DM_isLoading		=> Ctrl_DM_isLoading,
			Ctrl_DM_modRegAddr	=> Ctrl_DM_modRegAddr,
			Ctrl_DM_modRegValue	=> Ctrl_DM_modRegValue
		);

   EXE:  Execute
   	PORT MAP (	
			clock					=> pipe_clock,
			reset					=> reset,
			Read_data_1 		=> read_data_1,
			Read_data_2 		=> read_data_2,
			ALU_Result_out		=> EX_ALU_Result,
			write_data_out		=> EX_write_data,
			
			--WriteThrough
			CPU_inst				=> ID_CPU_inst,
			CPU_inst_out		=> EX_CPU_inst,
			
			--Bubble!
			Branch_freeze		=> Branch_freeze,
			
			--Forwarding Unit
			Ctrl_DM_isLoading		=> Ctrl_DM_isLoading,
			Ctrl_DM_modRegAddr	=> Ctrl_DM_modRegAddr,
			Ctrl_DM_modRegValue	=> Ctrl_DM_modRegValue,
			Ctrl_EX_isModReg		=> Ctrl_EX_isModReg,
			Ctrl_EX_modRegAddr	=> Ctrl_EX_modRegAddr,
			Ctrl_EX_modRegValue	=> Ctrl_EX_modRegValue
		);

   MEM:  dmemory
		PORT MAP (	
			pipe_clock			=> pipe_clock,  
			master_clock		=> master_clock,  
			reset					=> reset,
			dmem_data			=> dmem_data,
			dmem_address		=> EX_ALU_Result (7 DOWNTO 0),
			dmem_write_data	=> EX_write_data,
			dmem_Nok				=> dmem_Nok,
			DCPerformance_out => DCPerformance,

			--WriteThrough
			CPU_inst				=> EX_CPU_inst,		
			CPU_inst_out		=> DM_CPU_inst,			
			ALU_result			=> EX_ALU_Result,			
			ALU_result_out		=> DM_ALU_Result
		);
		
	WB: WriteBack
		PORT MAP (	
			clock					=>	pipe_clock,
			reset					=> reset,
			register_array		=> register_array,	
			ICPerformance		=> ICPerformance,
			DCPerformance		=> DCPerformance,
			BrPerformance 		=> BrPerformance,
			dmem_data			=> dmem_data,
			CPU_inst				=> DM_CPU_inst,		
			ALU_result			=> DM_ALU_Result
		);

			
	process(OSC_50_CLK)
		variable counter  :	integer range 0 to DIVISOR := DIVISOR; 
	begin
	
		if(rising_edge(OSC_50_CLK)) then
			counter := counter - 1;		
			if(counter = 0) then
				master_clock <= NOT master_clock;
				counter := DIVISOR;				
			end if;				
		end if;
	end process;
	
END structure;

