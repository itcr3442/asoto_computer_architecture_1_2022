# Makefile

CC := gcc
CFLAGS := -O0 -g

TARGET := benchmark.elf
SRCS := benchmark.c
OBJS := $(SRCS:.c=.o)

$(TARGET): $(OBJS)
	$(CC) $(CFLAGS) -o $@ $^

%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

clean:
	rm -f $(TARGET) $(OBJS)
