# controller script to run miltiple simulations
import os
print('Running Simple Atria Carp Simulation')
SCRIPT_DIR = os.path.dirname(__file__)

# Declare a string array with type
StimFiles =["anterior.vtx", "pv_1.vtx" "pv_2.vtx", "pv_3.vtx", "pv_4.vtx"]
StimStrengths = [4000,4000,5000,5000,5000]
startStim = 0
# Read the array values with space
for stimIx in range(startStim,len(StimFiles)):
  print(stimIx, StimFiles[stimIx])
  print({StimFiles[stimIx].replace(".vtx","")})
  # os.system(f'python runAtriaExample.py --stimFile {StimFiles[stimIx]} --label _{StimFiles[stimIx].replace(".vtx","")}_v2 --stimStr {StimStrengths[stimIx]}')
  os.system(f'python runAtriaExample.py --stimFile {StimFiles[stimIx]} --label {StimFiles[stimIx].replace(".vtx","")} --stimStr {StimStrengths[stimIx]}')






