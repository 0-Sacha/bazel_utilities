""

BuildConfigurationInfo = provider("", fields = ['type'])

_available_build_configurations = ["Debug", "Release", "Dist"]

def _impl(ctx):
    raw_configuration = ctx.build_setting_value
    if raw_configuration not in _available_build_configurations:
        fail(str(ctx.label) + " build setting allowed to take values {"
             + ", ".join(_available_build_configurations) + "} but was set to unallowed value "
             + raw_configuration)
    return BuildConfigurationInfo(type = raw_configuration)

build_configuration = rule(
    implementation = _impl,
    build_setting = config.string(flag = True)
)
