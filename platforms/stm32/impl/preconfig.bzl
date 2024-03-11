"preconfig.bzl"

# buildifier: disable=name-conventions
ButilsSTM32PreConfig = provider("", fields = {
    'copts': "",
    'conlyopts': "",
    'cxxopts': "",
    'linkopts': "",
})

def stm32_preconfig(
        copts = [],
        conlyopts = [],
        cxxopts = [],
        linkopts = []
    ):
    return ButilsSTM32PreConfig(
        copts = copts,
        conlyopts = conlyopts,
        cxxopts = cxxopts,
        linkopts = linkopts,
    )