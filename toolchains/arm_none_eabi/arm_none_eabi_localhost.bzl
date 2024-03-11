""

load("@local_config_platform//:constraints.bzl", "HOST_CONSTRAINTS")
load("@bazel_utilities:hosts.bzl", "filegroup_archive_localhost", "filter_hosts_info", "get_current_localhost_name", "default_hosts")
load("@bazel_utilities//toolchains/impl:archives_registry.bzl", "archive_repository_name")
load("@bazel_utilities//toolchains/impl:toolchain_registry.bzl", "get_full_version_label")
load(":arm_none_eabi.bzl", "arm_none_eabi_registry")

arm_none_eabi_hosts = [
    "windows_x86_64",
    "linux_x86_64",
    "linux_aarch64",
    "darwin_x86_64"
]

arm_none_eabi_hosts_filter = filter_hosts_info(hosts_filter = arm_none_eabi_hosts, hosts_info = default_hosts)
localhost_name = get_current_localhost_name(localhost_constraints = HOST_CONSTRAINTS, hosts_info = arm_none_eabi_hosts_filter)

def arm_none_eabi_localhost(version = "latest"):
    "arm_none_eabi_localhost"
    arm_none_eabi_arch = archive_repository_name(host_name = localhost_name, toolchain_registry = arm_none_eabi_registry, version = version)

    filegroup_archive_localhost(arm_none_eabi_registry.localhost_prefix, "gcc", arm_none_eabi_arch)
    filegroup_archive_localhost(arm_none_eabi_registry.localhost_prefix, "g++", arm_none_eabi_arch)
    filegroup_archive_localhost(arm_none_eabi_registry.localhost_prefix, "gdb", arm_none_eabi_arch)
    filegroup_archive_localhost(arm_none_eabi_registry.localhost_prefix, "cpp", arm_none_eabi_arch)
    filegroup_archive_localhost(arm_none_eabi_registry.localhost_prefix, "gcov", arm_none_eabi_arch)
    filegroup_archive_localhost(arm_none_eabi_registry.localhost_prefix, "ar", arm_none_eabi_arch)
    filegroup_archive_localhost(arm_none_eabi_registry.localhost_prefix, "ld", arm_none_eabi_arch)
    filegroup_archive_localhost(arm_none_eabi_registry.localhost_prefix, "nm", arm_none_eabi_arch)
    filegroup_archive_localhost(arm_none_eabi_registry.localhost_prefix, "objcopy", arm_none_eabi_arch)
    filegroup_archive_localhost(arm_none_eabi_registry.localhost_prefix, "objdump", arm_none_eabi_arch)
    filegroup_archive_localhost(arm_none_eabi_registry.localhost_prefix, "strip", arm_none_eabi_arch)
    filegroup_archive_localhost(arm_none_eabi_registry.localhost_prefix, "as", arm_none_eabi_arch)
    filegroup_archive_localhost(arm_none_eabi_registry.localhost_prefix, "size", arm_none_eabi_arch)
    filegroup_archive_localhost(arm_none_eabi_registry.localhost_prefix, "dwp", arm_none_eabi_arch)
    filegroup_archive_localhost(arm_none_eabi_registry.localhost_prefix, "compiler_pieces", arm_none_eabi_arch)
    filegroup_archive_localhost(arm_none_eabi_registry.localhost_prefix, "compiler_files", arm_none_eabi_arch)
    filegroup_archive_localhost(arm_none_eabi_registry.localhost_prefix, "linker_files", arm_none_eabi_arch)
    filegroup_archive_localhost(arm_none_eabi_registry.localhost_prefix, "compiler_components", arm_none_eabi_arch)
