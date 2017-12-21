PROJECT=bin/pangpang
CPPSRC=$(shell find src -type f -name *.cpp)
CCSRC=$(shell find src -type f -name *.cc)
CXXSRC=$(shell find src -type f -name *.cxx)
CPPOBJ=$(patsubst %.cpp,%.o,$(CPPSRC))
CCOBJ=$(patsubst %.cc,%.o,$(CCSRC))
CXXOBJ=$(patsubst %.cxx,%.o,$(CXXSRC))

CSRC=$(shell find src -type f -name *.c)
COBJ=$(patsubst %.c,%.o,$(CSRC))

OBJ=$(COBJ) $(CXXOBJ) $(CCOBJ) $(CPPOBJ)

CFLAGS=-std=c11 -O3 -Wall -Isrc/inc -Isrc/lib `php-config --includes`
CXXFLAGS=-std=c++11 -O3 -Wall -Isrc/inc -Isrc/lib -Isrc/lib/MPFDParser-1.1.1 `pkg-config --cflags hiredis libevent_openssl openssl` `php-config --includes`
LDLIBS=`pkg-config --libs hiredis libevent_openssl openssl` -lphp7 -lpcre -lz -lpthread -ldl -lstdc++ 

PREFIX=/usr/local/pangpang

all:$(PROJECT)

$(PROJECT):$(OBJ)
	g++ -o $@ $^ $(LDLIBS)

.c.o:
	gcc $(CFLAGS) -c $^ -o $@

.cpp.o:
	g++ $(CXXFLAGS)  -c $^ -o $@

.cc.o:
	g++ $(CXXFLAGS)  -c $^ -o $@
	
.cxx.o:
	g++ $(CXXFLAGS)  -c $^ -o $@

clean:
	@for i in $(OBJ);do echo "rm -f" $${i} && rm -f $${i} ;done
	rm -f $(PROJECT)

install:
	test -d $(PREFIX) || mkdir -p $(PREFIX)
	test -d $(PREFIX)/include || mkdir -p $(PREFIX)/include
	test -d $(PREFIX)/bin || mkdir -p $(PREFIX)/bin
	test -d $(PREFIX)/html || mkdir -p $(PREFIX)/html
	test -d $(PREFIX)/logs || mkdir -p $(PREFIX)/logs
	test -d $(PREFIX)/conf || mkdir -p $(PREFIX)/conf
	test -d $(PREFIX)/mod || mkdir -p $(PREFIX)/mod
	test -d $(PREFIX)/temp || mkdir -p $(PREFIX)/temp
	test -d $(PREFIX)/php || mkdir -p $(PREFIX)/php
	cp php/*.php $(PREFIX)/php
	cp src/inc/*.hpp $(PREFIX)/include
	install bin/pangpang $(PREFIX)/bin
	install --backup conf/pangpang.json $(PREFIX)/conf
	install --backup conf/pattern.conf $(PREFIX)/conf
	install --backup conf/zlog.conf $(PREFIX)/conf
	install --backup html/index.html $(PREFIX)/html
	cp systemctl/pangpang.service /etc/systemd/system
