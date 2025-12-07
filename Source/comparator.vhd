library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity comparator is
    generic (
        WIDTH : integer := 32
    );
    port (
        hash_in : in  std_logic_vector(WIDTH-1 downto 0);
        target  : in  std_logic_vector(WIDTH-1 downto 0);
        less    : out std_logic
    );
end entity;

architecture rtl of comparator is
begin
    less <= '1' when unsigned(hash_in) < unsigned(target) else '0';
end architecture;
