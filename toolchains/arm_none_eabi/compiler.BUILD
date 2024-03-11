# toolchains/compiler.BUILD

package(default_visibility = ["//visibility:public"])

# gcc executables.
filegroup(
    name = "gcc",
    srcs = glob(["bin/arm-none-eabi-gcc*"]),
)

# g++ executables.
filegroup(
    name = "g++",
    srcs = glob(["bin/arm-none-eabi-g++*"]),
)

# gdb executables.
filegroup(
    name = "gdb",
    srcs = glob(["bin/arm-none-eabi-gdb*"]),
)

# cpp executables.
filegroup(
    name = "cpp",
    srcs = glob(["bin/arm-none-eabi-cpp*"]),
)

# gcov executables.
filegroup(
    name = "gcov",
    srcs = glob(["bin/arm-none-eabi-gcov*"]),
)

# ar executables.
filegroup(
    name = "ar",
    srcs = glob(["bin/arm-none-eabi-ar*"]),
)

# ld executables.
filegroup(
    name = "ld",
    srcs = glob(["bin/arm-none-eabi-ld*"]),
)

# nm executables.
filegroup(
    name = "nm",
    srcs = glob(["bin/arm-none-eabi-nm*"]),
)

# objcopy executables.
filegroup(
    name = "objcopy",
    srcs = glob(["bin/arm-none-eabi-objcopy*"]),
)

# objdump executables.
filegroup(
    name = "objdump",
    srcs = glob(["bin/arm-none-eabi-objdump*"]),
)

# strip executables.
filegroup(
    name = "strip",
    srcs = glob(["bin/arm-none-eabi-strip*"]),
)

# as executables.
filegroup(
    name = "as",
    srcs = glob(["bin/arm-none-eabi-as*"]),
)

# size executables.
filegroup(
    name = "size",
    srcs = glob(["bin/arm-none-eabi-size*"]),
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
        "arm-none-eabi/**",
        "lib/gcc/arm-none-eabi/**",
        'arm-none-eabi/include/**',
        'libexec/**',
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
    ],
)

filegroup(
    name = "linker_files",
    srcs = [
        ":ar",
        ":compiler_pieces",
        ":gcc",
        ":g++",
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
        ":gcov",
        ":ld",
        ":nm",
        ":objcopy",
        ":objdump",
        ":strip",
    ],
)
