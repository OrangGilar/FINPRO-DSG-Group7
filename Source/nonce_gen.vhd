library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity nonce_gen is
    generic (
        WIDTH : integer := 32
    );
    port (
        clk     : in  std_logic;
        rst     : in  std_logic;
        enable  : in  std_logic;
        load    : in  std_logic;
        load_val: in  std_logic_vector(WIDTH-1 downto 0);
        nonce   : out std_logic_vector(WIDTH-1 downto 0)
    );
end entity;

architecture rtl of nonce_gen is
    signal cnt : unsigned(WIDTH-1 downto 0);
begin
    process(clk, rst)
    begin
        if rst = '1' then
            cnt <= (others => '0');
        elsif rising_edge(clk) then
            if load = '1' then
                cnt <= unsigned(load_val);
            elsif enable = '1' then
                cnt <= cnt + 1;
            end if;
        end if;
    end process;

    nonce <= std_logic_vector(cnt);
end architecture;
