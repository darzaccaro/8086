#import "Basic";
#import "File";
#import "String";

TESTING :: true;

#load "src/decoder.jai";

main :: () {
	print("running tests...");
	test_decode_register_to_register_move_single();
	print("passed!");
}

test_decode_register_to_register_move_single :: () {
	reference, success := read_entire_file("test-data/listing_0037_single_register_mov.asm");
	assert(success);
	ref := sanitize_asm_string(reference);

	output := decode_file_to_string("test-data/listing_0037_single_register_mov");
	out := sanitize_asm_string(output);
	assert(ref == out);
}

test_decode_register_to_register_move_many :: () {
	reference, success := read_entire_file("test-data/listing_0038_many_register_mov.asm");
	assert(success);
	ref := sanitize_asm_string(reference);

	output := decode_file_to_string("test-data/listing_0038_many_register_mov");
	out := sanitize_asm_string(output);
	assert(ref == out);
}

sanitize_asm_string :: (asm: string) -> string{
	normalized := normalize_line_endings(trim(asm));
	lines := split(asm, "\n");
	builder: String_Builder;
	init_string_builder(*builder);
	for lines {
		line := trim(it, " \t\r\n");
		if line.count < 1 continue;
		if line[0] == #char ";"{
			continue;
		}
		append(*builder, line);
		append(*builder, "\n");
	}
	str := builder_to_string(*builder);
	reset(*builder);
	return str;
}

#run main();