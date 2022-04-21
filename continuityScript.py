#NOTE: this program was developed for internal use but the repo is OPSEC-approved.
import numpy as np;import os;import openpyxl;import pandas as pds;import string;
xlsx_location = [r'C:\Users\NRhima\Desktop\  *** .xlsx']  #[*** = path of file(s)]
values=[];merge=pds.DataFrame()

def main(file):
        wb = pds.read_excel(file,usecols=[0,1,2,3,4,5,6,7],skiprows=2)
        global merge;merge= merge.append(wb,ignore_index=True)
        DayNm = wb['Department'].where(wb['DayNm']=='Monday').dropna()
        print('From: %s'%(file),DayNm,sep='\n')
try:
    main(xlsx_location[1]) #initializing main for calculator.V2
except Exception as ex:
    print("Exception type {0} Arguments:\n{1!r}".format\
        (type(ex).__name__,ex.args))

raw_data = [] #full cell list
for n in range(0,8,1):
    COL = string.ascii_uppercase[n]
    for ROW in range(4,88+1,1):
        raw_data.append('{0}{1}'.format(COL,ROW))

with pds.option_context('display.max_rows', None,
                       'display.max_columns', None,
                       'display.precision', 3,
                       ):
           print(merge)
#debug:
"""
values=[]
workbook = openpyxl.load_workbook(*WORKBOOK*)
worksheet = workbook[*SHEET_NAME*]
cell_value = worksheet[*CELL_NAME*].value                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  rns 3
values.append(*cell_value*) #ignore line

print(values) 
"""
