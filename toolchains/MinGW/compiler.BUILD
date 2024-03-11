# toolchains/compiler.BUILD

package(default_visibility = ["//visibility:public"])

# gcc executables.
filegroup(
    name = "gcc",
    srcs = glob(["bin/gcc*"]),
)

filegroup(
    name = "clang",
    srcs = glob(["bin/clang*"]),
)

# g++ executables.
filegroup(
    name = "g++",
    srcs = glob(["bin/g++*"]),
)

filegroup(
    name = "clang++",
    srcs = glob(["bin/clang++*"]),
)

# gdb executables.
filegroup(
    name = "gdb",
    srcs = glob(["bin/gdb*"]),
)

# cpp executables.
filegroup(
    name = "cpp",
    srcs = glob(["bin/cpp*"]),
)

# gcov executables.
filegroup(
    name = "gcov",
    srcs = glob(["bin/gcov*"]),
)

# ar executables.
filegroup(
    name = "ar",
    srcs = glob(["bin/ar*"]),
)

# ld executables.
filegroup(
    name = "ld",
    srcs = glob(["bin/ld*"]),
)

# nm executables.
filegroup(
    name = "nm",
    srcs = glob(["bin/nm*"]),
)

# objcopy executables.
filegroup(
    name = "objcopy",
    srcs = glob(["bin/objcopy*"]),
)

# objdump executables.
filegroup(
    name = "objdump",
    srcs = glob(["bin/objdump*"]),
)

# strip executables.
filegroup(
    name = "strip",
    srcs = glob(["bin/strip*"]),
)

# as executables.
filegroup(
    name = "as",
    srcs = glob(["bin/as*"]),
)

# size executables.
filegroup(
    name = "size",
    srcs = glob(["bin/size*"]),
)

# size executables.
filegroup(
    name = "dwp",
    srcs = [],
)

# libraries and headers.
filegroup(
    name = "compiler_pieces",
    srcs = glob([
        "**"
    ]),
)

# files for executing compiler.
filegroup(
    name = "compiler_files",
    srcs = [
        ":compiler_pieces",
        ":cpp",
        ":gcc",
        ":g++",
        ":clang",
        ":clang++",
    ],
)

filegroup(
    name = "linker_files",
    srcs = [
        ":ar",
        ":compiler_pieces",
        ":gcc",
        ":g++",
        ":clang",
        ":clang++",
        ":ld",
    ],
)

# collection of executables.
filegroup(
    name = "compiler_components",
    srcs = [
        ":ar",
        ":as",
        ":cpp",
        ":gcc",
        ":g++",
        ":clang",
        ":clang++",
        ":gcov",
        ":ld",
        ":nm",
        ":objcopy",
        ":objdump",
        ":strip",
    ],
)
