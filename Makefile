.DEFAULT_GOAL := all

ALUMINA_BOOT ?= /usr/local/bin/alumina-boot
SYSROOT ?= /usr/local/share/alumina

ifdef RELEASE
	BUILD_DIR = $(BUILD_ROOT)/release
	CFLAGS += -O3
	ALUMINA_FLAGS += --cfg threading --sysroot $(SYSROOT) --timings
else
	BUILD_DIR = $(BUILD_ROOT)/debug
	CFLAGS += -g3 -fPIE -rdynamic
	ALUMINA_FLAGS += --cfg threading --sysroot $(SYSROOT) --debug --timings
endif

BUILD_ROOT = build
LDFLAGS = -lm -lpthread
TIMESTAMPED = $(BUILD_DIR)/timestamped

SOURCES = $(shell find src/ -type f -name '*.alu')

$(BUILD_DIR)/.build:
	mkdir -p $(BUILD_DIR)
	touch $@

$(TIMESTAMPED).c: $(BUILD_DIR)/.build $(SOURCES)
	$(ALUMINA_BOOT) $(ALUMINA_FLAGS) --output $@ \
		$(foreach src,$(SOURCES),$(subst /,::,$(basename $(subst src/,timestamped/,$(src))))=$(src))

$(TIMESTAMPED)-tests.c: $(BUILD_DIR)/.build $(SOURCES)
	$(ALUMINA_BOOT) $(ALUMINA_FLAGS) --cfg test --output $@ \
		$(foreach src,$(SOURCES),$(subst /,::,$(basename $(subst src/,timestamped/,$(src))))=$(src))

$(TIMESTAMPED): $(TIMESTAMPED).c
	$(CC) $(CFLAGS) -o $@ $^ $(LDFLAGS)

$(TIMESTAMPED)-tests: $(TIMESTAMPED)-tests.c
	$(CC) $(CFLAGS) -o $@ $^ $(LDFLAGS)

timestamped: $(TIMESTAMPED)
	ln -sf $^ $@

.PHONY: all test clean

clean:
	rm -rf $(BUILD_ROOT)
	rm -f timestamped

test: $(TIMESTAMPED)-tests
	$(TIMESTAMPED)-tests

all: timestamped
