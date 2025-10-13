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

//#! -Wall

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
	bool clock;
	bool delta;
	unsigned int watchdog;
	FILE *logfile;
} options;

static void die(const char *fmt, ...)
{
	va_list ap;

	va_start(ap, fmt);
	vfprintf(stderr, fmt, ap);
	va_end(ap);

	exit(1);
}

static int logprintf(const char *fmt, ...)
{
	va_list ap;
	int res;

	va_start(ap, fmt);
	res = vprintf(fmt, ap);
	va_end(ap);

	if (res >= 0 && options.logfile) {
		va_start(ap, fmt);
		res = vfprintf(options.logfile, fmt, ap);
		va_end(ap);
	}

	return res;
}

static uint64_t time_now()
{
	struct timespec now;

	clock_gettime(CLOCK_REALTIME, &now);

	return (now.tv_sec * 1000000ull) + (now.tv_nsec / 1000);
}

int poll_with_stopwatch(int fd, uint64_t epoch)
{
	struct pollfd fds[1] = { { .fd = fd, .events = POLLIN } };
	int res;
	int scrub = 0;

	uint64_t start = time_now();
	uint64_t olddelta = 0;

	res = poll(fds, lengthof(fds),
		   (options.watchdog < 30 ? options.watchdog : 30) * 1000);
	if (res != 0)
		return res;

	do {
		unsigned int delta = (time_now() - start) / 1000000;
		if (delta != olddelta) {
			/* clear away any existing stopwatch message */
			while (scrub-- > 0)
				printf("\b \b");

			/* stopwatch messages are not logged since they are
			 * only really useful during interactive use
			 */
			scrub = printf("[No output for %02u:%02u:%02u]",
			       delta / 3600, (delta / 60) % 60, delta % 60);
			fflush(stdout);
			olddelta = delta;

			if (options.watchdog && delta >= options.watchdog) {
				uint64_t stamp = time_now() - epoch;
				logprintf("\n[%5" PRIu64 ".%06" PRIu64
				       "] WATCHDOG EXPIRED; Terminating...\n",
				       stamp / 1000000, stamp % 1000000);

				/* exit causes the pty file descriptors to be
				 * cleaned up... the supervised process won't
				 * last long after that!
				 */
				exit(10);
			}
		}

	} while ((res = poll(fds, lengthof(fds), 200)) == 0);

	/* clear away the stopwatch message */
	while (scrub-- > 0)
		printf("\b \b");
	fflush(stdout);

        return res;
}


void show_timestamp(uint64_t start, uint64_t prev, uint64_t now)
{
	uint64_t stamp = now - start;
	uint64_t delta = now - prev;

	if (options.no_stamp)
		return;

	unsigned int seconds = stamp / 1000000;
	unsigned int microseconds = stamp % 1000000;

	if (options.clock)
		logprintf("[%02u:%02u:%02u.%06u] ",
			seconds / 3600, (seconds % 3600) / 60, seconds % 60,
			microseconds);
	else if (options.delta)
		logprintf("[%5u.%06u  +%u.%06u] ", seconds, microseconds,
		       (unsigned int) (delta / 1000000),
		       (unsigned int) (delta % 1000000));
	else
		logprintf("[%5u.%06u] ", seconds, microseconds);
}

void timestamp(int fd)
{
	char buf[4096];
	ssize_t remaining;
	bool tstamp = true;

	uint64_t start = time_now();
	uint64_t prev = start;

	poll_with_stopwatch(fd, start);

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
			size_t show = q ? q - p + 1 : remaining;
			fwrite(p, show, 1, stdout);
			fflush(stdout);
			if (options.logfile)
				fwrite(p, show, 1, options.logfile);

			tstamp = q;
			remaining -= show;
			p += show;
                }

		poll_with_stopwatch(fd, start);
	}

	if (remaining < 0 && errno != EIO)
		die("Cannot read from sub-process: %s\n", strerror(errno));
}

int main(int argc, char *argv[])
{
	const static struct option opts[] = {
		{ "clock", no_argument, 0, 'c' },
		{ "delta", no_argument, 0, 'd' },
		{ "help", no_argument, 0, 'h' },
		{ "log", required_argument, 0, 'l' },
		{ "no-stamp", no_argument, 0, 'n' },
		{ "watchdog", required_argument, 0, 'w' },
		{ 0 }
	};

	int fd;
	int c;

	while ((c = getopt_long(argc, argv, "+cdhl:nw:", opts, NULL)) != -1) {
		switch (c) {
		case 'c': // --clock
			options.clock = true;
			break;

		case 'd': // --delta
			options.delta = true;
			break;

		case 'l': // --log
			options.logfile = fopen(optarg, "w");
			if (!options.logfile)
				die("Cannot open '%s' (%s)\n", optarg,
				    strerror(errno));
			break;

		case 'n': // --no-stamp
			options.no_stamp = true;
			break;

		case 'w': // --watchdog
			options.watchdog = strtoul(optarg, NULL, 10);
			break;

		case 'h':
		default:
			fprintf(stderr,
"USAGE: tstamp [OPTIONS] cmd arg...\n"
"\n"
"  -c, --clock          Issue timestamps in 00:00:00.000000 format\n"
"  -d, --delta          Show elapsed time between output\n"
"  -h, --help           Show this help, then exit\n"
"  -l, --log=FILENAME	Copy output to a log file\n"
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
