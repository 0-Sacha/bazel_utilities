"default_hosts.bzl"

load("@bazel_utilities//tools:tools.bzl", "list_same_elements")

ButilsHostsDataInfo = provider("", fields = {
    'constraints': "",
    'package_location': "",
})

default_hosts = {
    "windows_x86_64": ButilsHostsDataInfo(
        constraints = [ "@platforms//os:windows", "@platforms//cpu:x86_64" ],
        package_location = "@bazel_utilities"
    ),
    "windows_x86_32": ButilsHostsDataInfo(
        constraints = [ "@platforms//os:windows", "@platforms//cpu:x86_32" ],
        package_location = "@bazel_utilities"
    ),
    "windows_aarch64": ButilsHostsDataInfo(
        constraints = [ "@platforms//os:windows", "@platforms//cpu:aarch64" ],
        package_location = "@bazel_utilities"
    ),
    "linux_x86_64": ButilsHostsDataInfo(
        constraints = [ "@platforms//os:linux", "@platforms//cpu:x86_64" ],
        package_location = "@bazel_utilities"
    ),
    "linux_aarch64": ButilsHostsDataInfo(
        constraints = [ "@platforms//os:linux", "@platforms//cpu:aarch64" ],
        package_location = "@bazel_utilities"
    ),
    "darwin_x86_64": ButilsHostsDataInfo(
        constraints = [ "@platforms//os:macos" ],
        package_location = "@bazel_utilities"
    )
}

# TODO: this shouldn't exists
default_localhost = {
    "localhost": ButilsHostsDataInfo(
        constraints = [],
        package_location = None
    )
}

# TODO:
# buildifier: disable=function-docstring
# buildifier: disable=unnamed-macro
def host_platform(host_name, host_constraint):
    native.platform(
        name = host_name,
        constraint_values = host_constraint,
    )

# TODO:
# buildifier: disable=function-docstring
# buildifier: disable=unnamed-macro
def hosts_platform(hosts_info):
    for host_name, host_data in hosts_info.items():
        host_platform(host_name, host_data.constraints)

# TODO:
# buildifier: disable=function-docstring
def filter_hosts_info(hosts_filter, hosts_info = default_hosts):
    res_hosts_info = {}
    for host_name_filter in hosts_filter:
        if host_name_filter in hosts_info:
            res_hosts_info[host_name_filter] = hosts_info[host_name_filter]
    return res_hosts_info

def filter_hosts_name(host_name, hosts_info = default_hosts):
    res_hosts_info = {}
    if host_name in hosts_info:
        res_hosts_info[host_name] = hosts_info[host_name]
    return res_hosts_info

# TODO:
# buildifier: disable=function-docstring
def get_current_localhost_name(localhost_constraints, hosts_info = default_hosts):
    for host_name, host_data in hosts_info.items():
        if list_same_elements(host_data.constraints, localhost_constraints):
            return host_name
    # buildifier: disable=print
    print("get_current_localhost found no host than match requirements:\n")
    # buildifier: disable=print
    print("    localhost_constraint {}:\n".format(localhost_constraints))
    # buildifier: disable=print
    print("    hosts_info {}:\n".format(hosts_info))
    return None

# TODO:
# buildifier: disable=function-docstring
# buildifier: disable=unnamed-macro
def filegroup_archive_localhost(archive_prefix, package_name, toolchain_archive):
    package_src = "@{toolchain_archive}//:{package_name}".format(
        toolchain_archive = toolchain_archive,
        package_name = package_name,
    )
    native.filegroup(
        name = "{archive_prefix}{package_name}".format(
            archive_prefix = archive_prefix,
            package_name = package_name,
        ),
        srcs = [ package_src ],
        visibility = ["//visibility:public"],
    )
    

ButilsHostNameInfo = provider("", fields = {
    'host_name': "",
    'constraints': ""
})

def _impl_host_name(ctx):
    return [
        ButilsHostNameInfo(
            host_name = ctx.attr.host_name,
            constraints = ctx.attr.constraints,
        )
    ]

butils_host = rule(
    implementation = _impl_host_name,
    attrs = {
        'host_name': attr.string(mandatory = True),
        'constraints': attr.string_list(default = []),
    },
    provides = [ButilsHostNameInfo]
)
