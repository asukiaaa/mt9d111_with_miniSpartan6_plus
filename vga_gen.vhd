----------------------------------------------------------------------------------
-- Engineer: Mike Field <hamster@snap.net.nz>
-- Description: Generates a test 1280x720 signal
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity vga_gen is
  port(
    clk75   : in  std_logic;
    pclk    : out std_logic;
    red     : out std_logic_vector (7 downto 0) := (others => '0');
    green   : out std_logic_vector (7 downto 0) := (others => '0');
    blue    : out std_logic_vector (7 downto 0) := (others => '0');
    blank   : out std_logic := '0';
    hsync   : out std_logic := '0';
    vsync   : out std_logic := '0';
    pattern : in  std_logic_vector (3 downto 0)
  );
end vga_gen;

architecture Behavioral of vga_gen is
  constant h_rez        : natural := 1280;
  constant h_sync_start : natural := 1280+72;
  constant h_sync_end   : natural := 1280+72+80;
  constant h_max        : natural := 1648-1;
  signal   h_count      : unsigned(11 downto 0) := (others => '0');

  constant v_rez        : natural := 720;
  constant v_sync_start : natural := 720+3;
  constant v_sync_end   : natural := 720+3+5;
  constant v_max        : natural := 750-1;
  signal   v_count      : unsigned(11 downto 0) := (others => '0');

begin
  pclk <= clk75;

  process(clk75)
  begin
    if rising_edge(clk75) then

      if h_count < h_rez and v_count < v_rez then

        if pattern ="0000" then
          red   <= std_logic_vector(h_count(10 downto 3));
          green <= std_logic_vector(v_count(9 downto 2));
          blue  <= std_logic_vector(h_count(7 downto 0)+v_count(7 downto 0));
          blank <= '0';

        elsif pattern ="1110" then
          if (h_count(6) xor v_count(6))='1' then
            red   <= "11111111";
            green <= "11111111";
            blue  <= "11111111";
          else

            red   <= "00000000";
            green <= "00000000";
            blue  <= "00000000";
          end if;
          blank <= '0';

        elsif pattern ="1111" then
          if (h_count < 180) or (h_count >= 360+180 and h_count < 720 ) or (h_count >=720 and h_count < 720+180 ) or (h_count >=720+360 ) then
            green   <= "11111111";
          else
            green   <= "00000000";
          end if;

          if (h_count >= 180 and h_count < 360 ) or (h_count >= 360+180 and h_count < 720 ) or (h_count >=180+720 and h_count < 720+360 ) or (h_count >=720+360  ) then
            red   <= "11111111";
          else
            red   <= "00000000";
          end if;

          if (h_count >= 360 and h_count < 360+180 ) or (h_count >= 720 and h_count < 720+180 ) or (h_count >=180+720 and h_count < 720+360 ) or (h_count >=720+360 ) then
            blue   <= "11111111";
          else
            blue   <= "00000000";
          end if;

          blank <= '0';
        elsif pattern ="0111" then
          red   <= "11111111";
          green <= "00000000";
          blue  <= "00000000";
          blank <= '0';
        elsif pattern ="1011" then
          red   <= "00000000";
          green <= "11111111";
          blue  <= "00000000";
          blank <= '0';
        elsif pattern ="1101" then
          red   <= "00000000";
          green <= "00000000";
          blue  <= "11111111";
          blank <= '0';
        end if;
      else
        red   <= (others => '0');
        green <= (others => '0');
        blue  <= (others => '0');
        blank <= '1';
      end if;

      if h_count >= h_sync_start and h_count < h_sync_end then
        hsync <= '1';
      else
        hsync <= '0';
      end if;

      if v_count >= v_sync_start and v_count < v_sync_end then
        vsync <= '1';
      else
        vsync <= '0';
      end if;

      if h_count = h_max then
        h_count <= (others => '0');
        if v_count = v_max then
          v_count <= (others => '0');
        else
          v_count <= v_count+1;
        end if;
      else
        h_count <= h_count+1;
      end if;

    end if;
  end process;

end Behavioral;
