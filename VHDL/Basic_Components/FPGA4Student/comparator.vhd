library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
entity comparator is
port (
      clock: in std_logic; 
      A,B: in std_logic_vector(7 downto 0); 
      IAB: in std_logic; -- Expansion input ( Active low)
      Output: out std_logic -- Output = 0 when A = B 
 );
end comparator;
architecture Behavioral of comparator is
signal AB: std_logic_vector(7 downto 0); -- temporary variables
signal Result: std_logic;
begin

 AB(0) <= (not A(0)) xnor (not B(0));         
        -- combinational circuit
 AB(1) <= (not A(1)) xnor (not B(1)); 
 AB(2) <= (not A(2)) xnor (not B(2)); 
 AB(3) <= (not A(3)) xnor (not B(3)); 
 AB(4) <= (not A(4)) xnor (not B(4)); 
 AB(5) <= (not A(5)) xnor (not B(5)); 
 AB(6) <= (not A(6)) xnor (not B(6)); 
 AB(7) <= (not A(7)) xnor (not B(7)); 
 process(clock)
 begin
 if(rising_edge(clock))then
   if(AB = x"FF" and IAB = '0') then         
         -- check whether A = B and IAB =0 or not
            Result <= '0';
    else
     Result <= '1';
    end if;
 end if;
 end process;
 Output <= Result;
end Behavioral;