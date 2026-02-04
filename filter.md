# filter

Write a filter in gawk to filter input of block. The block is given as a text file.

## Block transmitting protocol
The block contains multiple messages, they are header, body and footer. We use header to identify start of transmition, footer for end of transmition. the body contains all the data
1. header: index number is 0, byte 2 and 3 is block length
2. body: index number 1 to 249 (0xF9), when the message total is more than 249, start with 1 again
3. footer: index is 250 (0xFA), byte 2 and 3 is crc

## Message Format

Each message has 8 bytes (HEX), the first byte is 'index', the rest 7 bytes is 'data'

## Page number

"=== PAGE 000 ===", it starts with "=== PAGE" and 3 digits number '000' as 0.


It provides a variable 'page' to define page number, default is 0.
Execute command:
```bash
gawk -v page=0 -f filter.awk test_3072.hex
```

## Input Example


```TEXT
=== PAGE 000 ===
...
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

## Requirements

1. It should parse page number '=== PAGE 000 ===', here '000' is page number
2. It should parse 'MC=0', means start of the block, it to get block length
3. It should parses 'MC=1','MC=2',...,'MC=F9' to get block data
   If MC more than 249, it starts from 1 again.
4. It parses 'MC=FA' means end of the block, 

## Usage
```bash
gawk -v page=0 -f filter.awk test_3072.hex
```
With a variable 'page', default to 0,  it selects page to filter the block data



### Output is a text
Below is the output of above input example, which is 3072 bytes (0xC00), Every message, it get 7 bytes (each byte = 2 ascii characters, use whitespace as delimiter), So we will have 439 messages: 438 x 7 = 3066, and the last message (439) will have 6 bytes, so total count is: 3072.

```Text
00 02 04 00 00 00 fe
03 00 4c 03 00 6e 03
00 42 04 00 20 04 00
....
10 2e 80 75 80 0a 
```

