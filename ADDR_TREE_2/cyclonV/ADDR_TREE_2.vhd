-- =====================================================================
--  Title       : Moving average 64taps 2adder
--
--  File Name   : ADDR_TREE_2.vhd
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

entity ADDR_TREE_2 is
    port(
        CLK         : in    std_logic;                          --(p) Clock
        nRST        : in    std_logic;                          --(n) Reset

        EN          : in    std_logic;                          --(p) Data input enable
        IN_DAT      : in    std_logic_vector(15 downto 0);      --(p) Data

        OUT_DAT     : out   std_logic_vector(15 downto 0)       --(p) Data
        );
end ADDR_TREE_2;

architecture RTL of ADDR_TREE_2 is

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
    for i in 0 to 31 loop
        if (nRST = '0') then 
            sum(i) <= (others => '0');
        elsif (CLK'event and CLK = '1') then
            if (EN = '1') then
                sum(i) <= (X"0000_0000_0000_0000" & dat_reg(i*2)) + (X"0000_0000_0000_0000" & dat_reg(i*2+1));
            end if;
        end if;
    end loop;
end process;

process (CLK, nRST) begin
    for i in 0 to 15 loop
        if (nRST = '0') then 
            sum(i+32) <= (others => '0');
        elsif (CLK'event and CLK = '1') then
            if (EN = '1') then
                sum(i+32) <= sum(i*2) + sum(i*2+1);
            end if;
        end if;
    end loop;
end process;

process (CLK, nRST) begin
    for i in 0 to 7 loop
        if (nRST = '0') then 
            sum(i+32+16) <= (others => '0');
        elsif (CLK'event and CLK = '1') then
            if (EN = '1') then
                sum(i+32+16) <= sum(i*2+32) + sum(i*2+1+32);
            end if;
        end if;
    end loop;
end process;

process (CLK, nRST) begin
    for i in 0 to 3 loop
        if (nRST = '0') then 
            sum(i+32+16+8) <= (others => '0');
        elsif (CLK'event and CLK = '1') then
            if (EN = '1') then
                sum(i+32+16+8) <= sum(i*2+32+16) + sum(i*2+1+32+16);
            end if;
        end if;
    end loop;
end process;

process (CLK, nRST) begin
    if (nRST = '0') then 
        sum(60) <= (others => '0');
        sum(61) <= (others => '0');
    elsif (CLK'event and CLK = '1') then
        if (EN = '1') then
            sum(60) <= sum(56) + sum(57);
            sum(61) <= sum(58) + sum(59);
        end if;
    end if;
end process;

process (CLK, nRST) begin
    if (nRST = '0') then 
        sum(62) <= (others => '0');
    elsif (CLK'event and CLK = '1') then
        if (EN = '1') then
            sum(62) <= sum(60) + sum(61);
        end if;
    end if;
end process;


-- ***********************************************************
--  Divider
-- ***********************************************************
OUT_DAT <= sum(62)(21 downto 6);


end RTL;    -- ADDR_TREE_2