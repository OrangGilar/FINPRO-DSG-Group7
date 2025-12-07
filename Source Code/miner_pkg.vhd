library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package miner_pkg is

    constant DATA_WIDTH  : integer := 32;
    constant NONCE_WIDTH : integer := 32;
    constant HASH_WIDTH  : integer := 32;

    type miner_state_t is (
        S_IDLE,
        S_LOAD,
        S_HASH,
        S_CHECK,
        S_NEXT,
        S_FOUND
    );

    function count_leading_zeros(x : std_logic_vector)
        return integer;

end package miner_pkg;

package body miner_pkg is

    function count_leading_zeros(x : std_logic_vector)
        return integer is
        variable count : integer := 0;
    begin
        for i in x'range loop
            if x(i) = '0' then
                count := count + 1;
            else
                exit;
            end if;
        end loop;
        return count;
    end;

end package body miner_pkg;
