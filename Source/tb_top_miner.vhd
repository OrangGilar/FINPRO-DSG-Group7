library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;

entity tb_top_miner is
end entity;

architecture sim of tb_top_miner is

    constant CLK_PERIOD : time := 10 ns;

    signal clk : std_logic := '0';
    signal rst : std_logic := '1';
    signal start_sig : std_logic := '0';
    signal message  : std_logic_vector(31 downto 0) := x"DEADBEEF";
    signal target   : std_logic_vector(31 downto 0);
    signal found    : std_logic;
    signal found_nonce : std_logic_vector(31 downto 0);
    signal current_hash: std_logic_vector(31 downto 0);
    signal nonce_out : std_logic_vector(31 downto 0);

    function hstring(sv : std_logic_vector(31 downto 0)) return string is
        variable res : string(1 to 8);
        constant hex : string := "0123456789ABCDEF";
        variable u   : unsigned(31 downto 0);
        variable nib : unsigned(3 downto 0);
        variable n   : integer;
    begin
        u := unsigned(sv);

        nib := u(31 downto 28); n := to_integer(nib); res(1) := hex(n+1);
        nib := u(27 downto 24); n := to_integer(nib); res(2) := hex(n+1);
        nib := u(23 downto 20); n := to_integer(nib); res(3) := hex(n+1);
        nib := u(19 downto 16); n := to_integer(nib); res(4) := hex(n+1);
        nib := u(15 downto 12); n := to_integer(nib); res(5) := hex(n+1);
        nib := u(11 downto 8 ); n := to_integer(nib); res(6) := hex(n+1);
        nib := u(7  downto 4 ); n := to_integer(nib); res(7) := hex(n+1);
        nib := u(3  downto 0 ); n := to_integer(nib); res(8) := hex(n+1);

        return res;
    end function;

begin

    clk_process : process
    begin
        while true loop
            clk <= '0'; wait for CLK_PERIOD/2;
            clk <= '1'; wait for CLK_PERIOD/2;
        end loop;
    end process;

    DUT: entity work.top_miner
        port map (
            clk => clk,
            rst => rst,
            start => start_sig,
            message => message,
            target => target,
            found => found,
            found_nonce => found_nonce,
            current_hash => current_hash,
            nonce_out => nonce_out
        );

    stim_proc: process
        variable L : line;
    begin
        -- RESET
        rst <= '1';
        start_sig <= '0';
        wait for 50 ns;
        rst <= '0';
        wait for 20 ns;

        target <= x"FFFFFFFF";
        report "TEST 1: EASY TARGET";

        start_sig <= '1';
        wait for CLK_PERIOD;
        start_sig <= '0';

        wait for 200 * CLK_PERIOD;

        if found = '1' then
            write(L, string'("TEST1: Found Nonce = "));
            write(L, integer'image(to_integer(unsigned(found_nonce))));
            writeline(output, L);

            write(L, string'("        Hash = "));
            write(L, hstring(current_hash));
            writeline(output, L);
        else
            report "TEST1: No result" severity warning;
        end if;

        wait for 100 ns;

        target <= x"00FFFFFF";
        report "TEST 2: ";
        start_sig <= '1';
        wait for CLK_PERIOD;
        start_sig <= '0';
        wait for 2000 * CLK_PERIOD;

        if found = '1' then
            write(L, string'("TEST2: Found Nonce = "));
            write(L, integer'image(to_integer(unsigned(found_nonce))));
            writeline(output, L);

            write(L, string'("        Hash = "));
            write(L, hstring(current_hash));
            writeline(output, L);
        else
            report "TEST2: No result" severity note;

            write(L, string'("Current Nonce = "));
            write(L, integer'image(to_integer(unsigned(nonce_out))));
            writeline(output, L);

            write(L, string'("Current Hash = "));
            write(L, hstring(current_hash));
            writeline(output, L);
        end if;

        report "SIMULATION COMPLETE";
        wait;
    end process;

end architecture;
