# CPE-487-Final-Project
### Nate Dawson & Zachary Reece
## Brick Break Game
#### Expanded off of Lab 6

- The bat_n_ball file is responsible for drawing both the bat and ball on the screen. It also causes the ball to bounce by reversing its vertical speed when it collides with the bat, top wall, or the top or bottom of the bricks, and by reversing its horizontal speed when it collides with the side of the bricks or one of the side walls.

  - The variable game_on indicates whether or not the ball is currently in play.
  - When game_on = ‘1’, the ball is visible and bounces off the bat, walls, and bricks.
  - If the ball hits the bottom wall, game_on is set to ‘0’. When game_on = ‘0’, the ball is not visible and waits to be served.
  - When the serve input goes high, game_on is set to ‘1’ and the ball becomes visible again.
  - other modifications?

- The adc_if module converts the serial data from both channels of the ADC into 12-bit parallel format.
  - When the CS line of the ADC is taken low, it begins a conversion and serially outputs a 16-bit quantity on the next 16 falling edges of the ADC serial clock.
  - The data consists of 4 leading zeros followed by the 12-bit converted value.
  - These 16 bits are loaded into a 12-bit shift register from the least significant end.
  - The top 4 zeros fall off the most significant end of the shift register leaving the 12-bit data in place after 16 clock cycles.
  - When CS goes high, this data is synchronously loaded into the two 12-bit parallel outputs of the module.

- The pong module is the top level.
  - BTNC on the Nexys A7 board is used to serve the ball and start the Brick Break game.
  - The process ckp is used to generate timing signals for the VGA and ADC modules.
  - The output of the adc_if module drives bat_x of the bat_n_ball module.

1. Create a new RTL project pong in Vivado:

- Copy/Create six new source files called clk_wiz_0, clk_wiz_0_clk_wiz, vga_sync, bat_n_ball, adc_if, and pong.vhdl

- Copy/Create a new constraint file pong.xdc

- Select the Nexys A7-100T board, then 'Finish'

2. Run synthesis

3. Run implementation

(Optionally, you can select ‘Open Implemented Design’, though this is generally not recommended as it is difficult to extract information from and can cause Vivado shutdown)

4. Write Bitstream:

- Click 'Generate Bitstream'

- Click 'Open Hardware Manager' and click 'Open Target' then 'Auto Connect'

- Click 'Program Device' then xc7a100t_0 to download pong.bit to the Nexys A7-100T board

  - Push BTNC to start the Brick Break game

  - Use BTNL and BTNR to move the bat side-to-side and break every brick!
