# CPE-487-Final-Project
### Nate Dawson & Zachary Reece
## Brick Break Game
#### Expanded off of Lab 6: Video Game PONG

_A description of the expected behavior of the project, attachments needed (speaker module, VGA connector, etc.), related images/diagrams, etc. The more detailed the better – you all know how much I love a good finite state machine and Boolean logic, so those could be some good ideas if appropriate for your system. If not, some kind of high level block diagram showing how different parts of your program connect together and/or showing how what you have created might fit into a more complete system could be appropriate instead._

- The bat_n_ball file is responsible for drawing both the bat and ball on the screen. It also causes the ball to bounce by reversing its vertical speed when it collides with the bat, top wall, or the top or bottom of the bricks, and by reversing its horizontal speed when it collides with the side of the bricks or one of the side walls.

  - The variable game_on indicates whether or not the ball is currently in play.
  - When game_on = ‘1’, the ball is visible and bounces off the bat, walls, and bricks.
  - If the ball hits the bottom wall, game_on is set to ‘0’. When game_on = ‘0’, the ball is not visible and waits to be served, and the bricks and counter reset.
  - When the serve input goes high, game_on is set to ‘1’ and the ball becomes visible again.
  - other modifications?

- The adc_if module converts the serial data from both channels of the ADC into 12-bit parallel format.
  - When the CS line of the ADC is taken low, it begins a conversion and serially outputs a 16-bit quantity on the next 16 falling edges of the ADC serial clock.
  - The data consists of 4 leading zeros followed by the 12-bit converted value.
  - These 16 bits are loaded into a 12-bit shift register from the least significant end.
  - The top 4 zeros fall off the most significant end of the shift register leaving the 12-bit data in place after 16 clock cycles.
  - When CS goes high, this data is synchronously loaded into the two 12-bit parallel outputs of the module.

- The pong module is the top level program.
  - BTNC on the Nexys A7 board is used to serve the ball and start the Brick Break game.
  - The process ckp is used to generate timing signals for the VGA and ADC modules.
  - The output of the adc_if module drives bat_x of the bat_n_ball module.
  - The bat x position increases while BTNR is pressed, and decreases as BTNL is pressed.

### Steps to Program Nexys Board with Vivado

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

5. Close project

### Description of Inputs and Outputs

Key Inputs:

- clk_in : standard logic (system clock)
- dig : 3-bit standard logic vector (selects which digit on Nexys board to display)
- data : 16-bit standard logic vector
- bat_x : 11-bit standard logic vector (width of bat)
- serve : standard logic (generates ball to play)
- btnl : standard logic (button to move bat left)
- btnr : standard logic (button to move bat right)
- btn0 : standard logic (button to start the game)
- sw : 11-bit standard logic vector (controls the speed)

Key Outputs:

- anode : 8-bit standard logic vector (each digit screen on Nexys board to display)
- seg : 7-bit standard logic vector (selects which segments to display corresponding to the current digit)
- red : standard logic (red color setting for program)
- green : standard logic (green color setting for program)
- blue : standard logic (blue color setting for program)
- hitcount : standard logic vector (measures how many walls have been hit by the ball)

### Modifications
_If building on an existing lab or expansive starter code of some kind, describe your “modifications” – the changes made to that starter code to improve the code, create entirely new functionalities, etc. Unless you were starting from one of the labs, please share any starter code used as well, including crediting the creator(s) of any code used. It is perfectly ok to start with a lab or other code you find as a baseline, but you will be judged on your contributions on top of that pre-existing code!_

- A total of 11 new logic vectors were assigned 8 x-coordinates and 3 y-coordinates to generate an 8 x 3 grid of walls.

  - These walls were drawn with the same logic for drawing the bat in the original Lab 6 code in the class Github repository.
  
- The same logic was used for the bouncing physics off the walls.
  
- A 24 bit vector named _active_ was used to represent each wall, each location would determine if a wall was hit or not.

- _hitcounter_ was modified to count the number of walls hit instead of how many times the ball hits the bat.

- When all walls are destroyed, the game resets the walls but keeps the number of hits encouraging the user to play on for a higher score.

- Every time all the walls are cleared, the ball speeds up making the game increasingly difficult.

  - To compensate for this, the bat also gets thicker each time.
 
- other modifications?

### Conclusion
_Conclude with a summary of the process itself – who was responsible for what components, any difficulties encountered and how they were solved, etc._

- For this project, Nate mainly worked on modifying the code while Zach mainly worked on the presentation and repository, with both of us debugging and collaborating in both lab sessions and online. 

- It was difficult to avoid spamming if statements for each wall. With the system of having coordinates requiring only 11 variables instead of 48 and utilizing one 24 bit vector to hold the status of every wall the code was still efficient enough.

- There were moments where the ball would phase though the bat even though we had not changed that process. We believe this was due to the board slowing down and missing the ball connecting with the bat, so we made the bat look slightly thicker but have a significantly bigger hitbox. 

- The hitcounter would only display one digit, but this was because of an error in the base code where cnt was called instead of count.

