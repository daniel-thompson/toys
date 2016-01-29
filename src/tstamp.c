/*
 * tstamp.c - Timestamp messages from sub-processes.
 *
 * Copyright (C) 2015 Daniel Thompson <daniel@redfelineninja.org.uk>
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 3 of the License, or
 * (at your option) any later version.
 */

/*
 * To build tstamp without hbcxx try:
 *     gcc -Wall -Os tstamp.c -o tstamp -lutil
 */

#include <errno.h>
#include <inttypes.h>
#include <stdarg.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

#include <getopt.h>
#include <poll.h>
#include <pty.h>
#include <unistd.h>

#define lengthof(x) ((sizeof(x) / sizeof(*(x))))

static struct {
	bool no_stamp;
	bool delta;
	unsigned int watchdog;
} options;

void die(const char *fmt, ...)
{
	va_list ap;

	va_start(ap, fmt);
	vfprintf(stderr, fmt, ap);
	va_end(ap);

	exit(1);
}

uint64_t time_now()
{
	struct timespec now;

	clock_gettime(CLOCK_REALTIME, &now);

	return (now.tv_sec * 1000000ull) + (now.tv_nsec / 1000);
}

int poll_with_stopwatch(int fd)
{
	struct pollfd fds[1] = { { .fd = fd, .events = POLLIN } };
	int res;

	uint64_t start = time_now();
	uint64_t olddelta = 0;

	res = poll(fds, lengthof(fds), 30000);
	if (res != 0)
		return res;

	do {
		unsigned int delta = (time_now() - start) / 1000000;
		if (delta != olddelta) {
			printf("\r[No output for %02u:%02u:%02u seconds]",
			       delta / 3600, (delta / 60) % 60, delta % 60);
			fflush(stdout);
			olddelta = delta;

			if (options.watchdog && options.watchdog > delta)
				exit(10);
		}

	} while ((res = poll(fds, lengthof(fds), 200)) == 0);

	/* clear away the stopwatch message */
	printf("\r                                      \r");
	fflush(stdout);

        return res;
}


void show_timestamp(uint64_t start, uint64_t prev, uint64_t now)
{
	uint64_t stamp = now - start;
	uint64_t delta = now - prev;

	if (options.no_stamp)
		return;

	if (options.delta)
		printf("[%5" PRIu64 ".%06" PRIu64
		       " +%" PRIu64 ".%06" PRIu64 "] ",
		       stamp / 1000000, stamp % 1000000,
		       delta / 1000000, delta % 1000000);
	else
		printf("[%5" PRIu64 ".%06" PRIu64 "] ",
		       stamp / 1000000, stamp % 1000000);
}

void timestamp(int fd)
{
	char buf[4096];
	ssize_t remaining;
	bool tstamp = true;

	uint64_t start = time_now();
	uint64_t prev = start;

	poll_with_stopwatch(fd);

	while ((remaining = read(fd, buf, sizeof(buf))) > 0) {
		char *p = buf;
		uint64_t now = time_now();
		while (remaining > 0) {
			if (tstamp) {
				show_timestamp(start, prev, now);
				prev = now;
				tstamp = false;
			}

			char *q = (char *) memchr(p, '\n', remaining);
			tstamp = q;
			size_t show = tstamp ? q - p + 1 : remaining;
			fwrite(p, show, 1, stdout);

			remaining -= show;
			p += show;
                }

		poll_with_stopwatch(fd);
	}

	if (remaining < 0 && errno != EIO)
		die("Cannot read from sub-process: %s\n", strerror(errno));
}

int main(int argc, char *argv[])
{
	const static struct option opts[] = {
		{ "delta", no_argument, 0, 'd' },
		{ "help", no_argument, 0, 'h' },
		{ "no-stamp", no_argument, 0, 'n' },
		{ "watchdog", required_argument, 0, 'w' },
		{ 0 }
	};

	int fd;
	int c;
	int digit_optind = 0;

	while ((c = getopt_long(argc, argv, "+dhnw:", opts, NULL)) != -1) {
		switch (c) {
		case 'd':
			options.delta = true;
			break;

		case 'n':
			options.no_stamp = true;
			break;

		case 'w':
			options.watchdog = strtoul(optarg, NULL, 10);
			break;

		case 'h':
		default:
			fprintf(stderr,
"USAGE: tstamp [OPTIONS] cmd arg...\n"
"\n"
"  -d, --delta          Show elapsed time between output\n"
"  -h, --help           Show this help, then exit\n"
"  -n, --no-stamp       Do not show timestamps (timeout reporting only)\n"
"  -w, --watchdog=SECS  Terminate if sub-process is unresponsive for SECS\n"
"\n"
				);
			exit(1);
			break;
		}
	}

	if (optind == argc)
		die("Nothing to run\n");

	pid_t child = forkpty(&fd, NULL, NULL, NULL);
	if (child < 0)
		die("Cannot create subprocess\n");

	if (0 == child) {
		char *targv[argc];
                memcpy(targv, argv + optind, sizeof(char *) * (argc - optind));
                targv[argc - optind] = NULL;

		execvp(targv[0], targv);
		/* does not return on success */
		die("Cannot switch to new process image\n");
	}

	timestamp(fd);

	return 0;
}
