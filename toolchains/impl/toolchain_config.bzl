# toolchain_config.bzl
""

load("@bazel_tools//tools/build_defs/cc:action_names.bzl", "ACTION_NAMES")
load("@bazel_tools//tools/cpp:cc_toolchain_config_lib.bzl", "action_config", "feature", "flag_group", "flag_set")

load("@bazel_utilities:hosts.bzl", "ButilsHostNameInfo")
load(":utils.bzl", "butils_tool_path", "butils_get_toolchain_archive_prefix", "ButilsToolchainsFlagsInfo", "butils_concat_toolchain_flags")


ButilsToolchainConfigInfo = provider("", fields = {
    'name': "",
    'toolchain_package': "",
    'toolchain_identifier': "",
    'toolchain_host_archive_prefix': "",
    'toolchain_host_bins': "",
    'host_name': "",
    'target_name': "",
    'target_cpu': "",

    'flags': "",
    'toolchain_formatted_flags': "",
})

def get_tool(bins, tool_name):
    return struct(type_name = "tool", tool = butils_tool_path(bins, tool_name))

def declare_action_configs(tool, action_names, implies = []):
    return [
        action_config(
            action_name = action_name,
            tools = [ tool ],
            implies = implies,
        )
        for action_name in action_names
    ]

def _cc_action_configs(bins, compiler):
    action_configs = []
    action_configs += declare_action_configs(
        get_tool(bins, compiler.c_compiler),
        [
            ACTION_NAMES.c_compile,
            ACTION_NAMES.cc_flags_make_variable,
            ACTION_NAMES.preprocess_assemble,
            # ACTION_NAMES.lto_backend,
            # ACTION_NAMES.lto_indexing,
            # ACTION_NAMES.linkstamp_compile,
            # ACTION_NAMES.clif_match,
        ]
    )

    action_configs += declare_action_configs(
        get_tool(bins, compiler.cxx_compiler),
        [
            ACTION_NAMES.cpp_compile,
            ACTION_NAMES.cpp_header_parsing,
            ACTION_NAMES.cpp_module_codegen,
            ACTION_NAMES.cpp_module_compile,
            ACTION_NAMES.assemble,
        ]
    )

    action_configs += declare_action_configs(
        get_tool(bins, compiler.cxx_compiler),
        [
            ACTION_NAMES.cpp_link_executable,
            ACTION_NAMES.cpp_link_dynamic_library,
            ACTION_NAMES.cpp_link_nodeps_dynamic_library,
        ]
    )

    action_configs += declare_action_configs(
        get_tool(bins, compiler.ar),
        [
            ACTION_NAMES.cpp_link_static_library
        ],
        implies = [ "archiver_flags", "linker_param_file" ]
    )

    action_configs += declare_action_configs(
        get_tool(bins, compiler.gcov),
        [
            ACTION_NAMES.llvm_cov
        ]
    )

    action_configs += declare_action_configs(
        get_tool(bins, compiler.strip),
        [
            ACTION_NAMES.strip
        ]
    )

    return action_configs

def declare_feature_configs(feature_name, action_names, flags):
    return [
        feature(
            name = feature_name,
            enabled = True,
            flag_sets = [
                flag_set(
                    actions = action_names,
                    flag_groups = [
                        flag_group(flags = flags),
                    ],
                ),
            ],
        )
    ]

def _cc_feature_config(toolchains_flags):
    features = []
    if len(toolchains_flags.copts + toolchains_flags.conlyopts) > 0:
        features += declare_feature_configs(
            "conly_copts",
            [
                ACTION_NAMES.c_compile,
                ACTION_NAMES.cc_flags_make_variable,
                ACTION_NAMES.linkstamp_compile,
                #ACTION_NAMES.lto_indexing,
                ACTION_NAMES.lto_backend,
                ACTION_NAMES.clif_match,
            ],
            toolchains_flags.copts + toolchains_flags.conlyopts
        )

    if len(toolchains_flags.copts + toolchains_flags.cxxopts) > 0:
        features += declare_feature_configs(
            "cxx_copts",
            [
                ACTION_NAMES.cpp_compile,
                ACTION_NAMES.cpp_header_parsing,
                ACTION_NAMES.cpp_module_codegen,
                ACTION_NAMES.cpp_module_compile,
                ACTION_NAMES.assemble,
                ACTION_NAMES.preprocess_assemble,
                ACTION_NAMES.linkstamp_compile,
            ],
            toolchains_flags.copts + toolchains_flags.cxxopts
        )

    if len(toolchains_flags.linkopts) > 0:
        features += declare_feature_configs(
            "linkopts",
            [
                ACTION_NAMES.linkstamp_compile,
                ACTION_NAMES.cpp_link_executable,
                ACTION_NAMES.cpp_link_dynamic_library,
                ACTION_NAMES.cpp_link_nodeps_dynamic_library,
                # ACTION_NAMES.cpp_link_static_library,
            ],
            toolchains_flags.linkopts
        )
    
    return features


ButilsPrefixInfo = provider("", fields = {
    'defines': "",
    'includes': ""
})

def get_butils_prefix(cmd_linux_style = True):
    if cmd_linux_style:
        return ButilsPrefixInfo(
            defines = "-D",
            includes = "-I",
        )
    else:
        return ButilsPrefixInfo(
            defines = "/D",
            includes = "/I",
        )

def _format_list_config(list_, ctx, true_host_name):
    res = []
    for element in list_:
        res.append(element.format(
            host_name = true_host_name,
            target_name = ctx.attr.target_name,
            target_cpu = ctx.attr.target_cpu
        ))
    return res

def butils_toolchain_config_rule(toolchain_package):
    def _impl_toolchain_config(ctx):
        true_host_name = ctx.attr.host_name
        if ctx.attr.host_name == "localhost":
            true_host_name = ctx.attr.localhost_name[ButilsHostNameInfo].host_name

        toolchain_host_archive_prefix = ctx.attr.toolchain_host_archive_prefix
        if toolchain_host_archive_prefix == "":
            toolchain_host_archive_prefix = butils_get_toolchain_archive_prefix(host_name = ctx.attr.host_name, toolchain_package = toolchain_package)

        toolchain_formatted_flags = ButilsToolchainsFlagsInfo(
            copts = _format_list_config(toolchain_package.flags.copts, ctx, true_host_name),
            conlyopts = _format_list_config(toolchain_package.flags.conlyopts, ctx, true_host_name),
            cxxopts = _format_list_config(toolchain_package.flags.cxxopts, ctx, true_host_name),
            linkopts = _format_list_config(toolchain_package.flags.linkopts, ctx, true_host_name),
        )

        prefix = get_butils_prefix(toolchain_package.toolchain_registry.linux_style_cmd_line)

        utilities_defines = []
        if toolchain_package.toolchain_registry.use_utilities_defines:
            utilities_defines.append("UTILITIES_COMPILER_BAZEL")

            if "linux" in ctx.attr.host_name:
                utilities_defines.append("UTILITIES_SYSTEM_LINUX")
            elif "windows" in ctx.attr.host_name:
                utilities_defines.append("UTILITIES_SYSTEM_WINDOWS")
            elif "osx" in ctx.attr.host_name:
                utilities_defines.append("UTILITIES_SYSTEM_OSX")

            if "x86_64" in ctx.attr.host_name:
                utilities_defines.append("UTILITIES_PLATFORM_X86_64")
            elif "x86" in ctx.attr.host_name:
                utilities_defines.append("UTILITIES_PLATFORM_X86")
            elif "arm" in ctx.attr.host_name:
                utilities_defines.append("UTILITIES_PLATFORM_ARM")
        
        utilities_flags = []
        for define in utilities_defines:
            utilities_flags.append(prefix.defines + " " + define)

        flags = ButilsToolchainsFlagsInfo(
            copts = ctx.attr.copts + utilities_flags,
            conlyopts = ctx.attr.conlyopts,
            cxxopts = ctx.attr.cxxopts,
            linkopts = ctx.attr.linkopts,
        )

        artifact_name_patterns = []
        if true_host_name in toolchain_package.toolchain_registry.artifact_name_patterns:
            artifact_name_patterns = toolchain_package.toolchain_registry.artifact_name_patterns[true_host_name]

        for c_mode, options in toolchain_package.toolchain_registry.build_configs.items():
            if ctx.attr.compilation_mode == c_mode:
                if "copts" in options:
                    flags.copts += options["copts"]
                if "conlyopts" in options:
                    flags.conlyopts += options["conlyopts"]
                if "cxxopts" in options:
                    flags.cxxopts += options["cxxopts"]
                if "linkopts" in options:
                    flags.linkopts += options["linkopts"]
        
        return [
            ButilsToolchainConfigInfo(
                name = ctx.label.name,
                toolchain_package = toolchain_package,
                toolchain_identifier = ctx.attr.toolchain_identifier,
                toolchain_host_archive_prefix = toolchain_host_archive_prefix,
                toolchain_host_bins = ctx.files.toolchain_bins,
                host_name = ctx.attr.host_name,
                target_name = ctx.attr.target_name,
                target_cpu = ctx.attr.target_cpu,

                flags = flags,
                toolchain_formatted_flags = toolchain_formatted_flags,
            ),
            cc_common.create_cc_toolchain_config_info(
                ctx = ctx,
                toolchain_identifier = ctx.attr.toolchain_identifier,
                host_system_name = true_host_name,
                target_system_name = ctx.attr.target_name,
                target_cpu = ctx.attr.target_cpu,

                target_libc = toolchain_package.toolchain_registry.toolchain_data.target_libc,
                compiler = toolchain_package.toolchain_registry.compiler.name,
                abi_version = toolchain_package.toolchain_registry.toolchain_data.abi_version,
                abi_libc_version = toolchain_package.toolchain_registry.toolchain_data.abi_libc_version,
                cxx_builtin_include_directories = _format_list_config(toolchain_package.cxx_builtin_include_directories, ctx, true_host_name),

                action_configs = _cc_action_configs(ctx.files.toolchain_bins, toolchain_package.toolchain_registry.compiler),
                features = _cc_feature_config(butils_concat_toolchain_flags(flags, toolchain_formatted_flags)),

                artifact_name_patterns = artifact_name_patterns,
            )
        ]

    _rule_toolchain_config = rule(
        implementation = _impl_toolchain_config,
        attrs = {
            'toolchain_identifier': attr.string(default = "local"),
            'toolchain_host_archive_prefix': attr.string(default = ""),
            'host_name': attr.string(default = "localhost"),
            'localhost_name': attr.label(default = None, providers = [ButilsHostNameInfo]),
            'target_name': attr.string(default = "local"),
            'target_cpu': attr.string(default = ""),
            'compilation_mode': attr.string(default = ""),

            'copts': attr.string_list(default = []),
            'conlyopts': attr.string_list(default = []),
            'cxxopts': attr.string_list(default = []),
            'linkopts': attr.string_list(default = []),

            'toolchain_bins': attr.label(mandatory = True, allow_files = True),
        },
        provides = [ButilsToolchainConfigInfo, CcToolchainConfigInfo]
    )

    return _rule_toolchain_config

# When localhost:
# utilities_defines += select({
#     "@platforms//os:linux" : [ "LINUX" ],
#     "@platforms//os:windows" : [ "WINDOWS" ],
#     "@platforms//os:osx" : [ "OSX" ],
# })
# utilities_defines += select({
#     "@platforms//cpu:x86" : [ "X86" ],
#     "@platforms//cpu:x86_64" : [ "X86_64" ],
#     "@platforms//cpu:arm" : [ "ARM" ],
# })
