import subprocess
import sys

def run_vscode_rule(args):
    try:
        cmd = [
            "bazelisk",
            "build"
        ]
        print("Run subprocess: ", cmd + args)
        subprocess.run(cmd + args)

        cmd = [
            "bazelisk",
            "info",
            "bazel-bin"
        ]
        print("Run subprocess: ", cmd)
        res = subprocess.run(cmd, stdout=subprocess.PIPE)
        path = str(res.stdout[0:-1], encoding='utf-8')
        print("Copy from path: ", path)

        cmd = [
            "rm",
            "-rf",
            "./.vscode"
        ]
        print("Run subprocess: ", cmd)
        subprocess.run(cmd)

        cmd = [
            "cp",
            "-r",
            "{}/generated.vscode".format(path),
            ".vscode"
        ]
        print("Run subprocess: ", cmd)
        subprocess.run(cmd)

    except Exception as e:
        print(f"Error: {e}")

if __name__ == "__main__":
    args = sys.argv[1:]

    if not args:
        print("Usage: python gen_vscode.py ")
    else:
        run_vscode_rule(args)