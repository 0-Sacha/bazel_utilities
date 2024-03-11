"BUILD"

load("@local_config_platform//:constraints.bzl", "HOST_CONSTRAINTS")
load("@bazel_utilities//toolchains/impl:toolchain_build_configuration.bzl", "build_configuration")
load(":hosts.bzl", "hosts_platform", "default_hosts", "get_current_localhost_name", "butils_host")

hosts_platform(hosts_info = default_hosts)

localhost_name = get_current_localhost_name(localhost_constraints = HOST_CONSTRAINTS, hosts_info = default_hosts)

butils_host(
    name = "localhost_name",
    host_name = localhost_name,
    constraints = HOST_CONSTRAINTS,
    visibility = ["//visibility:public"],
)

build_configuration(
    name = "config",
    build_setting_default = "Debug",
)

config_setting(
    name = "Debug",
    flag_values  = {
        "@bazel_utilities//:config": "Debug",
    }
)

config_setting(
    name = "Release",
    flag_values = {
        "@bazel_utilities//:config": "Release",
    }
)

config_setting(
    name = "Dist",
    flag_values = {
        "@bazel_utilities//:config": "Dist",
    }
)
