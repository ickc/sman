#!/usr/bin/env python

'''generate all combinations of supported GOOS and GOARCH

hint: run

$(./make.py)

or using parallel

./make.py | parallel -j 10
'''

import pandas as pd


def main():
    for _, row in pd.read_html('https://golang.org/doc/install/source')[0].iterrows():
        print(f"make build GOOS={row['$GOOS']} GOARCH={row['$GOARCH']}")

if __name__ == "__main__":
    main()
