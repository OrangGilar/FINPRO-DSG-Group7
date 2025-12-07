library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity controller is
    generic (
        NONCE_WIDTH : integer := 32
    );
    port (
        clk         : in  std_logic;
        rst         : in  std_logic;
        start_search: in  std_logic;
        hash_busy   : in  std_logic;
        hash_done   : in  std_logic;
        cmp_less    : in  std_logic;
        hash_start  : out std_logic;
        nonce_en    : out std_logic;
        nonce_load  : out std_logic;
        done_found  : out std_logic;
        latch_nonce : out std_logic
    );
end entity;

architecture rtl of controller is
    type state_t is (IDLE, LOAD, HASHING, CHECK, FOUND, STOP);
    signal state : state_t := IDLE;
begin
    process(clk, rst)
    begin
        if rst = '1' then
            state <= IDLE;
        elsif rising_edge(clk) then
            case state is
                when IDLE =>
                    hash_start <= '0';
                    nonce_en <= '0';
                    nonce_load <= '1';
                    done_found <= '0';
                    latch_nonce <= '0';
                    if start_search = '1' then
                        state <= LOAD;
                    end if;

                when LOAD =>
                    nonce_load <= '1';
                    hash_start <= '1';
                    nonce_en <= '0';
                    latch_nonce <= '0';
                    state <= HASHING;

                when HASHING =>
                    hash_start <= '0';
                    nonce_load <= '0';
                    if hash_busy = '1' then
                        state <= HASHING;
                    elsif hash_done = '1' then
                        state <= CHECK;
                    end if;

                when CHECK =>
                    if cmp_less = '1' then
                        done_found <= '1';
                        latch_nonce <= '1';
                        nonce_en <= '0';
                        state <= FOUND;
                    else
                        nonce_en <= '1';
                        latch_nonce <= '0';
                        hash_start <= '1';
                        state <= HASHING;
                    end if;

                when FOUND =>
                    latch_nonce <= '0';
                    hash_start <= '0';
                    nonce_en <= '0';
                    if start_search = '0' then
                        state <= STOP;
                    end if;

                when STOP =>
                    done_found <= '0';
                    if start_search = '1' then
                        state <= LOAD;
                    end if;

                when others =>
                    state <= IDLE;
            end case;
        end if;
    end process;
end architecture;
