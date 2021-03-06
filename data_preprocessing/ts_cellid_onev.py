#!/usr/bin/env python

"""
------------------------------------------------------------------------------------------------------------------
TELECOM OPEN DATA PREPROCESSING

File name: ts_cellid_onev.py
Description: This script sum values of each variable (messages_in, messages_out, calls_in, calls_out, internet_traffic), 
ignoring the country code and summing the data by hour. It creates one file for one variable each time you run the script (choose variable on line 77)
Author:Carolina Arias Munoz
Date Created: 30/07/2016
Date Last Modified: 30/07/2016
Python version: 2.7
------------------------------------------------------------------------------------------------------------------
"""
import csv
import numpy
import time
#from datetime import datetime, timedelta
import glob

def tsv_from_dict(dictionary):
  table = ""

  for date_time in dictionary.keys():
    for sid in dictionary[date_time].keys():
      table += date_time + '\t' + str(sid) + '\t' + str(dictionary[date_time][sid]) + '\n'
    
  
  return table
# ---------------------------------------------------------------
ncols = 2
nrows = 24

grid_nodata = -9999

records = nrows

# tsv_file = 'sms-call-internet-mi-2013-11-01.txt'

out = {}

#----------------------------------------------------------------------------------------------------- 
#imput folder most contain oiginal csv files from telecom open data. In this case we have only data for december    
data_path = '/media/sf_2_PhD_2013_-2014/1PhD_WorkDocs/PhD_Data-calculations/data/sms-call-internet-mi/12alldata_dic/'
#data_path = "D:\OneDrive for Business\Dropbox\2_PhD 2013 -2014\2PhD_WorkDocs\PhD_big-data\data\sms-call-internet-mi"
data_files = glob.glob(data_path + '*.txt')

for data_file in data_files:

  with open(data_file, 'rb') as telecom_data:

    telecom_data = csv.reader(telecom_data, delimiter='\t')
    count = 0

    print "Start parsing data in " + data_file + '...'

    for row in telecom_data:

      # 0: sid
      # 1: timestamp
      # 2: country_code
      # 3: messages_in
      # 4: messages_out
      # 5: calls_in
      # 6: calls_out
      # 7: internet_traffic

      sid = row[0]
      ts = row[1][0:10]
      ts = numpy.longdouble(ts)
      variable = row[6]

      # Check empty values and convert values to double
      if variable == '':
        variable = numpy.longdouble(0.0)
      elif type(variable) is str:
        variable = numpy.longdouble(variable)
      
      
      #timestamp 
      # %w - day of the week as a decimal, Sunday=0 
      # %W - week number of the current year, starting with the first Monday as the first day of the first week
      # ts = time.strftime("%Y-%m-%d %H:%M:%S-%W-%w", time.gmtime(ts))
  #    date = time.strftime("%Y-%m-%d", time.gmtime(ts))
      date_time = time.strftime("%Y-%m-%dT%H:00:00+0100", time.gmtime(ts))
  #    hour = time.strftime("%H", time.gmtime(ts))
    
       # Add the timestamp to the dictionary
      if date_time not in out:
        out[date_time] = {}
     
      # Add the cell id to the dictionary
      if sid not in out[date_time]:
       out[date_time][sid] = numpy.longdouble(0.0)

    # Add values with same timestamp and same cell id
      out[date_time][sid] += variable
      
      count += 1

      # Give feedback
      if count < 10000 and count % 1000 == 0:
        print 'Parsed', count, 'records'    
      elif count % 100000 == 0:
        print 'Parsed', count, 'records'
print ""
# Give feedback again
#print 'Finished parsing data. There are', len(out.keys()), 'timestamps.'
#print 'Writing', len(out.keys()), ' files...'
print 'Finished parsing data.'
print 'Writing files...'

#-----------------------------------------------------------------------------------------------------     

# Write the files
fcount = 0

for date_time in sorted(out):

  #assert len(out[date_time]) == records
  #print out[ts]

  values = tsv_from_dict(out)
  filename = ''.join(['/media/sf_2_PhD_2013_-2014/1PhD_WorkDocs/PhD_Data-calculations/data/wundermap/nov_dic_2013/csv/', 'callsout_dic', '.tsv'])

  if fcount == 0:
    f = open(filename, 'w')
  else:
    f = open(filename, 'a')
    
  f.write(values)
  f.close()
  
  fcount += 1
  print fcount,'timestamp added to the file...'
print "Done"
