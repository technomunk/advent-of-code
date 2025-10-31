#include <stdio.h>

int main() {
    char buffer[256];
    for (;;) {
        gets_s(buffer, 256);
        if (!buffer[0]) break;
        puts(buffer);
    }
    return 0;
}
