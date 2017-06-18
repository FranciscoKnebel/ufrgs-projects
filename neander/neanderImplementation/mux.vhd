--
-- Authors: Francisco Paiva Knebel
--				Gabriel Alexandre Zillmer
--
-- Universidade Federal do Rio Grande do Sul
-- Instituto de Inform�tica
-- Sistemas Digitais
-- Prof. Fernanda Lima Kastensmidt
--
-- Create Date:    11:07:47 05/03/2016 

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity mux is 
	port (
				REG1   	: in  std_logic_vector(7 downto 0);
				REG2  	: in  std_logic_vector(7 downto 0);
				sel  	: in  std_logic;
				
				S		: out std_logic_vector(7 downto 0)
	);					
end mux;

architecture Behavioral of mux is

begin

	S <= REG1 when sel = '0' else
		  REG2 when sel = '1';
	  
end Behavioral;