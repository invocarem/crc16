#!/usr/bin/awk -f
# ================================================================
# filter_hex.awk - Extract hex bytes from HEX2CAN dump
# ================================================================
# Outputs 7 bytes from each message (excluding MC=0 and MC=FA)
# Only processes specified page (default page 0)
# Removes trailing FF bytes that exceed page size boundary
#
# Usage:
#   gawk -f filter_hex.awk test_64.hex
#   gawk -v page=0 -f filter_hex.awk test_64.hex
# ================================================================

BEGIN {
    current_page = -1
    if (page == "") page = 0  # Default to page 0
    page_size = 0
    bytes_in_page = 0
}

# Extract page size
/^Page Size:/ {
    if (match($0, /Page Size:\s+([0-9]+)/)) {
        page_size = strtonum(substr($0, RSTART+11, RLENGTH-11))
    }
}

# Track page headers
/^=== PAGE/ {
    current_page = 0
    bytes_in_page = 0
    if (match($0, /PAGE ([0-9A-Fa-f]+)/)) {
        current_page = strtonum(substr($0, RSTART+5, RLENGTH-5))
    }
}

# Match message lines: "Message XX: <index> <byte1> <byte2> ... | MC=<value>"
/^Message/ {
    # Only process lines from the target page
    if (current_page != page) next
    
    # Extract MC value (after the = sign following "MC")
    mc = ""
    if (match($0, /MC=([0-9A-Fa-f]+)/)) {
        mc = toupper(substr($0, RSTART+3, RLENGTH-3))
    }
    
    # Skip MC=0 and MC=FA
    if (mc == "0" || mc == "FA") next
    
    # Extract the hex bytes portion (between colon and pipe)
    # Look for pattern: "Message XX: <data> | MC="
    colon_pos = index($0, ":")
    if (colon_pos == 0) next
    
    pipe_pos = index($0, "|")
    if (pipe_pos == 0) next
    
    hex_part = substr($0, colon_pos + 1, pipe_pos - colon_pos - 1)
    
    # Remove leading and trailing spaces
    gsub(/^[ \t]+/, "", hex_part)
    gsub(/[ \t]+$/, "", hex_part)
    
    # Split by spaces
    n = split(hex_part, bytes, /[ \t]+/)
    
    if (n < 2) next
    
    # Skip first byte (index), take up to 7 bytes
    output_count = 0
    for (i = 2; i <= n && output_count < 7; i++) {
        output[output_count++] = bytes[i]
    }
    
    # Trim trailing FF bytes if they exceed page boundary
    if (page_size > 0) {
        # Calculate bytes remaining in page
        bytes_remaining = page_size - bytes_in_page
        
        # If we have more bytes than fit in the page, trim
        if (output_count > bytes_remaining) {
            # Remove trailing FF bytes beyond page boundary
            while (output_count > bytes_remaining) {
                output_count--
            }
            # Also remove any remaining trailing FF bytes
            while (output_count > 0 && toupper(output[output_count-1]) == "FF") {
                output_count--
            }
        }
    }
    
    # Build output string
    result = ""
    for (i = 0; i < output_count; i++) {
        if (i > 0) result = result " "
        result = result output[i]
    }
    
    # Print result if any bytes exist
    if (output_count > 0) {
        print result
        bytes_in_page += output_count
    }
}
