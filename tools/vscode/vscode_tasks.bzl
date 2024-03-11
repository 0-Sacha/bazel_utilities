"vscode_tasks.bzl"

ButilsVSCodeTaskInfo = provider("", fields = {
    "label": "",
    "type": "",
    "cmd": "",
    "cwd": "",
    "is_default": "",
})

def _impl_vscode_task(ctx):
    return [
        ButilsVSCodeTaskInfo(
            label = ctx.label.name,
            type = ctx.attr.type,
            cmd = ctx.attr.cmd,
            cwd = ctx.attr.cwd,
            is_default = ctx.attr.is_default,
        )
    ]

butils_vscode_task = rule(
    implementation = _impl_vscode_task,
    attrs = {
        'cmd': attr.string(mandatory = True),
        'cwd': attr.string(default = "${workspaceFolder}"),
        'type': attr.string(default = "shell"),
        'is_default': attr.bool(default = False),
    },
    provides = [ButilsVSCodeTaskInfo]
)

# TODO:
# buildifier: disable=function-docstring
def butils_vscode_bazel_task(
        name,
        package_name,
        cwd = "${workspaceFolder}",
        compilation_mode = "dbg",
        cpu = "",
        platforms = "",
        extras = [],
        verbose = False,
        is_default = False
    ):
    cmd = "bazelisk build "
    if verbose:
        cmd += "-s "
    if compilation_mode != "":
        cmd += "-c {} ".format(compilation_mode)
    if platforms != "":
        cmd += "--platforms=//:{} ".format(platforms)
    if cpu != "":
        cmd += "--cpu=//:{} ".format(cpu)
    for extra in extras:
        cmd += "{} ".format(extra)
    cmd += "//:{}".format(package_name)
    butils_vscode_task(
        name = name,
        cmd = cmd,
        cwd = cwd,
        is_default = is_default,
    )
