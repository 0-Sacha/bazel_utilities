""

load(":vscode_config.bzl", "ButilsVSCodeConfigInfo", _butils_vscode_config = "butils_vscode_config", _butils_vscode_config_toolchain = "butils_vscode_config_toolchain", _butils_vscode_config_ids = "butils_vscode_config_ids")
load(":vscode_launch.bzl", "ButilsVSCodeLaunchInfo", _butils_vscode_launch = "butils_vscode_launch")
load(":vscode_tasks.bzl", "ButilsVSCodeTaskInfo", _butils_vscode_task = "butils_vscode_task", _butils_vscode_bazel_task = "butils_vscode_bazel_task")

butils_vscode_task = _butils_vscode_task
butils_vscode_bazel_task = _butils_vscode_bazel_task
butils_vscode_launch = _butils_vscode_launch
butils_vscode_config = _butils_vscode_config
butils_vscode_config_toolchain = _butils_vscode_config_toolchain
butils_vscode_config_ids = _butils_vscode_config_ids

def _c_cpp_properties(ctx):
    properties_file = {
        "version": 4,
        "configurations": [ ]
    }

    config_template = {
        "name": "default",
        "includePath": [],
        "defines": [],
        "cppStandard": "c++20",
        "cStandard": "c17",
        "compilerPath": "gcc",
        "compilerArgs": [],
    }

    if ctx.attr.configs != None:
        for toolchain_info in ctx.attr.configs:
            toolchain_struct = toolchain_info[ButilsVSCodeConfigInfo]
            toolchain_data = dict(config_template)

            toolchain_data["name"] = toolchain_struct.name
            toolchain_data["includePath"] = toolchain_struct.include_path
            toolchain_data["defines"] = toolchain_struct.defines
            toolchain_data["cppStandard"] = toolchain_struct.cpp_standard
            toolchain_data["cStandard"] = toolchain_struct.c_standard
            if toolchain_struct.intelli_sense_mode != "":
                toolchain_data["intelliSenseMode"] = toolchain_struct.intelli_sense_mode
            toolchain_data["compilerPath"] = toolchain_struct.compiler_path
            toolchain_data["compilerArgs"] = toolchain_struct.compiler_args

            properties_file["configurations"].append(toolchain_data)

    return json.encode_indent(properties_file, indent = '\t')

def _launch(ctx):
    launch_file = {
        "version": "0.2.0",
        "configurations": []
    }

    launch_template = {
        "name": "",
        "type": "",
        "program": "",
        "cwd": "${workspaceFolder}",
        "externalConsole": False,
        "miDebuggerPath": "",
        # "miDebuggerServerAddress": ":0",
        # "preLaunchTask": "",

        "request": "launch",
        "MIMode": "gdb",
    }

    if ctx.attr.launch != None:
        for launch_info in ctx.attr.launch:
            launch_struct = launch_info[ButilsVSCodeLaunchInfo]
            launch_data = dict(launch_template)
            
            launch_data["name"] = launch_struct.name
            launch_data["type"] = launch_struct.type
            launch_data["program"] = launch_struct.program.path
            launch_data["cwd"] = launch_struct.cwd
            launch_data["externalConsole"] = launch_struct.external_console
            launch_data["miDebuggerPath"] = launch_struct.debugger_path
            if launch_struct.extar != 0:
                launch_data["miDebuggerServerAddress"] = ":{}".format(launch_struct.extar)
            if launch_struct.pre_launch_task != None:
                launch_data["preLaunchTask"] = launch_struct.pre_launch_task[ButilsVSCodeTaskInfo].label
            
            launch_file["configurations"].append(launch_data)

    return json.encode_indent(launch_file, indent = '\t')

def _tasks(ctx):
    tasks_file = {
        "version": "2.0.0",
        "tasks": []
    }

    task_template = {
        "label": "",
        "type": "shell",
        "command": "",
        "options": {
            "cwd": "${workspaceFolder}"
        },
    }

    if ctx.attr.tasks != None:
        for task_info in ctx.attr.tasks:
            task_struct = task_info[ButilsVSCodeTaskInfo]
            task_data = dict(task_template)
            
            task_data["label"] = task_struct.label
            task_data["type"] = task_struct.type
            task_data["command"] = task_struct.cmd
            task_data["options"]["cwd"] = task_struct.cwd
            if task_struct.is_default == True:
                task_data["group"] = {
                    "kind": "build",
                    "isDefault": True
                }
            
            tasks_file["tasks"].append(task_data)

    return json.encode_indent(tasks_file, indent = '\t')

def _impl_vscode_files(ctx):
    c_cpp_properties = ctx.actions.declare_file("generated.vscode/c_cpp_properties.json")
    launch = ctx.actions.declare_file("generated.vscode/launch.json")
    tasks = ctx.actions.declare_file("generated.vscode/tasks.json")

    ctx.actions.write(
        output = c_cpp_properties,
        content = _c_cpp_properties(ctx)
    )
    ctx.actions.write(
        output = launch,
        content = _launch(ctx)
    )
    ctx.actions.write(
        output = tasks,
        content = _tasks(ctx)
    )

    return [DefaultInfo(files = depset([
        c_cpp_properties,
        launch,
        tasks
    ]))]

butils_vscode_files = rule(
    implementation = _impl_vscode_files,
    attrs = {
        'configs': attr.label_list(providers = [ButilsVSCodeConfigInfo]),
        'tasks': attr.label_list(providers = [ButilsVSCodeTaskInfo]),
        'launch': attr.label_list(providers = [ButilsVSCodeLaunchInfo]),
    },
    provides = [DefaultInfo],
)
