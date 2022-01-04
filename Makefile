
BINARY=binarytrees.rust-5.rust_run

RS_FILES=$(wildcard *.rs)

RUST_DEPS=crate rayon memchr

#########################

#RUST_DIR_LOOKUP = $(shell ls -d1 $1-* 2>/dev/null)
RUST_DIR_LOOKUP = $(wildcard $1-*)

DEPLIST=$(ONE_DEP)

DEP_LIST=$(foreach RUST_DEP,$(RUST_DEPS), \
	-C incremental=$(abspath $(call RUST_DIR_LOOKUP,$(RUST_DEP)))/target/debug/incremental \
	-L dependency=$(abspath $(call RUST_DIR_LOOKUP,$(RUST_DEP)))/target/debug/deps \
	--extern $(RUST_DEP)=$(wildcard $(abspath $(call RUST_DIR_LOOKUP,$(RUST_DEP)))/target/debug/deps/lib$(RUST_DEP)-*.rlib))

DEP_TARGETS=$(foreach RUST_DEP,$(RUST_DEPS),$(if $(wildcard $(abspath $(call RUST_DIR_LOOKUP,$(RUST_DEP)))/target/debug/deps/lib$(RUST_DEP)-*.rlib),,$(RUST_DEP).dep))

all: $(BINARY)

$(BINARY): $(RS_FILES) $(DEP_TARGETS)
	rustc $(DEP_LIST) -C opt-level=3 -C target-cpu=skylake --C codegen-units=1 $(RS_FILES) -o $@

run: all
	./$(BINARY) 0 < revcomp-input1000.txt

deps: $(RUST_DEPS:=.dep)
	
$(RUST_DEPS:=.dep):
	cargo download $(@:.dep=) > $(@:.dep=).gz; \
		tar -xvf $(@:.dep=).gz; \
		cd $(@:.dep=-)*; \
		cargo build --verbose
		
