""

load("@rules_cc//cc:defs.bzl", "cc_library", "cc_binary")

# buildifier: disable=name-conventions
ProjectType = struct(
    ConsoleApp = "ConsoleApp",
    StaticLib = "StaticLib",
    SharedLib = "SharedLib"
)

SolutionProjectInfo = provider("", fields = {
    'name': "",
    'path': "",
    'project_type': "",
    'platform_define_name': "",
    'hdrs': "",
    'srcs': "",
    'private_defines': "",
    'private_include_dirs': "",
    'private_deps': "",
    'private_project_deps': "",
    'defines': "",
    'include_dirs': "",
    'deps': "",
    'project_deps': "",
    'copts': "",
    'linkopts': ""
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

def _get_data_from_project_deps(project_deps):
    defines = []
    include_dirs = []
    deps = []
    for projdeps in project_deps:
        deps.append("//" + projdeps.path + ":" + projdeps.name)
        defines += projdeps.defines
        include_dirs += projdeps.include_dirs
        deps += projdeps.deps
    return defines, include_dirs, deps

# buildifier: disable=function-docstring
def solution_project_info(
        name,
        path = "",
        project_type = ProjectType.ConsoleApp,
        platform_define_name = None,

        private_defines = [],
        private_include_dirs = [],
        private_deps = [],
        private_project_deps = [],

        defines = [],
        include_dirs = [],
        deps = [],
        project_deps = [],

        copts = [],
        linkopts = [],
    ):

    utilities_defines = _get_utilities_defines(platform_define_name)
    projdeps_defines, projdeps_include_dirs, projdeps_deps = _get_data_from_project_deps(project_deps)
    private_projdeps_defines, private_projdeps_include_dirs, private_projdeps_deps = _get_data_from_project_deps(private_project_deps)

    return SolutionProjectInfo(
            name = name,
            path = path,
            project_type = project_type,
            platform_define_name = platform_define_name,

            hdrs = [],
            srcs = [],
            private_defines = private_defines + private_projdeps_defines,
            private_include_dirs = private_include_dirs + private_projdeps_include_dirs,
            private_deps = private_deps + private_projdeps_deps,
            private_project_deps = private_project_deps,

            defines = defines + utilities_defines + projdeps_defines,
            include_dirs = include_dirs + projdeps_include_dirs,
            deps = deps + projdeps_deps,
            project_deps = project_deps,

            copts = copts,
            linkopts = linkopts,
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
            visibility = ["//visibility:public"]
        )
    elif info.project_type == ProjectType.SharedLib:
        cc_library(
            name = info.name,
            hdrs = hdrs,
            srcs = srcs,
            defines = info.defines + info.private_defines,
            includes = info.include_dirs + info.private_include_dirs,
            deps = info.deps + info.private_deps,
            copts = info.copts,
            linkopts = info.linkopts,
            visibility = ["//visibility:public"]
        )
# TODO: Wait for Symbolic Macro Bazelv8
# This rule should do the build + the export of SolutionProjectInfo
#
#    solution_project = rule(
#        implementation = _impl_solution_project,
#        attrs = {
#            'project_type': attr.string(default = ProjectType.ConsoleApp),
#            'platform_define_name': attr.string(),
#            'hdrs': attr.label_list(default = [], allow_files = True),
#            'srcs': attr.label_list(default = [], allow_files = True),
#            'defines': attr.string_list(default = []),
#            'include_dirs': attr.string_list(default = []),
#            'deps': attr.label_list(default = [], providers = [SolutionProjectInfo]),
#            'project_deps': attr.label_list(default = [], providers = [SolutionProjectInfo]),#
#
#            'public_defines': attr.string_list(default = []),
#            'public_include_dirs': attr.string_list(default = []),
#            'public_deps': attr.label_list(default = [], providers = [SolutionProjectInfo]),
#            'public_project_deps': attr.label_list(default = [], providers = [SolutionProjectInfo]),#
#
#            'copts': attr.string_list(default = []),
#            'linkopts': attr.string_list(default = []),
#        },
#        provides = [SolutionProjectInfo]
#    )
#
