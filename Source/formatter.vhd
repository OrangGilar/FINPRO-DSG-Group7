library ieee;
use ieee.std_logic_1164.all;

entity formatter is
    generic (
        MSG_WIDTH   : integer := 32;
        NONCE_WIDTH : integer := 32
    );
    port (
        message : in  std_logic_vector(MSG_WIDTH-1 downto 0);
        nonce   : in  std_logic_vector(NONCE_WIDTH-1 downto 0);
        formatted : out std_logic_vector(MSG_WIDTH+NONCE_WIDTH-1 downto 0)
    );
end entity;

architecture rtl of formatter is
begin
    formatted <= message & nonce;
end architecture;
