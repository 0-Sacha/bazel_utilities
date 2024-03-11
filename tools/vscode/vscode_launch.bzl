"vscode_launch.bzl"

load("//bazel_utilities/toolchains/impl:utils.bzl", "butils_tool_path")
load(":vscode_tasks.bzl", "ButilsVSCodeTaskInfo")

ButilsVSCodeLaunchInfo = provider("", fields = {
    "name": "",
    "type": "",
    "program": "",
    "extar": "",
    "cwd": "",
    "args": "",
    "pre_launch_task": "",
    "debugger_path": "",
    "external_console": "",
    "other": "",
})

def _impl_vscode_task(ctx):
    debugger = butils_tool_path(ctx.files.debugger_bins, ctx.attr.debugger_name)
    debugger_path = ctx.attr.debugger_path + debugger.path

    return [
        ButilsVSCodeLaunchInfo(
            name = ctx.label.name,
            type = ctx.attr.type,
            program = ctx.file.program,
            extar = ctx.attr.extar,
            cwd = ctx.attr.cwd,
            args = ctx.attr.args,
            pre_launch_task = ctx.attr.pre_launch_task,
            debugger_path = debugger_path,
            external_console = ctx.attr.external_console,
            other = {},
        )
    ]

butils_vscode_launch = rule(
    implementation = _impl_vscode_task,
    attrs = {
        'type': attr.string(default = "cppdbg"),
        'program': attr.label(mandatory = True, allow_single_file = True),
        'extar': attr.int(default = 0),
        'cwd': attr.string(default = "${workspaceFolder}"),
        'args': attr.string_list(default = []),
        'pre_launch_task': attr.label(default = None, providers = [ButilsVSCodeTaskInfo]),
        'debugger_bins': attr.label(mandatory = True, allow_files = True),
        'debugger_name': attr.string(default = "gdb"),
        'debugger_path': attr.string(default = "$(bazelisk info output_base)/"),
        'external_console': attr.bool(default = False),
    },
    provides = [ButilsVSCodeLaunchInfo]
)
