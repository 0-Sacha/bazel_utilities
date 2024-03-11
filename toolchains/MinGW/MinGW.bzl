""

load("@bazel_tools//tools/cpp:cc_toolchain_config_lib.bzl", "artifact_name_pattern")

load("//bazel_utilities/toolchains/impl:toolchain.bzl", "butils_toolchain")
load("//bazel_utilities/toolchains/impl:toolchain_config.bzl", "butils_toolchain_config_rule")
load("//bazel_utilities/toolchains/impl:toolchain_registry.bzl", "butils_toolchain_registry", "butils_toolchain_package")

load(":MinGW_archives.bzl", "MINGW_ARCHIVES_REGISTRY")

mingw_gcc_registry = butils_toolchain_registry(
    name = "mingw_gcc",
    registry = MINGW_ARCHIVES_REGISTRY,
    target_libc = "gcc",
    compiler = {
        "name": "gcc",
        "c_compiler": "gcc",
        "cxx_compiler": "g++"
    },
    copts = [
        "-no-canonical-prefixes",
        "-fno-canonical-system-headers",

        "-Iexternal/mingw_{host_name}/include",
        "-Iexternal/mingw_{host_name}/x86_64-w64-mingw32/include",
        "-Iexternal/mingw_{host_name}/lib/gcc/x86_64-w64-mingw32/{gcc_version}/include",
        "-Iexternal/mingw_{host_name}/lib/gcc/x86_64-w64-mingw32/{gcc_version}/include-fixed",
    ],
    linkopts = [
        "-no-canonical-prefixes",
        "-fno-canonical-system-headers",

        "-Lexternal/mingw_{host_name}/x86_64-w64-mingw32/lib",
        "-Lexternal/mingw_{host_name}/lib/gcc/x86_64-w64-mingw32/{gcc_version}",
    ],
    cxx_builtin_include_directories = [
        "external/mingw_{host_name}/include",
        "external/mingw_{host_name}/x86_64-w64-mingw32/include",
        "external/mingw_{host_name}/lib/gcc/x86_64-w64-mingw32/{gcc_version}/include",
        "external/mingw_{host_name}/lib/gcc/x86_64-w64-mingw32/{gcc_version}/include-fixed",
    ],
    artifact_name_patterns = {
        "windows_x86_64": [
            artifact_name_pattern(
                category_name = "executable",
                prefix = "",
                extension = ".exe",
            )
        ]
    }
)

mingw_gcc_latest_package = butils_toolchain_package(toolchain_registry = mingw_gcc_registry, version = "latest")
_mingw_gcc_latest_config = butils_toolchain_config_rule(mingw_gcc_latest_package)
mingw_gcc_latest = butils_toolchain(mingw_gcc_latest_package, _mingw_gcc_latest_config)


mingw_clang_registry = butils_toolchain_registry(
    name = "mingw_clang",
    registry = MINGW_ARCHIVES_REGISTRY,
    target_libc = "clang",
    compiler = {
        "name": "clang",
        "c_compiler": "clang",
        "cxx_compiler": "clang++"
    },
    copts = [
        "-Iexternal/mingw_{host_name}/include",
        "-Iexternal/mingw_{host_name}/x86_64-w64-mingw32/include",
        "-Iexternal/mingw_{host_name}/lib/clang/{clang_version}/include",
    ],
    linkopts = [
        "-Lexternal/mingw_{host_name}/x86_64-w64-mingw32/lib",
    ],
    cxx_builtin_include_directories = [
        "external/mingw_{host_name}/include",
        "external/mingw_{host_name}/x86_64-w64-mingw32/include",
        "external/mingw_{host_name}/lib/clang/{clang_version}/include",
    ],
    artifact_name_patterns = {
        "windows_x86_64": [
            artifact_name_pattern(
                category_name = "executable",
                prefix = "",
                extension = ".exe",
            )
        ]
    }
)

mingw_clang_latest_package = butils_toolchain_package(toolchain_registry = mingw_clang_registry, version = "latest")
_mingw_clang_latest_config = butils_toolchain_config_rule(mingw_clang_latest_package)
mingw_clang_latest = butils_toolchain(mingw_clang_latest_package, _mingw_clang_latest_config)
