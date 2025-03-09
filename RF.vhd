library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity RF is
    Port ( clk : in STD_LOGIC;
           ReadAddress1 : in STD_LOGIC_VECTOR (3 downto 0);
           ReadAddress2 : in STD_LOGIC_VECTOR (3 downto 0);
           WriteAddress : in STD_LOGIC_VECTOR (3 downto 0);
           WriteData : in STD_LOGIC_VECTOR (15 downto 0);
           RegWrite : in STD_LOGIC;
           ReadData1 : out STD_LOGIC_VECTOR (15 downto 0);
           ReadData2 : out STD_LOGIC_VECTOR (15 downto 0));       
end RF;

architecture Behavioral of RF  is

type reg_array is array(0 to 15) of STD_LOGIC_VECTOR(15 downto 0);
signal reg_file : reg_array := (
		X"0000",
		X"A45C",
		X"7402",
		X"9903",
		X"AAAA",
		X"0F21",
		X"004C",
		X"9907",
		others => X"0000");
begin

    -- write port
    write: process(clk)			
    begin
        if rising_edge(clk) then
            if RegWrite = '1' then
                reg_file(conv_integer(WriteAddress)) <= WriteData;		
            end if;
        end if;
    end process;		

    -- read ports
    ReadData1 <= reg_file(conv_integer(ReadAddress1));
    ReadData2 <= reg_file(conv_integer(ReadAddress2));

end Behavioral;