library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity hash_core is
    generic (
        IN_WIDTH  : integer := 64;
        OUT_WIDTH : integer := 32;
        ROUNDS    : integer := 8
    );
    port (
        clk       : in  std_logic;
        rst       : in  std_logic;
        start     : in  std_logic;
        data_in   : in  std_logic_vector(IN_WIDTH-1 downto 0);
        hash_out  : out std_logic_vector(OUT_WIDTH-1 downto 0);
        busy      : out std_logic;
        done      : out std_logic
    );
end entity;

architecture rtl of hash_core is

    signal state_reg : unsigned(OUT_WIDTH-1 downto 0) := (others => '0');
    signal data_reg  : std_logic_vector(IN_WIDTH-1 downto 0) := (others => '0');
    signal round_cnt : integer range 0 to ROUNDS := 0;
    signal running   : std_logic := '0';

    type const_array is array (0 to ROUNDS-1) of unsigned(OUT_WIDTH-1 downto 0);
    constant CONSTS : const_array := (
        x"9E3779B1", x"C2B2A3D9", x"7F4A7C15", x"F39A2D57",
        x"A5E91C23", x"3C6E5F8B", x"1B2C0D9F", x"6DA98B31"
    );

begin

    process(clk, rst)
        variable picked  : unsigned(OUT_WIDTH-1 downto 0);
        variable rot_val : unsigned(OUT_WIDTH-1 downto 0);
        variable shift  : integer;
        variable b      : unsigned(7 downto 0);
    begin
        if rst = '1' then
            state_reg <= (others => '0');
            data_reg  <= (others => '0');
            round_cnt <= 0;
            running   <= '0';

        elsif rising_edge(clk) then

            if start = '1' and running = '0' then
                data_reg  <= data_in;
                state_reg <= unsigned(data_in(IN_WIDTH-1 downto IN_WIDTH-OUT_WIDTH));
                round_cnt <= 0;
                running   <= '1';

            elsif running = '1' then
                if round_cnt < ROUNDS then

                    picked := (others => '0');
                    b := unsigned(data_reg(8*round_cnt+7 downto 8*round_cnt));
                    picked(7 downto 0) := b;

                    shift := 3 + (round_cnt mod 5);
                    rot_val := (state_reg xor picked) rol shift;

                    state_reg <= rot_val + CONSTS(round_cnt);
                    round_cnt <= round_cnt + 1;

                else
                    running <= '0';
                end if;
            end if;
        end if;
    end process;

    busy <= running;
    done <= '1' when (running = '0' and round_cnt = ROUNDS) else '0';
    hash_out <= std_logic_vector(state_reg);

end architecture;
