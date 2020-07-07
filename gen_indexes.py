def hex3(n):
    return "0x%s"% ("00000000%x"%(n&0xffffffff))[-8:]

font_h = 5
font_w = 3
num_digit = 12
num_cols = 27

with open("digit_index.hex", 'w') as fh:
    for index in range(0, num_digit):
        fh.write(hex3(index * font_h) + "\n")

with open("col_index.hex", 'w') as fh:
    for index in range(0, num_cols):
        fh.write(hex3(index % 3) + "\n")
