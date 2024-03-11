"utils.bzl"

load("@bazel_utilities:hosts.bzl", "default_localhost")
load("@bazel_utilities//toolchains/arm_none_eabi:arm_none_eabi.bzl", "arm_none_eabi_toolchain")
load("@bazel_utilities//tools/vscode:vscode_files.bzl", "butils_vscode_bazel_task")
load(":preconfig.bzl", "stm32_preconfig")

stm32_hal_preconfig = stm32_preconfig(
    copts = [
        "-DUSE_HAL_DRIVER",
        "-ICore/Inc",
        "-IDrivers/{stm32_familly}xx_HAL_Driver/Inc",
        "-IDrivers/{stm32_familly}xx_HAL_Driver/Inc/Legacy",
        "-IDrivers/CMSIS/Device/ST/{stm32_familly}xx/Include",
        "-IDrivers/CMSIS/Include",
    ],
    linkopts = [
        "-lc",
        "-lm",
        "-lnosys",
        "-specs=nosys.specs",
    ]
)

# TODO:
# buildifier: disable=function-docstring
def stm32_binary(
    name,
    mcu_id,
    srcs = [],
    deps = [],
    copts = [],
    defines = [],
    linkopts = [],
    hosts_info = "localhost",

    vscode_rules = False,
    vscode_cwd = "${workspaceFolder}",
    arm_none_eabi_package = arm_none_eabi_toolchain
    ):
    mcu_id = mcu_id.upper()
    native.cc_binary(
        name = name,
        srcs = srcs,
        deps = deps + [
            "//:{}_startup".format(mcu_id),
        ],
        copts = copts,
        defines = defines,
        linkopts = linkopts,
        visibility = ["//visibility:public"],
    )

    arm_none_eabi_package.all_files(
        name = "{}_all".format(name),
        binary = name,
        hosts_info = hosts_info,
    )

    if vscode_rules:
        butils_vscode_bazel_task(
            name = "{}_debug".format(name),
            package_name = "{}_all".format(name),
            cwd = vscode_cwd,
            compilation_mode = "dbg",
            platforms = mcu_id
        )

        butils_vscode_bazel_task(
            name = "{}_release".format(name),
            package_name = "{}_all".format(name),
            cwd = vscode_cwd,
            compilation_mode = "opt",
            platforms = mcu_id
        )

# TODO:
# buildifier: disable=function-docstring
# buildifier: disable=unnamed-macro
def stm32_STM32CUBE_Core_BUILD():
    native.filegroup(
        name = "Include",
        srcs =  native.glob(["Inc/*.h"]),
        visibility = ["//visibility:public"]
    )

    native.filegroup(
        name = "Srcs",
        srcs =  native.glob([ "Src/*.c" ]) + native.glob([ "Src/*.cpp" ]),
        visibility = ["//visibility:public"]
    )

    native.cc_library(
        name = "Lib",
        hdrs = native.glob([ "Inc/*.h" ]) + [ ":Include" ],
        visibility = ["//visibility:public"],
    )