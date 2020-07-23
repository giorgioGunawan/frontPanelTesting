onerror {resume}

divider add "Toplevel"
wave add /DES_TEST/clk1
wave add /DES_TEST/hi_in(0)

divider add "Pipe Data"
wave add -radix hex /DES_TEST/pipeIn
wave add -radix hex /DES_TEST/pipeOut
wave add -radix hex /DES_TEST/pipetmp

divider add "Wire/Trigger Data"
wave add -radix hex /DES_TEST/WireIns
wave add -radix hex /DES_TEST/WireOuts
wave add -radix hex /DES_TEST/Triggered

run 250us;
