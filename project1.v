
module project1(
		CLOCK_50,						//	On Board 50 MHz
		// Your inputs and outputs here
        KEY,
		  LEDR,
		  HEX0,
		  SW,
		// The ports below are for the VGA output.  Do not change.
		VGA_CLK,   						//	VGA Clock
		VGA_HS,							//	VGA H_SYNC
		VGA_VS,							//	VGA V_SYNC
		VGA_BLANK_N,						//	VGA BLANK
		VGA_SYNC_N,						//	VGA SYNC
		VGA_R,   						//	VGA Red[9:0]
		VGA_G,							//	VGA Green[9:0]
		VGA_B   						//	VGA Blue[9:0]
	);
   input [17:0] SW;
	input			CLOCK_50;				//	50 MHz
	input   [3:0]   KEY;
	output [17:0] LEDR;
	output [6:0] HEX0;

	// Declare your inputs and outputs here
	// Do not change the following outputs
	output			VGA_CLK;   				//	VGA Clock
	output			VGA_HS;					//	VGA H_SYNC
	output			VGA_VS;					//	VGA V_SYNC
	output			VGA_BLANK_N;				//	VGA BLANK
	output			VGA_SYNC_N;				//	VGA SYNC
	output	[9:0]	VGA_R;   				//	VGA Red[9:0]n
	output	[9:0]	VGA_G;					//	VGA Green[9:0]
	output	[9:0]	VGA_B;   				//	VGA Blue[9:0]


	// Create an Instance of a VGA controller - there can be only one!
	// Define the number of colours as well as the initial background
	// image file (.MIF) for the controller.
	vga_adapter VGA(
			.resetn(1'b1),
			.clock(CLOCK_50),
			.colour(colour),
			.x(x),
			.y(y),
			.plot(1'b1),
			/* Signals for the DAC to drive the monitor. */
			.VGA_R(VGA_R),
			.VGA_G(VGA_G),
			.VGA_B(VGA_B),
			.VGA_HS(VGA_HS),
			.VGA_VS(VGA_VS),
			.VGA_BLANK(VGA_BLANK_N),
			.VGA_SYNC(VGA_SYNC_N),
			.VGA_CLK(VGA_CLK));
		defparam VGA.RESOLUTION = "160x120";
		defparam VGA.MONOCHROME = "FALSE";
		defparam VGA.BITS_PER_COLOUR_CHANNEL = 1;
		defparam VGA.BACKGROUND_IMAGE = "black.mif";

	reg [1:0] death;
	reg [5:0] state;
	reg border_initing, paddle_initing, ball_initing, block_initing;
	reg [7:0] x, y;
	reg [7:0] playerx, playery, ballx, bally, ballx1, bally1, ballx2, bally2, block1x,block1y,block2x,block2y;
	reg [2:0] colour;
	reg ballxdir, ballydir, ballxdir1, ballydir1, ballxdir2, ballydir2;
	reg [17:0] draw_counter;
	reg [2:0] block_1_colour, block_2_colour, block_3_colour, block_4_colour, block_5_colour, block_6_colour, block_7_colour, block_8_colour, block_9_colour, block_10_colour;
	wire frame;
	reg [4:0] deaths;
	reg[4:0] start_life = 4'b0101;
	reg[4:0] current_life;
	assign LEDR[5:0] = state;

	localparam  RESET_BLACK       = 6'b000000,
                init_player       = 6'b000001,
                INIT_BALL         = 6'b000010,
                INIT_BALL1        = 6'b000011,
					INIT_BALL_2        = 6'b000100,
					INIT_BLOCK_1      = 6'b000101,
					INIT_BLOCK_2      = 6'b000110,
					INIT_BLOCK_5      = 6'b000111,
                IDLE              = 6'b001000,
					erase_player	    = 6'b001001,
                update_player     = 6'b001010,
					draw_player	    = 6'b001011,
                ERASE_BALL        = 6'b001100,
					UPDATE_BALL       = 6'b001101,
					DRAW_BALL         = 6'b001110,
					ERASE_BALL1       = 6'b001111,
					UPDATE_BALL1        = 6'b010000,
					DRAW_BALL1      = 6'b010001,
					ERASE_BALL2      = 6'b010010,
					UPDATE_BALL2    = 6'b010011,
					DRAW_BALL2      = 6'b010100,
					UPDATE_BLOCK_1    = 6'b010101,
					DRAW_BLOCK_1      = 6'b010110,
					UPDATE_BLOCK_2    = 6'b010111,
					DRAW_BLOCK_2      = 6'b011000,
					DEAD    		    = 6'b011001;

	clock(.clock(CLOCK_50), .clk(frame));
hex_display hex0(.IN(current_life), .OUT(HEX0[6:0])) ;
	assign LEDR[7] = ((ballydir) && (bally > playery - 8'd1) && (bally < playery + 8'd2) && (ballx >= playerx) && (ballx <= playerx + 8'd8));
	always@(posedge CLOCK_50)
    begin

			border_initing = 1'b0;
			paddle_initing = 1'b0;
			ball_initing = 1'b0;
			block_initing = 1'b0;
			colour = 3'b000;
			x = 8'b00000000;
			y = 8'b00000000;
			if (SW[17]) state = RESET_BLACK;
			if(death) current_life= current_life -1'b1;
			else current_life= start_life;
        case (state)
		  RESET_BLACK: begin
			if (draw_counter < 17'b10000000000000000) begin
						x = draw_counter[7:0];
						y = draw_counter[16:8];
						draw_counter = draw_counter + 1'b1;
						end
					else begin
						draw_counter= 8'b00000000;
						state = init_player;
					end
		  end
    			init_player: begin
					if (draw_counter < 6'b10000) begin
					death = 1'b0;
					playerx = 8'd30;
					playery = 8'd100;
						x = playerx + draw_counter[3:0];
						y = playery + draw_counter[4];
						draw_counter = draw_counter + 1'b1;
						colour = 3'b111;
						end
					else begin
						draw_counter= 8'b00000000;
						state = INIT_BLOCK_1;
					end
				end

				INIT_BLOCK_1 : begin
    			     //current_life = start_life;

					if (draw_counter < 6'b10000) begin
					   block1x = 8'd40;
						block1y= 8'd40;
						x = block1x + draw_counter[2];
						y = block1y  + draw_counter[2];
						draw_counter = draw_counter + 1'b1;
						colour = 3'b110;
						end
					else begin
						draw_counter= 8'b00000000;
						state = INIT_BLOCK_2;
					end
					end

				INIT_BLOCK_2 : begin
    			     //current_life = start_life;

					if (draw_counter < 6'b10000) begin
					   block2x = 8'd80;
						block2y= 8'd20;
						x = block2x + draw_counter[2];
						y = block2y  + draw_counter[2];
						draw_counter = draw_counter + 1'b1;
						colour = 3'b110;
						end
					else begin
						draw_counter= 8'b00000000;
						state = INIT_BALL;
					end
					end
				INIT_BALL: begin
					ballx = 8'd20;
					bally = 8'd40;
						x = ballx;
						y = bally;
						colour = 3'b111;
						state = INIT_BALL1;
				end
					INIT_BALL1: begin
					ballx1 = 8'd50;
					bally1 = 8'd70;
						x = ballx1;
						y = bally1;
						colour = 3'b111;
						state = INIT_BALL_2;
					end
					INIT_BALL_2: begin
					ballx2 = 8'd70;
					bally2 = 8'd60;
						x = ballx2;
						y = bally2;
						colour = 3'b111;
						state = IDLE;
				end
				IDLE: begin
				if (frame)
					state = erase_player;
				end
				erase_player: begin
						if (draw_counter < 6'b100000) begin
						x = playerx + draw_counter[3:0];
						y = playery + draw_counter[4];
						draw_counter = draw_counter + 1'b1;
						end
					else begin
						draw_counter= 8'b00000000;
						state = update_player;
					end
				end
				update_player: begin
						if (~KEY[1] && playerx < 8'd144) playerx = playerx + 1'b1;
						if (~KEY[2] && playerx > 8'd0) playerx = playerx - 1'b1;
						if (~KEY[3] && playery < 8'd160) playery = playery + 1'b1;
						if (~KEY[0] && playery > 8'd0) playery = playery - 1'b1;
						state = draw_player;

				end
				draw_player: begin
					if (draw_counter < 6'b100000) begin
						x = playerx + draw_counter[2:0];
						y = playery + draw_counter[4];
						draw_counter = draw_counter + 1'b1;
						colour = 3'b111;
						end
					else begin
						draw_counter= 8'b00000000;
						state = DRAW_BLOCK_1;
					end
				end

				DRAW_BLOCK_1 : begin
				if (draw_counter < 6'b100000) begin
						x = block1x + draw_counter[2:0];
						y = block1y + draw_counter[4];
						draw_counter = draw_counter + 1'b1;
						colour = 3'b110;
						end
					else begin
						draw_counter= 8'b00000000;
						state = DRAW_BLOCK_2;
					end
				end

					DRAW_BLOCK_2 : begin
				if (draw_counter < 6'b100000) begin
						x = blo$150 ck2x + draw_counter[2:0];
						y = block2y + draw_counter[4];
						draw_counter = draw_counter + 1'b1;
						colour = 3'b110;
						end
					else begin
						draw_counter= 8'b00000000;
						state = ERASE_BALL;
					end
				end

				ERASE_BALL: begin
					x = ballx;
						y = bally;
						state = UPDATE_BALL;
				end
				UPDATE_BALL: begin
					if (~ballxdir) ballx = ballx + 1'b1;
					else ballx = ballx - 1'b1;
					if (ballydir) bally = bally + 1'b1;
					else bally = bally - 1'b1;
					if ((ballx == 8'd0) || (ballx == 8'd160))
					ballxdir = ~ballxdir;

				if ((bally == 8'd0) || (bally >= 8'd120) )
					ballydir = ~ballydir;

					if ((ballydir) && (bally > playery - 8'd1) && (bally < playery + 8'd2) && (ballx >= playerx) && (ballx <= playerx + 8'd15))
					state = DEAD;

					else if ((~ballydir) && (bally < playery - 8'd1) && (bally > playery + 8'd2) && (ballx >= playerx) && (ballx >= playerx + 8'd15))
					state = DEAD;

					else state = DRAW_BALL;
				end
				DRAW_BALL: begin
					x = ballx;
						y = bally;
						colour = 3'b111;
						state = ERASE_BALL1;
				end
				          // BALL 2 --------------------------------- BALL 2 //
         ERASE_BALL1: begin
          x = ballx1;
            y = bally1;
            state = UPDATE_BALL1;
         end
         UPDATE_BALL1: begin
           if (~ballxdir1) ballx1 = ballx1 + 1'b1;
           else ballx1 = ballx1 - 1'b1;
          if (ballydir1) bally1 = bally1 + 1'b1;
           else bally1 = bally1 - 1'b1;
           if ((ballx1 == 8'd0) || (ballx1 == 8'd160))
          ballxdir1 = ~ballxdir1;

         if ((bally1 == 8'd0) || (bally >= 8'd120) )
          ballydir1 = ~ballydir1;

			if ((ballydir1) && (bally1 > playery - 8'd1) && (bally1 < playery + 8'd2) && (ballx1 >= playerx) && (ballx1 <= playerx + 8'd15))
				state = DEAD;

			else if ((~ballydir1) && (bally1 < playery - 8'd1) && (bally1 > playery + 8'd2) && (ballx1 >= playerx) && (ballx1 >= playerx + 8'd15))
					state = DEAD;

          else state = DRAW_BALL1;
         end
         DRAW_BALL1: begin
          x = ballx1;
            y = bally1;
            colour = 3'b111;
            state = ERASE_BALL2;
         end

         // BALL 3 ------------------------- BALL 3 //
         ERASE_BALL2: begin
          x = ballx2;
            y = bally2;
            state = UPDATE_BALL2;
         end
         UPDATE_BALL2: begin
           if (~ballxdir2) ballx2 = ballx2 + 1'b1;
           else ballx2 = ballx2 - 1'b1;
          if (ballydir2) bally2 = bally2 + 1'b1;
           else bally2 = bally2 - 1'b1;
           if ((ballx2 == 8'd0) || (ballx2 == 8'd160))
          ballxdir2 = ~ballxdir2;

         if ((bally2 == 8'd0) || (bally >= 8'd120))
          ballydir2 = ~ballydir2;

          	if ((ballydir2) && (bally2 > playery - 8'd1) && (bally2 < playery + 8'd2) && (ballx2 >= playerx) && (ballx2 <= playerx + 8'd15))
					state = DEAD;
				else if ((~ballydir2) && (bally2 < playery - 8'd1) && (bally2 > playery + 8'd2) && (ballx2 >= playerx) && (ballx >= playerx + 8'd15))
					state = DEAD;
          else state = DRAW_BALL2;
         end
         DRAW_BALL2: begin
          x = ballx2;
            y = bally2;
            colour = 3'b111;
            state = UPDATE_BLOCK_1;
         end
         UPDATE_BLOCK_1:
         begin
         if ((block1y > playery - 8'd1) && (block1y < playery + 8'd2) && (block1x >= playerx) && (block1x <= playerx + 8'd15))
       state = DEAD;
       else state = UPDATE_BLOCK_2;
         end
			UPDATE_BLOCK_2:
         begin
         if ((block2y > playery - 8'd1) && (block2y < playery + 8'd2) && (block2x >= playerx) && (block2x <= playerx + 8'd15))
       state = DEAD;
       else state = IDLE;
         end
				DEAD: begin
				   death = 1'b1;
               current_life = current_life -1'b1;
					if (draw_counter < 17'b10000000000000000) begin
						x = draw_counter[7:0];
						y = draw_counter[16:8];
						draw_counter = draw_counter + 1'b1;
						colour = 3'b100;
						end
				end


         endcase
    end
endmodule

module clock(input clock, output clk);
reg [19:0] frame_counter;
reg frame;
	always@(posedge clock)
    begin
        if (frame_counter == 20'b00000000000000000000) begin
		  frame_counter = 20'b11001011011100110100;
		  frame = 1'b1;
		  end
        else begin
			frame_counter = frame_counter - 1'b1;
			frame = 1'b0;
		  end
    end
	assign clk = frame;
endmodule

module hex_display(IN, OUT);
    input [3:0] IN;
	output reg [7:0] OUT;

	always @(*)
	begin
		case(IN[3:0])
			4'b0000: OUT = 7'b1000000;
			4'b0001: OUT = 7'b1111001;
			4'b0010: OUT = 7'b0100100;
			4'b0011: OUT = 7'b0110000;
			4'b0100: OUT = 7'b0011001;
			4'b0101: OUT = 7'b0010010;
			4'b0110: OUT = 7'b0000010;
			4'b0111: OUT = 7'b1111000;
			4'b1000: OUT = 7'b0000000;
			4'b1001: OUT = 7'b0011000;
			4'b1010: OUT = 7'b0001000;
			4'b1011: OUT = 7'b0000011;
			4'b1100: OUT = 7'b1000110;
			4'b1101: OUT = 7'b0100001;
			4'b1110: OUT = 7'b0000110;
			4'b1111: OUT = 7'b0001110;
			default: OUT = 7'b0111111;
		endcase

	end
endmodule