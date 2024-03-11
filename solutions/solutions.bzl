""

load("@rules_cc//cc:defs.bzl", "cc_library", "cc_binary", "cc_test")

# buildifier: disable=name-conventions
ProjectType = struct(
    ConsoleApp = "ConsoleApp",
    StaticLib = "StaticLib",
    SharedLib = "SharedLib",
    Test = "Test"
)

# buildifier: disable=name-conventions
SolutionProject = provider("", fields = {
    'name': "",
    'project_type': "",
    'platform_define_name': "",

    'hdrs': "",
    'srcs': "",

    'private_defines': "",
    'private_include_dirs': "",
    'private_deps': "",

    'defines': "",
    'include_dirs': "",
    'deps': "",

    'copts': "",
    'linkopts': "",
    'compatible_with': "",
    'exec_compatible_with': ""
})

def _get_utilities_defines(platform_define_name):
    utilities_defines = []
    if platform_define_name != None:
        if platform_define_name != "":
            platform_define_name = platform_define_name + "_"
        utilities_defines += select({
            "@bazel_utilities//:Debug" : [ platform_define_name + "DEBUG" ],
            "@bazel_utilities//:Release" : [ platform_define_name + "RELEASE" ],
            "@bazel_utilities//:Dist" : [ platform_define_name + "DIST" ],
        })
    return utilities_defines

def _get_data_from_projdeps(projdeps):
    defines = []
    include_dirs = []
    deps = []
    for projpath, projdata in projdeps.items():
        deps.append(projpath + ":" + projdata.name)
        defines += projdata.defines
        include_dirs += projdata.include_dirs
        deps += projdata.deps
    return defines, include_dirs, deps

# buildifier: disable=function-docstring
def solution_project_info(
        name,
        project_type = ProjectType.ConsoleApp,
        platform_define_name = None,

        private_defines = [],
        private_include_dirs = [],
        private_deps = [],
        private_projdeps = {},

        defines = [],
        include_dirs = [],
        deps = [],
        projdeps = {},

        copts = [],
        linkopts = [],
        compatible_with = [],
        exec_compatible_with = []
    ):

    utilities_defines = _get_utilities_defines(platform_define_name)
    projdeps_defines, projdeps_include_dirs, projdeps_deps = _get_data_from_projdeps(projdeps)
    private_projdeps_defines, private_projdeps_include_dirs, private_projdeps_deps = _get_data_from_projdeps(private_projdeps)

    return SolutionProject(
            name = name,
            project_type = project_type,
            platform_define_name = platform_define_name,

            hdrs = [],
            srcs = [],
            private_defines = private_defines + private_projdeps_defines,
            private_include_dirs = private_include_dirs + private_projdeps_include_dirs,
            private_deps = private_deps + private_projdeps_deps,

            defines = defines + utilities_defines + projdeps_defines,
            include_dirs = include_dirs + projdeps_include_dirs,
            deps = deps + projdeps_deps,

            copts = copts,
            linkopts = linkopts,
            compatible_with = compatible_with,
            exec_compatible_with = exec_compatible_with,
        )

# buildifier: disable=function-docstring
def solution_project_build(
        info,
        hdrs = [],
        srcs = []
    ):

    if info.project_type == ProjectType.ConsoleApp:
        cc_binary(
            name = info.name,
            srcs = srcs,
            defines = info.defines + info.private_defines,
            includes = info.include_dirs + info.private_include_dirs,
            deps = info.deps + info.private_deps,
            copts = info.copts,
            linkopts = info.linkopts,
            compatible_with = info.compatible_with,
            exec_compatible_with = info.exec_compatible_with,
            visibility = ["//visibility:public"]
        )
    elif info.project_type == ProjectType.StaticLib:
        cc_library(
            name = info.name,
            hdrs = hdrs,
            srcs = srcs,
            defines = info.defines + info.private_defines,
            includes = info.include_dirs + info.private_include_dirs,
            deps = info.deps + info.private_deps,
            copts = info.copts,
            linkopts = info.linkopts,
            compatible_with = info.compatible_with,
            exec_compatible_with = info.exec_compatible_with,
            visibility = ["//visibility:public"]
        )
    elif info.project_type == ProjectType.SharedLib:
        # TODO
        cc_library(
            name = info.name,
            hdrs = hdrs,
            srcs = srcs,
            defines = info.defines + info.private_defines,
            includes = info.include_dirs + info.private_include_dirs,
            deps = info.deps + info.private_deps,
            copts = info.copts,
            linkopts = info.linkopts,
            compatible_with = info.compatible_with,
            exec_compatible_with = info.exec_compatible_with,
            visibility = ["//visibility:public"]
        )
    elif info.project_type == ProjectType.Test:
        cc_test(
            name = info.name,
            srcs = srcs,
            defines = info.defines + info.private_defines,
            includes = info.include_dirs + info.private_include_dirs,
            deps = info.deps + info.private_deps,
            copts = info.copts,
            linkopts = info.linkopts,
            compatible_with = info.compatible_with,
            exec_compatible_with = info.exec_compatible_with,
            visibility = ["//visibility:public"]
        )
