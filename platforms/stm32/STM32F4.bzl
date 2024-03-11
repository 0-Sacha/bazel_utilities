"STM32F4.bzl"

load("@bazel_utilities//platforms/stm32/impl:stm32_toolchain.bzl", "stm32_toolchain")
load("@bazel_utilities//platforms/stm32/impl:utils.bzl", "stm32_hal_preconfig")

# CONSTRAINTS
STM32F4_PLATFORM_CPU = "@platforms//cpu:{}".format("armv7e-mf")
STM32F4_FAMILLY = "@bazel_utilities//platforms/stm32:stm32f4"

# ARM Cortex-M4 with FPU
stm32f4_hal_toolchain = stm32_toolchain(
    familly = "STM32F4",
    arm_cpu_version = "armv7e-mf",
    cpu = "-mcpu=cortex-m4",
    fpu = "-mfpu=fpv4-sp-d16",
    fpu_abi = "-mfloat-abi=hard",
    preconfig = stm32_hal_preconfig,
)
