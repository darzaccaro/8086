#import "Basic";
#import "File";
#import "Hash_Table";

// byte 1 bitmasks
OPCODE_MASK :: 0b11111100;
D_MASK      :: 0b00000010;
W_MASK      :: 0b00000001;
// byte 2 bitmasks
MOD_MASK    :: 0b11000000;
REG_MASK    :: 0b00111000;
RM_MASK     :: 0b00000111;

decode_file_to_string :: (path: string) -> string {
	data, success := read_entire_file(path);
	assert(success);
	builder: String_Builder;
    init_string_builder(*builder);
    print_to_builder(*builder, "; disassembling %\n\nbits 16\n\n", path);

    p:*u8 = data.data;
    end := p + data.count;

    while p < end {
    	byte1 := <<p;
    	p += 1;
    	op, op_string := get_opcode(byte1);
    	if is_2_byte_op(op_string) {
    		byte2 := <<p;
    		p += 1;
    		// assert(mod == 0b00000011); // only supporting register to register moves for now
	    	if (op_string == "mov") {
		    	if success {
		    		source, source_string := get_register(byte1, byte2, true);
		    		destination, destination_string := get_register(byte1, byte2, false);
		    		print_to_builder(*builder, "% %, %\n", op_string, destination_string, source_string);
		    	}
		    }
		}
    }
    return builder_to_string(*builder);
}

#if !TESTING
main :: () {
	args := get_command_line_arguments();
	if args.count < 2 {
		print("usage: decoder.exe path/to/binary/input");
		return;
	}

	output := decode_file_to_string(args[1]);
	
    write_entire_file("out/decoded.asm", output);
}

get_opcode :: (byte1: u8) -> u8, string {
	op := byte1 & OPCODE_MASK;
	if op == {
		case 0b10001000; return op, "mov";
		case; assert(false);
	}
}

get_register :: (byte1: u8, byte2: u8, is_source: bool) -> u8, string {
	// TODO probably need to consider MOD when not doing register to register
	register: u8;
	if (byte1 & D_MASK > 0) {
		if is_source {
			register = byte2 & RM_MASK;
		} else {
			register = byte2 & REG_MASK;
			register >>= 3;
		}
	} else {
		if is_source {
			register = byte2 & REG_MASK;
			register >>= 3;
		} else {
			register = byte2 & RM_MASK;
		}
	}
	if byte1 & W_MASK > 0 {
		if register == {
			case 0b00000000; return register, "ax";
			case 0b00000001; return register, "cx";
			case 0b00000010; return register, "dx";
			case 0b00000011; return register, "bx";
			case 0b00000100; return register, "sp";
			case 0b00000101; return register, "bp";
			case 0b00000110; return register, "si";
			case 0b00000111; return register, "di";
		}

	} else {
		if register == {
			case 0b00000000; return register, "al";
			case 0b00000001; return register, "cl";
			case 0b00000010; return register, "dl";
			case 0b00000011; return register, "bl";
			case 0b00000100; return register, "ah";
			case 0b00000101; return register, "ch";
			case 0b00000110; return register, "dh";
			case 0b00000111; return register, "bh";
		}
	}
}

is_2_byte_op :: (op: string) -> bool {
	if op == "mov" {
		return true;
	}
	print("unsupported opcode");
	return false;
}
