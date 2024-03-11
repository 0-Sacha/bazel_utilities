""

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

# buildifier: disable=function-docstring
def gen_archives_registry(archives_version):
    archives_selector_registry = {}
    for archive_version in archives_version:
        archives_selector_registry[archive_version["version"]] = archive_version
        if "version-short" in archive_version:
            archives_selector_registry[archive_version["version-short"]] = archive_version
        if "latest" in archive_version and archive_version["latest"] == True:
            if "latest" in archives_selector_registry:
                # buildifier: disable=print
                print("Registry Already Has an latest flagged archive. Ignoring...")
            else:
                archives_selector_registry["latest"] = archive_version
    return archives_selector_registry

def get_full_version_label(toolchain_registry, version):
    return toolchain_registry.registry[version]["version"]

def archive_repository_name(host_name, toolchain_registry, version):
    return "{}_{}_{}".format(toolchain_registry.name, host_name, get_full_version_label(toolchain_registry, version))

def _register_archives_from_registry(toolchain_registry, version, host_name, archive_data):
    archive_repository = archive_repository_name(host_name = host_name, toolchain_registry = toolchain_registry, version = version)
    if not native.existing_rule(archive_repository):
        # buildifier: disable=print
        print("Add http_archive: '{}'".format(archive_repository))
        http_archive(
            name = archive_repository,
            build_file = toolchain_registry.registry[version]["build_file"],
            sha256 = archive_data["sha256"],
            strip_prefix = archive_data["strip_prefix"],
            url = archive_data["url"]
        )

# buildifier: disable=unnamed-macro
def register_archives_from_registry(toolchain_registry, version = "latest", host_name = None):
    if host_name == None or host_name == "localhost":
        for host_name, archive_data in toolchain_registry.registry[version]["archives"].items():
            _register_archives_from_registry(toolchain_registry, version, host_name, archive_data)
    else:
        _register_archives_from_registry(toolchain_registry, version, host_name, toolchain_registry.registry[version]["archives"][host_name])