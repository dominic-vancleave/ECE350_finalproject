`timescale 1 ns/ 100 ps
module VGAController(     
	input clk, 			// 100 MHz system Clock
	input reset, 		// Reset Signal
	output hSync, 		// H sync Signal
	output vSync, 		// Veritcal sync Signal
	output[3:0] VGA_R,  // Red Signal Bits
	output[3:0] VGA_G,  // Green Signal Bits
	output[3:0] VGA_B,  // Blue Signal Bits
	output screenEnd,	// VGA update rate for processor
	input BTNU, // Pushbuttons
	input BTND,
	input BTNL,
	input BTNR,
	input[31:0] sprite_x, // Sprite Location Based on Processor ($r1 for x)
	input[31:0] sprite_y, // ($r2 for y)
	output game_over,	// Game over bit for regfile
	input[31:0] score); // score stored in $r3
	
	// Lab Memory Files Location
	localparam FILES_PATH = "C:/Users/domin/Documents/DukeClasses/ECE/ECE350/ECE350_Jumpin_Jackpot/";

	// Clock divider 100 MHz -> 25 MHz
	wire clk25; // 25MHz clock

	reg[1:0] pixCounter = 0;      // Pixel counter to divide the clock
    assign clk25 = pixCounter[1]; // Set the clock high whenever the second bit (2) is high
	always @(posedge clk) begin
		pixCounter <= pixCounter + 1; // Since the reg is only 3 bits, it will reset every 8 cycles
	end

	// VGA Timing Generation for a Standard VGA Screen
	localparam 
		VIDEO_WIDTH = 640,  // Standard VGA Width
		VIDEO_HEIGHT = 480; // Standard VGA Height

	wire active, screenEnd;
	wire[9:0] x;
	wire[8:0] y;
	
	VGATimingGenerator #(
		.HEIGHT(VIDEO_HEIGHT), // Use the standard VGA Values
		.WIDTH(VIDEO_WIDTH))
	Display( 
		.clk25(clk25),  	   // 25MHz Pixel Clock
		.reset(reset),		   // Reset Signal
		.screenEnd(screenEnd), // High for one cycle when between two frames
		.active(active),	   // High when drawing pixels
		.hSync(hSync),  	   // Set Generated H Signal
		.vSync(vSync),		   // Set Generated V Signal
		.x(x), 				   // X Coordinate (from left)
		.y(y)); 			   // Y Coordinate (from top)	   

	//// START SCREEN
	// Image Data to Map Pixel Location to Color Address
	localparam 
		PIXEL_COUNT = VIDEO_WIDTH*VIDEO_HEIGHT, 	             // Number of pixels on the screen
		PIXEL_ADDRESS_WIDTH = $clog2(PIXEL_COUNT) + 1,           // Use built in log2 command
		BITS_PER_COLOR = 12, 	  								 // Nexys A7 uses 12 bits/color
		PALETTE_COLOR_COUNT = 256, 								 // Number of Colors available
		PALETTE_ADDRESS_WIDTH = $clog2(PALETTE_COLOR_COUNT) + 1; // Use built in log2 Command

	wire[PIXEL_ADDRESS_WIDTH-1:0] imgAddress_background;  	 // Image address for the image data
	wire[PALETTE_ADDRESS_WIDTH-1:0] colorAddr_background;	 // Color address for the color palette
	assign imgAddress_background = x + 640*y;				 // Address calculated coordinate

	RAM #(		
		.DEPTH(PIXEL_COUNT), 				     // Set RAM depth to contain every pixel
		.DATA_WIDTH(PALETTE_ADDRESS_WIDTH),      // Set data width according to the color palette
		.ADDRESS_WIDTH(PIXEL_ADDRESS_WIDTH),     // Set address with according to the pixel count
		.MEMFILE({FILES_PATH, "arcade_background_image.mem"})) // Memory initialization
	ImageData_background(
		.clk(clk), 						 // Falling edge of the 100 MHz clk
		.addr(imgAddress_background),					 // Image data address
		.dataOut(colorAddr_background),				 // Color palette address
		.wEn(1'b0)); 						 // We're always reading

	// Color Palette to Map Color Address to 12-Bit Color
	wire[BITS_PER_COLOR-1:0] colorData_background; // 12-bit color data at current pixel

	RAM #(
		.DEPTH(PALETTE_COLOR_COUNT), 		       // Set depth to contain every color		
		.DATA_WIDTH(BITS_PER_COLOR), 		       // Set data width according to the bits per color
		.ADDRESS_WIDTH(PALETTE_ADDRESS_WIDTH),     // Set address width according to the color count
		.MEMFILE({FILES_PATH, "arcade_background_colors.mem"}))  // Memory initialization
	ColorPalette_background(
		.clk(clk), 							   	   // Rising edge of the 100 MHz clk
		.addr(colorAddr_background),					       // Address from the ImageData RAM
		.dataOut(colorData_background),				       // Color at current pixel
		.wEn(1'b0)); 						       // We're always reading
		
	// Score Board
	reg[9:0] score0_corner_x, score1_corner_x, score2_corner_x, score3_corner_x;
	reg[8:0] score0_corner_y, score1_corner_y, score2_corner_y, score3_corner_y;
	
	wire[NUMBER_SPRITE_ADDRESS_WIDTH-1:0] score0addr, score1addr, score2addr, score3addr;
	assign score0addr = ((y - score0_corner_y) * 25 + (x - score0_corner_x));
	assign score1addr = (score % 10) * 625 + ((y - score1_corner_y) * 25 + (x - score1_corner_x));
	assign score2addr = ((score % 100)/10) * 625 + ((y - score2_corner_y) * 25 + (x - score2_corner_x));
	assign score3addr = ((score % 1000)/100) * 625 + ((y - score3_corner_y) * 25 + (x - score3_corner_x));
	wire score0data;

	// Number Sprites for the Score
	localparam
		NUMBER_SPRITE_COUNT = 6250,
		NUMBER_SPRITE_ADDRESS_WIDTH = $clog2(NUMBER_SPRITE_COUNT) + 1;
	
	RAM #(
		.DEPTH(6250),
		.DATA_WIDTH(1),
		.ADDRESS_WIDTH(NUMBER_SPRITE_ADDRESS_WIDTH),
		.MEMFILE({FILES_PATH, "numbers.mem"}))
	Numbers0(
		.clk(clk),
		.addr(score0addr),
		.dataOut(score0data),
		.wEn(1'b0));

	RAM #(
		.DEPTH(6250),
		.DATA_WIDTH(1),
		.ADDRESS_WIDTH(NUMBER_SPRITE_ADDRESS_WIDTH),
		.MEMFILE({FILES_PATH, "numbers.mem"}))
	Numbers1(
		.clk(clk),
		.addr(score1addr),
		.dataOut(score1data),
		.wEn(1'b0));

	RAM #(
		.DEPTH(6250),
		.DATA_WIDTH(1),
		.ADDRESS_WIDTH(NUMBER_SPRITE_ADDRESS_WIDTH),
		.MEMFILE({FILES_PATH, "numbers.mem"}))
	Numbers2(
		.clk(clk),
		.addr(score2addr),
		.dataOut(score2data),
		.wEn(1'b0));

	RAM #(
		.DEPTH(6250),
		.DATA_WIDTH(1),
		.ADDRESS_WIDTH(NUMBER_SPRITE_ADDRESS_WIDTH),
		.MEMFILE({FILES_PATH, "numbers.mem"}))
	Numbers3(
		.clk(clk),
		.addr(score3addr),
		.dataOut(score3data),
		.wEn(1'b0));

	reg[9:0] person_corner_x;
	reg[8:0] person_corner_y;
	
	// PERSON SPRITE
	localparam
		PERSON_SPRITE_COUNT = 1800,
		PERSON_SPRITE_ADDRESS_WIDTH = $clog2(PERSON_SPRITE_COUNT) + 1;
	
	wire[PERSON_SPRITE_ADDRESS_WIDTH-1:0] personAddr;
	assign personAddr = ((y - person_corner_y) * 30 + (x - person_corner_x));
	wire personData;
	
	RAM #(
		.DEPTH(PERSON_SPRITE_COUNT),
		.DATA_WIDTH(1),
		.ADDRESS_WIDTH(PERSON_SPRITE_ADDRESS_WIDTH),
		.MEMFILE({FILES_PATH, "person.mem"}))
	Person(
		.clk(clk),
		.addr(personAddr),
		.dataOut(personData),
		.wEn(1'b0));

	// JUMPIN JACKPOT TEXT
	reg[9:0] jjtext_corner_x;
	reg[8:0] jjtext_corner_y;
	
	localparam
		JJ_TEXT_SPRITE_COUNT = 30000,
		JJ_TEXT_SPRITE_ADDRESS_WIDTH = $clog2(JJ_TEXT_SPRITE_COUNT) + 1;
	
	wire[JJ_TEXT_SPRITE_ADDRESS_WIDTH-1:0] jjtextAddr;
	assign jjtextAddr = ((y - jjtext_corner_y) * 600 + (x - jjtext_corner_x));
	wire jjtextData;
	
	RAM #(
		.DEPTH(JJ_TEXT_SPRITE_COUNT),
		.DATA_WIDTH(1),
		.ADDRESS_WIDTH(JJ_TEXT_SPRITE_ADDRESS_WIDTH),
		.MEMFILE({FILES_PATH, "JumpinJackpot.mem"}))
	JumpinJackpot(
		.clk(clk),
		.addr(jjtextAddr),
		.dataOut(jjtextData),
		.wEn(1'b0));

	// START GAME TEXT
	reg[9:0] starttext_corner_x;
	reg[8:0] starttext_corner_y;

	localparam
		START_TEXT_SPRITE_COUNT = 15400,
		START_TEXT_SPRITE_ADDRESS_WIDTH = $clog2(START_TEXT_SPRITE_COUNT) + 1;
	
	wire[START_TEXT_SPRITE_ADDRESS_WIDTH-1:0] starttextAddr;
	assign starttextAddr = ((y - starttext_corner_y) * 440 + (x - starttext_corner_x));
	wire starttextData;
	
	RAM #(
		.DEPTH(START_TEXT_SPRITE_COUNT),
		.DATA_WIDTH(1),
		.ADDRESS_WIDTH(START_TEXT_SPRITE_ADDRESS_WIDTH),
		.MEMFILE({FILES_PATH, "Start.mem"}))
	StartGame(
		.clk(clk),
		.addr(starttextAddr),
		.dataOut(starttextData),
		.wEn(1'b0));

	// NAMES TEXT
	reg[9:0] nametext_corner_x;
	reg[8:0] nametext_corner_y;

	localparam
		NAME_TEXT_SPRITE_COUNT = 15400,
		NAME_TEXT_SPRITE_ADDRESS_WIDTH = $clog2(NAME_TEXT_SPRITE_COUNT) + 1;
	
	wire[NAME_TEXT_SPRITE_ADDRESS_WIDTH-1:0] nametextAddr;
	assign nametextAddr = ((y - nametext_corner_y) * 365 + (x - nametext_corner_x));
	wire nametextData;
	
	RAM #(
		.DEPTH(NAME_TEXT_SPRITE_COUNT),
		.DATA_WIDTH(1),
		.ADDRESS_WIDTH(NAME_TEXT_SPRITE_ADDRESS_WIDTH),
		.MEMFILE({FILES_PATH, "Names.mem"}))
	Names(
		.clk(clk),
		.addr(nametextAddr),
		.dataOut(nametextData),
		.wEn(1'b0));

	// GAME OVER TEXT
	reg[9:0] gameovertext_corner_x;
	reg[8:0] gameovertext_corner_y;

	localparam
		GAMEOVER_TEXT_SPRITE_COUNT = 27000,
		GAMEOVER_TEXT_SPRITE_ADDRESS_WIDTH = $clog2(GAMEOVER_TEXT_SPRITE_COUNT) + 1;
	
	wire[GAMEOVER_TEXT_SPRITE_ADDRESS_WIDTH-1:0] gameovertextAddr;
	assign gameovertextAddr = ((y - gameovertext_corner_y) * 450 + (x - gameovertext_corner_x));
	wire gameovertextData;
	
	RAM #(
		.DEPTH(GAMEOVER_TEXT_SPRITE_COUNT),
		.DATA_WIDTH(1),
		.ADDRESS_WIDTH(GAMEOVER_TEXT_SPRITE_ADDRESS_WIDTH),
		.MEMFILE({FILES_PATH, "gameover.mem"}))
	GameOver(
		.clk(clk),
		.addr(gameovertextAddr),
		.dataOut(gameovertextData),
		.wEn(1'b0));

	// SCORE TEXT
	reg[9:0] scoretext_corner_x;
	reg[8:0] scoretext_corner_y;

	localparam
		SCORE_TEXT_SPRITE_COUNT = 2750,
		SCORE_TEXT_SPRITE_ADDRESS_WIDTH = $clog2(SCORE_TEXT_SPRITE_COUNT) + 1;
	
	wire[SCORE_TEXT_SPRITE_ADDRESS_WIDTH-1:0] scoretextAddr;
	assign scoretextAddr = ((y - scoretext_corner_y) * 110 + (x - scoretext_corner_x));
	wire scoretextData;
	
	RAM #(
		.DEPTH(SCORE_TEXT_SPRITE_COUNT),
		.DATA_WIDTH(1),
		.ADDRESS_WIDTH(SCORE_TEXT_SPRITE_ADDRESS_WIDTH),
		.MEMFILE({FILES_PATH, "score.mem"}))
	Score(
		.clk(clk),
		.addr(scoretextAddr),
		.dataOut(scoretextData),
		.wEn(1'b0));
	
	// Square Time	
	localparam square_size1 = 10;
	localparam square_size2 = 30;
	
	reg[9:0] corner_x1;
	wire[9:0] left_border1, right_border1;
	reg[8:0] corner_y1;
	wire[8:0] top_border1, bottom_border1;
    
    reg[9:0] corner_x2;
	wire[9:0] left_border2, right_border2;
	reg[8:0] corner_y2;
	wire[8:0] top_border2, bottom_border2;
    
    reg[9:0] corner_x3;
	wire[9:0] left_border3, right_border3;
	reg[8:0] corner_y3;
	wire[8:0] top_border3, bottom_border3;
    
    reg[9:0] corner_x4;
	wire[9:0] left_border4, right_border4;
	reg[8:0] corner_y4;
	wire[8:0] top_border4, bottom_border4;
    
    reg[9:0] corner_x5;
	wire[9:0] left_border5, right_border5;
	reg[8:0] corner_y5;
	wire[8:0] top_border5, bottom_border5;
    
    reg[9:0] corner_x6;
	wire[9:0] left_border6, right_border6;
	reg[8:0] corner_y6;
	wire[8:0] top_border6, bottom_border6;
    
    reg[9:0] corner_x7;
	wire[9:0] left_border7, right_border7;
	reg[8:0] corner_y7;
	wire[8:0] top_border7, bottom_border7;
    
    reg[9:0] corner_x8;
	wire[9:0] left_border8, right_border8;
	reg[8:0] corner_y8;
	wire[8:0] top_border8, bottom_border8;

    reg[9:0] corner_x9;
	wire[9:0] left_border9, right_border9;
	reg[8:0] corner_y9;
	wire[8:0] top_border9, bottom_border9;
    
    reg[9:0] corner_x10;
	wire[9:0] left_border10, right_border10;
	reg[8:0] corner_y10;
	wire[8:0] top_border10, bottom_border10;
    
    reg[9:0] corner_x11;
	wire[9:0] left_border11, right_border11;
	reg[8:0] corner_y11;
	wire[8:0] top_border11, bottom_border11;
    
    reg[9:0] corner_x12;
	wire[9:0] left_border12, right_border12;
	reg[8:0] corner_y12;
	wire[8:0] top_border12, bottom_border12;
    
    reg[9:0] corner_x13;
	wire[9:0] left_border13, right_border13;
	reg[8:0] corner_y13;
	wire[8:0] top_border13, bottom_border13;
    
    reg[9:0] corner_x14;
	wire[9:0] left_border14, right_border14;
	reg[8:0] corner_y14;
	wire[8:0] top_border14, bottom_border14;
    
    reg[9:0] corner_x15;
	wire[9:0] left_border15, right_border15;
	reg[8:0] corner_y15;
	wire[8:0] top_border15, bottom_border15;
    
    reg[9:0] corner_x16;
	wire[9:0] left_border16, right_border16;
	reg[8:0] corner_y16;
	wire[8:0] top_border16, bottom_border16;

	reg[9:0] corner_x17;
 	wire[9:0] left_border17, right_border17;
 	reg[8:0] corner_y17;
 	wire[8:0] top_border17, bottom_border17;
    
	reg[9:0] corner_x18;
 	wire[9:0] left_border18, right_border18;
 	reg[8:0] corner_y18;
 	wire[8:0] top_border18, bottom_border18;
    
	reg[9:0] corner_x19;
 	wire[9:0] left_border19, right_border19;
 	reg[8:0] corner_y19;
 	wire[8:0] top_border19, bottom_border19;
	
	reg[9:0] corner_x20;
 	wire[9:0] left_border20, right_border20;
 	reg[8:0] corner_y20;
 	wire[8:0] top_border20, bottom_border20;
	
	reg[9:0] corner_x21;
 	wire[9:0] left_border21, right_border21;
 	reg[8:0] corner_y21;
 	wire[8:0] top_border21, bottom_border21;
    
	reg[9:0] corner_x22;
 	wire[9:0] left_border22, right_border22;
 	reg[8:0] corner_y22;
 	wire[8:0] top_border22, bottom_border22;
    
	reg[9:0] corner_x23;
 	wire[9:0] left_border23, right_border23;
 	reg[8:0] corner_y23;
 	wire[8:0] top_border23, bottom_border23;
	
	reg[9:0] corner_x24;
 	wire[9:0] left_border24, right_border24;
 	reg[8:0] corner_y24;
 	wire[8:0] top_border24, bottom_border24;
    
	reg[9:0] corner_x25;
 	wire[9:0] left_border25, right_border25;
 	reg[8:0] corner_y25;
 	wire[8:0] top_border25, bottom_border25;
    
	reg[9:0] corner_x26;
 	wire[9:0] left_border26, right_border26;
 	reg[8:0] corner_y26;
 	wire[8:0] top_border26, bottom_border26;
    
	reg[9:0] corner_x27;
 	wire[9:0] left_border27, right_border27;
 	reg[8:0] corner_y27;
 	wire[8:0] top_border27, bottom_border27;
    
	reg[9:0] corner_x28;
 	wire[9:0] left_border28, right_border28;
 	reg[8:0] corner_y28;
 	wire[8:0] top_border28, bottom_border28;
    
	reg[9:0] corner_x29;
 	wire[9:0] left_border29, right_border29;
 	reg[8:0] corner_y29;
 	wire[8:0] top_border29, bottom_border29;
    
	reg[9:0] corner_x30;
 	wire[9:0] left_border30, right_border30;
 	reg[8:0] corner_y30;
 	wire[8:0] top_border30, bottom_border30;
    
	reg[9:0] corner_x31;
 	wire[9:0] left_border31, right_border31;
 	reg[8:0] corner_y31;
 	wire[8:0] top_border31, bottom_border31;
    
	reg[9:0] corner_x32;
 	wire[9:0] left_border32, right_border32;
 	reg[8:0] corner_y32;
 	wire[8:0] top_border32, bottom_border32;
	
	reg [24:0] counter_8Hz, counter_16Hz;
    reg clk8Hz, clk16Hz;
    initial begin
        counter_8Hz = 0;
        clk8Hz = 0;
		counter_16Hz = 0;
		clk16Hz = 0;
    end
    always @(posedge clk) begin
        if (counter_8Hz == 0) begin
            counter_8Hz <= 3124999;
            clk8Hz <= ~clk8Hz;
        end else begin
            counter_8Hz <= counter_8Hz -1;
        end
    end
	always @(posedge clk) begin
		if (counter_16Hz == 0) begin
			counter_16Hz <= 1562499;
			clk16Hz <= ~clk16Hz;
		end else begin
			counter_16Hz <= counter_16Hz - 1;
		end
	end
    
    reg clk_square;
	reg[4:0] square_size;
	always @(posedge clk) begin
		if(score > 9) begin
			clk_square = clk16Hz;
			square_size = square_size2;
		end else begin
			clk_square = clk8Hz;
			square_size = square_size1;
		end
	end
	
	reg completed = 0;
	reg[4:0] square_counter = 0;
    always @(posedge clk_square) begin
        if(game_on) begin
			square_counter <= square_counter + 1;
			if(square_counter == 5'b10100) begin
				completed <= completed + 1;
			end else begin
				completed <= 0;
			end
		end else begin
			square_counter <= 0;
		end
    end
	
	always @(posedge clk or posedge reset)
		if(reset) begin
			// Start Text Location
			starttext_corner_x = 10'd100;
			starttext_corner_y = 9'd200;
			// Names Text Location
			nametext_corner_x = 10'd137;
			nametext_corner_y = 9'd430;
			// Game Over Text Location
			gameovertext_corner_x = 10'd95;
			gameovertext_corner_y = 9'd400;
			// Score Text Location
			scoretext_corner_x = 10'd265;
			scoretext_corner_y = 9'd270;
			// Title Screen Location
			jjtext_corner_x = 10'd20;
			jjtext_corner_y = 9'd25;
			// Score Location
			score0_corner_x = 10'd340;
			score0_corner_y = 9'd300;
			score1_corner_x = 10'd315;
			score1_corner_y = 9'd300;
			score2_corner_x = 10'd290;
			score2_corner_y = 9'd300;
			score3_corner_x = 10'd265;
			score3_corner_y = 9'd300;
		    // Person Sprite Location
			person_corner_x = sprite_x;
		    person_corner_y = sprite_y;
			// Location of the 32 "LEDs"
			corner_x1 = 10'd315;
			corner_y1 = 9'd50;
			corner_x2 = 10'd354;
			corner_y2 = 9'd54;
			corner_x3 = 10'd396;
			corner_y3 = 9'd65;
			corner_x4 = 10'd426;
			corner_y4 = 9'd84;
			corner_x5 = 10'd456;
			corner_y5 = 9'd109;
			corner_x6 = 10'd481;
			corner_y6 = 9'd139;
			corner_x7 = 10'd500;
			corner_y7 = 9'd173;
			corner_x8 = 10'd511;
			corner_y8 = 9'd211;
			corner_x9 = 10'd515;
			corner_y9 = 9'd250;
			corner_x10 = 10'd511;
			corner_y10 = 9'd289;
			corner_x11 = 10'd500;
			corner_y11 = 9'd327;
			corner_x12 = 10'd481;
			corner_y12 = 9'd361;
			corner_x13 = 10'd456;
			corner_y13 = 9'd391;
			corner_x14 = 10'd426;
			corner_y14 = 9'd416;
			corner_x15 = 10'd396;
			corner_y15 = 9'd435;
			corner_x16 = 10'd354;
			corner_y16 = 9'd435;
			corner_x17 = 10'd315;
			corner_y17 = 9'd435;
			corner_x18 = 10'd276;
			corner_y18 = 9'd435;
			corner_x19 = 10'd238;
			corner_y19 = 9'd435;
			corner_x20 = 10'd204;
			corner_y20 = 9'd416;
			corner_x21 = 10'd174;
			corner_y21 = 9'd391;
			corner_x22 = 10'd149;
			corner_y22 = 9'd361;
			corner_x23 = 10'd130;
			corner_y23 = 9'd327;
			corner_x24 = 10'd119;
			corner_y24 = 9'd289;
			corner_x25 = 10'd115;
			corner_y25 = 9'd250;
			corner_x26 = 10'd119;
			corner_y26 = 9'd211;
			corner_x27 = 10'd130;
			corner_y27 = 9'd173;
			corner_x28 = 10'd149;
			corner_y28 = 9'd139;
			corner_x29 = 10'd174;
			corner_y29 = 9'd109;
			corner_x30 = 10'd204;
			corner_y30 = 9'd84;
			corner_x31 = 10'd238;
			corner_y31 = 9'd65;
			corner_x32 = 10'd276;
			corner_y32 = 9'd54;
		end
		else begin
			// Start Text Location
			starttext_corner_x = 10'd100;
			starttext_corner_y = 9'd200;
			// Names Text Location
			nametext_corner_x = 10'd137;
			nametext_corner_y = 9'd430;
			// Game Over Text Location
			gameovertext_corner_x = 10'd95;
			gameovertext_corner_y = 9'd400;
			// Score Text Location
			scoretext_corner_x = 10'd265;
			scoretext_corner_y = 9'd270;
			// Title Screen Location
			jjtext_corner_x = 10'd20;
			jjtext_corner_y = 9'd25;
			// Score Location
			score0_corner_x = 10'd340;
			score0_corner_y = 9'd300;
			score1_corner_x = 10'd315;
			score1_corner_y = 9'd300;
			score2_corner_x = 10'd290;
			score2_corner_y = 9'd300;
			score3_corner_x = 10'd265;
			score3_corner_y = 9'd300;
		    // Person Sprite Location
			person_corner_x = sprite_x;
		    person_corner_y = sprite_y;
			// Location of the 32 "LEDs"
			corner_x1 = 10'd315;
			corner_y1 = 9'd50;
			corner_x2 = 10'd354;
			corner_y2 = 9'd54;
			corner_x3 = 10'd396;
			corner_y3 = 9'd65;
			corner_x4 = 10'd426;
			corner_y4 = 9'd84;
			corner_x5 = 10'd456;
			corner_y5 = 9'd109;
			corner_x6 = 10'd481;
			corner_y6 = 9'd139;
			corner_x7 = 10'd500;
			corner_y7 = 9'd173;
			corner_x8 = 10'd511;
			corner_y8 = 9'd211;
			corner_x9 = 10'd515;
			corner_y9 = 9'd250;
			corner_x10 = 10'd511;
			corner_y10 = 9'd289;
			corner_x11 = 10'd500;
			corner_y11 = 9'd327;
			corner_x12 = 10'd481;
			corner_y12 = 9'd361;
			corner_x13 = 10'd456;
			corner_y13 = 9'd391;
			corner_x14 = 10'd426;
			corner_y14 = 9'd416;
			corner_x15 = 10'd396;
			corner_y15 = 9'd435;
			corner_x16 = 10'd354;
			corner_y16 = 9'd435;
			corner_x17 = 10'd315;
			corner_y17 = 9'd435;
			corner_x18 = 10'd276;
			corner_y18 = 9'd435;
			corner_x19 = 10'd238;
			corner_y19 = 9'd435;
			corner_x20 = 10'd204;
			corner_y20 = 9'd416;
			corner_x21 = 10'd174;
			corner_y21 = 9'd391;
			corner_x22 = 10'd149;
			corner_y22 = 9'd361;
			corner_x23 = 10'd130;
			corner_y23 = 9'd327;
			corner_x24 = 10'd119;
			corner_y24 = 9'd289;
			corner_x25 = 10'd115;
			corner_y25 = 9'd250;
			corner_x26 = 10'd119;
			corner_y26 = 9'd211;
			corner_x27 = 10'd130;
			corner_y27 = 9'd173;
			corner_x28 = 10'd149;
			corner_y28 = 9'd139;
			corner_x29 = 10'd174;
			corner_y29 = 9'd109;
			corner_x30 = 10'd204;
			corner_y30 = 9'd84;
			corner_x31 = 10'd238;
			corner_y31 = 9'd65;
			corner_x32 = 10'd276;
			corner_y32 = 9'd54;
		end
	
	// Finding the Borders for each of the LEDs
	assign left_border1 = corner_x1;
	assign right_border1 = corner_x1 + square_size;
	assign top_border1 = corner_y1;
	assign bottom_border1 = corner_y1 + square_size;
    
    assign left_border2 = corner_x2;
	assign right_border2 = corner_x2 + square_size;
	assign top_border2 = corner_y2;
	assign bottom_border2 = corner_y2 + square_size;
    
    assign left_border3 = corner_x3;
	assign right_border3 = corner_x3 + square_size;
	assign top_border3 = corner_y3;
	assign bottom_border3 = corner_y3 + square_size;
    
    assign left_border4 = corner_x4;
	assign right_border4 = corner_x4 + square_size;
	assign top_border4 = corner_y4;
	assign bottom_border4 = corner_y4 + square_size;
    
    assign left_border5 = corner_x5;
	assign right_border5 = corner_x5 + square_size;
	assign top_border5 = corner_y5;
	assign bottom_border5 = corner_y5 + square_size;
    
    assign left_border6 = corner_x6;
	assign right_border6 = corner_x6 + square_size;
	assign top_border6 = corner_y6;
	assign bottom_border6 = corner_y6 + square_size;
    
    assign left_border7 = corner_x7;
	assign right_border7 = corner_x7 + square_size;
	assign top_border7 = corner_y7;
	assign bottom_border7 = corner_y7 + square_size;
    
    assign left_border8 = corner_x8;
	assign right_border8 = corner_x8 + square_size;
	assign top_border8 = corner_y8;
	assign bottom_border8 = corner_y8 + square_size;
    
    assign left_border9 = corner_x9;
	assign right_border9 = corner_x9 + square_size;
	assign top_border9 = corner_y9;
	assign bottom_border9 = corner_y9 + square_size;
    
    assign left_border10 = corner_x10;
	assign right_border10 = corner_x10 + square_size;
	assign top_border10 = corner_y10;
	assign bottom_border10 = corner_y10 + square_size;
    
    assign left_border11 = corner_x11;
	assign right_border11 = corner_x11 + square_size;
	assign top_border11 = corner_y11;
	assign bottom_border11 = corner_y11 + square_size;
    
    assign left_border12 = corner_x12;
	assign right_border12 = corner_x12 + square_size;
	assign top_border12 = corner_y12;
	assign bottom_border12 = corner_y12 + square_size;
    
    assign left_border13 = corner_x13;
	assign right_border13 = corner_x13 + square_size;
	assign top_border13 = corner_y13;
	assign bottom_border13 = corner_y13 + square_size;
    
    assign left_border14 = corner_x14;
	assign right_border14 = corner_x14 + square_size;
	assign top_border14 = corner_y14;
	assign bottom_border14 = corner_y14 + square_size;
    
    assign left_border15 = corner_x15;
	assign right_border15 = corner_x15 + square_size;
	assign top_border15 = corner_y15;
	assign bottom_border15 = corner_y15 + square_size;
    
    assign left_border16 = corner_x16;
	assign right_border16 = corner_x16 + square_size;
	assign top_border16 = corner_y16;
	assign bottom_border16 = corner_y16 + square_size;

	assign left_border17 = corner_x17;
 	assign right_border17 = corner_x17 + square_size;
 	assign top_border17 = corner_y17;
 	assign bottom_border17 = corner_y17 + square_size;
    
	assign left_border18 = corner_x18;
 	assign right_border18 = corner_x18 + square_size;
 	assign top_border18 = corner_y18;
 	assign bottom_border18 = corner_y18 + square_size;
    
	assign left_border19 = corner_x19;
 	assign right_border19 = corner_x19 + square_size;
 	assign top_border19 = corner_y19;
 	assign bottom_border19 = corner_y19 + square_size;
    
	assign left_border20 = corner_x20;
 	assign right_border20 = corner_x20 + square_size;
 	assign top_border20 = corner_y20;
 	assign bottom_border20 = corner_y20 + square_size;
    
	assign left_border21 = corner_x21;
 	assign right_border21 = corner_x21 + square_size;
 	assign top_border21 = corner_y21;
 	assign bottom_border21 = corner_y21 + square_size;
    
	assign left_border22 = corner_x22;
 	assign right_border22 = corner_x22 + square_size;
 	assign top_border22 = corner_y22;
 	assign bottom_border22 = corner_y22 + square_size;
    
	assign left_border23 = corner_x23;
 	assign right_border23 = corner_x23 + square_size;
 	assign top_border23 = corner_y23;
 	assign bottom_border23 = corner_y23 + square_size;
    
	assign left_border24 = corner_x24;
 	assign right_border24 = corner_x24 + square_size;
 	assign top_border24 = corner_y24;
 	assign bottom_border24 = corner_y24 + square_size;
    
	assign left_border25 = corner_x25;
 	assign right_border25 = corner_x25 + square_size;
 	assign top_border25 = corner_y25;
 	assign bottom_border25 = corner_y25 + square_size;
    
	assign left_border26 = corner_x26;
 	assign right_border26 = corner_x26 + square_size;
 	assign top_border26 = corner_y26;
 	assign bottom_border26 = corner_y26 + square_size;
    
	assign left_border27 = corner_x27;
 	assign right_border27 = corner_x27 + square_size;
 	assign top_border27 = corner_y27;
 	assign bottom_border27 = corner_y27 + square_size;
    
	assign left_border28 = corner_x28;
 	assign right_border28 = corner_x28 + square_size;
 	assign top_border28 = corner_y28;
 	assign bottom_border28 = corner_y28 + square_size;
    
	assign left_border29 = corner_x29;
 	assign right_border29 = corner_x29 + square_size;
 	assign top_border29 = corner_y29;
 	assign bottom_border29 = corner_y29 + square_size;
    
	assign left_border30 = corner_x30;
 	assign right_border30 = corner_x30 + square_size;
 	assign top_border30 = corner_y30;
 	assign bottom_border30 = corner_y30 + square_size;
    
	assign left_border31 = corner_x31;
 	assign right_border31 = corner_x31 + square_size;
 	assign top_border31 = corner_y31;
 	assign bottom_border31 = corner_y31 + square_size;
    
	assign left_border32 = corner_x32;
 	assign right_border32 = corner_x32 + square_size;
 	assign top_border32 = corner_y32;
 	assign bottom_border32 = corner_y32 + square_size;
	
	// Finding the Borders of the Texts for the game
	wire in_jjtext;
	assign in_jjtext = (jjtext_corner_x <= x) && (x <= (jjtext_corner_x + 600)) && (jjtext_corner_y <= y) && (y <= (jjtext_corner_y + 50));
	
	wire in_starttext;
	assign in_starttext = (starttext_corner_x <= x) && (x <= (starttext_corner_x + 440)) && (starttext_corner_y <= y) && (y <= (starttext_corner_y + 35));

	wire in_names;
	assign in_names = (nametext_corner_x <= x) && (x <= (nametext_corner_x + 365)) && (nametext_corner_y <= y) && (y <= (nametext_corner_y + 25));

	wire in_gameover;
	assign in_gameover = (gameovertext_corner_x <= x) && (x <= (gameovertext_corner_x + 450)) && (gameovertext_corner_y <= y) && (y <= (gameovertext_corner_y + 60));
	
	wire in_score;
	assign in_score = (scoretext_corner_x <= x) && (x <= (scoretext_corner_x + 110)) && (scoretext_corner_y <= y) && (y <= (scoretext_corner_y + 25));

	wire in_person;
	assign in_person = (person_corner_x <= x) && (x <= (person_corner_x + 30)) && (person_corner_y <= y) && (y <= (person_corner_y + 60));
	
	wire in_score0, in_score1, in_score2, in_score3;
	assign in_score0 = (score0_corner_x <= x) && (x <= (score0_corner_x + 25)) && (score0_corner_y <= y) && (y <= (score0_corner_y + 25));
	assign in_score1 = (score1_corner_x <= x) && (x <= (score1_corner_x + 25)) && (score1_corner_y <= y) && (y <= (score1_corner_y + 25));
	assign in_score2 = (score2_corner_x <= x) && (x <= (score2_corner_x + 25)) && (score2_corner_y <= y) && (y <= (score2_corner_y + 25));
	assign in_score3 = (score3_corner_x <= x) && (x <= (score3_corner_x + 25)) && (score3_corner_y <= y) && (y <= (score3_corner_y + 25));

	// Determination of which LED to turn on
	wire in_square_FINAL;
	wire in_square1, in_square2, in_square3, in_square4, in_square5, in_square6, in_square7, in_square8, in_square9, in_square10, in_square11, in_square12, in_square13, in_square14, in_square15, in_square16;
	assign in_square1 = (left_border1 <= x) && (x <= right_border1) && (top_border1 <= y) && (y <= bottom_border1);
    assign in_square2 = (left_border2 <= x) && (x <= right_border2) && (top_border2 <= y) && (y <= bottom_border2);
    assign in_square3 = (left_border3 <= x) && (x <= right_border3) && (top_border3 <= y) && (y <= bottom_border3);
    assign in_square4 = (left_border4 <= x) && (x <= right_border4) && (top_border4 <= y) && (y <= bottom_border4);
    assign in_square5 = (left_border5 <= x) && (x <= right_border5) && (top_border5 <= y) && (y <= bottom_border5);
    assign in_square6 = (left_border6 <= x) && (x <= right_border6) && (top_border6 <= y) && (y <= bottom_border6);
    assign in_square7 = (left_border7 <= x) && (x <= right_border7) && (top_border7 <= y) && (y <= bottom_border7);
    assign in_square8 = (left_border8 <= x) && (x <= right_border8) && (top_border8 <= y) && (y <= bottom_border8);
    assign in_square9 = (left_border9 <= x) && (x <= right_border9) && (top_border9 <= y) && (y <= bottom_border9);
    assign in_square10 = (left_border10 <= x) && (x <= right_border10) && (top_border10 <= y) && (y <= bottom_border10);
    assign in_square11 = (left_border11 <= x) && (x <= right_border11) && (top_border11 <= y) && (y <= bottom_border11);
    assign in_square12 = (left_border12 <= x) && (x <= right_border12) && (top_border12 <= y) && (y <= bottom_border12);
    assign in_square13 = (left_border13 <= x) && (x <= right_border13) && (top_border13 <= y) && (y <= bottom_border13);
    assign in_square14 = (left_border14 <= x) && (x <= right_border14) && (top_border14 <= y) && (y <= bottom_border14);
    assign in_square15 = (left_border15 <= x) && (x <= right_border15) && (top_border15 <= y) && (y <= bottom_border15);
    assign in_square16 = (left_border16 <= x) && (x <= right_border16) && (top_border16 <= y) && (y <= bottom_border16);
	assign in_square17 = (left_border17 <= x) && (x <= right_border17) && (top_border17 <= y) && (y <= bottom_border17);
	assign in_square18 = (left_border18 <= x) && (x <= right_border18) && (top_border18 <= y) && (y <= bottom_border18);
	assign in_square19 = (left_border19 <= x) && (x <= right_border19) && (top_border19 <= y) && (y <= bottom_border19);
	assign in_square20 = (left_border20 <= x) && (x <= right_border20) && (top_border20 <= y) && (y <= bottom_border20);
	assign in_square21 = (left_border21 <= x) && (x <= right_border21) && (top_border21 <= y) && (y <= bottom_border21);
	assign in_square22 = (left_border22 <= x) && (x <= right_border22) && (top_border22 <= y) && (y <= bottom_border22);
	assign in_square23 = (left_border23 <= x) && (x <= right_border23) && (top_border23 <= y) && (y <= bottom_border23);
	assign in_square24 = (left_border24 <= x) && (x <= right_border24) && (top_border24 <= y) && (y <= bottom_border24);
	assign in_square25 = (left_border25 <= x) && (x <= right_border25) && (top_border25 <= y) && (y <= bottom_border25);
	assign in_square26 = (left_border26 <= x) && (x <= right_border26) && (top_border26 <= y) && (y <= bottom_border26);
	assign in_square27 = (left_border27 <= x) && (x <= right_border27) && (top_border27 <= y) && (y <= bottom_border27);
	assign in_square28 = (left_border28 <= x) && (x <= right_border28) && (top_border28 <= y) && (y <= bottom_border28);
	assign in_square29 = (left_border29 <= x) && (x <= right_border29) && (top_border29 <= y) && (y <= bottom_border29);
	assign in_square30 = (left_border30 <= x) && (x <= right_border30) && (top_border30 <= y) && (y <= bottom_border30);
	assign in_square31 = (left_border31 <= x) && (x <= right_border31) && (top_border31 <= y) && (y <= bottom_border31);
	assign in_square32 = (left_border32 <= x) && (x <= right_border32) && (top_border32 <= y) && (y <= bottom_border32);
	
	mux_32 square_on(in_square_FINAL, square_counter, in_square1, in_square2, in_square3, in_square4, in_square5, in_square6, in_square7, in_square8, in_square9, in_square10, in_square11, in_square12, in_square13, in_square14, in_square15, in_square16,
						in_square17, in_square18, in_square19, in_square20, in_square21, in_square22, in_square23, in_square24, in_square25, in_square26, in_square27, in_square28, in_square29, in_square30, in_square31, in_square32);
	
	reg[11:0] counter;
	always @(posedge screenEnd) begin
		if(in_square_FINAL) begin
			counter = counter + 1;
        end
        if(counter==2500) begin
            counter = 0;
        end
    end
	
	// Determination of which color to show
	wire[BITS_PER_COLOR-1:0] lightColor, squareColor, scoreColor, jjtextColor, starttextColor, gameoverColor;
	assign scoreColor = ((in_score & ~scoretextData) | (in_score0 & ~score0data) | (in_score1 & ~score1data) | (in_score2 & ~score2data) | (in_score3 & ~score3data)) ? 12'h0FF : colorData_background;
	assign lightColor = in_square_FINAL ? 12'hFF0 : scoreColor;
	assign squareColor = (in_person & ~personData) ? 12'hF0F : lightColor;
	
	// Assign to output color from register if active
	wire[BITS_PER_COLOR-1:0] colorOut, startScreen; 			  // Output color 
	assign gameoverColor = (in_gameover & ~gameovertextData) ? 12'hF00 : scoreColor;
	assign colorOut = (active & ~game_over) ? squareColor : gameoverColor;
	assign jjtextColor = (~jjtextData & in_jjtext) ? 12'hF00 : colorData_background;
	assign starttextColor = ((~starttextData & in_starttext) | (~nametextData & in_names)) ? 12'hFFF : jjtextColor;
    assign startScreen = ~game_on ? starttextColor : colorOut;

	// Quickly assign the output colors to their channels using concatenation
	assign {VGA_R, VGA_G, VGA_B} = startScreen;
	
	// Game On Detection
	wire game_on;
	dffe_ref STARTGAME(game_on, BTNR, clk, ~game_on, reset);
	// Collision Detection
	wire game_over;
	dffe_ref COLLISION(game_over, (in_square_FINAL & in_person), clk, ~game_over, reset);

endmodule