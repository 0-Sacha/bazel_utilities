""

load("//bazel_utilities/toolchains/impl:archives_registry.bzl", "gen_archives_registry")

ARM_NONE_EABI_ARCHIVES_13_2_REL1 = {
    "version": "13.2.rel1",
    "version-short": "13.2",
    "latest": True,
    "details": { "compiler_version": "13.2.1" },
    "build_file": "//bazel_utilities/toolchains/arm_none_eabi:compiler.BUILD",
    "archives": {
        "windows_x86_64": {
            "sha256": "51D933F00578AA28016C5E3C84F94403274EA7915539F8E56C13E2196437D18F",
            "strip_prefix": "arm-gnu-toolchain-13.2.Rel1-mingw-w64-i686-arm-none-eabi",
            "url": "https://developer.arm.com/-/media/Files/downloads/gnu/13.2.rel1/binrel/arm-gnu-toolchain-13.2.rel1-mingw-w64-i686-arm-none-eabi.zip?rev=93fda279901c4c0299e03e5c4899b51f&hash=A3C5FF788BE90810E121091C873E3532336C8D46",
        },
        "linux_x86_64": {
            "sha256": "6CD1BBC1D9AE57312BCD169AE283153A9572BD6A8E4EEAE2FEDFBC33B115FDBB",
            "strip_prefix": "arm-gnu-toolchain-13.2.rel1-x86_64-arm-none-eabi",
            "url": "https://developer.arm.com/-/media/Files/downloads/gnu/13.2.rel1/binrel/arm-gnu-toolchain-13.2.rel1-x86_64-arm-none-eabi.tar.xz?rev=e434b9ea4afc4ed7998329566b764309&hash=688C370BF08399033CA9DE3C1CC8CF8E31D8C441",
        },
        "linux_aarch64": {
            "sha256": "8FD8B4A0A8D44AB2E195CCFBEEF42223DFB3EDE29D80F14DCF2183C34B8D199A",
            "strip_prefix": "arm-gnu-toolchain-13.2.rel1-aarch64-arm-none-eabi",
            "url": "https://developer.arm.com/-/media/Files/downloads/gnu/13.2.rel1/binrel/arm-gnu-toolchain-13.2.rel1-aarch64-arm-none-eabi.tar.xz?rev=17baf091942042768d55c9a304610954&hash=7F32B9E3ADFAFC4F8F74C30EBBBFECEB1AC96B60",
        },
        "darwin_x86_64": {
            "sha256": "075FAA4F3E8EB45E59144858202351A28706F54A6EC17EEDD88C9FB9412372CC",
            "strip_prefix": "arm-gnu-toolchain-13.2.rel1-darwin-x86_64-arm-none-eabi",
            "url": "https://developer.arm.com/-/media/Files/downloads/gnu/13.2.rel1/binrel/arm-gnu-toolchain-13.2.rel1-darwin-x86_64-arm-none-eabi.tar.xz?rev=a3d8c87bb0af4c40b7d7e0e291f6541b&hash=10927356ACA904E1A0122794E036E8DDE7D8435D",
        }
    }
}

ARM_NONE_EABI_ARCHIVES_REGISTRY = gen_archives_registry([
    ARM_NONE_EABI_ARCHIVES_13_2_REL1
])