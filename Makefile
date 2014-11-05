VARS_OLD := $(.VARIABLES)

# Also search tests for source files
VPATH := tests

###################################################################
### Setup
###################################################################

### Sources
SRCS = $(wildcard *.sv)  $(wildcard tests/*.sv) $(wildcard lib/*.v)

TESTS = hw_svm_test kernel_test

### Flags
VSIMFLAGS += #-L altera_mf_ver 

### Commands
VSIM = vsim
SIM = vsim $(VSIMFLAGS) -c -do "run -All"

###################################################################
### Compile
###################################################################
.DELETE_ON_ERROR:

all: compile
	
compile: $(SRCS) $(GENSRCS) | work
	vlog -sv -pedanticerrors $(SRCS) $(GENSRCS)

work:
	vlib work

TEMP_COMPILE = work/

###################################################################
### Simulate
###################################################################

tests: $(TESTS)

${TESTS}: compile
	$(SIM) $@

TEMP_TESTS = transcript vsim.wlf vish_stacktrace.vstf



###################################################################
### Misc.
###################################################################

clean:
	rm -rf $(TEMP_COMPILE) $(TEMP_TESTS)

print-vars:
	@$(foreach v,                                        \
		$(filter-out $(VARS_OLD) VARS_OLD,$(.VARIABLES)), \
		$(info $(v) = $($(v))))
