import itertools
from PIL import Image, ImageDraw
v_levels = [0, 0.25, 0.75, 1]
max_rgb = 255

square_size = 100
num_squares = 8 # 8*8 = 64
image_w = num_squares * square_size

im = Image.new('RGB', [image_w, image_w])

draw = ImageDraw.Draw(im)

# write to stdout
x = 0
y = 0
for v_combos in itertools.product(v_levels, v_levels, v_levels):
     
    rgb_levels = tuple(int(v * max_rgb) for v in v_combos)
    xy = [x,y,x+square_size, y+square_size]
    print(xy, rgb_levels)
    draw.rectangle(xy, rgb_levels)
    draw.text((x, y), str(v_combos), fill=(255,255,255))
    draw.text((x, y+10), str(v_combos), fill=(0,0,0))
    
    x = x + square_size
    if x >= image_w:
        x = 0
        y = y + square_size

im.save("colours.png", "PNG")
