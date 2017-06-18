--
-- Authors: Francisco Paiva Knebel
--				Gabriel Alexandre Zillmer
--
-- Universidade Federal do Rio Grande do Sul
-- Instituto de Inform�tica
-- Sistemas Digitais
-- Prof. Fernanda Lima Kastensmidt
--
-- Create Date:    09:49:46 05/03/2016 

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity neander is
	port (
		clk		: in STD_LOGIC;
		rst		: in STD_LOGIC;
		enable	: in STD_LOGIC;
		
		debug_out: out STD_LOGIC
	);
end neander;

architecture Behavioral of neander is
	component controlunit is
		port (
			clk		: in STD_LOGIC;
			rst		: in STD_LOGIC;
			enable_neander : in STD_LOGIC;
			N		: in STD_LOGIC;
			Z		: in STD_LOGIC;
			execNOP, execSTA, execLDA, execADD, execOR, execSHR, execSHL, execMUL,
			execAND, execNOT, execJMP, execJN, execJZ, execHLT : in STD_LOGIC;
						
						
			sel_ula		: out STD_LOGIC_VECTOR(2 downto 0);

			loadAC		: out STD_LOGIC;
			loadPC		: out STD_LOGIC;
			loadREM		: out STD_LOGIC;
			loadRDM		: out STD_LOGIC;
			loadRI 		: out STD_LOGIC;
			loadN			: out STD_LOGIC;
			loadZ			: out STD_LOGIC;

			wr_enable_mem : out STD_LOGIC_VECTOR (0 downto 0);
			sel			: out STD_LOGIC; -- mux_rem: 0 for PC, 1 for RDM
			PC_inc 		: out STD_LOGIC;
			sel_mux_RDM : out STD_LOGIC; -- mux_rdm: 0 for MEM, 1 for AC
			stop			: out STD_LOGIC
		);
	end component;
	
	COMPONENT dualBRAM
	  PORT (
		 clka : IN STD_LOGIC;
		 wea : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
		 addra : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
		 dina : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
		 douta : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
		 clkb : IN STD_LOGIC;
		 web : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
		 addrb : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
		 dinb : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
		 doutb : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
	  );
	END COMPONENT;
	
	component PC_register is
		 port (
			  clk         : in std_logic;
			  rst         : in std_logic;
			  cargaPC     : in std_logic;
			  incrementaPC: in std_logic;
			  data_in     : in std_logic_vector(7 downto 0);
			  
			  data_out    : out std_logic_vector(7 downto 0)
		 );
	end component;
	 
	component mux is
		 port (
				REG1    : in  std_logic_vector(7 downto 0);
				REG2    : in  std_logic_vector(7 downto 0);
				sel     : in  std_logic;
						 
				S       : out std_logic_vector(7 downto 0)
		 );                 
	end component;
	 
	component reg8bits is
		 port (
			  data_in   : in  STD_LOGIC_VECTOR (7 downto 0);
			  clk     	: in  STD_LOGIC;
			  rst     	: in  STD_LOGIC;
			  load      : in  STD_LOGIC;
			  
			  data_out  : out STD_LOGIC_VECTOR (7 downto 0)
		 );
	end component;
	 
	component decoder is
		 port (  
			  instruction_in : in  STD_LOGIC_VECTOR (7 downto 0);
			  
			  s_exec_NOP : out STD_LOGIC;
			  s_exec_STA : out STD_LOGIC;
			  s_exec_LDA : out STD_LOGIC;
			  s_exec_ADD : out STD_LOGIC;
			  s_exec_OR  : out STD_LOGIC;
			  s_exec_SHR : out STD_LOGIC;
			  s_exec_SHL : out STD_LOGIC;
			  s_exec_MUL : out STD_LOGIC;
			  s_exec_AND : out STD_LOGIC;
			  s_exec_NOT : out STD_LOGIC;
			  s_exec_JMP : out STD_LOGIC;
			  s_exec_JN  : out STD_LOGIC;
			  s_exec_JZ  : out STD_LOGIC;
			  s_exec_HLT : out STD_LOGIC
		 );
	end component;
	 
	component regNZ is
		 port (
			  N_in    : in    STD_LOGIC;
			  Z_in    : in    STD_LOGIC;
			  clk 	 : in  	STD_LOGIC;
			  rst 	 : in  	STD_LOGIC;
			  loadN   : in  	STD_LOGIC;
			  loadZ	 : in 	STD_LOGIC;
			  
			  N_out : out STD_LOGIC;
			  Z_out : out STD_LOGIC
		 );
	end component;
	 
	component ula is
		Port (  
			  X           : in  STD_LOGIC_VECTOR (7 downto 0);
			  Y           : in  STD_LOGIC_VECTOR (7 downto 0);
			  selector	  : in  STD_LOGIC_VECTOR (2 downto 0);
			  N           : out STD_LOGIC;
			  Z           : out STD_LOGIC;
			  output  	  : out STD_LOGIC_VECTOR (7 downto 0);
			  carryMUL	  : out STD_LOGIC_VECTOR (7 downto 0)
		 );
	end component;
	-------------------------
	--	PROGRAM SIGNALS
	-------------------------
	-- operation signal
	signal exec_NOP 		: STD_LOGIC;
	signal exec_STA 		: STD_LOGIC;
	signal exec_LDA		: STD_LOGIC;
	signal exec_ADD 		: STD_LOGIC;
	signal exec_OR			: STD_LOGIC;
	signal exec_SHR 		: STD_LOGIC;
	signal exec_SHL		: STD_LOGIC;
	signal exec_MUL		: STD_LOGIC;
	signal exec_AND 		: STD_LOGIC;
	signal exec_NOT 		: STD_LOGIC;
	signal exec_JMP 		: STD_LOGIC;
	signal exec_JN	   	: STD_LOGIC;
	signal exec_JZ 		: STD_LOGIC;
	signal exec_HLT 		: STD_LOGIC;
	-- load signals
	signal AC_load			: STD_LOGIC;
	signal N_load			: STD_LOGIC;
	signal Z_load			: STD_LOGIC;
	signal RI_load			: STD_LOGIC;
	signal REM_load		: STD_LOGIC;
	signal RDM_load		: STD_LOGIC;
	signal PC_load			: STD_LOGIC;
	-- ULA
	signal ULA_selector	: STD_LOGIC_VECTOR (2 downto 0);
	signal ULA_N			: STD_LOGIC;
	signal ULA_Z			: STD_LOGIC;
	signal ULA_output		: STD_LOGIC_VECTOR (7 downto 0);
	signal ULA_carryMUL	: STD_LOGIC_VECTOR (7 downto 0);
	-- AC
	signal AC_output		: STD_LOGIC_VECTOR (7 downto 0);	
	-- NZ
	signal NZ_outputN		: STD_LOGIC;
	signal NZ_outputZ		: STD_LOGIC;
	-- RI
	signal RI_output		: STD_LOGIC_VECTOR (7 downto 0);
	-- RDM
	signal RDM_output		: STD_LOGIC_VECTOR (7 downto 0);
	-- REM
	signal REM_output		: STD_LOGIC_VECTOR (7 downto 0);
	-- MPX
	signal MPX_output		: STD_LOGIC_VECTOR (7 downto 0);
	signal MPX_sel			: STD_LOGIC;
	-- MUX para o RDM
	signal muxrdm_output : STD_LOGIC_VECTOR (7 downto 0);
	signal muxrdm_sel		: STD_LOGIC;
	-- PC
	signal PC_increment	: STD_LOGIC;
	signal PC_output		: STD_LOGIC_VECTOR (7 downto 0);
	-- MEM
	signal wr_enable		: STD_LOGIC_VECTOR (0 downto 0);
	signal MEM_output		: STD_LOGIC_VECTOR (7 downto 0);
	signal MEM_output2	: STD_LOGIC_VECTOR (7 downto 0);

begin

	AC: reg8bits
	port map (
		data_in => ULA_output, clk => clk, rst => rst, load => AC_load, data_out => AC_output
	);--
	
	RI: reg8bits
	port map (
		data_in => RDM_output, clk => clk, rst => rst, load => RI_load, data_out => RI_output
	);--
	
	R_E_M: reg8bits
	port map (
		data_in => MPX_output, clk => clk, rst => rst, load => REM_load, data_out => REM_output
	);
	
	R_D_M: reg8bits
	port map (
		data_in => muxrdm_output, clk => clk, rst => rst, load => RDM_load, data_out => RDM_output	
	);--
	
	NZ : regNZ
	port map (
		N_in => ULA_N, Z_in => ULA_Z, clk => clk, rst => rst, loadN => N_load, loadZ => Z_load,
		N_out => NZ_outputN, Z_out => NZ_outputZ
	);--

	alu: ula
	port map (
		X => AC_output, Y => RDM_output, selector => ULA_selector, N => ULA_N, Z => ULA_Z, output => ULA_output, carryMUL => ULA_carryMUL
	);--
	
	dec: decoder
	port map (
		instruction_in => RI_output,
		s_exec_NOP => exec_NOP, s_exec_STA => exec_STA, s_exec_LDA => exec_LDA,
		s_exec_ADD => exec_ADD, s_exec_OR  => exec_OR,	s_exec_SHR => exec_SHR,
		s_exec_SHL => exec_SHL, s_exec_MUL => exec_MUL, s_exec_AND => exec_AND,
		s_exec_NOT => exec_NOT, s_exec_JMP => exec_JMP,
		s_exec_JN  => exec_JN,	s_exec_JZ  => exec_JZ, 	s_exec_HLT => exec_HLT
	);--
	
	mpx: mux
	port map ( -- mpx: 0 for PC, 1 for RDM
		REG1 => PC_output, REG2 => RDM_output, sel => MPX_sel, S =>	MPX_output
	);--
	
	mux_rdm: mux
	port map ( -- mux_rdm: 0 for MEM, 1 for AC
		REG1 => MEM_output, REG2 => AC_output, sel => muxrdm_sel, S => muxrdm_output
	);

	PC: PC_register
	port map (
		clk => clk, rst => rst, cargaPC => PC_load,
		incrementaPC => PC_increment, data_in => RDM_output, data_out => PC_output
	);--
	
	CU: controlunit
	port map (
		clk => clk, rst => rst, enable_neander => enable, N => NZ_outputN, Z => NZ_outputZ,
		
		-- operation signals
		execNOP => exec_NOP, execSTA => exec_STA, execLDA => exec_LDA,
		execADD => exec_ADD, execOR	 => exec_OR,  execSHR => exec_SHR,
		execSHL => exec_SHL, execMUL => exec_MUL, execAND => exec_AND,
		execNOT => exec_NOT, execJMP => exec_JMP, execJN  => exec_JN,
		execJZ	=> exec_JZ,  execHLT => exec_HLT,
		
		sel_ula => ULA_selector,
		loadAC  => AC_load , loadPC => PC_load, loadREM => REM_load,
		loadRDM => RDM_load, loadRI => RI_load,
		loadN	  => N_load  , loadZ  => Z_load,

		wr_enable_mem => wr_enable,
			
		sel => MPX_sel, PC_inc => PC_increment,
		sel_mux_RDM => muxrdm_sel, stop => debug_out
	);
	
	MEM : dualBRAM
	PORT MAP (
		clka => clk,
		wea => wr_enable,
		addra => REM_output,
		dina => RDM_output,
		douta => MEM_output,
		
		clkb => clk,
		web => "0",
		addrb => "00000000",
		dinb => "00000000",
		doutb => MEM_output2
	);
end Behavioral;

