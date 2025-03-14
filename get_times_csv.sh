#!/bin/bash

# Set the starting directory
START_DIR=$PWD

iterations=("E1" "E2" "E3" "E4" "E5" "E6")
categories=("REISA" "REISA_ONE_ACTOR" "DASK_ON_REISA" "DASK_ON_REISA_ONE_ACTOR")
tasks=("derivative" "reduction")

# List of directory name prefixes for each task
prefixes_derivative=(
    "P4-SN2-LS268-GS1073-I10-AN2"
    "P4-SN2-LS536-GS2147-I10-AN2"
    "P8-SN4-LS268-GS2147-I10-AN4"
    "P8-SN4-LS536-GS4294-I10-AN4"
    "P16-SN8-LS268-GS4294-I10-AN8"
    "P16-SN8-LS536-GS8589-I10-AN8"
    "P128-SN4-LS1-GS134-I10-AN2"
    "P128-SN4-LS134-GS17179-I10-AN2"
)

prefixes_reduction=(
    "P4-SN2-LS268-GS1073-I20-AN2"
    "P4-SN2-LS536-GS2147-I20-AN2"
    "P8-SN4-LS268-GS2147-I20-AN4"
    "P8-SN4-LS536-GS4294-I20-AN4"
    "P16-SN8-LS268-GS4294-I20-AN8"
    "P16-SN8-LS536-GS8589-I20-AN8"
    "P128-SN4-LS1-GS134-I20-AN2"
    "P128-SN4-LS134-GS17179-I20-AN2"
)

#135 246 78
prefixes_derivative=(
    "P4-SN2-LS268-GS1073-I10-AN2"
    "P8-SN4-LS268-GS2147-I10-AN4"
    "P16-SN8-LS268-GS4294-I10-AN8"

    "P4-SN2-LS536-GS2147-I10-AN2"
    "P8-SN4-LS536-GS4294-I10-AN4"
    "P16-SN8-LS536-GS8589-I10-AN8"

    "P128-SN4-LS1-GS134-I10-AN2"
    "P128-SN4-LS134-GS17179-I10-AN2"
)


prefixes_reduction=(
    "P4-SN2-LS268-GS1073-I20-AN2"
    "P8-SN4-LS268-GS2147-I20-AN4"
    "P16-SN8-LS268-GS4294-I20-AN8"

    "P4-SN2-LS536-GS2147-I20-AN2"
    "P8-SN4-LS536-GS4294-I20-AN4"
    "P16-SN8-LS536-GS8589-I20-AN8"

    "P128-SN4-LS1-GS134-I20-AN2"
    "P128-SN4-LS134-GS17179-I20-AN2"
)

# Function to calculate average
calculate_average() {
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

# Create the output directory
mkdir -p regs_csv

# Initialize total results counter
total_results=0

# Loop through categories and tasks
for category in "${categories[@]}"; do
    for task in "${tasks[@]}"; do
        # Select the correct prefix array based on task
        if [ "$task" == "derivative" ]; then
            prefixes=("${prefixes_derivative[@]}")
        elif [ "$task" == "reduction" ]; then
            prefixes=("${prefixes_reduction[@]}")
        else
            echo "Unknown task: $task"
            continue
        fi

        result_file="regs_csv/${category}_${task}.csv"
        echo "Prefix;Analytics_Avg;Sim_Avg;PDI_Avg;Result_Ratio;Total_Number_Of_Results;Total_Number_Of_Runs" > "$result_file"

        # Loop through prefixes and iterations
        for prefix in "${prefixes[@]}"; do
            matching_dirs=()
            for iteration in "${iterations[@]}"; do
                # Find matching directories
                find_cmd=(find "$START_DIR" -mindepth 4 -maxdepth 4 -type d -path "*/$iteration/$category/$task/$prefix*")
                #echo "Running: ${find_cmd[@]}"

                while IFS= read -r dir; do
                    #echo "Found directory: $dir"
                    matching_dirs+=("$dir")
                done < <("${find_cmd[@]}" 2>/dev/null)
            done

            # Initialize counters for ratio calculation
            buffer_results=0
            buffer_total_results=0

            # Initialize arrays to collect all values across directories
            all_analytics_values=()
            all_sim_values=()
            all_pdi_values=()

            # Process each matching directory
            for dir in "${matching_dirs[@]}"; do
                # Extract values from log files
                while IFS= read -r log_file; do
                    buffer_total_results=$((buffer_total_results + 1))
                    analytics=$(grep "EST_ANALYTICS_TIME" "$log_file" | awk '{print $2}')
                    sim=$(grep "SIM_WTHOUT_PDI" "$log_file" | awk '{print $2}')
                    pdi=$(grep "PDI_DELAY" "$log_file" | awk '{print $2}')

                    if [[ -n "$analytics" && -n "$sim" && -n "$pdi" ]]; then
                        buffer_results=$((buffer_results + 1))
                        [[ -n "$analytics" ]] && all_analytics_values+=("$analytics") #double check
                        [[ -n "$sim" ]] && all_sim_values+=("$sim") #double check
                        [[ -n "$pdi" ]] && all_pdi_values+=("$pdi") #double check
                    fi

                    #echo "buffer_total_results: $buffer_total_results; buffer_results: $buffer_results"

                done < <(find "$dir" -type f -name "*eisa.log" 2>/dev/null)
            done

            # Calculate global averages
            global_analytics_avg=$(calculate_average "${all_analytics_values[@]}")
            global_sim_avg=$(calculate_average "${all_sim_values[@]}")
            global_pdi_avg=$(calculate_average "${all_pdi_values[@]}")

            # Calculate the ratio of valid results over total log files analyzed
            if [ "$buffer_total_results" -gt 0 ]; then
                ratio_results=$(echo "scale=2; $buffer_results / $buffer_total_results" | bc -l)
            else
                ratio_results="0.00"
            fi

            # Write results to CSV
            echo "$prefix; $global_analytics_avg; $global_sim_avg; $global_pdi_avg; $ratio_results; $buffer_results; $buffer_total_results" >> "$result_file"
        done

        echo "Results for $category - $task saved in $result_file."
    done
done

# Display total results found
echo "All results are in the 'regs_csv' directory."
