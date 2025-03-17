#!/bin/sh

exit_msg(){
	echo "$1"
	exit $2
}

help() {
    cat <<EOF
Usage: $(basename "$0") -d <deb_dist_arch> -r <rpm_dist_arch>

Download files and verify them against a manifest.

Required Arguments:
    -d <deb_dist_arch> Git tag to check out
	-r <rpm_dist_arch> Git revision to check out
    -h                 Show this help message
EOF
    exit 0
}

while getopts ":hd:r:" opt; do
    case $opt in
        h) help ;;
        d) deb_dist_arch="$OPTARG" ;;
        r) rpm_dist_arch="$OPTARG" ;;
        \?) error_exit "Invalid option: -$OPTARG" "$tmp_dir" ;;
        :) error_exit "Option -$OPTARG requires an argument" "$tmp_dir" ;;
    esac
done

# Validate required arguments
[ -z "$rpm_dist_arch" ] && [ -z "$deb_dist_arch" ]  && \
	exit_msg "Missing required argument(s) -d <deb_dist_arch> and/or -r <rpm_dist_arch>" 1

process_dist_arch() {
    target="$1"
    dist_arch_list="$2"
    job_count="$3"
    
    for dist_arch in $dist_arch_list; do
        # Select host based on architecture
        case $dist_arch in
            *:arm*|*:aarch*) host="ubuntu-24.04-arm" ;;
            *) host="ubuntu-latest" ;;
        esac
        echo "$host:$target:$dist_arch:$job_count"
    done
}

gen_columns() {
    # Process RPM distributions
    process_dist_arch "rpm" "$rpm_dist_arch" "8"
    # Process DEB distributions
    process_dist_arch "deb" "$deb_dist_arch" "8"
}

gen_columns | \
	column -s ":" --table-columns "host,target,dist,arch,jobs" --json --table-name "to_remove" | \
	sed 's/^.\{0,3\}//' | sed 's/"to_remove": //' | tr '\n' ' ' |sed 's/ //g'
