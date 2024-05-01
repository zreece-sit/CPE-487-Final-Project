LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY bat_n_ball IS
    PORT (
        v_sync : IN STD_LOGIC;
        pixel_row : IN STD_LOGIC_VECTOR(10 DOWNTO 0);
        pixel_col : IN STD_LOGIC_VECTOR(10 DOWNTO 0);
        bat_x : IN STD_LOGIC_VECTOR (10 DOWNTO 0); -- current bat x position
        serve : IN STD_LOGIC; -- initiates serve
        red : OUT STD_LOGIC;
        green : OUT STD_LOGIC;
        blue : OUT STD_LOGIC;
        hitcount: inout std_logic_vector(15 downto 0) := "0000000000000000";
        ball_speed : inout STD_LOGIC_VECTOR (10 DOWNTO 0) := "00000000001";
        switch : inout STD_LOGIC_VECTOR (10 DOWNTO 0)
    );
END bat_n_ball;

ARCHITECTURE Behavioral OF bat_n_ball IS
    CONSTANT bsize : INTEGER := 8; -- ball size in pixels
    signal recent: std_logic := '0';
    signal bat_w : INTEGER := 40; -- bat width in pixels
    CONSTANT bat_h : INTEGER := 10; -- bat height in pixels
    
    constant wall_w: integer := 30;
    constant wall_h: integer := 5;
    
    signal wall_on: std_logic;
    -- distance ball moves each frame
    --constant ball_speed : STD_LOGIC_VECTOR (10 DOWNTO 0):= CONV_STD_LOGIC_VECTOR (6, 11);
    SIGNAL ball_on : STD_LOGIC; -- indicates whether ball is at current pixel position
    SIGNAL bat_on : STD_LOGIC; -- indicates whether bat at over current pixel position
    SIGNAL game_on : STD_LOGIC := '0'; -- indicates whether ball is in play
    -- current ball position - intitialized to center of screen
    SIGNAL ball_x : STD_LOGIC_VECTOR(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(400, 11);
    SIGNAL ball_y : STD_LOGIC_VECTOR(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(300, 11);
    -- bat vertical position
    CONSTANT bat_y : STD_LOGIC_VECTOR(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(500, 11);
    -- current ball motion - initialized to (+ ball_speed) pixels/frame in both X and Y directions
    SIGNAL ball_x_motion : STD_LOGIC_VECTOR(10 DOWNTO 0) := ball_speed;
    signal ball_y_motion : STD_LOGIC_VECTOR(10 DOWNTO 0) := ball_speed;
    
    --signal for drawing the base wall
    signal wall_x : std_logic_vector(10 downto 0) := conv_std_logic_vector(50, 11);
    signal wall_x2 : std_logic_vector(10 downto 0) := conv_std_logic_vector(150, 11);
    signal wall_x3 : std_logic_vector(10 downto 0) := conv_std_logic_vector(250, 11);
    signal wall_x4 : std_logic_vector(10 downto 0) := conv_std_logic_vector(350, 11);
    signal wall_x5 : std_logic_vector(10 downto 0) := conv_std_logic_vector(450, 11);
    signal wall_x6 : std_logic_vector(10 downto 0) := conv_std_logic_vector(550, 11);
    signal wall_x7 : std_logic_vector(10 downto 0) := conv_std_logic_vector(650, 11);
    signal wall_x8 : std_logic_vector(10 downto 0) := conv_std_logic_vector(750, 11);
    
    
    signal wall_y : std_logic_vector(10 downto 0) := conv_std_logic_vector(80, 11);
    signal wall_y2 : std_logic_vector(10 downto 0) := conv_std_logic_vector(30, 11);
    signal wall_y3 : std_logic_vector(10 downto 0) := conv_std_logic_vector(130, 11);
    
    -- walls will be set to 0 as they are hit, each bit is one wall
    signal active : std_logic_vector(23 downto 0) := "111111111111111111111111";
    
BEGIN
    
    
    
    red <= NOT bat_on; -- color setup for red ball and cyan bat on white background
    green <= NOT ball_on;
    blue <= NOT wall_on;
    --blue <= NOT ball_on;
     
    ball_speed(4 downto 1) <= switch(4 downto 1);
    ball_speed(0) <= '1';
    
    
    -- process to draw round ball
    -- set ball_on if current pixel address is covered by ball position
    balldraw : PROCESS (ball_x, ball_y, pixel_row, pixel_col) IS
        VARIABLE vx, vy : STD_LOGIC_VECTOR (10 DOWNTO 0); -- 9 downto 0
    BEGIN
        IF pixel_col <= ball_x THEN -- vx = |ball_x - pixel_col|
            vx := ball_x - pixel_col;
        ELSE
            vx := pixel_col - ball_x;
        END IF;
        IF pixel_row <= ball_y THEN -- vy = |ball_y - pixel_row|
            vy := ball_y - pixel_row;
        ELSE
            vy := pixel_row - ball_y;
        END IF;
        IF ((vx * vx) + (vy * vy)) < (bsize * bsize) THEN -- test if radial distance < bsize
            ball_on <= game_on;
        ELSE
            ball_on <= '0';
        END IF;
    END PROCESS;
    -- process to draw bat
    -- set bat_on if current pixel address is covered by bat position
    batdraw : PROCESS (bat_x, pixel_row, pixel_col) IS
        VARIABLE vx, vy : STD_LOGIC_VECTOR (10 DOWNTO 0); -- 9 downto 0
    BEGIN
        IF ((pixel_col >= bat_x - bat_w) OR (bat_x <= bat_w)) AND
         pixel_col <= bat_x + bat_w AND
             pixel_row >= bat_y - bat_h + 5 AND
             pixel_row <= bat_y + bat_h - 5 THEN
                bat_on <= '1';
        ELSE
            bat_on <= '0';
        END IF;
    END PROCESS;
    -- process to move ball once every frame (i.e., once every vsync pulse)
    mball : PROCESS
        VARIABLE temp : STD_LOGIC_VECTOR (11 DOWNTO 0);
    BEGIN
        WAIT UNTIL rising_edge(v_sync);
        IF serve = '1' AND game_on = '0' THEN -- test for new serve
            game_on <= '1';
            ball_y_motion <= (NOT ball_speed) + 1; -- set vspeed to (- ball_speed) pixels
            recent <= '0';
        ELSIF ball_y <= bsize THEN -- bounce off top wall
        recent <= '0';
            ball_y_motion <= ball_speed; -- set vspeed to (+ ball_speed) pixels
        ELSIF (ball_y + bsize >= 600) or (active = "000000000000000000000000") THEN -- if ball meets bottom wall
        recent <= '0';
            ball_y_motion <= (NOT ball_speed) + 1; -- set vspeed to (- ball_speed) pixels
            game_on <= '0'; -- and make ball disappear
            hitcount <= "0000000000000000";
            bat_w <= 40;
            active <= "111111111111111111111111";
        END IF;
        IF (ball_x + bsize/2) >= (bat_x - bat_w) AND
         (ball_x - bsize/2) <= (bat_x + bat_w) AND
             (ball_y + bsize/2) >= (bat_y - bat_h) AND
             (ball_y - bsize/2) <= (bat_y + bat_h) AND
             (recent = '0')  THEN
                ball_y_motion <= (NOT ball_speed) + 1; -- set vspeed to (- ball_speed) pixels
                    
                    --bat_w <= bat_w - 1;
                    recent <= '1';
        END IF;
        
        -- allow for bounce off left or right of screen
        IF ball_x + bsize >= 800 THEN -- bounce off right wall
        recent <= '0';
            ball_x_motion <= (NOT ball_speed) + 1; -- set hspeed to (- ball_speed) pixels
        ELSIF ball_x <= bsize THEN -- bounce off left wall
        recent <= '0';
            ball_x_motion <= ball_speed; -- set hspeed to (+ ball_speed) pixels
        END IF;
        
        -- wall 0
        IF (ball_x + bsize/2) >= (wall_x - wall_w) AND
         (ball_x - bsize/2) <= (wall_x + wall_w) AND
             (ball_y + bsize/2) >= (wall_y - wall_h) AND
             (ball_y - bsize/2) <= (wall_y + wall_h) AND 
             active(0) = '1' THEN
                ball_y_motion <= (NOT ball_y_motion);
                --ball_x_motion <= (NOT ball_x_motion); -- set vspeed to (- ball_speed) pixels
                    active(0) <= '0'; 
                    hitcount <= hitcount + '1';                  
        END IF;
        -- wall 2
        IF (ball_x + bsize/2) >= (wall_x2 - wall_w) AND
         (ball_x - bsize/2) <= (wall_x2 + wall_w) AND
             (ball_y + bsize/2) >= (wall_y - wall_h) AND
             (ball_y - bsize/2) <= (wall_y + wall_h) AND
             active (1) = '1' THEN
                ball_y_motion <= (NOT ball_y_motion);
                --ball_x_motion <= (NOT ball_x_motion); -- set vspeed to (- ball_speed) pixels
                    active(1) <= '0';
                    hitcount <= hitcount + '1';
        END IF;
        -- wall 3
        IF (ball_x + bsize/2) >= (wall_x3 - wall_w) AND
         (ball_x - bsize/2) <= (wall_x3 + wall_w) AND
             (ball_y + bsize/2) >= (wall_y - wall_h) AND
             (ball_y - bsize/2) <= (wall_y + wall_h) AND 
             active(2) = '1' THEN
                ball_y_motion <= (NOT ball_y_motion);
                --ball_x_motion <= (NOT ball_x_motion); -- set vspeed to (- ball_speed) pixels
                    active(2) <= '0';   
                    hitcount <= hitcount + '1';                
        END IF;
        -- wall 4
        IF (ball_x + bsize/2) >= (wall_x4 - wall_w) AND
         (ball_x - bsize/2) <= (wall_x4 + wall_w) AND
             (ball_y + bsize/2) >= (wall_y - wall_h) AND
             (ball_y - bsize/2) <= (wall_y + wall_h) AND
             active (3) = '1' THEN
                ball_y_motion <= (NOT ball_y_motion);
                --ball_x_motion <= (NOT ball_x_motion); -- set vspeed to (- ball_speed) pixels
                    active(3) <= '0';
                    hitcount <= hitcount + '1';
        END IF;
        -- wall 5
        IF (ball_x + bsize/2) >= (wall_x5 - wall_w) AND
         (ball_x - bsize/2) <= (wall_x5  + wall_w) AND
             (ball_y + bsize/2) >= (wall_y - wall_h) AND
             (ball_y - bsize/2) <= (wall_y + wall_h) AND 
             active(4) = '1' THEN
                ball_y_motion <= (NOT ball_y_motion);
                --ball_x_motion <= (NOT ball_x_motion); -- set vspeed to (- ball_speed) pixels
                    active(4) <= '0';  
                    hitcount <= hitcount + '1';                 
        END IF;
        -- wall 6
        IF (ball_x + bsize/2) >= (wall_x6 - wall_w) AND
         (ball_x - bsize/2) <= (wall_x6 + wall_w) AND
             (ball_y + bsize/2) >= (wall_y - wall_h) AND
             (ball_y - bsize/2) <= (wall_y + wall_h) AND
             active (5) = '1' THEN
                ball_y_motion <= (NOT ball_y_motion);
                --ball_x_motion <= (NOT ball_x_motion); -- set vspeed to (- ball_speed) pixels
                    active(5) <= '0';
                    hitcount <= hitcount + '1';
        END IF;
        -- wall 7
        IF (ball_x + bsize/2) >= (wall_x7 - wall_w) AND
         (ball_x - bsize/2) <= (wall_x7 + wall_w) AND
             (ball_y + bsize/2) >= (wall_y - wall_h) AND
             (ball_y - bsize/2) <= (wall_y + wall_h) AND 
             active(6) = '1' THEN
                ball_y_motion <= (NOT ball_y_motion);
                --ball_x_motion <= (NOT ball_x_motion); -- set vspeed to (- ball_speed) pixels
                    active(6) <= '0';  
                    hitcount <= hitcount + '1';                 
        END IF;
        -- wall 8
        IF (ball_x + bsize/2) >= (wall_x8 - wall_w) AND
         (ball_x - bsize/2) <= (wall_x8 + wall_w) AND
             (ball_y + bsize/2) >= (wall_y - wall_h) AND
             (ball_y - bsize/2) <= (wall_y + wall_h) AND
             active (7) = '1' THEN
                ball_y_motion <= (NOT ball_y_motion);
                --ball_x_motion <= (NOT ball_x_motion); -- set vspeed to (- ball_speed) pixels
                    active(7) <= '0';
                    hitcount <= hitcount + '1';
        END IF;
        -- row 2
        -- wall 0
        IF (ball_x + bsize/2) >= (wall_x - wall_w) AND
         (ball_x - bsize/2) <= (wall_x + wall_w) AND
             (ball_y + bsize/2) >= (wall_y2 - wall_h) AND
             (ball_y - bsize/2) <= (wall_y2 + wall_h) AND 
             active(8) = '1' THEN
                ball_y_motion <= (NOT ball_y_motion);
                --ball_x_motion <= (NOT ball_x_motion); -- set vspeed to (- ball_speed) pixels
                    active(8) <= '0'; 
                    hitcount <= hitcount + '1';                  
        END IF;
        -- wall 2
        IF (ball_x + bsize/2) >= (wall_x2 - wall_w) AND
         (ball_x - bsize/2) <= (wall_x2 + wall_w) AND
             (ball_y + bsize/2) >= (wall_y2 - wall_h) AND
             (ball_y - bsize/2) <= (wall_y2 + wall_h) AND
             active (9) = '1' THEN
                ball_y_motion <= (NOT ball_y_motion);
                --ball_x_motion <= (NOT ball_x_motion); -- set vspeed to (- ball_speed) pixels
                    active(9) <= '0';
                    hitcount <= hitcount + '1';
        END IF;
        -- wall 3
        IF (ball_x + bsize/2) >= (wall_x3 - wall_w) AND
         (ball_x - bsize/2) <= (wall_x3 + wall_w) AND
             (ball_y + bsize/2) >= (wall_y2 - wall_h) AND
             (ball_y - bsize/2) <= (wall_y2 + wall_h) AND 
             active(10) = '1' THEN
                ball_y_motion <= (NOT ball_y_motion);
                --ball_x_motion <= (NOT ball_x_motion); -- set vspeed to (- ball_speed) pixels
                    active(10) <= '0';
                    hitcount <= hitcount + '1';                   
        END IF;
        -- wall 4
        IF (ball_x + bsize/2) >= (wall_x4 - wall_w) AND
         (ball_x - bsize/2) <= (wall_x4 + wall_w) AND
             (ball_y + bsize/2) >= (wall_y2 - wall_h) AND
             (ball_y - bsize/2) <= (wall_y2 + wall_h) AND
             active (11) = '1' THEN
                ball_y_motion <= (NOT ball_y_motion);
                ball_x_motion <= (NOT ball_x_motion); -- set vspeed to (- ball_speed) pixels
                    active(11) <= '0';
                    hitcount <= hitcount + '1';
        END IF;
        -- wall 5
        IF (ball_x + bsize/2) >= (wall_x5 - wall_w) AND
         (ball_x - bsize/2) <= (wall_x5  + wall_w) AND
             (ball_y + bsize/2) >= (wall_y2 - wall_h) AND
             (ball_y - bsize/2) <= (wall_y2 + wall_h) AND 
             active(12) = '1' THEN
                ball_y_motion <= (NOT ball_y_motion);
                --ball_x_motion <= (NOT ball_x_motion); -- set vspeed to (- ball_speed) pixels
                    active(12) <= '0'; 
                    hitcount <= hitcount + '1';                  
        END IF;
        -- wall 6
        IF (ball_x + bsize/2) >= (wall_x6 - wall_w) AND
         (ball_x - bsize/2) <= (wall_x6 + wall_w) AND
             (ball_y + bsize/2) >= (wall_y2 - wall_h) AND
             (ball_y - bsize/2) <= (wall_y2 + wall_h) AND
             active (13) = '1' THEN
                ball_y_motion <= (NOT ball_y_motion);
                --ball_x_motion <= (NOT ball_x_motion); -- set vspeed to (- ball_speed) pixels
                    active(13) <= '0';
                    hitcount <= hitcount + '1';
        END IF;
        -- wall 7
        IF (ball_x + bsize/2) >= (wall_x7 - wall_w) AND
         (ball_x - bsize/2) <= (wall_x7 + wall_w) AND
             (ball_y + bsize/2) >= (wall_y2 - wall_h) AND
             (ball_y - bsize/2) <= (wall_y2 + wall_h) AND 
             active(14) = '1' THEN
                ball_y_motion <= (NOT ball_y_motion);
                --ball_x_motion <= (NOT ball_x_motion); -- set vspeed to (- ball_speed) pixels
                    active(14) <= '0';  
                    hitcount <= hitcount + '1';                 
        END IF;
        -- wall 8
        IF (ball_x + bsize/2) >= (wall_x8 - wall_w) AND
         (ball_x - bsize/2) <= (wall_x8 + wall_w) AND
             (ball_y + bsize/2) >= (wall_y2 - wall_h) AND
             (ball_y - bsize/2) <= (wall_y2 + wall_h) AND
             active (15) = '1' THEN
                ball_y_motion <= (NOT ball_y_motion);
                --ball_x_motion <= (NOT ball_x_motion); -- set vspeed to (- ball_speed) pixels
                    active(15) <= '0';
                    hitcount <= hitcount + '1';
        END IF;
        -- row 3
        -- wall 0
        IF (ball_x + bsize/2) >= (wall_x - wall_w) AND
         (ball_x - bsize/2) <= (wall_x + wall_w) AND
             (ball_y + bsize/2) >= (wall_y3 - wall_h) AND
             (ball_y - bsize/2) <= (wall_y3 + wall_h) AND 
             active(16) = '1' THEN
                ball_y_motion <= (NOT ball_y_motion);
                --ball_x_motion <= (NOT ball_x_motion); -- set vspeed to (- ball_speed) pixels
                    active(16) <= '0';  
                    hitcount <= hitcount + '1';                 
        END IF;
        -- wall 2
        IF (ball_x + bsize/2) >= (wall_x2 - wall_w) AND
         (ball_x - bsize/2) <= (wall_x2 + wall_w) AND
             (ball_y + bsize/2) >= (wall_y3 - wall_h) AND
             (ball_y - bsize/2) <= (wall_y3 + wall_h) AND
             active (17) = '1' THEN
                ball_y_motion <= (NOT ball_y_motion);
                --ball_x_motion <= (NOT ball_x_motion); -- set vspeed to (- ball_speed) pixels
                    active(17) <= '0';
                    hitcount <= hitcount + '1';
        END IF;
        -- wall 3
        IF (ball_x + bsize/2) >= (wall_x3 - wall_w) AND
         (ball_x - bsize/2) <= (wall_x3 + wall_w) AND
             (ball_y + bsize/2) >= (wall_y3 - wall_h) AND
             (ball_y - bsize/2) <= (wall_y3 + wall_h) AND 
             active(18) = '1' THEN
                ball_y_motion <= (NOT ball_y_motion);
                --ball_x_motion <= (NOT ball_x_motion); -- set vspeed to (- ball_speed) pixels
                    active(18) <= '0'; 
                    hitcount <= hitcount + '1';                  
        END IF;
        -- wall 4
        IF (ball_x + bsize/2) >= (wall_x4 - wall_w) AND
         (ball_x - bsize/2) <= (wall_x4 + wall_w) AND
             (ball_y + bsize/2) >= (wall_y3 - wall_h) AND
             (ball_y - bsize/2) <= (wall_y3 + wall_h) AND
             active (19) = '1' THEN
                ball_y_motion <= (NOT ball_y_motion);
                --ball_x_motion <= (NOT ball_x_motion); -- set vspeed to (- ball_speed) pixels
                    active(19) <= '0';
                    hitcount <= hitcount + '1';
        END IF;
        -- wall 5
        IF (ball_x + bsize/2) >= (wall_x5 - wall_w) AND
         (ball_x - bsize/2) <= (wall_x5  + wall_w) AND
             (ball_y + bsize/2) >= (wall_y3 - wall_h) AND
             (ball_y - bsize/2) <= (wall_y3 + wall_h) AND 
             active(20) = '1' THEN
                ball_y_motion <= (NOT ball_y_motion);
                --ball_x_motion <= (NOT ball_x_motion); -- set vspeed to (- ball_speed) pixels
                    active(20) <= '0'; 
                    hitcount <= hitcount + '1';                  
        END IF;
        -- wall 6
        IF (ball_x + bsize/2) >= (wall_x6 - wall_w) AND
         (ball_x - bsize/2) <= (wall_x6 + wall_w) AND
             (ball_y + bsize/2) >= (wall_y3 - wall_h) AND
             (ball_y - bsize/2) <= (wall_y3 + wall_h) AND
             active (21) = '1' THEN
                ball_y_motion <= (NOT ball_y_motion);
                --ball_x_motion <= (NOT ball_x_motion); -- set vspeed to (- ball_speed) pixels
                    active(21) <= '0';
                    hitcount <= hitcount + '1';
        END IF;
        -- wall 7
        IF (ball_x + bsize/2) >= (wall_x7 - wall_w) AND
         (ball_x - bsize/2) <= (wall_x7 + wall_w) AND
             (ball_y + bsize/2) >= (wall_y3 - wall_h) AND
             (ball_y - bsize/2) <= (wall_y3 + wall_h) AND 
             active(22) = '1' THEN
                ball_y_motion <= (NOT ball_y_motion);
                --ball_x_motion <= (NOT ball_x_motion); -- set vspeed to (- ball_speed) pixels
                    active(22) <= '0';  
                    hitcount <= hitcount + '1';                 
        END IF;
        -- wall 8
        IF (ball_x + bsize/2) >= (wall_x8 - wall_w) AND
         (ball_x - bsize/2) <= (wall_x8 + wall_w) AND
             (ball_y + bsize/2) >= (wall_y3 - wall_h) AND
             (ball_y - bsize/2) <= (wall_y3 + wall_h) AND
             active (23) = '1' THEN
                ball_y_motion <= (NOT ball_y_motion);
                --ball_x_motion <= (NOT ball_x_motion); -- set vspeed to (- ball_speed) pixels
                    active(23) <= '0';
                    hitcount <= hitcount + '1';
        END IF;



        
        
        -- compute next ball vertical position
        -- variable temp adds one more bit to calculation to fix unsigned underflow problems
        -- when ball_y is close to zero and ball_y_motion is negative
        temp := ('0' & ball_y) + (ball_y_motion(10) & ball_y_motion);
        IF game_on = '0' THEN
            ball_y <= CONV_STD_LOGIC_VECTOR(440, 11);
        ELSIF temp(11) = '1' THEN
            ball_y <= (OTHERS => '0');
        ELSE ball_y <= temp(10 DOWNTO 0); -- 9 downto 0
        END IF;
        -- compute next ball horizontal position
        -- variable temp adds one more bit to calculation to fix unsigned underflow problems
        -- when ball_x is close to zero and ball_x_motion is negative
        temp := ('0' & ball_x) + (ball_x_motion(10) & ball_x_motion);
        IF temp(11) = '1' THEN
            ball_x <= (OTHERS => '0');
        ELSE ball_x <= temp(10 DOWNTO 0);
        END IF;
    END PROCESS;
    
    
    -- process to draw walls
    walldraw : PROCESS (pixel_row, pixel_col) IS
        VARIABLE vx, vy : STD_LOGIC_VECTOR (10 DOWNTO 0); -- 9 downto 0
    BEGIN
        IF ((pixel_col >= wall_x - wall_w) OR (wall_x <= wall_w)) AND
         pixel_col <= wall_x + wall_w AND
             pixel_row >= wall_y - wall_h AND
             pixel_row <= wall_y + wall_h AND
             active(0) = '1' THEN
                wall_on <= '1';
        ELSIF 
        ((pixel_col >= wall_x2 - wall_w) OR (wall_x2 <= wall_w)) AND
         pixel_col <= wall_x2 + wall_w AND
             pixel_row >= wall_y - wall_h AND
             pixel_row <= wall_y + wall_h AND
             active(1) = '1' THEN
                wall_on <= '1';
        ElSIF 
        ((pixel_col >= wall_x3 - wall_w) OR (wall_x3 <= wall_w)) AND
         pixel_col <= wall_x3 + wall_w AND
             pixel_row >= wall_y - wall_h AND
             pixel_row <= wall_y + wall_h AND
             active(2) = '1' THEN
                wall_on <= '1';
        ELSIF 
        ((pixel_col >= wall_x4 - wall_w) OR (wall_x4 <= wall_w)) AND
         pixel_col <= wall_x4 + wall_w AND
             pixel_row >= wall_y - wall_h AND
             pixel_row <= wall_y + wall_h AND
             active(3) = '1' THEN
                wall_on <= '1';
        ElSIF 
        ((pixel_col >= wall_x5 - wall_w) OR (wall_x5 <= wall_w)) AND
         pixel_col <= wall_x5 + wall_w AND
             pixel_row >= wall_y - wall_h AND
             pixel_row <= wall_y + wall_h AND
             active(4) = '1' THEN
                wall_on <= '1';
        ELSIF 
        ((pixel_col >= wall_x6 - wall_w) OR (wall_x6 <= wall_w)) AND
         pixel_col <= wall_x6 + wall_w AND
             pixel_row >= wall_y - wall_h AND
             pixel_row <= wall_y + wall_h AND
             active(5) = '1' THEN
                wall_on <= '1';
        ElSIF 
        ((pixel_col >= wall_x7 - wall_w) OR (wall_x7 <= wall_w)) AND
         pixel_col <= wall_x7 + wall_w AND
             pixel_row >= wall_y - wall_h AND
             pixel_row <= wall_y + wall_h AND
             active(6) = '1' THEN
                wall_on <= '1';
        ELSIF 
        ((pixel_col >= wall_x8 - wall_w) OR (wall_x8 <= wall_w)) AND
         pixel_col <= wall_x8 + wall_w AND
             pixel_row >= wall_y - wall_h AND
             pixel_row <= wall_y + wall_h AND
             active(7) = '1' THEN
                wall_on <= '1';
       -- Row 2
       elsIF ((pixel_col >= wall_x - wall_w) OR (wall_x <= wall_w)) AND
         pixel_col <= wall_x + wall_w AND
             pixel_row >= wall_y2 - wall_h AND
             pixel_row <= wall_y2 + wall_h AND
             active(8) = '1' THEN
                wall_on <= '1';
        ELSIF 
        ((pixel_col >= wall_x2 - wall_w) OR (wall_x2 <= wall_w)) AND
         pixel_col <= wall_x2 + wall_w AND
             pixel_row >= wall_y2 - wall_h AND
             pixel_row <= wall_y2 + wall_h AND
             active(9) = '1' THEN
                wall_on <= '1';
        ElSIF 
        ((pixel_col >= wall_x3 - wall_w) OR (wall_x3 <= wall_w)) AND
         pixel_col <= wall_x3 + wall_w AND
             pixel_row >= wall_y2 - wall_h AND
             pixel_row <= wall_y2 + wall_h AND
             active(10) = '1' THEN
                wall_on <= '1';
        ELSIF 
        ((pixel_col >= wall_x4 - wall_w) OR (wall_x4 <= wall_w)) AND
         pixel_col <= wall_x4 + wall_w AND
             pixel_row >= wall_y2 - wall_h AND
             pixel_row <= wall_y2 + wall_h AND
             active(11) = '1' THEN
                wall_on <= '1';
        ElSIF 
        ((pixel_col >= wall_x5 - wall_w) OR (wall_x5 <= wall_w)) AND
         pixel_col <= wall_x5 + wall_w AND
             pixel_row >= wall_y2 - wall_h AND
             pixel_row <= wall_y2 + wall_h AND
             active(12) = '1' THEN
                wall_on <= '1';
        ELSIF 
        ((pixel_col >= wall_x6 - wall_w) OR (wall_x6 <= wall_w)) AND
         pixel_col <= wall_x6 + wall_w AND
             pixel_row >= wall_y2 - wall_h AND
             pixel_row <= wall_y2 + wall_h AND
             active(13) = '1' THEN
                wall_on <= '1';
        ElSIF 
        ((pixel_col >= wall_x7 - wall_w) OR (wall_x7 <= wall_w)) AND
         pixel_col <= wall_x7 + wall_w AND
             pixel_row >= wall_y2 - wall_h AND
             pixel_row <= wall_y2 + wall_h AND
             active(14) = '1' THEN
                wall_on <= '1';
        ELSIF 
        ((pixel_col >= wall_x8 - wall_w) OR (wall_x8 <= wall_w)) AND
         pixel_col <= wall_x8 + wall_w AND
             pixel_row >= wall_y2 - wall_h AND
             pixel_row <= wall_y2 + wall_h AND
             active(15) = '1' THEN
                wall_on <= '1';

        -- row 3
        elsIF ((pixel_col >= wall_x - wall_w) OR (wall_x <= wall_w)) AND
         pixel_col <= wall_x + wall_w AND
             pixel_row >= wall_y3 - wall_h AND
             pixel_row <= wall_y3 + wall_h AND
             active(16) = '1' THEN
                wall_on <= '1';
        ELSIF 
        ((pixel_col >= wall_x2 - wall_w) OR (wall_x2 <= wall_w)) AND
         pixel_col <= wall_x2 + wall_w AND
             pixel_row >= wall_y3 - wall_h AND
             pixel_row <= wall_y3 + wall_h AND
             active(17) = '1' THEN
                wall_on <= '1';
        ElSIF 
        ((pixel_col >= wall_x3 - wall_w) OR (wall_x3 <= wall_w)) AND
         pixel_col <= wall_x3 + wall_w AND
             pixel_row >= wall_y3 - wall_h AND
             pixel_row <= wall_y3 + wall_h AND
             active(18) = '1' THEN
                wall_on <= '1';
        ELSIF 
        ((pixel_col >= wall_x4 - wall_w) OR (wall_x4 <= wall_w)) AND
         pixel_col <= wall_x4 + wall_w AND
             pixel_row >= wall_y3 - wall_h AND
             pixel_row <= wall_y3 + wall_h AND
             active(19) = '1' THEN
                wall_on <= '1';
        ElSIF 
        ((pixel_col >= wall_x5 - wall_w) OR (wall_x5 <= wall_w)) AND
         pixel_col <= wall_x5 + wall_w AND
             pixel_row >= wall_y3 - wall_h AND
             pixel_row <= wall_y3 + wall_h AND
             active(20) = '1' THEN
                wall_on <= '1';
        ELSIF 
        ((pixel_col >= wall_x6 - wall_w) OR (wall_x6 <= wall_w)) AND
         pixel_col <= wall_x6 + wall_w AND
             pixel_row >= wall_y3 - wall_h AND
             pixel_row <= wall_y3 + wall_h AND
             active(21) = '1' THEN
                wall_on <= '1';
        ElSIF 
        ((pixel_col >= wall_x7 - wall_w) OR (wall_x7 <= wall_w)) AND
         pixel_col <= wall_x7 + wall_w AND
             pixel_row >= wall_y3 - wall_h AND
             pixel_row <= wall_y3 + wall_h AND
             active(22) = '1' THEN
                wall_on <= '1';
        ELSIF 
        ((pixel_col >= wall_x8 - wall_w) OR (wall_x8 <= wall_w)) AND
         pixel_col <= wall_x8 + wall_w AND
             pixel_row >= wall_y3 - wall_h AND
             pixel_row <= wall_y3 + wall_h AND
             active(23) = '1' THEN
                wall_on <= '1';
        ELSE
            wall_on <= '0';
        END IF;
        END PROCESS;
    
END Behavioral;
