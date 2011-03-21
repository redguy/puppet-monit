/* As bare as it gets */

#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>

char filename[200];

int main(int argc, char ** argv) {
    pid_t   pid, sid;

    pid = fork();

    if (pid < 0) {
        exit(EXIT_FAILURE);
    } else if (pid > 0) {
        exit(EXIT_SUCCESS);
    }

    char * c = strrchr(argv[0], '/');
    c = c ? c+1 : argv[0];

    sprintf(filename, "/tmp/%s.pid", c);
    FILE * f = fopen(filename, "w");
    if (!f) {
	exit(EXIT_FAILURE);
    }
    fprintf(f, "%d\n", getpid());
    fclose(f);

    umask(0);

    sid = setsid();
    if (sid < 0) {
        exit(EXIT_FAILURE);
    }

    printf("%s running.\n", c);
    while (1) {
        sleep(10);
        // printf("tic\n");
    }

    exit(EXIT_SUCCESS);
}

