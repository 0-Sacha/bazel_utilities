"preconfig.bzl"

ButilsSTM32PreConfigInfo = provider("", fields = {
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
    return ButilsSTM32PreConfigInfo(
        copts = copts,
        conlyopts = conlyopts,
        cxxopts = cxxopts,
        linkopts = linkopts,
    )