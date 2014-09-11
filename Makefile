#
# =BEGIN MIT LICENSE
# 
# The MIT License (MIT)
#
# Copyright (c) 2014 The CrossBridge Team
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
# 
# =END MIT LICENSE
#

.PHONY: clean all

SWFS=atomic.swf flash++flavors.swf flash++ui.swf openmp.swf pthreads.swf sema.swf workers.swf

# Detect host 
$?UNAME=$(shell uname -s)
#$(info $(UNAME))
ifneq (,$(findstring CYGWIN,$(UNAME)))
	$?nativepath=$(shell cygpath -at mixed $(1))
	$?unixpath=$(shell cygpath -at unix $(1))
else
	$?nativepath=$(abspath $(1))
	$?unixpath=$(abspath $(1))
endif

# CrossBridge SDK Home
ifneq "$(wildcard $(call unixpath,$(FLASCC_ROOT)/sdk))" ""
 $?FLASCC:=$(call unixpath,$(FLASCC_ROOT)/sdk)
else
 $?FLASCC:=/path/to/crossbridge-sdk/
endif
$?ASC2=java -jar $(call nativepath,$(FLASCC)/usr/lib/asc2.jar) -merge -md -parallel
 
# Auto Detect AIR/Flex SDKs
ifneq "$(wildcard $(AIR_HOME)/lib/compiler.jar)" ""
 $?FLEX=$(AIR_HOME)
else
 $?FLEX:=/path/to/adobe-air-sdk/
endif

# C/CPP Compiler
$?BASE_CFLAGS=-Werror -Wno-write-strings -Wno-trigraphs
$?EXTRACFLAGS=
$?OPT_CFLAGS=-O4

# ASC2 Compiler
$?MXMLC_DEBUG=true
$?SWF_VERSION=25
$?SWF_SIZE=800x600

all: clean check $(SWFS)

atomic.swf: atomic.cpp
	$(FLASCC)/usr/bin/g++ -emit-swf -swf-version=$(SWF_VERSION) -swf-size=$(SWF_SIZE) -O4 -flto-api=exports.txt -pthread atomic.cpp -o atomic.swf

pthreads.swf: pthreads.cpp
	$(FLASCC)/usr/bin/g++ -emit-swf -swf-version=$(SWF_VERSION) -swf-size=$(SWF_SIZE) -O4 -flto-api=exports.txt -pthread pthreads.cpp -o pthreads.swf

sema.swf: sema.cpp
	$(FLASCC)/usr/bin/g++ -emit-swf -swf-version=$(SWF_VERSION) -swf-size=$(SWF_SIZE) -O4 -flto-api=exports.txt -pthread sema.cpp -o sema.swf

workers.swf: workers.cpp
	$(FLASCC)/usr/bin/g++ -emit-swf -swf-version=$(SWF_VERSION) -swf-size=$(SWF_SIZE) -O4 -flto-api=exports.txt -pthread workers.cpp -o workers.swf

openmp.swf: openmp.cpp
	$(FLASCC)/usr/bin/g++ -emit-swf -swf-version=$(SWF_VERSION) -swf-size=$(SWF_SIZE) -O4 -flto-api=exports.txt -pthread -fopenmp openmp.cpp -o openmp.swf

flash++flavors.swf: flash++flavors.cpp
	$(FLASCC)/usr/bin/g++ -emit-swf -swf-version=$(SWF_VERSION) -swf-size=$(SWF_SIZE) -O4 -flto-api=exports.txt -pthread flash++flavors.cpp -lFlash++ -lAS3++ -o flash++flavors.swf

flash++ui.swf: flash++ui.cpp
	$(FLASCC)/usr/bin/g++ -emit-swf -swf-version=$(SWF_VERSION) -swf-size=$(SWF_SIZE) -O4 -flto-api=exports.txt -pthread flash++ui.cpp -lFlash++ -lAS3++ -o flash++ui.swf

# Self check
check:
	@if [ -d $(FLASCC)/usr/bin ] ; then true ; \
	else echo "Couldn't locate CrossBridge SDK directory, please invoke make with \"make FLASCC=/path/to/CrossBridge/ ...\"" ; exit 1 ; \
	fi
	@if [ -d "$(FLEX)/bin" ] ; then true ; \
	else echo "Couldn't locate Adobe AIR or Apache Flex SDK directory, please invoke make with \"make FLEX=/path/to/AirOrFlex  ...\"" ; exit 1 ; \
	fi
	@echo "ASC2: $(ASC2)"

clean:
	rm -f *.swf *.swc
