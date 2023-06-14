#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "sha256.h"

int main(int argc, const char *argv[])
{
	if (argc != 2) {
		fprintf(stderr, "usage: %s <str>\n", argv[0]);
		return EXIT_FAILURE;
	}

	size_t len_argv1 = strlen(argv[1]);

	asm volatile("int3");

	SHA256_CTX ctx;
	sha256_init(&ctx);
	sha256_update(&ctx, argv[1], len_argv1);

	unsigned char hash[32];
	sha256_final(&ctx, hash);

	asm volatile("int3");

	for (int i = 0; i < sizeof hash; ++i)
		printf("%02x", hash[i]);

	putchar('\n');
	return 0;
}
