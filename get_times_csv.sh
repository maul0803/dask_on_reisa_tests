#!/bin/bash

# Define the starting directory
START_DIR=$PWD

# Create the output folder
mkdir -p regs_csv 2>/dev/null

# List of iterations and categories
iterations=("E3")
categories=("REISA" "REISA_ONE_ACTOR" "DASK_ON_REISA" "DASK_ON_REISA_ONE_ACTOR")
tasks=("derivative" "reduction")

# Function to calculate the average
function calculate_average {
    local sum=0
    local count=0
    for val in "$@"; do
        sum=$(echo "$sum + $val" | bc -l)
        count=$((count + 1))
    done
    if [ "$count" -gt 0 ]; then
        echo "scale=2; $sum / $count" | bc -l
    else
        echo "0"
    fi
}

# Loop through each category and task
for categorie in "${categories[@]}"; do
    for task in "${tasks[@]}"; do
        # Create a CSV file for each category and task
        result_name="regs_csv/${categorie}_${task}.csv"
        echo "Fichier_Log;Analytics_Avg;Sim_Avg;PDI_Avg" > "${result_name}"

        # Initialize an associative array to store directories per iteration
        declare -A log_dirs_list
        max_subdirs=0  # Maximum number of subdirectories found

        # Find directories containing logs
        for iter in "${iterations[@]}"; do
            dir="$START_DIR/${iter}/${categorie}/${task}"
            if [ -d "$dir" ]; then
                # Read subdirectories into an array
                readarray -t subdirs < <(find "$dir" -mindepth 1 -maxdepth 1 -type d | sort -V)
                
                # Store subdirectories as an array
                log_dirs_list["$iter"]="${subdirs[*]}"

                # Update max_subdirs
                if [ "${#subdirs[@]}" -gt "$max_subdirs" ]; then
                    max_subdirs="${#subdirs[@]}"
                fi
            fi
        done

        # Process directories in batches
        for ((i=0; i<max_subdirs; i++)); do
            echo "Batch $((i+1)) :"
            batch_dirs=()

            for iter in "${iterations[@]}"; do
                # Read directories as an array
                IFS=' ' read -r -a subdirs <<< "${log_dirs_list["$iter"]}"
                if [ -n "${subdirs[i]}" ]; then
                    batch_dirs+=("${subdirs[i]}")
                    echo "  - ${subdirs[i]}"
                fi
            done

            # Extract values and calculate averages
            analytics_values=()
            sim_values=()
            pdi_values=()

            for dir in "${batch_dirs[@]}"; do
                # Check if eisa.log files exist
                while IFS= read -r log_file; do
                    analytics=$(grep "EST_ANALYTICS_TIME" "$log_file" | awk '{print $2}')
                    sim=$(grep "SIM_WTHOUT_PDI" "$log_file" | awk '{print $2}')
                    pdi=$(grep "PDI_DELAY" "$log_file" | awk '{print $2}')
                    
                    # Add values to arrays (ignore if empty)
                    [[ -n "$analytics" ]] && analytics_values+=("$analytics")
                    [[ -n "$sim" ]] && sim_values+=("$sim")
                    [[ -n "$pdi" ]] && pdi_values+=("$pdi")
                done < <(find "$dir" -type f -name "*eisa.log" 2>/dev/null)
            done

            analytics_avg=$(calculate_average "${analytics_values[@]}")
            sim_avg=$(calculate_average "${sim_values[@]}")
            pdi_avg=$(calculate_average "${pdi_values[@]}")

            # Save results to the CSV file
            echo "Batch $((i+1)); $analytics_avg;$sim_avg;$pdi_avg" >> "${result_name}"
        done
    done
done

echo "Processing completed. The Excel files are in the regs_csv folder."
