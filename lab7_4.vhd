-- MIPS16 Single Cycle

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity lab7_4 is
    Port ( clk : in STD_LOGIC;
           btn : in STD_LOGIC_VECTOR (4 downto 0);
           sw : in STD_LOGIC_VECTOR (15 downto 0);
           led : out STD_LOGIC_VECTOR (15 downto 0);
           an : out STD_LOGIC_VECTOR (3 downto 0);
           cat : out STD_LOGIC_VECTOR (6 downto 0));
end lab7_4;

architecture Behavioral of lab7_4 is

component MPG is
    Port ( en : out STD_LOGIC;
           input : in STD_LOGIC;
           clock : in STD_LOGIC);
end component;

component SSD is
    Port ( clk: in STD_LOGIC;
           digits: in STD_LOGIC_VECTOR(15 downto 0);
           an: out STD_LOGIC_VECTOR(3 downto 0);
           cat: out STD_LOGIC_VECTOR(6 downto 0));
end component;

component IFetch
    Port ( clk: in STD_LOGIC;
           rst : in STD_LOGIC;
           en : in STD_LOGIC;
           BranchAddress : in STD_LOGIC_VECTOR(15 downto 0);
           JumpAddress : in STD_LOGIC_VECTOR(15 downto 0);
           Jump : in STD_LOGIC;
           PCSrc : in STD_LOGIC;
           Instruction : out STD_LOGIC_VECTOR(15 downto 0);
           PCinc : out STD_LOGIC_VECTOR(15 downto 0));
end component;

component IDecode
    Port ( clk: in STD_LOGIC;
           en : in STD_LOGIC;    
           Instr : in STD_LOGIC_VECTOR(12 downto 0);
           WD : in STD_LOGIC_VECTOR(15 downto 0);
           RegWrite : in STD_LOGIC;
           RegDst : in STD_LOGIC;
           ExtOp : in STD_LOGIC;
           RD1 : out STD_LOGIC_VECTOR(15 downto 0);
           RD2 : out STD_LOGIC_VECTOR(15 downto 0);
           Ext_Imm : out STD_LOGIC_VECTOR(15 downto 0);
           func : out STD_LOGIC_VECTOR(2 downto 0);
           sa : out STD_LOGIC);
end component;

component MainControl
    Port ( Instr : in STD_LOGIC_VECTOR(2 downto 0);
           RegDst : out STD_LOGIC;
           ExtOp : out STD_LOGIC;
           ALUSrc : out STD_LOGIC;
           Branch : out STD_LOGIC;
           Jump : out STD_LOGIC;
           ALUOp : out STD_LOGIC_VECTOR(2 downto 0);
           MemWrite : out STD_LOGIC;
           MemtoReg : out STD_LOGIC;
           RegWrite : out STD_LOGIC);
end component;

component ExecutionUnit is
    Port ( PCinc : in STD_LOGIC_VECTOR(15 downto 0);
           RD1 : in STD_LOGIC_VECTOR(15 downto 0);
           RD2 : in STD_LOGIC_VECTOR(15 downto 0);
           Ext_Imm : in STD_LOGIC_VECTOR(15 downto 0);
           func : in STD_LOGIC_VECTOR(2 downto 0);
           sa : in STD_LOGIC;
           ALUSrc : in STD_LOGIC;
           ALUOp : in STD_LOGIC_VECTOR(2 downto 0);
           BranchAddress : out STD_LOGIC_VECTOR(15 downto 0);
           ALURes : out STD_LOGIC_VECTOR(15 downto 0);
           Zero : out STD_LOGIC);
end component;

component MEM
    port ( clk : in STD_LOGIC;
           en : in STD_LOGIC;
           ALUResIn : in STD_LOGIC_VECTOR(15 downto 0);
           RD2 : in STD_LOGIC_VECTOR(15 downto 0);
           MemWrite : in STD_LOGIC;			
           MemData : out STD_LOGIC_VECTOR(15 downto 0);
           ALUResOut : out STD_LOGIC_VECTOR(15 downto 0));
end component;

signal Instruction, PCinc, RD1, RD2, WD, Ext_imm : STD_LOGIC_VECTOR(15 downto 0); 
signal JumpAddress, BranchAddress, ALURes, ALURes1, MemData : STD_LOGIC_VECTOR(15 downto 0);
signal func : STD_LOGIC_VECTOR(2 downto 0);
signal sa, zero : STD_LOGIC;
signal digits : STD_LOGIC_VECTOR(15 downto 0);
signal en, rst, PCSrc : STD_LOGIC; 
-- main controls 
signal RegDst, ExtOp, ALUSrc, Branch, Jump, MemWrite, MemtoReg, RegWrite : STD_LOGIC;
signal ALUOp :  STD_LOGIC_VECTOR(2 downto 0);

begin

    -- buttons: reset, enable
    monopulse1: MPG port map(en, btn(0), clk);
    monopulse2: MPG port map(rst, btn(1), clk);
    
    -- main units
    inst_IF: IFetch port map(clk, rst, en, BranchAddress, JumpAddress, Jump, PCSrc, Instruction, PCinc);
    inst_ID: IDecode port map(clk, en, Instruction(12 downto 0), WD, RegWrite, RegDst, ExtOp, RD1, RD2, Ext_imm, func, sa);
    inst_MC: MainControl port map(Instruction(15 downto 13), RegDst, ExtOp, ALUSrc, Branch, Jump, ALUOp, MemWrite, MemtoReg, RegWrite);
    inst_EX: ExecutionUnit port map(PCinc, RD1, RD2, Ext_imm, func, sa, ALUSrc, ALUOp, BranchAddress, ALURes, Zero); 
    inst_MEM: MEM port map(clk, en, ALURes, RD2, MemWrite, MemData, ALURes1);

    -- WriteBack unit
    with MemtoReg select
        WD <= MemData when '1',
              ALURes1 when '0',
              (others => 'X') when others;

    -- branch control
    PCSrc <= Zero and Branch;

    -- jump address
    JumpAddress <= PCinc(15 downto 13) & Instruction(12 downto 0);

   -- SSD display MUX
    with sw(7 downto 5) select
        digits <=  Instruction when "000", 
                   PCinc when "001",
                   RD1 when "010",
                   RD2 when "011",
                   Ext_Imm when "100",
                   ALURes when "101",
                   MemData when "110",
                   WD when "111",
                   (others => 'X') when others; 

    display : SSD port map (clk, digits, an, cat);
    
    -- main controls on the leds
    led(10 downto 0) <= ALUOp & RegDst & ExtOp & ALUSrc & Branch & Jump & MemWrite & MemtoReg & RegWrite;
    
end Behavioral;