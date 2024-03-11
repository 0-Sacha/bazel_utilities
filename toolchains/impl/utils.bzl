""

def _best_match(matchs):
    smallest = matchs[0]
    for match in matchs[1:]:
        if len(match.basename) < len(smallest.basename):
            smallest = match
    return smallest

# TODO:
# buildifier: disable=function-docstring
def butils_tool_path(bins, tool_name, tool_base_name = "", tool_extention = ""):
    matchs = []
    tool_fullname = "{}{}{}".format(tool_base_name, tool_name, tool_extention)
    tool_fullname_woext = "{}{}".format(tool_base_name, tool_name)
    for file in bins:
        if file.basename == tool_fullname:
            matchs.append(file)
        if file.basename.startswith(tool_fullname_woext):
            matchs.append(file)

    if len(matchs) == 0:
        # buildifier: disable=print
        print("Tool NOT Found : '{}' in {} !!".format(tool_fullname, bins))
        return None

    if len(matchs) == 1:
        return matchs[0]
    
    best_match = _best_match(matchs)
    # buildifier: disable=print
    print("Warrning: multiple Tool Found for {} !!. Keeping best_match : {}".format(tool_name, best_match))
    return best_match

# TODO:
# buildifier: disable=function-docstring
def butils_get_toolchain_archive_prefix(host_name, toolchain_package):
    if host_name == "localhost":
        return "{}{}".format(toolchain_package.toolchain_registry.localhost_path, toolchain_package.toolchain_registry.localhost_prefix)
    return "@{}//:".format(toolchain_package.archive_repository).format(host_name = host_name)

def butils_get_package_from_toolchain(package_name, host_name, toolchain):
    return "{archive}{package_name}".format(
        archive = butils_get_toolchain_archive_prefix(host_name, toolchain),
        package_name = package_name
    )

# buildifier: disable=name-conventions
ButilsToolchainsFlags = provider("", fields = {
    'copts': "",
    'conlyopts': "",
    'cxxopts': "",
    'linkopts': "",
})

def butils_toolchain_flags(
        copts = [],
        conlyopts = [],
        cxxopts = [],
        linkopts = [],
    ):
    return ButilsToolchainsFlags(
        copts = copts,
        conlyopts = conlyopts,
        cxxopts = cxxopts,
        linkopts = linkopts,
    )   

def butils_concat_toolchain_flags(a, b):
    return ButilsToolchainsFlags(
        copts = a.copts + b.copts,
        conlyopts = a.conlyopts + b.conlyopts,
        cxxopts = a.cxxopts + b.cxxopts,
        linkopts = a.linkopts + b.linkopts,
    )   

empty_toolchain_flags = butils_toolchain_flags()
