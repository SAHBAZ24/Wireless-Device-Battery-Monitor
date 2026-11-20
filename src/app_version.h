#pragma once
#include "../build/version.h"

namespace appversion {
constexpr const char* text = WB_VERSION_STRING;
constexpr const wchar_t* wide = WB_VERSION_WSTRING;
#ifdef WB_PERSONAL_BUILD
constexpr bool official = false; // Never replace reviewed personal code with an upstream installer.
#else
constexpr bool official = WB_OFFICIAL_RELEASE != 0;
#endif
}
