module regfile(clock, ctrl_writeEnable, ctrl_reset, ctrl_writeReg, 
	ctrl_readRegA, ctrl_readRegB, data_writeReg, data_readRegA, data_readRegB, r1, r2, r3, r4);

	input clock, ctrl_writeEnable, ctrl_reset;
	input [4:0] ctrl_writeReg, ctrl_readRegA, ctrl_readRegB;
	input [31:0] data_writeReg;
	//input jump_completed;

	output [31:0] data_readRegA, data_readRegB, r1, r2, r3, r4;

	wire [31:0] write_enables, decode_write, reg_o0, reg_o1, reg_o2, reg_o3, reg_o4, reg_o5, reg_o6, reg_o7, reg_o8, reg_o9, reg_o10, reg_o11, reg_o12, reg_o13, reg_o14, reg_o15, reg_o16, reg_o17, reg_o18, reg_o19, reg_o20, reg_o21, reg_o22, reg_o23, reg_o24, reg_o25, reg_o26, reg_o27, reg_o28, reg_o29, reg_o30, reg_o31;

	// module decoder32(out, select, enable);
	// decoder32 get_write_enables(write_enables, ctrl_writeReg, ctrl_writeEnable);
	decoder32 get_write_enables(decode_write, ctrl_writeReg, 1'b1);

	and we0(write_enables[0], decode_write[0], ctrl_writeEnable);
	and we1(write_enables[1], decode_write[1], ctrl_writeEnable);
	and we2(write_enables[2], decode_write[2], ctrl_writeEnable);
	and we3(write_enables[3], decode_write[3], ctrl_writeEnable);
	and we4(write_enables[4], decode_write[4], ctrl_writeEnable);
	and we5(write_enables[5], decode_write[5], ctrl_writeEnable);
	and we6(write_enables[6], decode_write[6], ctrl_writeEnable);
	and we7(write_enables[7], decode_write[7], ctrl_writeEnable);
	and we8(write_enables[8], decode_write[8], ctrl_writeEnable);
	and we9(write_enables[9], decode_write[9], ctrl_writeEnable);
	and we10(write_enables[10], decode_write[10], ctrl_writeEnable);
	and we11(write_enables[11], decode_write[11], ctrl_writeEnable);
	and we12(write_enables[12], decode_write[12], ctrl_writeEnable);
	and we13(write_enables[13], decode_write[13], ctrl_writeEnable);
	and we14(write_enables[14], decode_write[14], ctrl_writeEnable);
	and we15(write_enables[15], decode_write[15], ctrl_writeEnable);
	and we16(write_enables[16], decode_write[16], ctrl_writeEnable);
	and we17(write_enables[17], decode_write[17], ctrl_writeEnable);
	and we18(write_enables[18], decode_write[18], ctrl_writeEnable);
	and we19(write_enables[19], decode_write[19], ctrl_writeEnable);
	and we20(write_enables[20], decode_write[20], ctrl_writeEnable);
	and we21(write_enables[21], decode_write[21], ctrl_writeEnable);
	and we22(write_enables[22], decode_write[22], ctrl_writeEnable);
	and we23(write_enables[23], decode_write[23], ctrl_writeEnable);
	and we24(write_enables[24], decode_write[24], ctrl_writeEnable);
	and we25(write_enables[25], decode_write[25], ctrl_writeEnable);
	and we26(write_enables[26], decode_write[26], ctrl_writeEnable);
	and we27(write_enables[27], decode_write[27], ctrl_writeEnable);
	and we28(write_enables[28], decode_write[28], ctrl_writeEnable);
	and we29(write_enables[29], decode_write[29], ctrl_writeEnable);
	and we30(write_enables[30], decode_write[30], ctrl_writeEnable);
	and we31(write_enables[31], decode_write[31], ctrl_writeEnable);

	//wire[31:0] write_jump;
	//assign write_jump = jump_completed ? {31'b0, jump_completed} : data_writeReg;
	
	// reg(out, in, clock, input_enable, ctrl_reset);
	register reg0(reg_o0, data_writeReg, clock, 1'b0, ctrl_reset);
	register reg1(reg_o1, data_writeReg, clock, write_enables[1], ctrl_reset);
	register reg2(reg_o2, data_writeReg, clock, write_enables[2], ctrl_reset);
	register reg3(reg_o3, data_writeReg, clock, write_enables[3], ctrl_reset);
	register reg4(reg_o4, data_writeReg, clock, write_enables[4], ctrl_reset);
	register reg5(reg_o5, data_writeReg, clock, write_enables[5], ctrl_reset);
	register reg6(reg_o6, data_writeReg, clock, write_enables[6], ctrl_reset);
	register reg7(reg_o7, data_writeReg, clock, write_enables[7], ctrl_reset);
	register reg8(reg_o8, data_writeReg, clock, write_enables[8], ctrl_reset);
	register reg9(reg_o9, data_writeReg, clock, write_enables[9], ctrl_reset);
	register reg10(reg_o10, data_writeReg, clock, write_enables[10], ctrl_reset);
	register reg11(reg_o11, data_writeReg, clock, write_enables[11], ctrl_reset);
	register reg12(reg_o12, data_writeReg, clock, write_enables[12], ctrl_reset);
	register reg13(reg_o13, data_writeReg, clock, write_enables[13], ctrl_reset);
	register reg14(reg_o14, data_writeReg, clock, write_enables[14], ctrl_reset);
	register reg15(reg_o15, data_writeReg, clock, write_enables[15], ctrl_reset);
	register reg16(reg_o16, data_writeReg, clock, write_enables[16], ctrl_reset);
	register reg17(reg_o17, data_writeReg, clock, write_enables[17], ctrl_reset);
	register reg18(reg_o18, data_writeReg, clock, write_enables[18], ctrl_reset);
	register reg19(reg_o19, data_writeReg, clock, write_enables[19], ctrl_reset);
	register reg20(reg_o20, data_writeReg, clock, write_enables[20], ctrl_reset);
	register reg21(reg_o21, data_writeReg, clock, write_enables[21], ctrl_reset);
	register reg22(reg_o22, data_writeReg, clock, write_enables[22], ctrl_reset);
	register reg23(reg_o23, data_writeReg, clock, write_enables[23], ctrl_reset);
	register reg24(reg_o24, data_writeReg, clock, write_enables[24], ctrl_reset);
	register reg25(reg_o25, data_writeReg, clock, write_enables[25], ctrl_reset);
	register reg26(reg_o26, data_writeReg, clock, write_enables[26], ctrl_reset);
	register reg27(reg_o27, data_writeReg, clock, write_enables[27], ctrl_reset);
	register reg28(reg_o28, data_writeReg, clock, write_enables[28], ctrl_reset);
	register reg29(reg_o29, data_writeReg, clock, write_enables[29], ctrl_reset);
	register reg30(reg_o30, data_writeReg, clock, write_enables[30], ctrl_reset);
	register reg31(reg_o31, data_writeReg, clock, write_enables[31], ctrl_reset);
	
	wire [31:0] rs1, rs2;
	decoder32 rs1_read(rs1, ctrl_readRegA, 1'b1);
	decoder32 rs2_read(rs2, ctrl_readRegB, 1'b1);

	// module tri(out, in, oe);
	my_tri rs1_tri0(data_readRegA, reg_o0, rs1[0]);
	my_tri rs1_tri1(data_readRegA, reg_o1, rs1[1]);
	my_tri rs1_tri2(data_readRegA, reg_o2, rs1[2]);
	my_tri rs1_tri3(data_readRegA, reg_o3, rs1[3]);
	my_tri rs1_tri4(data_readRegA, reg_o4, rs1[4]);
	my_tri rs1_tri5(data_readRegA, reg_o5, rs1[5]);
	my_tri rs1_tri6(data_readRegA, reg_o6, rs1[6]);
	my_tri rs1_tri7(data_readRegA, reg_o7, rs1[7]);
	my_tri rs1_tri8(data_readRegA, reg_o8, rs1[8]);
	my_tri rs1_tri9(data_readRegA, reg_o9, rs1[9]);
	my_tri rs1_tri10(data_readRegA, reg_o10, rs1[10]);
	my_tri rs1_tri11(data_readRegA, reg_o11, rs1[11]);
	my_tri rs1_tri12(data_readRegA, reg_o12, rs1[12]);
	my_tri rs1_tri13(data_readRegA, reg_o13, rs1[13]);
	my_tri rs1_tri14(data_readRegA, reg_o14, rs1[14]);
	my_tri rs1_tri15(data_readRegA, reg_o15, rs1[15]);
	my_tri rs1_tri16(data_readRegA, reg_o16, rs1[16]);
	my_tri rs1_tri17(data_readRegA, reg_o17, rs1[17]);
	my_tri rs1_tri18(data_readRegA, reg_o18, rs1[18]);
	my_tri rs1_tri19(data_readRegA, reg_o19, rs1[19]);
	my_tri rs1_tri20(data_readRegA, reg_o20, rs1[20]);
	my_tri rs1_tri21(data_readRegA, reg_o21, rs1[21]);
	my_tri rs1_tri22(data_readRegA, reg_o22, rs1[22]);
	my_tri rs1_tri23(data_readRegA, reg_o23, rs1[23]);
	my_tri rs1_tri24(data_readRegA, reg_o24, rs1[24]);
	my_tri rs1_tri25(data_readRegA, reg_o25, rs1[25]);
	my_tri rs1_tri26(data_readRegA, reg_o26, rs1[26]);
	my_tri rs1_tri27(data_readRegA, reg_o27, rs1[27]);
	my_tri rs1_tri28(data_readRegA, reg_o28, rs1[28]);
	my_tri rs1_tri29(data_readRegA, reg_o29, rs1[29]);
	my_tri rs1_tri30(data_readRegA, reg_o30, rs1[30]);
	my_tri rs1_tri31(data_readRegA, reg_o31, rs1[31]);

	my_tri rs2_tri0(data_readRegB, reg_o0, rs2[0]);
	my_tri rs2_tri1(data_readRegB, reg_o1, rs2[1]);
	my_tri rs2_tri2(data_readRegB, reg_o2, rs2[2]);
	my_tri rs2_tri3(data_readRegB, reg_o3, rs2[3]);
	my_tri rs2_tri4(data_readRegB, reg_o4, rs2[4]);
	my_tri rs2_tri5(data_readRegB, reg_o5, rs2[5]);
	my_tri rs2_tri6(data_readRegB, reg_o6, rs2[6]);
	my_tri rs2_tri7(data_readRegB, reg_o7, rs2[7]);
	my_tri rs2_tri8(data_readRegB, reg_o8, rs2[8]);
	my_tri rs2_tri9(data_readRegB, reg_o9, rs2[9]);
	my_tri rs2_tri10(data_readRegB, reg_o10, rs2[10]);
	my_tri rs2_tri11(data_readRegB, reg_o11, rs2[11]);
	my_tri rs2_tri12(data_readRegB, reg_o12, rs2[12]);
	my_tri rs2_tri13(data_readRegB, reg_o13, rs2[13]);
	my_tri rs2_tri14(data_readRegB, reg_o14, rs2[14]);
	my_tri rs2_tri15(data_readRegB, reg_o15, rs2[15]);
	my_tri rs2_tri16(data_readRegB, reg_o16, rs2[16]);
	my_tri rs2_tri17(data_readRegB, reg_o17, rs2[17]);
	my_tri rs2_tri18(data_readRegB, reg_o18, rs2[18]);
	my_tri rs2_tri19(data_readRegB, reg_o19, rs2[19]);
	my_tri rs2_tri20(data_readRegB, reg_o20, rs2[20]);
	my_tri rs2_tri21(data_readRegB, reg_o21, rs2[21]);
	my_tri rs2_tri22(data_readRegB, reg_o22, rs2[22]);
	my_tri rs2_tri23(data_readRegB, reg_o23, rs2[23]);
	my_tri rs2_tri24(data_readRegB, reg_o24, rs2[24]);
	my_tri rs2_tri25(data_readRegB, reg_o25, rs2[25]);
	my_tri rs2_tri26(data_readRegB, reg_o26, rs2[26]);
	my_tri rs2_tri27(data_readRegB, reg_o27, rs2[27]);
	my_tri rs2_tri28(data_readRegB, reg_o28, rs2[28]);
	my_tri rs2_tri29(data_readRegB, reg_o29, rs2[29]);
	my_tri rs2_tri30(data_readRegB, reg_o30, rs2[30]);
	my_tri rs2_tri31(data_readRegB, reg_o31, rs2[31]);

	assign r1 = reg_o1;
	assign r2 = reg_o2;
	assign r3 = reg_o3;
	assign r4 = reg_o4;

endmodule