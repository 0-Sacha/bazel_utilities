"vscode_config.bzl"

load("//bazel_utilities/toolchains/impl:utils.bzl", "butils_tool_path")
load("//bazel_utilities/toolchains/impl:toolchain_config.bzl", "ButilsToolchainConfigInfo")
load("//bazel_utilities/toolchains/impl:utils.bzl", "butils_get_toolchain_archive_prefix")

load("//bazel_utilities/tools:tools.bzl", "list_remove_duplicates", "flag_change_external_path")

ButilsVSCodeConfigInfo = provider(fields = {
    "name": "",
    "include_path": "",
    "defines": "",
    "cpp_standard": "",
    "c_standard": "",
    "intelli_sense_mode": "",
    "compiler_path": "",
    "compiler_args": "",
})

def _impl_vscode_config(ctx):
    compiler = butils_tool_path(ctx.files.compiler_bins, ctx.attr.compiler_name)
    compiler_path = ctx.attr.compiler_archive_path + compiler.path

    return [
        ButilsVSCodeConfigInfo(
            name = ctx.label.name,
            include_path = ctx.attr.include_path,
            defines = ctx.attr.defines,
            cpp_standard = ctx.attr.cpp_standard,
            c_standard = ctx.attr.c_standard,
            intelli_sense_mode = ctx.attr.intelli_sense_mode,
            compiler_path = compiler_path,
            compiler_args = ctx.attr.compiler_args,
        )
    ]

butils_vscode_config = rule(
    implementation = _impl_vscode_config,
    attrs = {
        'include_path': attr.string_list(default = []),
        'defines': attr.string_list(default = []),
        'cpp_standard': attr.string(default = "c++20"),
        'c_standard': attr.string(default = "c17"),
        'compiler_args': attr.string_list(default = []),
        'intelli_sense_mode': attr.string(default = ""),
        'compiler_bins': attr.label(mandatory = True, allow_files = True),
        'compiler_name': attr.string(default = "gcc"),
    },
    provides = [ButilsVSCodeConfigInfo]
)

def _options_includes(flag):
    return "include_path", flag[2:]

def _options_link(flag):
    return "compiler_args", flag

def _options_standard(flag):
    option = flag[5:]
    if '++' in option:
        return "cpp_standard", option
    else:
        return "c_standard", option

def _options_define(flag):
    return "defines", flag[2:]

def _options_others(flag):
    return "compiler_args", flag

_flag_options = {
    "-I": _options_includes,
    "-L": _options_link,
    "-l": _options_link,
    "-D": _options_define,
    "-std=": _options_standard,
}

def _switch_flags(all_flags, default_values):
    context = {
        "include_path": [],
        "defines": [],
        "compiler_args": [],
        "c_standard": [],
        "cpp_standard": [],
    }

    context["include_path"] += default_values.force_include_path
    context["defines"] += default_values.force_defines
    context["compiler_args"] += default_values.force_compiler_args
    context["c_standard"] += [ default_values.default_c_standard ]
    context["cpp_standard"] += [ default_values.default_cpp_standard ]

    for flag in all_flags:
        matched = False
        for option, func in _flag_options.items():
            if flag.startswith(option):
                idx, values = func(flag)
                context[idx].append(values)
                matched = True
                break
        if not matched:
            idx, values = _options_others(flag)
            context[idx].append(values)
    return context

def _impl_vscode_config_toolchain(ctx):
    toolchain_config = ctx.attr.toolchain_config[ButilsToolchainConfigInfo]

    compiler = butils_tool_path(toolchain_config.toolchain_host_bins, toolchain_config.toolchain_package.compiler.cxx_compiler)
    compiler_path = "$(bazelisk info output_base)/" + compiler.path

    toolchain_formatted_flags = toolchain_config.toolchain_formatted_flags.copts + \
                                    toolchain_config.toolchain_formatted_flags.conlyopts + \
                                    toolchain_config.toolchain_formatted_flags.cxxopts + \
                                    toolchain_config.toolchain_formatted_flags.linkopts
    
    toolchain_formatted_flags_external = []
    for flag in toolchain_formatted_flags:
        toolchain_formatted_flags_external.append(flag_change_external_path(flag, "$(bazelisk info output_base)/"))

    flags = toolchain_config.flags.copts + \
                toolchain_config.flags.conlyopts + \
                toolchain_config.flags.cxxopts + \
                toolchain_config.flags.linkopts

    context = _switch_flags(flags + toolchain_formatted_flags_external, ctx.attr)

    return [
        ButilsVSCodeConfigInfo(
            name = ctx.label.name,
            compiler_path = compiler_path,
            compiler_args = context["compiler_args"],
            include_path = context["include_path"],
            defines = context["defines"],
            cpp_standard = context["cpp_standard"][-1],
            c_standard = context["c_standard"][-1],
            intelli_sense_mode = ctx.attr.intelli_sense_mode,
        )
    ]

butils_vscode_config_toolchain = rule(
    implementation = _impl_vscode_config_toolchain,
    attrs = {
        'toolchain_config': attr.label(providers = [ButilsToolchainConfigInfo]),
        'intelli_sense_mode': attr.string(default = ""),

        'default_cpp_standard': attr.string(default = "c++20"),
        'default_c_standard': attr.string(default = "c17"),

        'force_compiler_args': attr.string_list(default = []),
        'force_include_path': attr.string_list(default = []),
        'force_defines': attr.string_list(default = []),
    },
    provides = [ButilsVSCodeConfigInfo]
)

def butils_vscode_config_ids(
    toolchain_ids,
    intelli_sense_mode = "",
    default_cpp_standard = "c++20",
    default_c_standard = "c17",
    force_compiler_args = [],
    force_include_path = [],
    force_defines = [],
    ):
    configs = []
    for id in toolchain_ids:
        configs.append(id.identifier)
        butils_vscode_config_toolchain(
            name = id.identifier,
            toolchain_config = ":config_{}".format(id.identifier),
            intelli_sense_mode = intelli_sense_mode,
            default_cpp_standard = default_cpp_standard,
            default_c_standard = default_c_standard,
            force_compiler_args = force_compiler_args,
            force_include_path = force_include_path,
            force_defines = force_defines,
        )
    return configs