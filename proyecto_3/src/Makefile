# Makefile

CC := gcc
CFLAGS := -O0

TARGET := benchmark.elf
SRCS := benchmark.c
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