def hex3(n):
    return "0x%s"% ("00000000%x"%(n&0xffffffff))[-8:]

font_h = 5
font_w = 4
num_digit = 12
num_chars = 8
num_cols = num_chars * font_w

with open("digit_index.hex", 'w') as fh:
    for index in range(0, num_digit):
        fh.write(hex3(index * font_h) + "\n")

with open("col_index.hex", 'w') as fh:
    for index in range(0, num_cols):
        fh.write(hex3(index % font_w) + "\n")
