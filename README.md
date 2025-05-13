## Foundry

First run the command 
```
forge t --mt testCurvePoints -vvvv > curve_output.txt

```
this command will save all balances point inside file named curve_output.txt in root.

next run `python3 extract_csv.py `. this command will extract the logs inside another file named `curve_data.csv`
copy the output after running `python3 extract_csv.py ` and use that data to replace the x and y fields in `write.py` and run the command `python3 write.py` this will create a csv ready data points needed for curve graph.

