"""cc_toolchain rule

According to:
https://bazel.build/docs/cc-toolchain-config-reference
"""

load("@rules_cc//cc:action_names.bzl", "ACTION_NAMES")

load("//toolchains:artifacts.bzl", "artifacts_patterns_unpack")
load("//toolchains:tools_utils.bzl",
    "link_actions_to_tool",
    "toolchain_tool_path_from_paths",
    "toolchain_path_from_tools",
    "toolchain_tools_from_paths",
    "toolchain_tools_from_bins_path_label",
    "toolchain_tools_from_bins_keyed",
)
# load("//toolchains:xflags.bzl", "xflags_unpack")

load("//toolchains/toolchains_features:toolchains_features.bzl", "TOOLCHAINS_FEATURES")

def toolchain_tools_actions_config(ctx, toolchain_tools):
    """Tools action config

    Args:
        toolchain_tools: The context toolchain's paths
    Returns:
        The list of all action_configs for this context
    """
    action_configs = []

    ########## Assembler actions ##########
    action_configs += link_actions_to_tool(
        toolchain_tools,
        "cxx",
        [ ACTION_NAMES.preprocess_assemble ],
        implies = [ "toolchain-assemble", "toolchain-assember-w-preprocess" ],
    )
    action_configs += link_actions_to_tool(
        toolchain_tools,
        "cxx",
        [ ACTION_NAMES.assemble ],
        implies = [ "toolchain-assemble" ],
    )

    ########## Compiler actions ##########
    # !NOT DONE: cc-flags-make-variable [ ACTION_NAMES.cc_flags_make_variable ]
    # !NOT DONE: c++-module-codegen [ ACTION_NAMES.cpp_module_codegen ]
    # !NOT DONE: c++-module-compile [ ACTION_NAMES.cpp_module_compile ]
    action_configs += link_actions_to_tool(
        toolchain_tools,
        "cxx",
        [ ACTION_NAMES.c_compile ],
        implies = [ "toolchain-compile", "toolchain-compile-c" ],
    )
    action_configs += link_actions_to_tool(
        toolchain_tools,
        "cxx",
        [ ACTION_NAMES.cpp_compile ],
        implies = [ "toolchain-compile", "toolchain-compile-cxx" ],
    )
    action_configs += link_actions_to_tool(
        toolchain_tools,
        "cxx",
        [ ACTION_NAMES.cpp_header_parsing ],
        implies = [ "toolchain-compile-header-parsing" ],
    )
    action_configs += link_actions_to_tool(
        toolchain_tools,
        "cxx",
        [ ACTION_NAMES.linkstamp_compile ],
        implies = [ "toolchain-compile", "toolchain-compile-cxx", "toolchain-compile-linkstamp"],
    )

    ########## Link actions ##########
    action_configs += link_actions_to_tool(
        toolchain_tools,
        "cxx",
        [
            ACTION_NAMES.cpp_link_dynamic_library,
            ACTION_NAMES.lto_index_for_dynamic_library,
        ],
        implies = [ "toolchain-link-dynamic-lib" ],
    )
    action_configs += link_actions_to_tool(
        toolchain_tools,
        "cxx",
        [
            ACTION_NAMES.cpp_link_nodeps_dynamic_library,
            ACTION_NAMES.lto_index_for_nodeps_dynamic_library,
        ],
        implies = [ "toolchain-link-dynamic-lib", "toolchain-link-nodeps" ],
    )
    action_configs += link_actions_to_tool(
        toolchain_tools,
        "cxx",
        [
            ACTION_NAMES.cpp_link_executable,
            ACTION_NAMES.lto_index_for_executable,
        ],
        implies = [ "toolchain-link-exe" ],
    )

    ########## AR actions ##########
    action_configs += link_actions_to_tool(
        toolchain_tools,
        "ar",
        [ ACTION_NAMES.cpp_link_static_library ],
        implies = [ "toolchain-archive-static-lib" ],
    )

    ########## LTO actions ##########
    action_configs += link_actions_to_tool(
        toolchain_tools,
        "cxx",
        [ ACTION_NAMES.lto_backend ],
        implies = [ "toolchain-lto-backend" ],
    )
    action_configs += link_actions_to_tool(
        toolchain_tools,
        "cxx",
        [
            ACTION_NAMES.lto_indexing,
            # Theses actions are already link to a tool
            # ACTION_NAMES.lto_index_for_executable,
            # ACTION_NAMES.lto_index_for_dynamic_library,
            # ACTION_NAMES.lto_index_for_nodeps_dynamic_library,
        ],
        implies = [ "toolchain-lto-indexing" ],
    )

    ########## Strip actions ##########
    action_configs += link_actions_to_tool(
        toolchain_tools,
        "strip",
        [ ACTION_NAMES.strip ],
        implies = [ "toolchain-strip" ],
    )

    ########## Cliff ##########
    if ctx.attr.disable_clif == False:
        action_configs += link_actions_to_tool(
            toolchain_tools,
            "cxx",
            [ ACTION_NAMES.clif_match ],
            implies = [ "toolchain-clif-match" ],
        )

    ########## ObjC / ObjC++ ##########
    # DISCARDED: objc-compile [ ACTION_NAMES.objc_compile ]
    # DISCARDED: objc++-compile [ ACTION_NAMES.objc_executable ]
    # DISCARDED: objc-executable [ ACTION_NAMES.objc_fully_link ]
    # DISCARDED: objc-fully-link [ ACTION_NAMES.objcpp_compile ]

    return action_configs

def _impl_create_cc_toolchain_config_info(ctx, toolchain_tools, toolchain_paths):
    return cc_common.create_cc_toolchain_config_info(
        ctx = ctx,
        toolchain_identifier = ctx.attr.toolchain_identifier,

        compiler = ctx.attr.compiler_type,
 
        features = TOOLCHAINS_FEATURES[ctx.attr.compiler_type](ctx, ctx.attr.compiler_type),
        action_configs = toolchain_tools_actions_config(ctx, toolchain_tools),
        tool_paths = toolchain_tool_path_from_paths(toolchain_paths),

        cxx_builtin_include_directories = ctx.attr.toolchain_builtin_includedirs_isystem + ctx.attr.toolchain_builtin_includedirs,

        artifact_name_patterns = artifacts_patterns_unpack(ctx.attr.artifacts_patterns_packed),

        builtin_sysroot = ctx.attr.builtin_sysroot,

        # Deprecated, Need default value
        abi_version = ctx.attr.abi_version,
        abi_libc_version = ctx.attr.abi_libc_version,

        # Deprecated, Need default value
        target_cpu = "unknown",
        target_libc = "unknown",
        target_system_name = "unknown",
        host_system_name = "unknown",
    )

_IMPL_ATTR_CC_TOOLCHAIN_CONFIG = {
        'toolchain_identifier': attr.string(mandatory = True),

        'compiler_type': attr.string(mandatory = True),

        # Theses path are added to the `cxx_builtin_include_directories`.
        # In case theses path are not visible during remote/sandboxed build, you can use `toolchain_builtin_includedirs_isystem` that will add theses path to the toolchain arguments by using `-isystem`
        'toolchain_builtin_includedirs': attr.string_list(default = []),
        'toolchain_builtin_includedirs_isystem': attr.string_list(default = []),

        'builtin_sysroot': attr.string(),

        'copts': attr.string_list(default = []),
        'conlyopts': attr.string_list(default = []),
        'cxxopts': attr.string_list(default = []),
        'linkopts': attr.string_list(default = []),
        'defines': attr.string_list(default = []),
        'includedirs': attr.string_list(default = []),
        'linkdirs': attr.string_list(default = []),
        'linklibs': attr.string_list(default = []),
        # dbg / opt
        'dbg_copts': attr.string_list(default = []),
        'dbg_linkopts': attr.string_list(default = []),
        'opt_copts': attr.string_list(default = []),
        'opt_linkopts': attr.string_list(default = []),

        'artifacts_patterns_packed' : attr.string_list(default = []),
        
        'verbose_steps': attr.string_list(default = []),

        # TODO:
        'xflags_packed': attr.string_dict(default = {}),
        'enable_features': attr.string_list(default = []),
        'extras_features': attr.string_list(default = []),

        # Config:
        'disable_dynamiclink': attr.bool(default = False),
        'disable_runtimelib': attr.bool(default = True),
        'disable_interfacelib': attr.bool(default = True),
        'disable_clif': attr.bool(default = True),
        'disable_lto': attr.bool(default = False),
        'disable_fdo': attr.bool(default = False),
        'disable_cov': attr.bool(default = False),
        'disable_sanitizers': attr.bool(default = False),
        'disable_pic': attr.bool(default = False),

        # Not really useful, just forwarders
        'abi_version': attr.string(default = "local"),
        'abi_libc_version': attr.string(default = "local")
    }

def _impl_cc_toolchain_config_path(ctx):
    return _impl_create_cc_toolchain_config_info(ctx, toolchain_tools_from_paths(ctx.attr.toolchain_paths), ctx.attr.toolchain_paths)

cc_toolchain_config_path = rule(
    implementation = _impl_cc_toolchain_config_path,
    attrs = dict(
        _IMPL_ATTR_CC_TOOLCHAIN_CONFIG,
        toolchain_paths = attr.string_dict(mandatory = True),
    ),
    fragments = ["cpp"],
    provides = [CcToolchainConfigInfo],
)

def _impl_cc_toolchain_config_bins(ctx):
    toolchain_tools = toolchain_tools_from_bins_path_label({
        'cpp': ctx.file.cpp_bin,
        'cc': ctx.file.cc_bin,
        'cxx': ctx.file.cxx_bin,
        'ar': ctx.file.ar_bin,
        'as': ctx.file.as_bin,
        'ld': ctx.file.ld_bin,

        'strip': ctx.file.strip_bin,
        
        'cov': ctx.file.cov_bin,

        'nm': ctx.file.nm_bin,
        'objdump': ctx.file.objdump_bin,
    })
    return _impl_create_cc_toolchain_config_info(ctx, toolchain_tools, toolchain_path_from_tools(toolchain_tools))

cc_toolchain_config_bins = rule(
    implementation = _impl_cc_toolchain_config_bins,
    attrs = dict(
        _IMPL_ATTR_CC_TOOLCHAIN_CONFIG,
        cpp_bin = attr.label(mandatory = True, allow_single_file = True),
        cc_bin = attr.label(mandatory = True, allow_single_file = True),
        cxx_bin = attr.label(mandatory = True, allow_single_file = True),
        ar_bin = attr.label(mandatory = True, allow_single_file = True),
        as_bin = attr.label(mandatory = True, allow_single_file = True),
        ld_bin = attr.label(mandatory = True, allow_single_file = True),

        strip_bin = attr.label(mandatory = True, allow_single_file = True),

        cov_bin = attr.label(mandatory = True, allow_single_file = True),
        nm_bin = attr.label(mandatory = True, allow_single_file = True),
        objdump_bin = attr.label(mandatory = True, allow_single_file = True),
    ),
    fragments = ["cpp"],
    provides = [CcToolchainConfigInfo],
)

##### Old version with label-key list #####
def _impl_cc_toolchain_config_bins_keyed(ctx):
    toolchain_tools = toolchain_tools_from_bins_keyed(ctx.attr.toolchain_bins, ctx.files.toolchain_bins)
    return _impl_create_cc_toolchain_config_info(ctx, toolchain_tools, toolchain_path_from_tools(toolchain_tools))

cc_toolchain_config_bins_keyed = rule(
    implementation = _impl_cc_toolchain_config_bins_keyed,
    attrs = dict(
        _IMPL_ATTR_CC_TOOLCHAIN_CONFIG,
        toolchain_bins = attr.label_keyed_string_dict(mandatory = True, allow_files = True),
    ),
    fragments = ["cpp"],
    provides = [CcToolchainConfigInfo],
)
