#!/usr/bin/awk -f
# crc16_arc.awk  –  CRC‑16‑ARC (IBM/ANSI) calculator
# -------------------------------------------------
# Usage examples
#   echo "31 32 33 34 35 36 37 38 39" | ./crc16_arc.awk
#   ./crc16_arc.awk < hexlist.txt
# -------------------------------------------------

# -------------------------------------------------
# 1) The 256‑entry lookup table (exact copy of the C# table)
# -------------------------------------------------
BEGIN {
    # The table is written as an explicit array literal – no splitting,
    # no chance of a missing element.
    tbl[0]   = 0x0000; tbl[1]   = 0xC0C1; tbl[2]   = 0xC181; tbl[3]   = 0x0140;
    tbl[4]   = 0xC301; tbl[5]   = 0x03C0; tbl[6]   = 0x0280; tbl[7]   = 0xC241;
    tbl[8]   = 0xC601; tbl[9]   = 0x06C0; tbl[10]  = 0x0780; tbl[11]  = 0xC741;
    tbl[12]  = 0x0500; tbl[13]  = 0xC5C1; tbl[14]  = 0xC481; tbl[15]  = 0x0440;
    tbl[16]  = 0xCC01; tbl[17]  = 0x0CC0; tbl[18]  = 0x0D80; tbl[19]  = 0xCD41;
    tbl[20]  = 0x0F00; tbl[21]  = 0xCFC1; tbl[22]  = 0xCE81; tbl[23]  = 0x0E40;
    tbl[24]  = 0x0A00; tbl[25]  = 0xCAC1; tbl[26]  = 0xCB81; tbl[27]  = 0x0B40;
    tbl[28]  = 0xC901; tbl[29]  = 0x09C0; tbl[30]  = 0x0880; tbl[31]  = 0xC841;
    tbl[32]  = 0xD801; tbl[33]  = 0x18C0; tbl[34]  = 0x1980; tbl[35]  = 0xD941;
    tbl[36]  = 0x1B00; tbl[37]  = 0xDBC1; tbl[38]  = 0xDA81; tbl[39]  = 0x1A40;
    tbl[40]  = 0x1E00; tbl[41]  = 0xDEC1; tbl[42]  = 0xDF81; tbl[43]  = 0x1F40;
    tbl[44]  = 0xDD01; tbl[45]  = 0x1DC0; tbl[46]  = 0x1C80; tbl[47]  = 0xDC41;
    tbl[48]  = 0x1400; tbl[49]  = 0xD4C1; tbl[50]  = 0xD581; tbl[51]  = 0x1540;
    tbl[52]  = 0xD701; tbl[53]  = 0x17C0; tbl[54]  = 0x1680; tbl[55]  = 0xD641;
    tbl[56]  = 0xD201; tbl[57]  = 0x12C0; tbl[58]  = 0x1380; tbl[59]  = 0xD341;
    tbl[60]  = 0x1100; tbl[61]  = 0xD1C1; tbl[62]  = 0xD081; tbl[63]  = 0x1040;
    tbl[64]  = 0xF001; tbl[65]  = 0x30C0; tbl[66]  = 0x3180; tbl[67]  = 0xF141;
    tbl[68]  = 0x3300; tbl[69]  = 0xF3C1; tbl[70]  = 0xF281; tbl[71]  = 0x3240;
    tbl[72]  = 0x3600; tbl[73]  = 0xF6C1; tbl[74]  = 0xF781; tbl[75]  = 0x3740;
    tbl[76]  = 0xF501; tbl[77]  = 0x35C0; tbl[78]  = 0x3480; tbl[79]  = 0xF441;
    tbl[80]  = 0x3C00; tbl[81]  = 0xFCC1; tbl[82]  = 0xFD81; tbl[83]  = 0x3D40;
    tbl[84]  = 0xFF01; tbl[85]  = 0x3FC0; tbl[86]  = 0x3E80; tbl[87]  = 0xFE41;
    tbl[88]  = 0xFA01; tbl[89]  = 0x3AC0; tbl[90]  = 0x3B80; tbl[91]  = 0xFB41;
    tbl[92]  = 0x3900; tbl[93]  = 0xF9C1; tbl[94]  = 0xF881; tbl[95]  = 0x3840;
    tbl[96]  = 0x2800; tbl[97]  = 0xE8C1; tbl[98]  = 0xE981; tbl[99]  = 0x2940;
    tbl[100] = 0xEB01; tbl[101] = 0x2BC0; tbl[102] = 0x2A80; tbl[103] = 0xEA41;
    tbl[104] = 0xEE01; tbl[105] = 0x2EC0; tbl[106] = 0x2F80; tbl[107] = 0xEF41;
    tbl[108] = 0x2D00; tbl[109] = 0xEDC1; tbl[110] = 0xEC81; tbl[111] = 0x2C40;
    tbl[112] = 0xE401; tbl[113] = 0x24C0; tbl[114] = 0x2580; tbl[115] = 0xE541;
    tbl[116] = 0x2700; tbl[117] = 0xE7C1; tbl[118] = 0xE681; tbl[119] = 0x2640;
    tbl[120] = 0x2200; tbl[121] = 0xE2C1; tbl[122] = 0xE381; tbl[123] = 0x2340;
    tbl[124] = 0xE101; tbl[125] = 0x21C0; tbl[126] = 0x2080; tbl[127] = 0xE041;
    tbl[128] = 0xA001; tbl[129] = 0x60C0; tbl[130] = 0x6180; tbl[131] = 0xA141;
    tbl[132] = 0x6300; tbl[133] = 0xA3C1; tbl[134] = 0xA281; tbl[135] = 0x6240;
    tbl[136] = 0x6600; tbl[137] = 0xA6C1; tbl[138] = 0xA781; tbl[139] = 0x6740;
    tbl[140] = 0xA501; tbl[141] = 0x65C0; tbl[142] = 0x6480; tbl[143] = 0xA441;
    tbl[144] = 0x6C00; tbl[145] = 0xACC1; tbl[146] = 0xAD81; tbl[147] = 0x6D40;
    tbl[148] = 0xAF01; tbl[149] = 0x6FC0; tbl[150] = 0x6E80; tbl[151] = 0xAE41;
    tbl[152] = 0xAA01; tbl[153] = 0x6AC0; tbl[154] = 0x6B80; tbl[155] = 0xAB41;
    tbl[156] = 0x6900; tbl[157] = 0xA9C1; tbl[158] = 0xA881; tbl[159] = 0x6840;
    tbl[160] = 0x7800; tbl[161] = 0xB8C1; tbl[162] = 0xB981; tbl[163] = 0x7940;
    tbl[164] = 0xBB01; tbl[165] = 0x7BC0; tbl[166] = 0x7A80; tbl[167] = 0xBA41;
    tbl[168] = 0xBE01; tbl[169] = 0x7EC0; tbl[170] = 0x7F80; tbl[171] = 0xBF41;
    tbl[172] = 0x7D00; tbl[173] = 0xBDC1; tbl[174] = 0xBC81; tbl[175] = 0x7C40;
    tbl[176] = 0xB401; tbl[177] = 0x74C0; tbl[178] = 0x7580; tbl[179] = 0xB541;
    tbl[180] = 0x7700; tbl[181] = 0xB7C1; tbl[182] = 0xB681; tbl[183] = 0x7640;
    tbl[184] = 0x7200; tbl[185] = 0xB2C1; tbl[186] = 0xB381; tbl[187] = 0x7340;
    tbl[188] = 0xB101; tbl[189] = 0x71C0; tbl[190] = 0x7080; tbl[191] = 0xB041;
    tbl[192] = 0x5000; tbl[193] = 0x90C1; tbl[194] = 0x9181; tbl[195] = 0x5140;
    tbl[196] = 0x9301; tbl[197] = 0x53C0; tbl[198] = 0x5280; tbl[199] = 0x9241;
    tbl[200] = 0x9601; tbl[201] = 0x56C0; tbl[202] = 0x5780; tbl[203] = 0x9741;
    tbl[204] = 0x5500; tbl[205] = 0x95C1; tbl[206] = 0x9481; tbl[207] = 0x5440;
    tbl[208] = 0x9C01; tbl[209] = 0x5CC0; tbl[210] = 0x5D80; tbl[211] = 0x9D41;
    tbl[212] = 0x5F00; tbl[213] = 0x9FC1; tbl[214] = 0x9E81; tbl[215] = 0x5E40;
    tbl[216] = 0x5A00; tbl[217] = 0x9AC1; tbl[218] = 0x9B81; tbl[219] = 0x5B40;
    tbl[220] = 0x9901; tbl[221] = 0x59C0; tbl[222] = 0x5880; tbl[223] = 0x9841;
    tbl[224] = 0x8801; tbl[225] = 0x48C0; tbl[226] = 0x4980; tbl[227] = 0x8941;
    tbl[228] = 0x4B00; tbl[229] = 0x8BC1; tbl[230] = 0x8A81; tbl[231] = 0x4A40;
    tbl[232] = 0x4E00; tbl[233] = 0x8EC1; tbl[234] = 0x8F81; tbl[235] = 0x4F40;
    tbl[236] = 0x8D01; tbl[237] = 0x4DC0; tbl[238] = 0x4C80; tbl[239] = 0x8C41;
    tbl[240] = 0x4400; tbl[241] = 0x84C1; tbl[242] = 0x8581; tbl[243] = 0x4540;
    tbl[244] = 0x8701; tbl[245] = 0x47C0; tbl[246] = 0x4680; tbl[247] = 0x8641;
    tbl[248] = 0x8201; tbl[249] = 0x42C0; tbl[250] = 0x4380; tbl[251] = 0x8341;
    tbl[252] = 0x4100; tbl[253] = 0x81C1; tbl[254] = 0x8081; tbl[255] = 0x4040;

    crc = 0            # start value = 0x0000
}
{
    # -------------------------------------------------
    # 2) Process each hex token on the current line
    # -------------------------------------------------
    for (i = 1; i <= NF; i++) {
        # Convert the textual token to a numeric byte (0‑255)
        byte = strtonum("0x" $i)

        # x = (crc ^ byte) & 0xFF
        x = and(xor(crc, byte), 0xFF)

        # high = (crc >> 8) & 0xFF   (unsigned shift)
        high = and(rshift(crc, 8), 0xFF)

        # crc = (tbl[x] ^ high) & 0xFFFF
        crc = and(xor(tbl[x], high), 0xFFFF)
    }
}
END {
    # -------------------------------------------------
    # 3) Print the final CRC (no final xor)
    # -------------------------------------------------
    printf "CRC‑16 (IBM/ARC) = %04X\n", and(crc, 0xFFFF)
}
