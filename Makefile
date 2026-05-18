CC        := clang
TARGET    := otter

SRC_DIR   := src
TEST_DIR  := tests
BUILD_DIR := build

BUILD     ?= debug

CFLAGS_COMMON := \
    -std=c23 \
    -Wall -Wextra -Wpedantic \
    -Wshadow \
    -Wstrict-prototypes -Wmissing-prototypes \
    -Wnull-dereference \
    -Wdouble-promotion \
    -Wformat=2 \
    -MMD -MP

CFLAGS_debug  := -O0 -g3 -DOTTER_DEBUG=1 \
               -fno-omit-frame-pointer \
               -fsanitize=address,undefined
LDFLAGS_debug := -fsanitize=address,undefined

CFLAGS_release  := -O2 -DNDEBUG -flto -fstack-protector-strong
LDFLAGS_release := -flto

CFLAGS  := $(CFLAGS_COMMON) $(CFLAGS_$(BUILD)) $(CFLAGS_EXTRA)
LDFLAGS := $(LDFLAGS_$(BUILD)) $(LDFLAGS_EXTRA)
LDLIBS  := $(LDLIBS_EXTRA)


OUT_DIR   := $(BUILD_DIR)/$(BUILD)
OBJ_DIR   := $(OUT_DIR)/obj
BIN       := $(OUT_DIR)/$(TARGET)

SRCS      := $(shell find $(SRC_DIR) -name '*.c')
HDRS      := $(shell find $(SRC_DIR) -name '*.h')
OBJS      := $(SRCS:$(SRC_DIR)/%.c=$(OBJ_DIR)/%.o)
DEPS      := $(OBJS:.o=.d)

NONMAIN_OBJS := $(filter-out $(OBJ_DIR)/main.o $(OBJ_DIR)/otter.o,$(OBJS))

TEST_SRCS := $(wildcard $(TEST_DIR)/*.c)
TEST_BINS := $(TEST_SRCS:$(TEST_DIR)/%.c=$(OUT_DIR)/test_%)

V ?= 0
ifeq ($(V),0)
    Q := @
else
    Q :=
endif

.DEFAULT_GOAL := all

.PHONY: all
all: $(BIN)

$(BIN): $(OBJS) | $(OUT_DIR)
	@printf "  LINK    %s\n" "$@"
	$(Q)$(CC) $(CFLAGS) $(OBJS) -o $@ $(LDFLAGS) $(LDLIBS)

$(OBJ_DIR)/%.o: $(SRC_DIR)/%.c | $(OBJ_DIR)
	@mkdir -p $(dir $@)
	@printf "  CC      %s\n" "$<"
	$(Q)$(CC) $(CFLAGS) -c $< -o $@

$(OUT_DIR)/test_%: $(TEST_DIR)/%.c $(NONMAIN_OBJS) | $(OUT_DIR)
	@printf "  TEST    %s\n" "$@"
	$(Q)$(CC) $(CFLAGS) -I$(SRC_DIR) $< $(NONMAIN_OBJS) -o $@ $(LDFLAGS) $(LDLIBS)

.PHONY: test
test: $(TEST_BINS)
	@for t in $(TEST_BINS); do \
	    printf "  RUN     %s\n" "$$t"; \
	    "$$t" || exit 1; \
	done
	@echo "  PASS    all tests"

.PHONY: run
run: $(BIN)
	$(Q)$(BIN)

.PHONY: debug release
debug:
	$(Q)$(MAKE) --no-print-directory BUILD=debug
release:
	$(Q)$(MAKE) --no-print-directory BUILD=release

.PHONY: format
format:
	$(Q)clang-format -i $(SRCS) $(HDRS) $(TEST_SRCS)

.PHONY: tidy
tidy:
	$(Q)clang-tidy $(SRCS) -- $(CFLAGS)

.PHONY: clean
clean:
	$(Q)rm -rf $(BUILD_DIR)

.PHONY: help
help:
	@echo "Otter build system"
	@echo ""
	@echo "Targets:"
	@echo "  all (default)   Build for current profile (BUILD=$(BUILD))"
	@echo "  debug             Build with sanitizers + debug symbols"
	@echo "  release         Build optimized + LTO + hardening"
	@echo "  run             Build and run"
	@echo "  test            Build and run all tests"
	@echo "  format          clang-format all sources in place"
	@echo "  tidy            Run clang-tidy across all sources"
	@echo "  clean           Remove all build artifacts"
	@echo ""
	@echo "Variables:"
	@echo "  BUILD=debug|release    select build profile"
	@echo "  V=1                  show full command lines"
	@echo "  CC=...               override compiler (default: clang)"
	@echo "  CFLAGS_EXTRA=...     append extra compile flags"
	@echo "  LDFLAGS_EXTRA=...    append extra link flags"

$(OUT_DIR) $(OBJ_DIR):
	$(Q)mkdir -p $@

-include $(DEPS)
