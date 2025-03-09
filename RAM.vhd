library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity RAM is
    Port ( clk : in STD_LOGIC;
           Address : STD_LOGIC_VECTOR (3 downto 0);
           WriteData : in STD_LOGIC_VECTOR (15 downto 0);
           MemWrite : in STD_LOGIC;
           MemData : out STD_LOGIC_VECTOR (15 downto 0));
end RAM;

architecture Behavioral of RAM is

type ram_type is array (0 to 15) of STD_LOGIC_VECTOR (15 downto 0);
signal RAM: ram_type := (
		X"0000",
        X"0001",
        X"0002",
        X"0003",
        X"0004",
        X"0005",
        X"0006",
        X"0007",
        others => X"0000");

begin

    process (clk)
    begin
        if rising_edge(clk) then
            if MemWrite = '1' then
                RAM(conv_integer(Address)) <= WriteData;
                MemData <= WriteData;
            else
                MemData <= RAM(conv_integer(Address));
            end if;
        end if;
    end process;
    
end Behavioral;