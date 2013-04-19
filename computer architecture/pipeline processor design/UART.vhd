-- Computer Architecture Project
-- Spring 2012

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE WORK.LCSTYPES.ALL;

ENTITY UART IS
   PORT (
      OSC_50_CLK        : IN STD_LOGIC;								--	50 MHz
      clock					: IN STD_LOGIC;								-- Same as 50MHz or could be a button or such		
		CPU_inst				: IN LCSInstruction;								-- Comes from the processor, is '1' when there is new data ready
		transmit_data		: IN STD_LOGIC_VECTOR( 31 DOWNTO 0 );  -- The data (This code latches it at the falling edge of clock)
      UART_D         	: OUT STD_LOGIC;								--	UART Transmitter Data
      UART_BUSY			: OUT STD_LOGIC								--	UART Transmitter Status 
   );
END ENTITY UART;


ARCHITECTURE BEHAVIOR OF UART IS

COMPONENT UART_TX is
	Port ( 
		I_CLK				:	in std_logic;
		I_RESET_NEG		:	in std_logic;
		I_TX_Start		:	in std_logic;
		I_TX_Data		:	in std_logic_vector(7 downto 0);
		Q_TXD          :	out std_logic;
		Q_BUSY			:	out std_logic 
	);
END COMPONENT UART_TX;

--//////////////////////////////////////////////////////////////////


	type s32_array is array (0 to 255) of std_logic_vector(31 downto 0);
   SIGNAL stack:	s32_array;
	
	SIGNAL UART_newTransmit			:	STD_LOGIC := '0';
	SIGNAL UART_transmit_data		:	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
	SIGNAL UART_CPU_inst				:	LCSInstruction;
	
	SIGNAL UART_TX_START				:	STD_LOGIC := '0';
	SIGNAL UART_TX_STATUS			:	STD_LOGIC := '0';
	SIGNAL UART_TX_BUFFER			:	STD_LOGIC_VECTOR(7 downto 0);
	
BEGIN   

	UART_newTransmit <= '1' WHEN UART_CPU_inst.alu = transmit ELSE '0';
	
	PROCESS(clock)  BEGIN
		IF(clock'event AND clock = '1') THEN
			UART_transmit_data 	<= transmit_data;
			UART_CPU_inst			<= CPU_inst;
		END IF;
	END PROCESS;

-------------------------------------SAMPLE to use uart txd.----------------------------------------
--UART configuration in PC: Baud 115200, Data Bits:8, Stop Bits: 1, Parity: None, Flow Control: None
		
	--output data process
	process (clock)
	
		variable present	:	std_logic_vector( 31 downto 0)		;
		variable nibble	:	std_logic_vector( 3 downto 0)			;
		variable ascii		:	std_logic_vector( 3 downto 0)			;
		variable top		:	integer range 0 to 255			:= 0	;
		variable bottom	:	integer range 0 to 255			:= 0	;
		variable byte8		:	integer range 0 to 9 			:= 0	;
	begin
	
		IF (clock'event AND clock = '0') THEN
	
			--new data came in
			IF (UART_newTransmit = '1') then
				stack(top)	<=	UART_transmit_data;
				top 			:=	top + 1; 		-- mod 256 not needed, there will be no more thatn 256 characters to send
			END IF;
			
			--If we have stuff to transmit, we're not transmitting anything, and we haven't asked uart to transmit any new stuff, then:
			IF ((UART_TX_STATUS = '0') AND (UART_TX_START = '0') AND ((bottom /= top) OR (byte8 /= 0) )) THEN
			
				--If byte8 = 0 we POP the next 32 bit integer
				if(byte8 = 0) then
					present	:= stack(bottom);
					bottom	:= bottom + 1;
					
					IF(bottom = top AND UART_newTransmit = '1') THEN
						present := UART_transmit_data;
					END IF;
					
				end if;
				
				--If we've transmitted 9 nibbles, the 10th is the CR
				if(byte8 = 1) then
					ascii		:= X"0"; --NL
					nibble	:= X"D"; --NL
				
				--If we've transmitted 8 nibbles, the 9th is the NL
				elsif(byte8 = 2) then
					ascii		:= X"0"; --NL
					nibble	:= X"A"; --NL
				--Else, we're still transmitting the 8 nibbles
				else
					nibble	:= present(31 downto 28);
					present	:= present(27 downto 0) & b"0000"; --shift 4
					
					--Adapt the nibble into a byte to match it's ascii code
					if(nibble < 10) then
						ascii	:= b"0011";
					else
						ascii := b"0100";
						nibble := nibble - 9;
					end if;
				end if;
				byte8		:=	(byte8 - 1) mod 10;
				
				UART_TX_BUFFER 	    <= ascii & nibble;      --Send it in ASCII (Will be replaced by 8to4 component)
				UART_TX_START		<= '1'; 				--Request the start of trasmission
				
			--whenever UART starts transmitting, we clean up the request bit
			elsif(UART_TX_STATUS = '1') THEN
				
				UART_TX_START <= '0';		--1 means there is no pending request to uart		
			end if;
			
		end if;
	end process;
	

--------------------------------------Define the Interconnection------------------------------------   
	TXD : UART_TX
	PORT MAP (
		I_CLK				=>	OSC_50_CLK,
		I_RESET_NEG		=>	'1',
		I_TX_Start		=>	UART_TX_START,
		I_TX_Data		=>	UART_TX_BUFFER,
		Q_TXD				=>	UART_D,
		Q_BUSY			=> UART_TX_STATUS
	);
	
	UART_BUSY <= UART_TX_STATUS;

END ARCHITECTURE BEHAVIOR;
