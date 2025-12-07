library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity top_miner is
    generic (
        MSG_WIDTH   : integer := 32;
        NONCE_WIDTH : integer := 32;
        HASH_WIDTH  : integer := 32
    );
    port (
        clk     : in  std_logic;
        rst     : in  std_logic;
        start   : in  std_logic;
        message : in  std_logic_vector(MSG_WIDTH-1 downto 0);
        target  : in  std_logic_vector(HASH_WIDTH-1 downto 0);
        found   : out std_logic;
        found_nonce : out std_logic_vector(NONCE_WIDTH-1 downto 0);
        current_hash: out std_logic_vector(HASH_WIDTH-1 downto 0);
        nonce_out    : out std_logic_vector(NONCE_WIDTH-1 downto 0)
    );
end entity;

architecture rtl of top_miner is
    signal nonce_sig   : std_logic_vector(NONCE_WIDTH-1 downto 0);
    signal formatted   : std_logic_vector(MSG_WIDTH+NONCE_WIDTH-1 downto 0);
    signal hash_val    : std_logic_vector(HASH_WIDTH-1 downto 0);
    signal hash_busy   : std_logic;
    signal hash_done   : std_logic;
    signal cmp_less    : std_logic;
    signal ctrl_hash_start : std_logic;
    signal ctrl_nonce_en : std_logic;
    signal ctrl_nonce_load : std_logic;
    signal ctrl_done_found : std_logic;
    signal latch_nonce_sig : std_logic;
    signal latched_nonce : std_logic_vector(NONCE_WIDTH-1 downto 0);
begin
    NG: entity work.nonce_gen
        generic map (WIDTH => NONCE_WIDTH)
        port map (
            clk => clk,
            rst => rst,
            enable => ctrl_nonce_en,
            load => ctrl_nonce_load,
            load_val => (others => '0'),
            nonce => nonce_sig
        );

    FMT: entity work.formatter
        generic map (MSG_WIDTH => MSG_WIDTH, NONCE_WIDTH => NONCE_WIDTH)
        port map (
            message => message,
            nonce => nonce_sig,
            formatted => formatted
        );

    HC: entity work.hash_core
        generic map (IN_WIDTH => MSG_WIDTH+NONCE_WIDTH, OUT_WIDTH => HASH_WIDTH, ROUNDS => 8)
        port map (
            clk => clk,
            rst => rst,
            start => ctrl_hash_start,
            data_in => formatted,
            hash_out => hash_val,
            busy => hash_busy,
            done => hash_done
        );

    CMP: entity work.comparator
        generic map (WIDTH => HASH_WIDTH)
        port map (
            hash_in => hash_val,
            target  => target,
            less    => cmp_less
        );

    CTRL: entity work.controller
        generic map (NONCE_WIDTH => NONCE_WIDTH)
        port map (
            clk => clk,
            rst => rst,
            start_search => start,
            hash_busy => hash_busy,
            hash_done => hash_done,
            cmp_less => cmp_less,
            hash_start => ctrl_hash_start,
            nonce_en => ctrl_nonce_en,
            nonce_load => ctrl_nonce_load,
            done_found => ctrl_done_found,
            latch_nonce => latch_nonce_sig
        );

    -- latch nonce when controller requests
    process(clk, rst)
    begin
        if rst = '1' then
            latched_nonce <= (others => '0');
        elsif rising_edge(clk) then
            if latch_nonce_sig = '1' then
                latched_nonce <= nonce_sig;
            end if;
        end if;
    end process;

    -- outputs
    found <= ctrl_done_found;
    found_nonce <= latched_nonce;
    current_hash <= hash_val;
    nonce_out <= nonce_sig;
end architecture;
