import os
from snakemake.utils import R

# packrat
PACKRAT_SRC = "/zfs/datastore0/software/packrat_snapshots/sRNA-norm/src"


COUNTS_DIR = "./counts/"
NORM_DIR = "./norm/"
SPIKE_COUNTS = "CountTable_spike.txt"

COUNT_FILES = [f for f in os.listdir(COUNTS_DIR) if f != SPIKE_COUNTS]
COUNT_SPECIES = [os.path.splitext(cf)[0].split("_")[1] for cf in COUNT_FILES] 

SPIKE_PATH = os.path.join(COUNTS_DIR, SPIKE_COUNTS)

rule all:
    input: expand(NORM_DIR + "CountTable_{species}.txt", species=COUNT_SPECIES)

rule normalize_counts:
    input: dir=NORM_DIR,
           counts=COUNTS_DIR + "CountTable_{species}.txt"
    output: NORM_DIR + "CountTable_{species}.txt"
    message: "normalizing counts"
    run: R("""
            library(faradr);
            normalize_counts("{SPIKE_PATH}", "{input.counts}", "{output}")
            """)
    
rule make_results_dir:
    output: NORM_DIR
    shell: "mkdir -p {NORM_DIR}" 

rule setup_packrat:
    output: "./packrat/src"
    message: "copying packrat source files"
    shell: "cp -R {PACKRAT_SRC} {output}"

