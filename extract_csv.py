import re
import csv
from collections import defaultdict

input_file = "curve_output.txt"
output_file = "curve_data.csv"

# CSV lines
with open(input_file, "r") as infile, open(output_file, "w") as outfile:
    for line in infile:
        if re.match(r"^\d+(\.\d+)?(,\d+(\.\d+)?)*$", line.strip()) or line.startswith("dx,"):
            outfile.write(line)

print(f"✅ CSV saved to {output_file}")

Parse and group by A
data_by_A = defaultdict(list)

with open(output_file) as infile:
    reader = csv.reader(infile)
    for row in reader:
        try:
            dx = int(row[0]) / 1e18
            y = int(row[6]) / 1e18
            A = int(row[2])
            data_by_A[A].append((dx, y))
        except (ValueError, IndexError):
            continue

# Output 
for A, points in data_by_A.items():
    points.sort()  # optional: sort by dx
    dxs = [str(p[0]) for p in points]
    ys = [str(p[1]) for p in points]
    print(f"\ndxs_{A} = [{', '.join(dxs)}]")
    print(f"ys_{A} = [{', '.join(ys)}]")
    print(f"points_{A} = zip(dxs_{A}, ys_{A})")

