#include <windows.h>
#include <cstdio>
static unsigned calls = 0;
BOOL WINAPI BlockProcess(LPCWSTR, LPWSTR, LPSECURITY_ATTRIBUTES, LPSECURITY_ATTRIBUTES, BOOL, DWORD, LPVOID, LPCWSTR, LPSTARTUPINFOW, LPPROCESS_INFORMATION) { ++calls; return FALSE; }
#define CreateProcessW BlockProcess
#include "../src/drivers/headsetcontrol.cpp"
#undef CreateProcessW
int main() {
    auto output = Run(L"headsetcontrol.exe -b -o json", 0);
    if (calls || !output.empty()) { std::fputs("FAIL: personal build attempted an external helper\n", stderr); return 1; }
    std::puts("PASS: personal build cannot start the external helper");
}
