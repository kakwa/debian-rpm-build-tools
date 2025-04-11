#!/bin/sh

# Default values
VERSION_START=""
IGNORE_CVES=""

# Convert CPE pattern to regex pattern
cpe_to_regex() {
    local cpe="$1"
    # Escape special regex characters except *
    cpe=$(echo "$cpe" | sed 's/[*+?^${}()|[]/\\&/g')
    # Replace * with .* for regex matching
    echo "$cpe" | sed 's/\\\*/.*/g'
}

usage() {
    echo "Usage: $0 -c cpe_pattern [-v version] [-k api_key] [-i cve1,cve2,...]"
    echo "  -c cpe_pattern  CPE pattern (e.g. 'cpe:2.3:*:libssh2:*:*:*:*:*')"
    echo "  -V version      Starting version to monitor from"
    echo "  -I cve1,cve2,... Comma-separated list of CVE IDs to ignore"
    echo
    echo "Examples:"
    echo "  $0 -c 'cpe:2.3:*:libssh2:*:*:*:*:*' -V 1.10.0"
    echo "  $0 -c 'cpe:2.3:*:openssl:*:*:*:*:*' -V 3.0.0 -I CVE-2022-1234,CVE-2023-5678"
    echo
    echo "Exit codes:"
    echo "  0: No CVEs found or all CVEs are ignored"
    echo "  1: CVEs found (not in ignore list)"
    exit 1
}

while getopts "c:V:I:" opt; do
    case $opt in
        c) CPE_PATTERN="$OPTARG" ;;
        V) VERSION_START="$OPTARG" ;;
        I) IGNORE_CVES="$OPTARG" ;;
        *) usage ;;
    esac
done

# Check if CPE pattern is provided
if [ -z "$CPE_PATTERN" ]; then
    echo "Error: CPE pattern is required" >&2
    usage
fi

# Convert comma-separated list to pipe-separated for regex
IGNORE_LIST=""
if [ -n "$IGNORE_CVES" ]; then
    IGNORE_LIST=$(echo "$IGNORE_CVES" | tr ',' '|')
fi

# Construct URL with parameters
URL="https://services.nvd.nist.gov/rest/json/cves/2.0"
PARAMS="virtualMatchString=${CPE_PATTERN}"

# Add version constraint if provided
if [ -n "$VERSION_START" ]; then
    PARAMS="${PARAMS}&versionStart=${VERSION_START}&versionStartType=including"
fi

# Add API key header if provided
HEADERS=""
if [ -n "$API_KEY" ]; then
    HEADERS="-H apiKey: ${API_KEY}"
fi

# Make the API request and format output with jq
JQ_FILTER='.vulnerabilities[]'
if [ -n "$IGNORE_LIST" ]; then
    # Filter out ignored CVEs
    JQ_FILTER="$JQ_FILTER | select(.cve.id | test(\"^($IGNORE_LIST)$\") | not)"
fi

# Convert CPE pattern to regex for matching
CPE_REGEX=$(cpe_to_regex "$CPE_PATTERN")

QUERY="$JQ_FILTER | \
                    \"ID:          \" + .cve.id +
                    \"\nLink:        https://nvd.nist.gov/vuln/detail/\"+(.cve.id) +
                    \"\nPublished:   \" + (.cve.published) +
                    \"\nSeverity:    \" + (try .cve.metrics.cvssMetricV31[0].cvssData.baseSeverity catch \"UNKNOWN\") +
                    \"\nBase Score:  \" + (try (.cve.metrics.cvssMetricV31[0].cvssData.baseScore | tostring) catch \"N/A\") +
                    \"\nVersion End: \" + (try (.cve.configurations[].nodes[] | select(.cpeMatch[] | .criteria | test(\"^$CPE_REGEX$\")) | .cpeMatch[].versionEndExcluding) catch \"N/A\") +
                    \"\n\" + (\"-\" * 80)"

# Create a temporary file for the JSON response
TEMP_JSON=$(mktemp)
trap 'rm -f "$TEMP_JSON"' EXIT

# Fetch the data
while ! curl -f -s $HEADERS "${URL}?${PARAMS}" > "$TEMP_JSON";
do
    echo "NVD Error for ${CPE_PATTERN}, retrying in 10 seconds"
    sleep 10
done

#cat $TEMP_JSON

# Process and output the results
jq -r "$QUERY" "$TEMP_JSON"

# Check if any CVEs were found (after filtering ignored ones)
CVE_COUNT=$(jq "$JQ_FILTER | .cve.id" "$TEMP_JSON" | wc -l)

if [ "$CVE_COUNT" -gt 0 ]; then
    exit 1
fi

exit 0
