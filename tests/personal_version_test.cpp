#include "../src/app_version.h"
#include <cstdio>

int main() {
    // Build this test with stable metadata: the personal policy must still win.
    if (appversion::official) {
        std::fputs("FAIL: personal build allows official upstream updates\n", stderr);
        return 1;
    }
    std::puts("PASS: personal build refuses official upstream updates");
}
