""

load("//bazel_utilities/toolchains/impl:utils.bzl", "butils_tool_path")

def _arm_all_files_impl(ctx):
    # buildifier: disable=print
    print("Copy '{}' to '{}'".format(ctx.file.binary, ctx.outputs.elf))
    ctx.actions.run(
        inputs = [ ctx.file.binary ],
        outputs = [ ctx.outputs.elf ],
        executable = "cp",
        arguments = [
            ctx.file.binary.path,
            ctx.outputs.elf.path
        ],
    )

    # buildifier: disable=print
    print("Create bin file '{}' from '{}'".format(ctx.outputs.bin, ctx.file.binary))
    ctx.actions.run(
        inputs = [ ctx.file.binary ],
        outputs = [ ctx.outputs.bin ],
        executable = butils_tool_path(ctx.files.objcopy_bin, "objcopy", tool_base_name = "arm_none_eabi-"),
        arguments = [
            "-O",
            "binary",
            "-S",
            ctx.file.binary.path,
            ctx.outputs.bin.path
        ],
    )

    # buildifier: disable=print
    print("Create hex file '{}' from '{}'".format(ctx.outputs.hex, ctx.file.binary))
    ctx.actions.run(
        inputs = [ ctx.file.binary ],
        outputs = [ ctx.outputs.hex ],
        executable = butils_tool_path(ctx.files.objcopy_bin, "objcopy", tool_base_name = "arm_none_eabi-"),
        arguments = [
            "-O",
            "ihex",
            ctx.file.binary.path,
            ctx.outputs.hex.path
        ],
    )

arm_all_files = rule(
    implementation = _arm_all_files_impl,
    attrs = {
        "objcopy_bin": attr.label(mandatory = True, allow_files = True),
        "binary": attr.label(allow_single_file = True),
        "elf": attr.output(),
        "bin": attr.output(),
        "hex": attr.output(),
    },
)
