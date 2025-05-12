## Foundry

First run the command 
```
forge t --mt testCurvePoints -vvvv > curve_output.txt

```
this command will save all balances point inside file named curve_output.txt in root.

next run `python3 extract_csv.py `. this command will extract the logs inside another file named `curve_data.csv`

