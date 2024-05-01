# CPE-487-Final-Project
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
