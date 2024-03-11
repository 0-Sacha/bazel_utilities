""

load(":archives_registry.bzl", "archive_repository_name", "get_full_version_label")
load(":utils.bzl", "ButilsToolchainsFlagsInfo")

ButilsToolchainRegistryInfo = provider("", fields = {
    'name': "",
    'registry': "",

    'compiler': "",
    'toolchain_data': "",

    'localhost_path': "",
    'localhost_prefix': "",
    'custom_localhost_name': "",

    'flags': "",
    'cxx_builtin_include_directories': "",

    'extra_output_files': "",
    'build_configs': "",
    'artifact_name_patterns': "",

    'linux_style_cmd_line': "",
    'use_utilities_defines': ""
})

ButilsToolchainPackageInfo = provider("", fields = {
    'version': "",
    'toolchain_registry': "",
    'archive_repository': "",

    'flags': "",
    'cxx_builtin_include_directories': ""
})

def _toolchain_compiler(compiler):
    base_name = compiler.get("base_name", "")
    return struct(
        name = compiler.get("name", ""),

        c_compiler = base_name + compiler.get("c_compiler", "gcc"),
        cxx_compiler = base_name + compiler.get("cxx_compiler", "g++"),

        ld = base_name + compiler.get("ld", "ld"),
        ar = base_name + compiler.get("ar", "ar"),
        nm = base_name + compiler.get("nm", "nm"),
        objdump = base_name + compiler.get("objdump", "objdump"),
        objcopy = base_name + compiler.get("objcopy", "objcopy"),
        gcov = base_name + compiler.get("gcov", "gcov"),
        strip = base_name + compiler.get("strip", "strip"),
        gdb = base_name + compiler.get("gdb", "gdb"),
    )

# buildifier: disable=function-docstring
def butils_toolchain_registry(
        name,
        registry,

        compiler,
        target_libc = "",
        abi_libc_version = "",
        abi_version = "",

        localhost_path = "//:",
        localhost_prefix = None,
        custom_localhost_name = False,

        copts = [],
        conlyopts = [],
        cxxopts = [],
        linkopts = [],
        cxx_builtin_include_directories = [],

        extra_output_files = [],
        build_configs = {},
        artifact_name_patterns = {},

        linux_style_cmd_line = True,
        use_utilities_defines = True
    ):

    if localhost_prefix == None:
        localhost_prefix = "{}/localhost/".format(name)

    toolchain_data = struct(
        abi_libc_version = abi_libc_version,
        target_libc = target_libc,
        abi_version = abi_version
    )

    flags = ButilsToolchainsFlagsInfo(
        copts = copts,
        conlyopts = conlyopts,
        cxxopts = cxxopts,
        linkopts = linkopts
    )

    return ButilsToolchainRegistryInfo(
        name = name,
        registry = registry,

        compiler = _toolchain_compiler(compiler),
        toolchain_data = toolchain_data,

        localhost_path = localhost_path,
        localhost_prefix = localhost_prefix,
        custom_localhost_name = custom_localhost_name,

        flags = flags,
        cxx_builtin_include_directories = cxx_builtin_include_directories,

        extra_output_files = extra_output_files,
        build_configs = build_configs,
        artifact_name_patterns = artifact_name_patterns,

        linux_style_cmd_line = linux_style_cmd_line,
        use_utilities_defines = use_utilities_defines
    )



def _format_list_toolchain_package(list_, archive_details):
    res = []
    for element in list_:
        res.append(element.format(
            host_name = "{host_name}",
            **archive_details
        ))
    return res

def _toolchain_flags(flags, archive_details):
    return ButilsToolchainsFlagsInfo(
        copts = _format_list_toolchain_package(flags.copts, archive_details),
        conlyopts = _format_list_toolchain_package(flags.conlyopts, archive_details),
        cxxopts = _format_list_toolchain_package(flags.cxxopts, archive_details),
        linkopts = _format_list_toolchain_package(flags.linkopts, archive_details),
    )

def butils_toolchain_package(toolchain_registry, version = "latest"):
    full_version_label = get_full_version_label(toolchain_registry, version)
    return ButilsToolchainPackageInfo(
        version = full_version_label,
        toolchain_registry = toolchain_registry,
        archive_repository = archive_repository_name(host_name = "{host_name}", toolchain_registry = toolchain_registry, version = full_version_label),

        flags = _toolchain_flags(toolchain_registry.flags, toolchain_registry.registry[version]["details"]),
        cxx_builtin_include_directories = _format_list_toolchain_package(toolchain_registry.cxx_builtin_include_directories, toolchain_registry.registry[version]["details"])
    )
