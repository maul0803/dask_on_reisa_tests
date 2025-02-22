###################################################################################################
# Copyright (c) 2020-2022 Centre national de la recherche scientifique (CNRS)
# Copyright (c) 2020-2022 Commissariat a l'énergie atomique et aux énergies alternatives (CEA)
# Copyright (c) 2020-2022 Institut national de recherche en informatique et en automatique (Inria)
# Copyright (c) 2020-2022 Université Paris-Saclay
# Copyright (c) 2020-2022 Université de Versailles Saint-Quentin-en-Yvelines
#
# SPDX-License-Identifier: MIT
#
###################################################################################################

from dask_interface import Deisa
# from deisa import Deisa
from dask.distributed import performance_report, wait
import os
import time
import numpy as np

os.environ["DASK_DISTRIBUTED__COMM__UCX__INFINIBAND"] = "True"

# Scheduler file name and configuration file
scheduler_info = 'scheduler.json'
config_file = 'config.yml'

# Initialize Deisa
Deisa = Deisa(scheduler_info, config_file)

# Get client
client = Deisa.get_client()

# either: Get data descriptor as a list of Deisa arrays object
arrays = Deisa.get_deisa_arrays()
# or: Get data descriptor as a dict of Dask array
# arrays = Deisa.get_dask_arrays()

# Select data
gt = arrays["global_t"][...]
print(gt, flush=True)

# Check contract
arrays.check_contract()
arrays.validate_contract()

start = time.time()
# py-bokeh is needed if you wanna see the perf report
with performance_report(filename="dask-report.html"):

    results = []
    for i in range(25):
        
        cpt = np.sum(gt[i])

        s = client.persist(cpt, release=True)

        results.append(client.compute(s))

    del gt

# Write the results
with open("results.log", "a") as f:
    result = [cpt.result() for cpt in results]
    f.write(str(result))

print("{:<21}".format("EST_ANALYTICS_TIME:") + "{:.5f}".format(time.time()-start))


print("Done", flush=True)
client.shutdown()