# Copyright (c) 2011 The LevelDB Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file. See the AUTHORS file for names of contributors.

CXX ?= g++
CC  ?= gcc

#-----------------------------------------------
# Uncomment exactly one of the lines labelled (A), (B), and (C) below
# to switch between compilation modes.

OPT ?= -O2 -DNDEBUG       # (A) Production use (optimized mode)
# OPT ?= -g2              # (B) Debug mode, w/ full line-level debugging symbols
# OPT ?= -O2 -g2 -DNDEBUG # (C) Profiling mode: opt, but w/debugging symbols
#-----------------------------------------------

# detect what platform we're building on
$(shell sh ./build_detect_platform)
# this file is generated by build_detect_platform to set build flags
include build_config.mk

# If Snappy is installed, add compilation and linker flags
# (see http://code.google.com/p/snappy/)
ifeq ($(SNAPPY), 1)
SNAPPY_CFLAGS=-DSNAPPY
SNAPPY_LDFLAGS=-lsnappy
else
SNAPPY_CFLAGS=
SNAPPY_LDFLAGS=
endif

# If Google Perf Tools are installed, add compilation and linker flags
# (see http://code.google.com/p/google-perftools/)
ifeq ($(GOOGLE_PERFTOOLS), 1)
GOOGLE_PERFTOOLS_LDFLAGS=-ltcmalloc
else
GOOGLE_PERFTOOLS_LDFLAGS=
endif

CFLAGS += -c -I. -I./include $(PORT_CFLAGS) $(PLATFORM_CFLAGS) $(OPT) $(SNAPPY_CFLAGS)

LDFLAGS += $(PLATFORM_LDFLAGS) $(SNAPPY_LDFLAGS) $(GOOGLE_PERFTOOLS_LDFLAGS)

LIBOBJECTS = \
	./db/builder.o \
	./db/c.o \
	./db/db_impl.o \
	./db/db_iter.o \
	./db/filename.o \
	./db/dbformat.o \
	./db/log_reader.o \
	./db/log_writer.o \
	./db/memtable.o \
	./db/repair.o \
	./db/table_cache.o \
	./db/version_edit.o \
	./db/version_set.o \
	./db/write_batch.o \
	./port/port_posix.o \
	./table/block.o \
	./table/block_builder.o \
	./table/format.o \
	./table/iterator.o \
	./table/merger.o \
	./table/table.o \
	./table/table_builder.o \
	./table/two_level_iterator.o \
	./util/arena.o \
	./util/cache.o \
	./util/coding.o \
	./util/comparator.o \
	./util/crc32c.o \
	./util/env.o \
	./util/env_posix.o \
	./util/hash.o \
	./util/histogram.o \
	./util/logging.o \
	./util/options.o \
	./util/status.o

TESTUTIL = ./util/testutil.o
TESTHARNESS = ./util/testharness.o $(TESTUTIL)

TESTS = \
	arena_test \
	c_test \
	cache_test \
	coding_test \
	corruption_test \
	crc32c_test \
	db_test \
	dbformat_test \
	env_test \
	filename_test \
	log_test \
	memenv_test \
	skiplist_test \
	table_test \
	version_edit_test \
	version_set_test \
	write_batch_test

PROGRAMS = db_bench $(TESTS)
BENCHMARKS = db_bench_sqlite3 db_bench_tree_db

LIBRARY = libleveldb.a
MEMENVLIBRARY = libmemenv.a

all: $(LIBRARY)

check: $(PROGRAMS) $(TESTS)
	for t in $(TESTS); do echo "***** Running $$t"; ./$$t || exit 1; done

clean:
	-rm -f $(PROGRAMS) $(BENCHMARKS) $(LIBRARY) $(MEMENVLIBRARY) */*.o */*/*.o ios-x86/*/*.o ios-arm/*/*.o
	-rm -rf ios-x86/* ios-arm/*
	-rm build_config.mk

$(LIBRARY): $(LIBOBJECTS)
	rm -f $@
	$(AR) -rs $@ $(LIBOBJECTS)

db_bench: db/db_bench.o $(LIBOBJECTS) $(TESTUTIL)
	$(CXX) $(LDFLAGS) db/db_bench.o $(LIBOBJECTS) $(TESTUTIL) -o $@

db_bench_sqlite3: doc/bench/db_bench_sqlite3.o $(LIBOBJECTS) $(TESTUTIL)
	$(CXX) $(LDFLAGS) -lsqlite3 doc/bench/db_bench_sqlite3.o $(LIBOBJECTS) $(TESTUTIL) -o $@

db_bench_tree_db: doc/bench/db_bench_tree_db.o $(LIBOBJECTS) $(TESTUTIL)
	$(CXX) $(LDFLAGS) -lkyotocabinet doc/bench/db_bench_tree_db.o $(LIBOBJECTS) $(TESTUTIL) -o $@

arena_test: util/arena_test.o $(LIBOBJECTS) $(TESTHARNESS)
	$(CXX) $(LDFLAGS) util/arena_test.o $(LIBOBJECTS) $(TESTHARNESS) -o $@

c_test: db/c_test.o $(LIBOBJECTS) $(TESTHARNESS)
	$(CXX) $(LDFLAGS) db/c_test.o $(LIBOBJECTS) $(TESTHARNESS) -o $@

cache_test: util/cache_test.o $(LIBOBJECTS) $(TESTHARNESS)
	$(CXX) $(LDFLAGS) util/cache_test.o $(LIBOBJECTS) $(TESTHARNESS) -o $@

coding_test: util/coding_test.o $(LIBOBJECTS) $(TESTHARNESS)
	$(CXX) $(LDFLAGS) util/coding_test.o $(LIBOBJECTS) $(TESTHARNESS) -o $@

corruption_test: db/corruption_test.o $(LIBOBJECTS) $(TESTHARNESS)
	$(CXX) $(LDFLAGS) db/corruption_test.o $(LIBOBJECTS) $(TESTHARNESS) -o $@

crc32c_test: util/crc32c_test.o $(LIBOBJECTS) $(TESTHARNESS)
	$(CXX) $(LDFLAGS) util/crc32c_test.o $(LIBOBJECTS) $(TESTHARNESS) -o $@

db_test: db/db_test.o $(LIBOBJECTS) $(TESTHARNESS)
	$(CXX) $(LDFLAGS) db/db_test.o $(LIBOBJECTS) $(TESTHARNESS) -o $@

dbformat_test: db/dbformat_test.o $(LIBOBJECTS) $(TESTHARNESS)
	$(CXX) $(LDFLAGS) db/dbformat_test.o $(LIBOBJECTS) $(TESTHARNESS) -o $@

env_test: util/env_test.o $(LIBOBJECTS) $(TESTHARNESS)
	$(CXX) $(LDFLAGS) util/env_test.o $(LIBOBJECTS) $(TESTHARNESS) -o $@

filename_test: db/filename_test.o $(LIBOBJECTS) $(TESTHARNESS)
	$(CXX) $(LDFLAGS) db/filename_test.o $(LIBOBJECTS) $(TESTHARNESS) -o $@

log_test: db/log_test.o $(LIBOBJECTS) $(TESTHARNESS)
	$(CXX) $(LDFLAGS) db/log_test.o $(LIBOBJECTS) $(TESTHARNESS) -o $@

table_test: table/table_test.o $(LIBOBJECTS) $(TESTHARNESS)
	$(CXX) $(LDFLAGS) table/table_test.o $(LIBOBJECTS) $(TESTHARNESS) -o $@

skiplist_test: db/skiplist_test.o $(LIBOBJECTS) $(TESTHARNESS)
	$(CXX) $(LDFLAGS) db/skiplist_test.o $(LIBOBJECTS) $(TESTHARNESS) -o $@

version_edit_test: db/version_edit_test.o $(LIBOBJECTS) $(TESTHARNESS)
	$(CXX) $(LDFLAGS) db/version_edit_test.o $(LIBOBJECTS) $(TESTHARNESS) -o $@

version_set_test: db/version_set_test.o $(LIBOBJECTS) $(TESTHARNESS)
	$(CXX) $(LDFLAGS) db/version_set_test.o $(LIBOBJECTS) $(TESTHARNESS) -o $@

write_batch_test: db/write_batch_test.o $(LIBOBJECTS) $(TESTHARNESS)
	$(CXX) $(LDFLAGS) db/write_batch_test.o $(LIBOBJECTS) $(TESTHARNESS) -o $@

$(MEMENVLIBRARY) : helpers/memenv/memenv.o
	rm -f $@
	$(AR) -rs $@ helpers/memenv/memenv.o

memenv_test : helpers/memenv/memenv_test.o $(MEMENVLIBRARY) $(LIBRARY) $(TESTHARNESS)
	$(CXX) $(LDFLAGS) helpers/memenv/memenv_test.o $(MEMENVLIBRARY) $(LIBRARY) $(TESTHARNESS) -o $@

ifeq ($(PLATFORM), IOS)
# For iOS, create universal object files to be used on both the simulator and
# a device.
SIMULATORROOT=/Developer/Platforms/iPhoneSimulator.platform/Developer
DEVICEROOT=/Developer/Platforms/iPhoneOS.platform/Developer
IOSVERSION=$(shell defaults read /Developer/Platforms/iPhoneOS.platform/version CFBundleShortVersionString)

.cc.o:
	mkdir -p ios-x86/$(dir $@)
	$(SIMULATORROOT)/usr/bin/$(CXX) $(CFLAGS) -isysroot $(SIMULATORROOT)/SDKs/iPhoneSimulator$(IOSVERSION).sdk -arch i686 $< -o ios-x86/$@
	mkdir -p ios-arm/$(dir $@)
	$(DEVICEROOT)/usr/bin/$(CXX) $(CFLAGS) -isysroot $(DEVICEROOT)/SDKs/iPhoneOS$(IOSVERSION).sdk -arch armv6 -arch armv7 $< -o ios-arm/$@
	lipo ios-x86/$@ ios-arm/$@ -create -output $@

.c.o:
	mkdir -p ios-x86/$(dir $@)
	$(SIMULATORROOT)/usr/bin/$(CC) $(CFLAGS) -isysroot $(SIMULATORROOT)/SDKs/iPhoneSimulator$(IOSVERSION).sdk -arch i686 $< -o ios-x86/$@
	mkdir -p ios-arm/$(dir $@)
	$(DEVICEROOT)/usr/bin/$(CC) $(CFLAGS) -isysroot $(DEVICEROOT)/SDKs/iPhoneOS$(IOSVERSION).sdk -arch armv6 -arch armv7 $< -o ios-arm/$@
	lipo ios-x86/$@ ios-arm/$@ -create -output $@

else
.cc.o:
	$(CXX) $(CFLAGS) $< -o $@

.c.o:
	$(CC) $(CFLAGS) $< -o $@
endif
