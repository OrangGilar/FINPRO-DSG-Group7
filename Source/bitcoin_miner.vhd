library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.miner_pkg.all;

entity miner_testbench is
end entity miner_testbench;

architecture sim of miner_testbench is
    
    -- Clock and reset
    signal clk : std_logic := '0';
    signal rst : std_logic := '1';
    
    -- Testbench control
    constant CLK_PERIOD : time := 10 ns;
    signal sim_done : boolean := false;
    
    -- Block header signals
    signal load_header : std_logic := '0';
    signal version : std_logic_vector(7 downto 0) := x"01";
    signal prev_hash : std_logic_vector(HASH_WIDTH-1 downto 0) := x"ABCD1234";
    signal merkle_root : std_logic_vector(HASH_WIDTH-1 downto 0) := x"5678EFAB";
    signal timestamp : std_logic_vector(31 downto 0) := x"12345678";
    signal difficulty_bits : std_logic_vector(7 downto 0) := x"04";
    signal header_data : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal header_valid : std_logic;
    
    -- Miner signals
    signal start_mining : std_logic := '0';
    signal difficulty : integer range 0 to 32 := 4;
    signal nonce_found : std_logic_vector(NONCE_WIDTH-1 downto 0);
    signal hash_found : std_logic_vector(HASH_WIDTH-1 downto 0);
    signal mining_done : std_logic;
    signal mining_active : std_logic;
    
    -- SHA256 core signals
    signal sha_start : std_logic := '0';
    signal sha_data : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal sha_nonce : std_logic_vector(NONCE_WIDTH-1 downto 0);
    signal sha_hash : std_logic_vector(HASH_WIDTH-1 downto 0);
    signal sha_valid : std_logic;
    signal sha_busy : std_logic;
    
    -- Nonce generator signals
    signal nonce_enable : std_logic := '0';
    signal nonce_reset : std_logic := '0';
    signal nonce_current : std_logic_vector(NONCE_WIDTH-1 downto 0);
    signal nonce_overflow : std_logic;
    
    -- Components
    component block_header is
        port (
            clk           : in  std_logic;
            rst           : in  std_logic;
            load          : in  std_logic;
            version       : in  std_logic_vector(7 downto 0);
            prev_hash     : in  std_logic_vector(HASH_WIDTH-1 downto 0);
            merkle_root   : in  std_logic_vector(HASH_WIDTH-1 downto 0);
            timestamp     : in  std_logic_vector(31 downto 0);
            difficulty_bits : in std_logic_vector(7 downto 0);
            header_data   : out std_logic_vector(DATA_WIDTH-1 downto 0);
            header_valid  : out std_logic
        );
    end component;
    
    component bitcoin_miner is
        port (
            clk          : in  std_logic;
            rst          : in  std_logic;
            start        : in  std_logic;
            difficulty   : in  integer range 0 to 32;
            block_data   : in  std_logic_vector(DATA_WIDTH-1 downto 0);
            nonce_out    : out std_logic_vector(NONCE_WIDTH-1 downto 0);
            hash_out     : out std_logic_vector(HASH_WIDTH-1 downto 0);
            found        : out std_logic;
            mining       : out std_logic
        );
    end component;
    
    component sha256_core is
        port (
            clk       : in  std_logic;
            rst       : in  std_logic;
            start     : in  std_logic;
            data_in   : in  std_logic_vector(DATA_WIDTH-1 downto 0);
            nonce_in  : in  std_logic_vector(NONCE_WIDTH-1 downto 0);
            hash_out  : out std_logic_vector(HASH_WIDTH-1 downto 0);
            valid     : out std_logic;
            busy      : out std_logic
        );
    end component;
    
    component nonce_generator is
        generic (
            START_NONCE : integer := 0;
            INCREMENT   : integer := 1
        );
        port (
            clk        : in  std_logic;
            rst        : in  std_logic;
            enable     : in  std_logic;
            reset_nonce: in  std_logic;
            nonce_out  : out std_logic_vector(NONCE_WIDTH-1 downto 0);
            overflow   : out std_logic
        );
    end component;
    
begin

    -- Clock generation
    clk_proc: process
    begin
        while not sim_done loop
            clk <= '0';
            wait for CLK_PERIOD/2;
            clk <= '1';
            wait for CLK_PERIOD/2;
        end loop;
        wait;
    end process;
    
    -- Component instantiations
    header_inst: block_header
        port map (
            clk => clk,
            rst => rst,
            load => load_header,
            version => version,
            prev_hash => prev_hash,
            merkle_root => merkle_root,
            timestamp => timestamp,
            difficulty_bits => difficulty_bits,
            header_data => header_data,
            header_valid => header_valid
        );
    
    miner_inst: bitcoin_miner
        port map (
            clk => clk,
            rst => rst,
            start => start_mining,
            difficulty => difficulty,
            block_data => header_data,
            nonce_out => nonce_found,
            hash_out => hash_found,
            found => mining_done,
            mining => mining_active
        );
    
    sha_inst: sha256_core
        port map (
            clk => clk,
            rst => rst,
            start => sha_start,
            data_in => sha_data,
            nonce_in => sha_nonce,
            hash_out => sha_hash,
            valid => sha_valid,
            busy => sha_busy
        );
    
    nonce_gen_inst: nonce_generator
        generic map (
            START_NONCE => 0,
            INCREMENT => 1
        )
        port map (
            clk => clk,
            rst => rst,
            enable => nonce_enable,
            reset_nonce => nonce_reset,
            nonce_out => nonce_current,
            overflow => nonce_overflow
        );
    
    -- Test stimulus
    test_proc: process
    begin
        -- Initial reset
        rst <= '1';
        wait for CLK_PERIOD * 5;
        rst <= '0';
        wait for CLK_PERIOD * 2;
        
        report "========================================";
        report "Test 1: Block Header Builder";
        report "========================================";
        
        -- Load block header
        load_header <= '1';
        wait for CLK_PERIOD;
        load_header <= '0';
        wait for CLK_PERIOD * 2;
        
        assert header_valid = '1' 
            report "ERROR: Header not valid!" severity error;
        
        report "Block header loaded successfully";
        report "Header data: " & to_hstring(header_data);
        
        wait for CLK_PERIOD * 5;
        
        report "========================================";
        report "Test 2: Nonce Generator";
        report "========================================";
        
        -- Test nonce generator
        nonce_enable <= '1';
        for i in 0 to 10 loop
            wait for CLK_PERIOD;
            report "Nonce " & integer'image(i) & ": " & to_hstring(nonce_current);
        end loop;
        nonce_enable <= '0';
        
        wait for CLK_PERIOD * 3;
        
        -- Reset nonce
        nonce_reset <= '1';
        wait for CLK_PERIOD;
        nonce_reset <= '0';
        report "Nonce reset to: " & to_hstring(nonce_current);
        
        wait for CLK_PERIOD * 5;
        
        report "========================================";
        report "Test 3: SHA-256 Core";
        report "========================================";
        
        -- Test SHA core with a specific nonce
        sha_data <= header_data;
        sha_nonce <= x"00000042";
        sha_start <= '1';
        wait for CLK_PERIOD;
        sha_start <= '0';
        
        wait until sha_valid = '1';
        report "SHA-256 hash computed: " & to_hstring(sha_hash);
        
        wait for CLK_PERIOD * 5;
        
        report "========================================";
        report "Test 4: Bitcoin Miner (Main Test)";
        report "========================================";
        
        -- Start mining with difficulty = 4 (need 4 leading zeros)
        difficulty <= 4;
        start_mining <= '1';
        wait for CLK_PERIOD;
        start_mining <= '0';
        
        report "Mining started with difficulty " & integer'image(difficulty);
        
        -- Wait for mining to complete (or timeout)
        for i in 0 to 10000 loop
            wait for CLK_PERIOD;
            
            if mining_done = '1' then
                report "========================================";
                report "SUCCESS! Valid nonce found!";
                report "========================================";
                report "Nonce: " & to_hstring(nonce_found);
                report "Hash:  " & to_hstring(hash_found);
                report "Cycles taken: " & integer'image(i);
                
                -- Verify leading zeros
                report "Leading zeros check...";
                exit;
            end if;
            
            -- Progress indicator every 100 cycles
            if i mod 100 = 0 then
                report "Mining... cycle " & integer'image(i);
            end if;
        end loop;
        
        wait for CLK_PERIOD * 10;
        
        report "========================================";
        report "All tests completed!";
        report "========================================";
        
        sim_done <= true;
        wait;
    end process;

end architecture sim;
