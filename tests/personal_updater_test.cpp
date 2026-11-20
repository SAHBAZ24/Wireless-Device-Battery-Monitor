#include <windows.h>
#include <cstdio>
static unsigned cleanupSearches = 0;
HANDLE WINAPI ObserveCleanup(LPCWSTR, LPWIN32_FIND_DATAW) { ++cleanupSearches; return INVALID_HANDLE_VALUE; }
#define FindFirstFileW ObserveCleanup
#include "../src/update_win.cpp"
#undef FindFirstFileW
#include "../src/update_apply.cpp"
int main() {
    updates::Initialize();
    wchar_t app[] = L"BatteryHub.exe", command[] = L"--apply-update";
    wchar_t* args[] = {app, command};
    bool good = updates::RunApplyMode(1, args) == -1;
    good = (updates::RunApplyMode(2, args) == 2) && good;
    good = (cleanupSearches == 0) && good;
    updates::Shutdown();
    if (!good) { std::fputs("FAIL: personal updater touches shared cache or treats disabled apply as startup\n", stderr); return 1; }
    std::puts("PASS: personal updater leaves shared cache alone and rejects apply mode");
}
