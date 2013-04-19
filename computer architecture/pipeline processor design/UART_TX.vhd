-- Computer Architecture Project
-- Spring 2012

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity UART_TX is
	Port ( 
		I_CLK				: in std_logic;
		I_RESET_NEG		: in std_logic;
		I_TX_Start		: in std_logic;
		I_TX_Data		: in std_logic_vector(7 downto 0);
		Q_TXD				: out std_logic;
		Q_BUSY			: out std_logic 
	);
end UART_TX;

architecture Behavior of UART_TX is

	constant DIVISOR : integer := (50000000/115200); 			-- for baud rate 115200	

	type		UartTXStateType is (IDLE, TRANSMIT);
	signal	S_UartTXState: 	UartTXStateType := IDLE;
	signal	S_TX_Register: 	std_logic_vector(10 downto 0) := (others=>'1'); 

begin
	TransmitFSM: process (I_CLK)					-- a finite state machine triggered by clock signals
		variable S_TX_Counter  : integer range 0 to DIVISOR := DIVISOR;  
	begin
		if (rising_edge(I_CLK)) then							-- upon the rising edge of a clock signal
		
			if (I_RESET_NEG = '0') then								-- if "reset"
				S_UartTXState <= IDLE; 
				S_TX_Register <= (others=>'1');
			else												-- otherwise
				case S_UartTXState is					-- check the uart status
				
					when IDLE =>								-- if "idle"
						S_TX_Counter := DIVISOR;
						S_TX_Register <= (others=>'1');
						if (I_TX_Start = '1') then
							S_TX_Register <= "11" & I_TX_Data & '0'; 
							S_UartTXState <= TRANSMIT;
						end if;

					when TRANSMIT =>
						S_TX_Counter := S_TX_Counter - 1;
						if (S_TX_Counter = 0) then
							if (S_TX_Register(10 downto 1) = "0000000000") then 
								S_UartTXState <= IDLE;
								S_TX_Register <= (others=>'1');
							else
								S_TX_Counter := DIVISOR;
								S_TX_Register <= '0' & S_TX_Register(10 downto 1);
							end if;
						end if;
						
					when others => 
						S_UartTXState <= IDLE;
						
				end case;
			end if;
		end if;
   end process;

   Q_TXD 	<= 	S_TX_Register(0);
   Q_BUSY 	<= 	'1' when (S_UartTXState = TRANSMIT) else '0';   
end Behavior;
