##!/usr/bin/env python
print('Version String so we know any updates made it: 11')
#import block
import os
EXAMPLE_DESCRIPTIVE_NAME = 'Simple Atria Simulation Example'
EXAMPLE_AUTHOR = 'Jake Bergquist'
SCRIPT_DIR = os.path.dirname(__file__)
CALLER_DIR = os.getcwd()
from datetime import date

# import required carputils modules
from carputils import settings
from carputils import tools
from carputils import mesh
from carputils import testing

# define parameters exposed to the user on the commandline
def parser():
    parser = tools.standard_parser()#Initilize a standard CARP parser
    #add simulation time as an argument
    parser.add_argument('--tend',
                        type=float, default=20.,
                        help='Duration of simulation (ms). Run for longer to also see repolarization.')
    #stimulation file, specifying the indices of th enodes to stimulate at, 0 based
    parser.add_argument('--stimFile',
                        type=str, default='pv_1.vtx',
                        help='stimulation file .vtx')
    #a label to append to the output files and folder
    parser.add_argument('--label',
                        type=str, default='pv_1_v2',
                        help='label for outputs')
    #the strength of the stimulation. See opencarp website for what kinds of stimulations available
    parser.add_argument('--stimStr',type=float,default=4000.,help='Stimulation strength')
    return parser

def jobID(args):
    """
    Generate name of top level output directory.
    """
    today = date.today()
    return f'{today.isoformat()}_{args.tend:0.0f}{args.label}'

@tools.carpexample(parser, jobID)
def run(args, job):
    #specify where the meshes live. Assumes that they are in a subfolder of the directory
    # where the scrip was called from called meshes. In this cases looking for the atria mesh
  
    meshDir = CALLER_DIR + '/meshes/'
    print("@@@ meshDir: ", meshDir)
    meshname = meshDir + 'atria'
    print("@@@ meshname: ", meshname)
    print("###### ", os.path.join(SCRIPT_DIR, 'atriaExample.par'))

    
    # Get basic command line, including solver options from external .par file
    cmd = tools.carp_cmd(tools.simfile_path(os.path.join(SCRIPT_DIR, 'atriaExample.par')))
    
    # Attach electrophysiology physics (bidomain) to mesh region with tag 1
    cmd += tools.gen_physics_opts(IntraTags=[1], ExtraTags=[1])

    # add the id, mesh location, and simulation time
    cmd += ['-simID',    job.ID,
            '-meshname', meshname,
            '-tend',     args.tend]

    # Set monodomain conductivities
    cmd += ['-num_gregions',            1,
            '-gregion[0].name',         "myocardium",
            '-gregion[0].num_IDs',  1,          # one tag will be given in the next line
            '-gregion[0].ID',       "1",        # use these setting for the mesh region with tag 1
            # monodomain (if used) conductivites will be calculated as half of the harmonic mean of intracellular
            # and extracellular conductivities
            # we are assuming isotropic conductivity, so all directions set to the same
            '-gregion[0].g_el',         0.625,  # extracellular conductivity in longitudinal direction
            '-gregion[0].g_et',         0.625,  # extracellular conductivity in transverse direction
            '-gregion[0].g_en',         0.625,  # extracellular conductivity in sheet direction
            '-gregion[0].g_il',         0.174,  # intracellular conductivity in longitudinal direction
            '-gregion[0].g_it',         0.174,  # intracellular conductivity in transverse direction
            '-gregion[0].g_in',         0.174,  # intracellular conductivity in sheet direction
            '-gregion[0].g_mult',       0.005     # scale all conducitivites by a factor (to reduce conduction velocity)          
            ]


    # specify the location of the stimulation file
    stimFile = meshDir+args.stimFile
    print("stimFile: ", stimFile)
    
    # set up the stimulus
    stim = ['-num_stim',1, #stimulate one time
            '-stimulus[0].start', 1., #start at 1 ms into the simulation
            '-stimulus[0].vtx_file',  stimFile, #use this file to know where to stimulate
            '-stimulus[0].npls',       1, #one pulse
            '-stimulus[0].strength', args.stimStr, #at this strength
            '-stimulus[0].duration',  1.0, #stimulate for this many miliseconds
            '-stimulus[0].stimtype',  0, #Check opencarp website for what type of stimulus this codes for
            #'-extracell_monodomain_stim', '1', #uncomment this if using monodomain
            ]
    cmd += stim
    # recover phie's at given locations
    #ecg = ['-phie_rec_ptf', os.path.join(CALLER_DIR, 'ecg')]
    ecg = ['-phie_rec_ptf', meshname] #specifies where to recover phie
    cmd+= ecg
    # Run simulation
    print(f'Here is the command\n======\n {cmd}') # print the full final command
    # Run the command through carp
    job.carp(cmd)


if __name__ == '__main__':
    StimFiles =["anterior.vtx", "pv_1.vtx" "pv_2.vtx", "pv_3.vtx", "pv_4.vtx"]
    StimStrengths = [4000,4000,5000,5000,5000]
    startStim = 0
    run()