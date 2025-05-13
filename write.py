import csv

# Input data
dxs_100 = [1000.0, 1000.0, 1000.0, 1000.0, 1000.0, 1000.0, 2000.0, 2000.0, 2000.0, 2000.0, 2000.0, 2000.0, 3000.0, 3000.0, 3000.0, 4000.0, 4000.0, 4000.0]
ys_100 = [57151.94090987559, 57151.94090987559, 60921.61125779207, 60921.61125779207, 65182.69593141933, 65182.69593141933, 55482.31645666618, 55482.31645666618, 59344.61932271163, 59344.61932271163, 63699.709610557315, 63699.709610557315, 53814.8214556599, 57769.125983903614, 62217.76831962638, 52149.6413033136, 56195.244082035606, 60736.93858660098]

dxs_500 = [1000.0, 1000.0, 1000.0, 1000.0, 1000.0, 1000.0, 2000.0, 2000.0, 2000.0, 2000.0, 2000.0, 2000.0, 3000.0, 3000.0, 3000.0, 4000.0, 4000.0, 4000.0]
ys_500 = [57129.35304915225, 57129.35304915225, 60904.413334979596, 60904.413334979596, 65169.929524890176, 65169.929524890176, 55435.59195877943, 55435.59195877943, 59309.11903026242, 59309.11903026242, 63673.39660309805, 63673.39660309805, 53742.28318831589, 57714.13946079732, 62177.0810165116, 52049.46860849034, 56119.49958021555, 60680.99722108949]

dxs_2000 = [1000.0, 1000.0, 1000.0, 1000.0, 1000.0, 1000.0, 2000.0, 2000.0, 2000.0, 2000.0, 2000.0, 2000.0, 3000.0, 3000.0, 3000.0, 4000.0, 4000.0, 4000.0]
ys_2000 = [57124.99215661372, 57124.99215661372, 60901.10771800875, 60901.10771800875, 65167.48511376755, 65167.48511376755, 55426.559830242746, 55426.559830242746, 59302.28916314589, 59302.28916314589, 63668.354972644025, 63668.354972644025, 53728.24189686033, 57703.5500305498, 62169.27957136514, 52030.049070163834, 56104.89667915113, 60670.26258124954]

# Process the data to remove duplicates and organize
def process_data(dxs, ys):
    # Create a dictionary to store unique values for each dx, preserving only unique y values
    data_by_dx = {}
    for dx, y in zip(dxs, ys):
        if dx not in data_by_dx:
            data_by_dx[dx] = set()
        data_by_dx[dx].add(y)
    
    # Convert sets to sorted lists
    for dx in data_by_dx:
        data_by_dx[dx] = sorted(list(data_by_dx[dx]))
    
    return data_by_dx

# Process each dataset
data_100 = process_data(dxs_100, ys_100)
data_500 = process_data(dxs_500, ys_500)
data_2000 = process_data(dxs_2000, ys_2000)

# Get unique dx values and sort them
all_dx_values = sorted(list(set(dxs_100)))

# Create the CSV output
with open('converted_data.csv', 'w', newline='') as csvfile:
    writer = csv.writer(csvfile)
    
    # There are 3 different value sets (grouped by magnitude)
    for group in range(3):
        # Write header for each group
        writer.writerow(['dx', 'a100', 'a500', 'a2000'])
        
        # Write data for each dx in this group
        for dx in all_dx_values:
            writer.writerow([
                dx,
                data_100[dx][group],
                data_500[dx][group],
                data_2000[dx][group]
            ])

# Print the result to console
with open('converted_data.csv', 'r') as f:
    print(f.read())