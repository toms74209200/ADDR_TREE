-- =====================================================================
--  Title       : Moving average 64taps 3adder
--
--  File Name   : ADDR_TREE_3.vhd
--  Project     : Sample
--  Block       : 
--  Tree        : 
--  Designer    : toms74209200 <https://github.com/toms74209200>
--  Copyright   : 2019 toms74209200
--  License     : MIT License.
--                http://opensource.org/licenses/mit-license.php
-- =====================================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity ADDR_TREE_3 is
    port(
        CLK         : in    std_logic;                          --(p) Clock
        nRST        : in    std_logic;                          --(n) Reset

        EN          : in    std_logic;                          --(p) Data input enable
        IN_DAT      : in    std_logic_vector(15 downto 0);      --(p) Data

        OUT_DAT     : out   std_logic_vector(15 downto 0)       --(p) Data
        );
end ADDR_TREE_3;

architecture RTL of ADDR_TREE_3 is

-- Parameter --
constant TAP            : integer := 64;                        -- Filter taps

-- Internal signal --
type    RegAryType      is array (0 to TAP-1) of std_logic_vector(15 downto 0);
type    SumAryType      is array (0 to TAP-1) of std_logic_vector(IN_DAT'length+TAP-1 downto 0);
signal  dat_reg         : RegAryType;                           -- Data register array x[n]
signal  sum             : SumAryType;                           -- Sum array

begin

-- ***********************************************************
--  Data register
-- ***********************************************************
process (CLK, nRST) begin
    if (nRST = '0') then
        dat_reg(0) <= (others => '0');
    elsif (CLK'event and CLK = '1') then
        if (EN = '1') then
            dat_reg(0) <= IN_DAT;
        end if;
    end if;
end process;

process (CLK, nRST) begin
    for i in 1 to TAP-1 loop
        if (nRST = '0') then
            dat_reg(i) <= (others => '0');
        elsif (CLK'event and CLK = '1') then
            if (EN = '1') then
                dat_reg(i) <= dat_reg(i-1);
            end if;
        end if;
    end loop;
end process;


-- ***********************************************************
--  Summation
-- ***********************************************************
process (CLK, nRST) begin
    for i in 0 to 20 loop
        if (nRST = '0') then 
            sum(i) <= (others => '0');
        elsif (CLK'event and CLK = '1') then
            if (EN = '1') then
                sum(i) <= (X"0000_0000_0000_0000" & dat_reg(i*3)) + (X"0000_0000_0000_0000" & dat_reg(i*3+1)) + (X"0000_0000_0000_0000" & dat_reg(i*3+2));
            end if;
        end if;
    end loop;
end process;

process (CLK, nRST) begin
    for i in 0 to 6 loop
        if (nRST = '0') then 
            sum(i+21) <= (others => '0');
        elsif (CLK'event and CLK = '1') then
            if (EN = '1') then
                sum(i+21) <= sum(i*3) + sum(i*3+1) + sum(i*3+2);
            end if;
        end if;
    end loop;
end process;

process (CLK, nRST) begin
    if (nRST = '0') then 
        sum(28) <= (others => '0');
        sum(29) <= (others => '0');
    elsif (CLK'event and CLK = '1') then
        if (EN = '1') then
            sum(28) <= sum(21) + sum(22) + sum(23);
            sum(29) <= sum(24) + sum(25) + sum(26);
            sum(30) <= sum(27) + (X"0000_0000_0000_0000" & dat_reg(63));
        end if;
    end if;
end process;

process (CLK, nRST) begin
    if (nRST = '0') then 
        sum(31) <= (others => '0');
    elsif (CLK'event and CLK = '1') then
        if (EN = '1') then
            sum(31) <= sum(28) + sum(29) + sum(30);
        end if;
    end if;
end process;


-- ***********************************************************
--  Divider
-- ***********************************************************
OUT_DAT <= sum(31)(21 downto 6);


end RTL;    -- ADDR_TREE_3