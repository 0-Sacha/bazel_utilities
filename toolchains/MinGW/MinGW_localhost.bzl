""

load("@local_config_platform//:constraints.bzl", "HOST_CONSTRAINTS")
load("//bazel_utilities:hosts.bzl", "filegroup_archive_localhost", "filter_hosts_info", "get_current_localhost_name", "default_hosts")
load("//bazel_utilities/toolchains/impl:archives_registry.bzl", "archive_repository_name")
load(":MinGW.bzl", "mingw_gcc_registry", "mingw_clang_registry")

mingw_hosts = [
    "windows_x86_64",
]

mingw_hosts_filter = filter_hosts_info(hosts_filter = mingw_hosts, hosts_info = default_hosts)
localhost_name = get_current_localhost_name(localhost_constraints = HOST_CONSTRAINTS, hosts_info = mingw_hosts_filter)

def _MinGW_localhost(mingw_repo, mingw_prefix):
    filegroup_archive_localhost(mingw_prefix, "gcc", mingw_repo)
    filegroup_archive_localhost(mingw_prefix, "clang", mingw_repo)
    filegroup_archive_localhost(mingw_prefix, "g++", mingw_repo)
    filegroup_archive_localhost(mingw_prefix, "clang++", mingw_repo)
    filegroup_archive_localhost(mingw_prefix, "gdb", mingw_repo)
    filegroup_archive_localhost(mingw_prefix, "cpp", mingw_repo)
    filegroup_archive_localhost(mingw_prefix, "gcov", mingw_repo)
    filegroup_archive_localhost(mingw_prefix, "ar", mingw_repo)
    filegroup_archive_localhost(mingw_prefix, "ld", mingw_repo)
    filegroup_archive_localhost(mingw_prefix, "nm", mingw_repo)
    filegroup_archive_localhost(mingw_prefix, "objcopy", mingw_repo)
    filegroup_archive_localhost(mingw_prefix, "objdump", mingw_repo)
    filegroup_archive_localhost(mingw_prefix, "strip", mingw_repo)
    filegroup_archive_localhost(mingw_prefix, "as", mingw_repo)
    filegroup_archive_localhost(mingw_prefix, "size", mingw_repo)
    filegroup_archive_localhost(mingw_prefix, "dwp", mingw_repo)
    filegroup_archive_localhost(mingw_prefix, "compiler_pieces", mingw_repo)
    filegroup_archive_localhost(mingw_prefix, "compiler_files", mingw_repo)
    filegroup_archive_localhost(mingw_prefix, "linker_files", mingw_repo)
    filegroup_archive_localhost(mingw_prefix, "compiler_components", mingw_repo)

def MinGW_gcc_localhost(version = "latest"):
    mingw_repo = archive_repository_name(host_name = localhost_name, toolchain_registry = mingw_gcc_registry, version = version)
    mingw_prefix = mingw_gcc_registry.localhost_prefix
    _MinGW_localhost(mingw_repo, mingw_prefix)

def MinGW_clang_localhost(version = "latest"):
    mingw_repo = archive_repository_name(host_name = localhost_name, toolchain_registry = mingw_clang_registry, version = version)
    mingw_prefix = mingw_clang_registry.localhost_prefix
    _MinGW_localhost(mingw_repo, mingw_prefix)
