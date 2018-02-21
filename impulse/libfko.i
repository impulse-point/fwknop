%module libfko

%include "carrays.i"

%array_class(unsigned char, uchar_array);
%array_class(short, short_array);
%array_class(int, int_array);

%{
#include "fko.h"
%}

%include "fko.h"

%newobject createFkoContextPointer;
%newobject createCharPointerPointer;

%inline %{
	// TODO solve this the same way we did short_array, int_array, etc. ?
	fko_ctx_t* createFkoContextPointer() {
		return malloc(sizeof(fko_ctx_t));
	}

	void deleteFkoContextPointer(fko_ctx_t* context) {
		free(context);
	}

	fko_ctx_t derefFkoContextPointer(fko_ctx_t* ctx) {
		return *ctx;
	}

	// TODO solve this the same way we did short_array, int_array, etc. ?
	char** createCharPointerPointer() {
		return malloc(sizeof(char*));
	}

	void deleteCharPointerPointer(char** pointer) {
		free(pointer);
	}

	char* derefCharPointerPointer(char** data) {
		return *data;
	}

	// intended for base64 encoding and decoded
	// I can't figure out how to avoid having SWIG convert all `char*` to `string`
	// instead, we'll wrap the functions using `unsigned char*`, and do the conversions ourselves in C#
	int fko_base64_encode_wrapper(unsigned char* in, unsigned char* out, int in_len) {
		return fko_base64_encode(in, out, in_len);
	}
	int fko_base64_decode_wrapper(unsigned char* in, unsigned char* out) {
		return fko_base64_decode(in, out);
	}

	// same as base64, can't figure out how to get this to not be strings, so use unsigned char*
	int fko_spa_data_final_wrapper(fko_ctx_t ctx, unsigned char* key, int key_len, unsigned char* hmac_key, int hmac_key_len) {
		return fko_spa_data_final(ctx, key, key_len, hmac_key, hmac_key_len);
	}
%}