LOCAL_PATH := $(call my-dir)
include $(CLEAR_VARS)
LOCAL_MODULE := fko
LOCAL_SRC_FILES := \
	../../lib/sha3.c \
	../../lib/fko_client_timeout.c \
	../../lib/fko_hmac.c \
	../../lib/hmac.c \
	../../lib/md5.c \
	../../lib/fko_message.c \
	../../lib/fko_error.c \
	../../lib/digest.c \
	../../lib/fko_user.c \
	../../lib/fko_rand_value.c \
	../../lib/fko_funcs.c \
	../../lib/fko_digest.c \
	../../lib/base64.c \
	../../lib/fko_server_auth.c \
	../../lib/sha2.c \
	../../lib/fko_encryption.c \
	../../lib/gpgme_funcs.c \
	../../lib/sha1.c \
	../../lib/fko_decode.c \
	../../lib/cipher_funcs.c \
	../../lib/fko_timestamp.c \
	../../lib/rijndael.c \
	../../lib/fko_nat_access.c \
	../../lib/fko_encode.c \
	../../common/cunit_common.c \
	../../common/fko_util.c \
	../../common/strlcpy.c \
	../../common/strlcat.c \
	../../.swig/libfko_wrap.c
LOCAL_C_INCLUDES := \
	../../lib \
	../../common
LOCAL_CFLAGS := \
	-include stdlib.h \
	-include string.h \
	-include strings.h \
	-include unistd.h \
	-include ctype.h \
	-include endian.h
include $(BUILD_SHARED_LIBRARY)