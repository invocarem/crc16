# filter

This defines a gawk script that process a text file

### requirements

1. the script parses 'MC=0' for block length
2. the script parses 'MC=1','MC=2',...,'MC=F9' to get block data
3. the script parses 'MC=FA' for block
4. the script should generate crc based on the parsed block buffer
5. compare the two crc, hope they are same

## Input is a text file:

below is an example:

```TEXT
Message 00: 0 00 0C 00 00 00 00 00 | MC=0 [Page Header] PageSize: 3072 FlashAddr: 0x00000000
Message 01: 1 00 02 04 00 00 00 fe | MC=1
Message 02: 2 03 00 4c 03 00 6e 03 | MC=2
Message 03: 3 00 42 04 00 20 04 00 | MC=3
Message 04: 4 66 04 00 90 03 00 66 | MC=4
Message 05: 5 04 00 66 04 00 66 04 | MC=5
Message 06: 6 00 66 04 00 66 04 00 | MC=6
...
Message 439: BE 10 2e 80 75 80 0a FF | MC=BE
Message 440: FA 91 AC FF FF FF FF FF | MC=FA
```

## Message Format

Each message has 8 bytes (HEX), the first byte is 'index', the rest 7 bytes is 'data'

## Block transmitting protocol

1. header: index is 0, byte 2 and 3 is block length
2. body: index 1 to 249 (0xF9), when more than 249, start from 1 again
3. footer: index is 250 (0xFA), byte 2 and 3 is crc

# Awk Implementation notes
1. for generating crc please refer to crc16.md and crc16.awk