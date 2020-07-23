--------------------------------------------------------------------------
-- destop.vhd
--
-- Verilog source for the toplevel OpenCores.org DES tutorial.
-- This source includes an instantiation of the DES module, hooks to 
-- the FrontPanel host interface, as well as a short behavioral 
-- description of the DES stepping to complete an encrypt/decrypt
-- process.  This part includes PipeIn / PipeOut interfaces to allow block
-- encryption and decryption.
--
-- There are two block RAMs instantiated, one for the input side and
-- one for the output side.  Each one is configured as 18-bits on 
-- one port and 36-bits on the other port.  The parity bits are not 
-- used.
--
-- INPUT RAM: The 18-bit port is connected to the PipeIn.  Data is 
-- written directly from the pipe to the RAM.  The 36-bit port is
-- connected to the state machine and sources the 64-bit input to 
-- the DES algorithm.
--
-- OUTPUT RAM: The 36-bit port is connected to the state machine and
-- is the destination for the 64-bit result from the DES algorithm.
-- The 18-bit port is connected to the PipeOut.  Data is read directly
-- from this RAM by the pipe.
--
-- Copyright (c) 2005-2009 Opal Kelly Incorporated
--------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_misc.all;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;

use work.FRONTPANEL.all;

entity destop is
	port (
		okUH      : in     STD_LOGIC_VECTOR(4 downto 0);
		okHU      : out    STD_LOGIC_VECTOR(2 downto 0);
		okUHU     : inout  STD_LOGIC_VECTOR(31 downto 0);
		okAA      : inout  STD_LOGIC;

		sys_clk_p : in     STD_LOGIC;
		sys_clk_n : in     STD_LOGIC;
		
		led       : out    STD_LOGIC_VECTOR(3 downto 0)
	);
end destop;

architecture arch of destop is
	component des port (
		clk      : in std_logic;
		roundSel : in std_logic_vector(3 downto 0);
		desOut   : out std_logic_vector(63 downto 0);
		desIn    : in std_logic_vector(63 downto 0);
		key      : in std_logic_vector(55 downto 0);
		decrypt  : in std_logic);
	end component;

	component alt_inbuf_diff
	PORT
	(
		i    : IN STD_LOGIC;
		ibar : IN STD_LOGIC;
		o    : OUT STD_LOGIC
	);
	end component;
	
	component ramb_w32_512_r32_512 PORT (
		aclr_a    : IN STD_LOGIC  := '0';
		aclr_b    : IN STD_LOGIC  := '0';
		address_a : IN STD_LOGIC_VECTOR (8 DOWNTO 0);
		address_b : IN STD_LOGIC_VECTOR (8 DOWNTO 0);
		clock_a   : IN STD_LOGIC  := '1';
		clock_b   : IN STD_LOGIC ;
		data_a    : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
		data_b    : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
		rden_a    : IN STD_LOGIC  := '1';
		rden_b    : IN STD_LOGIC  := '1';
		wren_a    : IN STD_LOGIC  := '0';
		wren_b    : IN STD_LOGIC  := '0';
		q_a       : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
		q_b       : OUT STD_LOGIC_VECTOR (31 DOWNTO 0) );
	end component;
	
	signal okClk        : STD_LOGIC;
	signal okHE         : STD_LOGIC_VECTOR(112 downto 0);
	signal okEH         : STD_LOGIC_VECTOR(64 downto 0);
	signal okEHx        : STD_LOGIC_VECTOR(65*3-1 downto 0);
	signal sys_clk      : STD_LOGIC;

	signal des_out      : STD_LOGIC_VECTOR(63 downto 0);
	signal des_in       : STD_LOGIC_VECTOR(63 downto 0);
	signal des_key      : STD_LOGIC_VECTOR(63 downto 0);
	signal des_keyshort : STD_LOGIC_VECTOR(55 downto 0);
	signal des_decrypt  : STD_LOGIC;
	signal des_roundSel : STD_LOGIC_VECTOR(3 downto 0);
	signal des_result   : STD_LOGIC_VECTOR(63 downto 0);
	
	signal WireIn08     : STD_LOGIC_VECTOR(31 downto 0);
	signal WireIn09     : STD_LOGIC_VECTOR(31 downto 0);
	signal WireIn0A     : STD_LOGIC_VECTOR(31 downto 0);
	signal WireIn0B     : STD_LOGIC_VECTOR(31 downto 0);
	signal WireIn10     : STD_LOGIC_VECTOR(31 downto 0);
	signal TrigIn40     : STD_LOGIC_VECTOR(31 downto 0);
	signal TrigIn41     : STD_LOGIC_VECTOR(31 downto 0);
	signal TrigOut60    : STD_LOGIC_VECTOR(31 downto 0);
	
	signal pipeI_write  : STD_LOGIC;
	signal pipeO_read   : STD_LOGIC;
	signal pipeI_data   : STD_LOGIC_VECTOR(31 downto 0);
	signal pipeO_data   : STD_LOGIC_VECTOR(31 downto 0);
	signal start        : STD_LOGIC;
	signal reset        : STD_LOGIC;
	signal ram_reset    : STD_LOGIC;
	signal done         : STD_LOGIC;

	signal ramI_addrA   : STD_LOGIC_VECTOR(8 downto 0);
	signal ramI_addrB   : STD_LOGIC_VECTOR(8 downto 0);
	signal ramO_addrA   : STD_LOGIC_VECTOR(8 downto 0);
	signal ramO_addrB   : STD_LOGIC_VECTOR(8 downto 0);
	signal ramO_write   : STD_LOGIC;
	signal ramI_dout    : STD_LOGIC_VECTOR(31 downto 0);
	signal ramO_din     : STD_LOGIC_VECTOR(31 downto 0);

	type state_type is (s_idle,
	                    s_loadinput1,
	                    s_loadinput2,
	                    s_loadinput3,
	                    s_dodes1,
	                    s_saveoutput1,
	                    s_saveoutput2,
	                    s_saveoutput3,
	                    s_done);
	signal state : state_type;

	signal i : INTEGER;
	
begin

alt_inbuf_diff_inst: alt_inbuf_diff PORT MAP (
	i    => sys_clk_p,
	ibar => sys_clk_n,
	o    => sys_clk
	);

led(3)       <= '0' when (des_roundSel(3) = '1') else 'Z';
led(2)       <= '0' when (des_roundSel(2) = '1') else 'Z';
led(1)       <= '0' when (des_roundSel(1) = '1') else 'Z';
led(0)       <= '0' when (des_roundSel(0) = '1') else 'Z';
reset        <= WireIn10(0);
des_decrypt  <= WireIn10(4);
start        <= TrigIn40(0);
ram_reset    <= TrigIn41(0);
TrigOut60(0) <= done;
des_key      <= WireIn0B(15 downto 0) & WireIn0A(15 downto 0) & WireIn09(15 downto 0) & WireIn08(15 downto 0);

-- Remove KEY parity bits.
des_keyshort <= (des_key(63 downto 57) &
                 des_key(55 downto 49) &
                 des_key(47 downto 41) &
                 des_key(39 downto 33) &
                 des_key(31 downto 25) &
                 des_key(23 downto 17) &
                 des_key(15 downto 9) &
                 des_key(7 downto 1));

-- Block DES state machine.
--
-- This machine is triggered to perform the DES encrypt/decrypt algorithm
-- on a full block RAM.  Upon triggering, it performs the DES algorithm
-- on 64-bit sections for the entire 2048-byte block RAM.  When complete,
-- it asserts DONE for a single cycle.
process (sys_clk) begin
	if rising_edge(sys_clk) then
		if (reset = '1') then
			done <= '0';
			state <= s_idle;
		else
			done <= '0';
			ramO_write <= '0';
		
			case (state) is
				when s_idle =>
					if (start = '1') then
						state <= s_loadinput1;
						ramI_addrB <= "000000000";
						ramO_addrB <= "000000000";
					end if;
		
				when s_loadinput1 =>
					state <= s_loadinput2;
					ramI_addrB <= ramI_addrB + "1";
			
				when s_loadinput2 =>
					state <= s_loadinput3;
					des_in(31 downto 0) <= ramI_dout;
					ramI_addrB <= ramI_addrB + "1";
		
				when s_loadinput3 =>
					state <= s_dodes1;
					des_in(63 downto 32) <= ramI_dout;
					des_roundSel <= "0000";

				when s_dodes1 =>
					state <= s_dodes1;
					des_roundSel <= des_roundSel + "1";
					if (des_roundSel = x"f") then
						des_result <= des_out;
						state <= s_saveoutput1;
					end if;
		
				when s_saveoutput1 =>
					state <= s_saveoutput2;
					ramO_din <= des_result(31 downto 0);
					ramO_write <= '1';
		
				when s_saveoutput2 =>
					state <= s_saveoutput3;
					ramO_din <= des_result(63 downto 32);
					ramO_write <= '1';
					ramO_addrB <= ramO_addrB + "1";
			
				when s_saveoutput3 =>
					ramO_addrB <= ramO_addrB + "1";
					if (ramI_addrB = "00000000000") then
						state <= s_done;
					else
						state <= s_loadinput1;
					end if;
		
				when s_done =>
					state <= s_idle;
					done <= '1';
					
			end case;
		end if;
	end if;
end process;


-- Pipe <--> RAM addressing
--
-- The PipeIn and PipeOut are connected directly to one port of each
-- block RAM.  The only thing we need to take care of is the address
-- pointers.  They are reset on RAM_RESET (a TriggerIn) and incremented
-- on write and read operations, respectively.
process (okClk) is
begin
	if rising_edge(okClk) then
		if (ram_reset = '1') then
			ramI_addrA <= "000000000";
			ramO_addrA <= "000000000";
		else
			if (pipeI_write = '1') then
				ramI_addrA <= ramI_addrA + "1";
			end if;

			if (pipeO_read = '1') then
				ramO_addrA <= ramO_addrA + "1";
			end if;
		end if;
	end if;
end process;


-- Instantiate the input block RAM
ram_I : ramb_w32_512_r32_512 port map(
	aclr_a => reset,
	aclr_b => reset,
	address_a => ramI_addrA,
	address_b => ramI_addrB,
	clock_a => okClk,
	clock_b => sys_clk,
	data_a => pipeI_data,
	data_b => x"0000_0000",
	rden_a => '0',
	rden_b => '1',
	wren_a => pipeI_write,
	wren_b => '0',
	q_b => ramI_dout );

-- Instantiate the output block RAM
ram_O : ramb_w32_512_r32_512 port map(
	aclr_a => reset,
	aclr_b => reset,
	address_a => ramO_addrA,
	address_b => ramO_addrB,
	clock_a => okClk,
	clock_b => sys_clk,
	data_a => x"0000_0000",
	data_b => ramO_din,
	rden_a => '1',
	rden_b => '0',
	wren_a => '0',
	wren_b => ramO_write,
	q_a => pipeO_data );

-- Instantiate the OpenCores.org DES module.
desModule : des port map(
		clk => sys_clk, roundSel => des_roundSel,
		desOut => des_out, desIn => des_in,
		key => des_keyshort, decrypt => des_decrypt);


-- Instantiate the okHost and connect endpoints
okHI : okHost port map (
	okUH=>okUH, 
	okHU=>okHU, 
	okUHU=>okUHU, 
	okAA=>okAA,
	okClk=>okClk, 
	okHE=>okHE, 
	okEH=>okEH
);

okWO : okWireOR     generic map (N=>3) port map (okEH=>okEH, okEHx=>okEHx);

ep08 : okWireIn     port map (okHE=>okHE,                                    ep_addr=>x"08", ep_dataout=>WireIn08);
ep09 : okWireIn     port map (okHE=>okHE,                                    ep_addr=>x"09", ep_dataout=>WireIn09);
ep0A : okWireIn     port map (okHE=>okHE,                                    ep_addr=>x"0A", ep_dataout=>WireIn0A);
ep0B : okWireIn     port map (okHE=>okHE,                                    ep_addr=>x"0B", ep_dataout=>WireIn0B);
ep10 : okWireIn     port map (okHE=>okHE,                                    ep_addr=>x"10", ep_dataout=>WireIn10);
ep40 : okTriggerIn  port map (okHE=>okHE,                                    ep_addr=>x"40", ep_clk=>sys_clk, ep_trigger=>TrigIn40);
ep41 : okTriggerIn  port map (okHE=>okHE,                                    ep_addr=>x"41", ep_clk=>okClk, ep_trigger=>TrigIn41);
ep60 : okTriggerOut port map (okHE=>okHE, okEH=>okEHx( 1*65-1 downto 0*65 ), ep_addr=>x"60", ep_clk=>sys_clk, ep_trigger=>TrigOut60);
ep80 : okPipeIn     port map (okHE=>okHE, okEH=>okEHx( 2*65-1 downto 1*65 ), ep_addr=>x"80", ep_write=>pipeI_write, ep_dataout=>pipeI_data);
epA0 : okPipeOut    port map (okHE=>okHE, okEH=>okEHx( 3*65-1 downto 2*65 ), ep_addr=>x"a0", ep_read=>pipeO_read, ep_datain=>pipeO_data);

end arch;