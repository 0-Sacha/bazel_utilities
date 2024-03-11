"stm32_mcu_familly.bzl"

load("//bazel_utilities:hosts.bzl", "default_localhost")
load("//bazel_utilities/toolchains/arm_none_eabi:arm_none_eabi.bzl", "arm_none_eabi_toolchain")

ButilsSTM32ToolchainGeneratorInfo = provider("", fields = {
    'familly': "",
    'mcu_data': "",
    'register': "",
    'gen': "",
})

def _stm32_toolchain_format_list(list, stm32_familly):
    res = []
    for element in list:
        res.append(element.format(stm32_familly = stm32_familly))
    return res

# TODO:
# buildifier: disable=function-docstring
# buildifier: disable=unnamed-macro
def stm32_toolchain(
        familly,
        arm_cpu_version,
        cpu,
        fpu = None,
        fpu_abi = None,

        preconfig = None,
        gc_sections = True,

        ctx_copts = [],
        ctx_conlyopts = [],
        ctx_cxxopts = [],
        ctx_linkopts = [],
        ctx_target_compatible_with = [],
        
        arm_none_eabi_package = arm_none_eabi_toolchain,
        autofind = None,
    ):

    familly = familly.upper()

    def _check_mcu_id(mcu_id):
        if not mcu_id.startswith(familly):
            # buildifier: disable=print
            print("Warning: Construct toolchain for {} with the {} toolchain familly".format(mcu_id, familly))

    def _register(mcu_id, hosts_info = default_localhost):
        mcu_id = mcu_id.upper()
        _check_mcu_id(mcu_id)
        arm_none_eabi_package.register(
            target_name = familly,
            target_cpu = mcu_id[len(familly):],
            hosts_info = hosts_info,
        )

    def _gen(
        mcu_id,
        hosts_info = default_localhost,
        mcu_ldscript = None,
        mcu_startupfile = None,
        mcu_device_group = None,
        copts = [],
        conlyopts = [],
        cxxopts = [],
        linkopts = [],
        gen_mcu_constraint = False,
        gen_platform = True,
        use_mcu_constraint = False,
        target_compatible_with = [],
        ):
        mcu_id = mcu_id.upper()
        _check_mcu_id(mcu_id)
        
        if mcu_ldscript == None:
            if autofind != None and ("mcu_ldscript" in autofind):
                mcu_ldscript = autofind["mcu_ldscript"](mcu_id)
                # buildifier: disable=print
                print("Automatic name for mcu_ldscript: {}".format(mcu_ldscript))
            else:
                # buildifier: disable=print
                print("NO ldscript FOUND !!")

        if mcu_device_group == None:
            if autofind != None and ("mcu_device_group" in autofind):
                mcu_device_group = autofind["mcu_device_group"](mcu_id)
                # buildifier: disable=print
                print("Automatic name for mcu_device_group copts: {}".format(mcu_device_group))
            else:
                # buildifier: disable=print
                print("NO device_group SET !!")

        if mcu_startupfile == None:
            if autofind != None and ("mcu_startupfile" in autofind):
                mcu_startupfile = autofind["mcu_startupfile"](mcu_id)
                # buildifier: disable=print
                print("Automatic name for mcu_startupfile: {}".format(mcu_startupfile))
            else:
                # buildifier: disable=print
                print("NO startupfile FOUND !!")
        
        mcu = [ cpu, "-mthumb" ]
        if fpu != None:
            mcu += [ fpu, fpu_abi ]

        copts = ctx_copts + copts + mcu + [ "-D {}".format(mcu_device_group) ]
        conlyopts = ctx_conlyopts + conlyopts
        cxxopts = ctx_cxxopts + cxxopts
        linkopts = ctx_linkopts + linkopts + mcu + [ "-T {}".format(mcu_ldscript) ]

        if gc_sections:
            copts += [ "-fdata-sections", "-ffunction-sections" ]
            # buildifier: disable=list-append
            linkopts += [ "-Wl,--gc-sections" ]

        if preconfig != None:
            copts += _stm32_toolchain_format_list(preconfig.copts, familly)
            conlyopts += _stm32_toolchain_format_list(preconfig.conlyopts, familly)
            cxxopts += _stm32_toolchain_format_list(preconfig.cxxopts, familly)
            linkopts += _stm32_toolchain_format_list(preconfig.linkopts, familly)

        target_compatible_with = target_compatible_with + ctx_target_compatible_with
        
        native.cc_library(
            name = "{}_startup".format(mcu_id),
            srcs = [ mcu_startupfile ],
            copts = [ "-x", "assembler-with-cpp" ],
            visibility = ["//visibility:public"],
        )

        toolchain_mcu_constraint = [
            "@platforms//cpu:{}".format(arm_cpu_version),
            "//bazel_utilities/platforms/stm32:{}".format(familly.lower()),
        ]

        if gen_mcu_constraint:
            native.constraint_value(
                name = mcu_id.lower(),
                constraint_setting = "//bazel_utilities/platforms/stm32:stm32",
            )

            # buildifier: disable=list-append
            toolchain_mcu_constraint += [ "//:{}".format(mcu_id.lower()) ]

        if use_mcu_constraint:
            target_compatible_with += toolchain_mcu_constraint

        if gen_platform:
            native.platform(
                name = mcu_id,
                constraint_values = toolchain_mcu_constraint
            )

        return arm_none_eabi_package.gen(
            target_name = familly,
            target_cpu = mcu_id[len(familly):],
            hosts_info = hosts_info,
            target_compatible_with = target_compatible_with,
            copts = copts,
            conlyopts = conlyopts,
            cxxopts = cxxopts,
            linkopts = linkopts
        )

    return ButilsSTM32ToolchainGeneratorInfo(
        familly = familly.upper(),
        mcu_data = struct(
            arm_cpu_version = arm_cpu_version,
            cpu = cpu,
            fpu = fpu,
            fpu_abi = fpu_abi
        ),
        register = _register,
        gen = _gen
    )
