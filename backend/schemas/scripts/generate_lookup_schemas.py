import json
import pandas as pd
import sys

"""
This script processes CFDA/ALN and cluster name CSV files to generate schema
JSON, and it can be run using `make source_data`. Input files are found in
`schemas/source/data`.

Usage:
`python scripts/generate_lookup_schemas.py <item to process> <output JSON filepath>`

where "item to process" is either "cfda-lookup" or "cluster-names".
"""


def cleanup_string(s):
    s = str(s).strip()
    s = " ".join(s.split())
    return s


def lmap(fun, ls):
    return list(map(fun, ls))


def process_cfda_lookup(file_path):
    print(f"Processing CFDA lookup file: {file_path}")
    df = pd.read_csv(file_path, encoding="utf-8", converters={"Program Number": str})

    program_names = list(df["Program Title"])
    program_numbers = list(df["Program Number"])

    prefixes = []
    numbers = []

    for program_number in program_numbers:
        program_number = cleanup_string(program_number)
        prefix = ""

        if "." in program_number:
            prefix, _ = program_number.split(".", 1)

        prefixes.append(prefix)
        numbers.append(program_number)

    program_names = lmap(cleanup_string, program_names)
    prefixes = lmap(cleanup_string, prefixes)
    numbers = lmap(cleanup_string, numbers)
    program_names = lmap(lambda s: s.upper(), program_names)

    return {
        "program_names": program_names,
        "all_alns": numbers,
        "aln_prefixes": prefixes,
    }


def process_cluster_names(filename):
    print(f"Processing cluster names file: {filename}")
    df = pd.read_csv(filename)
    cluster_names = list(df["NAME"])
    cluster_names = lmap(cleanup_string, cluster_names)
    cluster_names = lmap(lambda s: s.upper(), cluster_names)

    return {"cluster_names": cluster_names}


if __name__ == "__main__":
    if len(sys.argv) >= 2:
        item_to_process = sys.argv[1]
        output_file = sys.argv[2]
        input_file = f"./source/data/{item_to_process}.csv"

        print(f"Using input file: {input_file}")

        obj = None
        match item_to_process:
            case "cfda-lookup":
                obj = process_cfda_lookup(input_file)
            case "cluster-names":
                obj = process_cluster_names(input_file)
            case _:
                print(f"Unknown item {item_to_process}, exiting")
                sys.exit(1)

        print(f"Saving output to {output_file}")

        with open(output_file, "w", newline="\n") as write_file:
            json.dump(obj, write_file, indent=2, sort_keys=True)

        print(f"File {output_file} successfully saved.")
