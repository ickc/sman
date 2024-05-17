#!/usr/bin/env python

"""generate all combinations of supported GOOS and GOARCH
"""

import subprocess
from concurrent.futures import ProcessPoolExecutor as Executor
from pathlib import Path

import pandas as pd


def make(GOOS: str, GOOARCH: str) -> None:
    args = ["make", "build", f"GOOS={GOOS}", f"GOARCH={GOOARCH}"]
    print(subprocess.list2cmdline(args))
    res = subprocess.run(
        args,
        check=False,
        capture_output=True,
    )
    with Path(f"{GOOS}_{GOOARCH}.stdout").open("wb") as f:
        f.write(res.stdout)
    with Path(f"{GOOS}_{GOOARCH}.stderr").open("wb") as f:
        f.write(res.stderr)


def main():
    envs = pd.read_html("https://golang.org/doc/install/source")[0][
        ["$GOOS", "$GOARCH"]
    ].T.values.tolist()
    with Executor() as executor:
        executor.map(make, *envs)


if __name__ == "__main__":
    main()
