# Makefile

CC := gcc
CFLAGS := -O3 -g -fno-tree-vectorize -funroll-all-loops

TARGET := benchmark.elf
SRCS := benchmark.c sha256.c
OBJS := $(SRCS:.c=.o)

$(TARGET): $(OBJS)
	$(CC) $(CFLAGS) -o $@ $^
	rm -f $(OBJS)

%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

clean:
	rm -f $(TARGET) $(OBJS)

test: clean $(TARGET)
	./$(TARGET)
