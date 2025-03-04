# Copyright (c) 2012 Intel Corporation. All Rights Reserved.
#
#
# Permission is hereby granted, free of charge, to any person obtaining a
# copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sub license, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice (including the
# next paragraph) shall be included in all copies or substantial portions
# of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
# OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NON-INFRINGEMENT.
# IN NO EVENT SHALL PRECISION INSIGHT AND/OR ITS SUPPLIERS BE LIABLE FOR
# ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
# TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
# SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#

LOCAL_PATH:= $(call my-dir)

include $(LOCAL_PATH)/Makefile.sources

include $(CLEAR_VARS)

LOCAL_SRC_FILES := $(source_c)

LOCAL_MODULE := crocus_drv_video
LOCAL_MODULE_TAGS := optional
LOCAL_MODULE_CLASS := SHARED_LIBRARIES
LOCAL_PROPRIETARY_MODULE := true

intermediates := $(call local-generated-sources-dir)

LOCAL_EXPORT_C_INCLUDE_DIRS := $(intermediates)

GEN := $(intermediates)/config_android.h
$(GEN): SCRIPT := $(LOCAL_PATH)/../build/gen_version.sh
$(GEN): PRIVATE_CUSTOM_TOOL = \
	eval $$(sed -n "/^m4_define.*\(intel_vaapi_driver_.*_version\).*\[\([0-9]*\)\].*/s//\1=\2;/p" $(word 2,$^)); \
	sed -e "s/\(define INTEL_DRIVER_MAJOR_VERSION\)\(.*\)/\1 $$intel_vaapi_driver_major_version/; \
		s/\(define INTEL_DRIVER_MINOR_VERSION\)\(.*\)/\1 $$intel_vaapi_driver_minor_version/; \
		s/\(define INTEL_DRIVER_MICRO_VERSION\)\(.*\)/\1 $$intel_vaapi_driver_micro_version/; \
		s/\(define INTEL_DRIVER_PRE_VERSION\)\(.*\)/\1 $$intel_vaapi_driver_pre_version/" \
		$< > $@
$(GEN): $(intermediates)/%.h : $(LOCAL_PATH)/%.h.in $(LOCAL_PATH)/../configure.ac
	$(transform-generated-source)
LOCAL_GENERATED_SOURCES := $(GEN)

GEN := $(intermediates)/intel_version.h
$(GEN): $(LOCAL_PATH)/intel_version.h.in $(wildcard $(LOCAL_PATH)/../.git/logs/HEAD)
	@echo "Generating: $@ <= git"; mkdir -p $(@D)
	$(hide) VER=`cd $(<D)/.. && git describe --tags --always --dirty || echo unknown`; \
	sed -e "s|\@INTEL_DRIVER_GIT_VERSION\@|$$VER|" $< > $@
LOCAL_GENERATED_SOURCES += $(GEN)

LOCAL_CFLAGS := -DLINUX -g -Wall -Wno-unused -fvisibility=hidden \
	-Wno-missing-field-initializers \
	-Wno-unused-parameter \
	-Wno-pointer-arith \
	-Wno-sign-compare \

LOCAL_SHARED_LIBRARIES := libdl libdrm libdrm_intel libcutils \
               libva libva-android
LOCAL_HEADER_LIBRARIES := libva_headers

ifeq ($(strip $(DRIVER_LOG_ENABLE)),true)
LOCAL_CFLAGS += -DDRIVER_LOG_ENABLE
LOCAL_SHARED_LIBRARIES += liblog
endif

include $(BUILD_SHARED_LIBRARY)
