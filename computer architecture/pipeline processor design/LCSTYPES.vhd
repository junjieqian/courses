-- Computer Architecture Project
-- Spring 2012

-- the MIPS computer
LIBRARY IEEE; 			
USE IEEE.STD_LOGIC_1164.ALL;

package LCSTYPES is
    	
		TYPE ALU_FUNCTION is (add, addi, subtract, slt, brancheq, load, store, transmit, nop);
		TYPE register_file IS ARRAY ( 0 TO 31 ) OF STD_LOGIC_VECTOR( 31 DOWNTO 0 );
		TYPE cache_4blocks IS ARRAY ( 0 TO 3) OF STD_LOGIC_VECTOR( 31 DOWNTO 0 );
		
		TYPE LCSInstruction IS record
			alu			: ALU_function;
			rs				: STD_LOGIC_VECTOR( 4 DOWNTO 0 );
			rt				: STD_LOGIC_VECTOR( 4 DOWNTO 0 );
			rd				: STD_LOGIC_VECTOR( 4 DOWNTO 0 );
			immediate	: STD_LOGIC_VECTOR( 31 DOWNTO 0 );
		end record;
		
		TYPE cache_frame IS record
			valid:			STD_LOGIC;
			dirty:			STD_LOGIC;
			tag:				STD_LOGIC_VECTOR(1 downto 0);
			cache_block: 	cache_4blocks;
		end record;
		
		TYPE cache_struct IS ARRAY ( 15 downto 0 ) OF cache_frame;
		
		CONSTANT NOPConstant : LCSInstruction := (alu => nop, rs => B"00000", rt => B"00000", rd => B"00000", immediate => X"00000000");
end package LCSTYPES;
