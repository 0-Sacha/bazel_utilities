"""deps.bzl"""

load("@bazel_utilities//:hosts.bzl", "default_localhost")

load("@bazel_utilities//toolchains/impl:toolchain.bzl", "butils_toolchain")
load("@bazel_utilities//toolchains/impl:toolchain_config.bzl", "butils_toolchain_config_rule")
load("@bazel_utilities//toolchains/impl:toolchain_registry.bzl", "butils_toolchain_registry", "butils_toolchain_package")
load("@bazel_utilities//toolchains/impl:utils.bzl", "butils_get_package_from_toolchain")

load(":arm_all_files.bzl", "arm_all_files")
load("arm_none_eabi_archives.bzl", "ARM_NONE_EABI_ARCHIVES_REGISTRY")

arm_none_eabi_registry = butils_toolchain_registry(
    name = "arm_none_eabi",
    registry = ARM_NONE_EABI_ARCHIVES_REGISTRY,
    target_libc = "gcc",
    abi_version = "eabi",
    compiler = {
        "name": "arm-none-eabi-gcc",
        "base_name": "arm-none-eabi-",
        "c_compiler": "gcc",
        "cxx_compiler": "g++"
    },
    copts = [
        "-no-canonical-prefixes",
        "-fno-canonical-system-headers",
        
        "-Iexternal/arm_none_eabi_{host_name}/arm-none-eabi/include",
        "-Iexternal/arm_none_eabi_{host_name}/lib/gcc/arm-none-eabi/{compiler_version}/include",
        "-Iexternal/arm_none_eabi_{host_name}/lib/gcc/arm-none-eabi/{compiler_version}/include-fixed",
        "-Iexternal/arm_none_eabi_{host_name}/arm-none-eabi/include/c++/{compiler_version}/",
        "-Iexternal/arm_none_eabi_{host_name}/arm-none-eabi/include/c++/{compiler_version}/arm-none-eabi",
    ],
    linkopts = [
        "-no-canonical-prefixes",
        "-fno-canonical-system-headers",

        "-Lexternal/arm_none_eabi_{host_name}/arm-none-eabi/lib",
        "-Lexternal/arm_none_eabi_{host_name}/lib/gcc/arm-none-eabi/{compiler_version}",
    ],
    cxx_builtin_include_directories = [
        "external/arm_none_eabi_{host_name}/arm-none-eabi/include",
        "external/arm_none_eabi_{host_name}/lib/gcc/arm-none-eabi/{compiler_version}/include",
        "external/arm_none_eabi_{host_name}/lib/gcc/arm-none-eabi/{compiler_version}/include-fixed",
        "external/arm_none_eabi_{host_name}/arm-none-eabi/include/c++/{compiler_version}/",
        "external/arm_none_eabi_{host_name}/arm-none-eabi/include/c++/{compiler_version}/arm-none-eabi",
    ],
    # TODO :
    # extra_output_files = {
    #     "{bin_name}.map": {
    #         "linkopts": "-Wl,-Map=${bin_name}.map,--cref"
    #     }
    # },
    # TODO
    # build_configs = {
    #     "dgb": {
    #         "copts": [ "-Og", "-g", "-gdwarf-2" ]
    #     },
    #     "opt": {
    #         "copts": [ "-O3" ]
    #     }
    # }
)

arm_none_eabi_latest_package = butils_toolchain_package(toolchain_registry = arm_none_eabi_registry, version = "latest")
_arm_none_eabi_latest_config = butils_toolchain_config_rule(arm_none_eabi_latest_package)
arm_none_eabi_latest = butils_toolchain(arm_none_eabi_latest_package, _arm_none_eabi_latest_config)

def _all_files(name, binary, hosts_info = default_localhost, elf = None, bin = None, hex = None):
    for host_name, host_data in hosts_info.items():
        default_base_name = binary
        if binary[0] == ":":
            default_base_name = binary[1:]
        else:
            binary = ":{}".format(default_base_name)
        if elf == None:
            elf = "{}.elf".format(default_base_name)
        if bin == None:
            bin = "{}.bin".format(default_base_name)
        if hex == None:
            hex = "{}.hex".format(default_base_name)
        arm_all_files(
            name = name,
            objcopy_bin = butils_get_package_from_toolchain("objcopy", host_name, arm_none_eabi),
            binary = binary,
            elf = elf,
            bin = bin,
            hex = hex,
            exec_compatible_with = host_data.constraints,
        )

ButilsToolchainGeneratorArmNoneEabiInfo = provider("", fields = {
    'register': "",
    'gen': "",
    'all_files': "",
})

arm_none_eabi_toolchain = ButilsToolchainGeneratorArmNoneEabiInfo(
    register = _arm_none_eabi_toolchain.register,
    gen = _arm_none_eabi_toolchain.gen,
    all_files = _all_files,
)
