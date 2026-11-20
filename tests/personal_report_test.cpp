#include <windows.h>
#include <winhttp.h>
#include <cstdio>
static unsigned calls = 0;
HINTERNET WINAPI BlockOpen(LPCWSTR, DWORD, LPCWSTR, LPCWSTR, DWORD) { ++calls; return nullptr; }
#define WinHttpOpen BlockOpen
#include "../src/report.cpp"
#undef WinHttpOpen
// UI and HID enumeration are outside this transport regression test.
std::wstring DumpHidCollections() { return {}; }
int main() {
    std::string reply;
    const auto status = Post("{}", reply);
    if (calls || status != 0) { std::fputs("FAIL: personal report opened a network session\n", stderr); return 1; }
    std::puts("PASS: personal report cannot open a network session");
}
