"gen_toolchain.bzl"

load("@bazel_utilities//:hosts.bzl", "default_localhost")
load(":archives_registry.bzl", "register_archives_from_registry")
load(":utils.bzl", "butils_get_toolchain_archive_prefix")

# buildifier: disable=name-conventions
ButilsToolchainGenerator = provider("", fields = {
    'register': "",
    'gen': ""
})

# buildifier: disable=name-conventions
ButilsToolchainId = provider("", fields = {
    'identifier': "",
    'host_name': "",
    'host_archive': "",
    'target_name': "",
    'target_cpu': "",
})

toolchain_identifier_format = "{}-{}-{}{}" # toolchain_name-host_name-target_namecpu

# buildifier: disable=unnamed-macro
def butils_toolchain(
        toolchain_package,
        toolchain_config_rule,
        ctx_copts = [],
        ctx_conlyopts = [],
        ctx_cxxopts = [],
        ctx_linkopts = [],
        ctx_target_compatible_with = [],
        hosts_info = default_localhost,
    ):

    def _register(target_name = "localhost", target_cpu = ""):
        for host_name in hosts_info:
            toolchain_identifier = toolchain_identifier_format.format(toolchain_package.toolchain_registry.name, host_name, target_name, target_cpu)
            # buildifier: disable=print
            print("register_toolchain: toolchain_{}".format(toolchain_identifier))
            register_archives_from_registry(toolchain_registry = toolchain_package.toolchain_registry, version = toolchain_package.version, host_name = host_name)
            native.register_toolchains("@//:toolchain_{}".format(toolchain_identifier))
    
    def _gen(
        target_name = "localhost",
        target_cpu = "",
        hosts_info = default_localhost,
        copts = [],
        conlyopts = [],
        cxxopts = [],
        linkopts = [],
        target_compatible_with = []
        ):
        toolchain_ids = []
        for host_name, host_constraints in hosts_info.items():
            toolchain_host_archive_prefix = butils_get_toolchain_archive_prefix(host_name, toolchain_package)
            toolchain_identifier = toolchain_identifier_format.format(toolchain_package.toolchain_registry.name, host_name, target_name, target_cpu)
            # buildifier: disable=print
            print("gen_toolchain: toolchain_{}".format(toolchain_identifier))

            localhost_name = ""
            if host_name == "localhost":
                if toolchain_package.toolchain_registry.custom_localhost_name:
                    localhost_name = "{}localhost_name".format(toolchain_host_archive_prefix)
                else:
                    localhost_name = "@bazel_utilities//:localhost_name"

            toolchain_config_rule(
                name = "config_{}".format(toolchain_identifier),
                toolchain_identifier = toolchain_identifier,
                toolchain_bins = "{}compiler_components".format(toolchain_host_archive_prefix),
                host_name = host_name,
                localhost_name = localhost_name,
                target_name = target_name,
                target_cpu = target_cpu,
                copts = ctx_copts + copts,
                conlyopts = ctx_conlyopts + conlyopts,
                cxxopts = ctx_cxxopts + cxxopts,
                linkopts = ctx_linkopts + linkopts,
            )

            native.cc_toolchain(
                name = "cc_toolchain_{}".format(toolchain_identifier),
                toolchain_identifier = toolchain_identifier,
                toolchain_config = "config_{}".format(toolchain_identifier),
                
                all_files = "{}compiler_pieces".format(toolchain_host_archive_prefix),
                ar_files = "{}ar".format(toolchain_host_archive_prefix),
                compiler_files = "{}compiler_files".format(toolchain_host_archive_prefix),
                dwp_files = "{}dwp".format(toolchain_host_archive_prefix),
                linker_files = "{}linker_files".format(toolchain_host_archive_prefix),
                objcopy_files = "{}objcopy".format(toolchain_host_archive_prefix),
                strip_files = "{}strip".format(toolchain_host_archive_prefix),
                supports_param_files = 0
            )

            native.toolchain(
                name = "toolchain_{}".format(toolchain_identifier),
                target_compatible_with = ctx_target_compatible_with + target_compatible_with,
                exec_compatible_with = host_constraints,
                toolchain = "cc_toolchain_{}".format(toolchain_identifier),
                toolchain_type = "@bazel_tools//tools/cpp:toolchain_type"
            )

            toolchain_ids.append(
                ButilsToolchainId(
                    identifier = toolchain_identifier,
                    host_name = host_name,
                    target_name = target_name,
                    target_cpu = target_cpu,
                    host_archive = toolchain_host_archive_prefix,
                )
            )
        return toolchain_ids
    
    return ButilsToolchainGenerator(
        register = _register,
        gen = _gen
    )
