TESTING :: false;
#load "src/decoder.jai";

#run  { 
    Compiler :: #import "Compiler";
    Compiler.set_build_options_dc( .{ output_path = "out", output_executable_name = "decoder" } );
}