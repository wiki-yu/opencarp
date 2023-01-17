##!/usr/bin/env python
print('Version String 11')
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
    parser = tools.standard_parser()
    parser.add_argument('--tend',
                        type=float, default=100.,
                        help='Duration of simulation (ms). Run for longer to also see repolarization.')
    parser.add_argument('--stimFile',
                        type=str, default='stimFile.vtk',
                        help='stimulation file .vtk')
    parser.add_argument('--label',
                        type=str, default='',
                        help='label for outputs')
    parser.add_argument('--s2',
                        type=float, default=25.,
                        help='s2 start time')
    return parser

def jobID(args):
    """
    Generate name of top level output directory.
    """
    today = date.today()
    return f'{today.isoformat()}_{args.tend:0.0f}{args.label}'

@tools.carpexample(parser, jobID)
def run(args, job):

    meshDir = '/DockerBridge/SignalAlgos_data/openCarp/simpleAtriaExample/meshes/'
    meshname = meshDir+'atria'

    
    # Get basic command line, including solver options from external .par file
    #cmd = tools.carp_cmd(tools.carp_path(os.path.join(EXAMPLE_DIR, 'simple.par')))
    cmd = tools.carp_cmd(tools.simfile_path(os.path.join(SCRIPT_DIR, 'atrialFlutter.par')))
    
    # Attach electrophysiology physics (monodomain) to mesh region with tag 1
    cmd += tools.gen_physics_opts(IntraTags=[1], ExtraTags=[1])

    cmd += ['-simID',    job.ID,
            '-meshname', meshname,
            '-tend',     args.tend]

    # Set monodomain conductivities
    cmd += ['-num_gregions',            1,
            '-gregion[0].name',         "myocardium",
            '-gregion[0].num_IDs',  1,          # one tag will be given in the next line
            '-gregion[0].ID',       "1",        # use these setting for the mesh region with tag 1
            # mondomain conductivites will be calculated as half of the harmonic mean of intracellular
            # and extracellular conductivities
            '-gregion[0].g_el',         0.625,  # extracellular conductivity in longitudinal direction
            '-gregion[0].g_et',         0.625,  # extracellular conductivity in transverse direction
            '-gregion[0].g_en',         0.625,  # extracellular conductivity in sheet direction
            '-gregion[0].g_il',         0.174,  # intracellular conductivity in longitudinal direction
            '-gregion[0].g_it',         0.174,  # intracellular conductivity in transverse direction
            '-gregion[0].g_in',         0.174,  # intracellular conductivity in sheet direction
            '-gregion[0].g_mult',       0.005     # scale all conducitivites by a factor (to reduce conduction velocity)          
            ]




    stimFile = meshDir+args.stimFile
            
    stim = ['-num_stim',2,
            '-stimulus[0].start', 0.,
            '-stimulus[0].vtx_file',  stimFile,
            '-stimulus[0].npls',       1,
            '-stimulus[0].strength', 4000.0,
            '-stimulus[0].duration',  1.0,
            '-stimulus[0].stimtype',  0,
            '-stimulus[1].start', args.s2,
            '-stimulus[1].vtx_file',  stimFile,
            '-stimulus[1].npls',       1,
            '-stimulus[1].strength', 5000.0,
            '-stimulus[1].duration',  1.0,
            '-stimulus[1].stimtype',  0,
            #'-extracell_monodomain_stim', '1',
            ]

    # stim = ['num_stim', 1, 
    #         'stim[0].name', "S1",
    #         'stim[0].crct.type', 0,          
    #         'stim[0].pulse.strength', 250.0,
    #         'stim[0].ptcl.start', 0.,         
    #         'stim[0].ptcl.duration', 2.,      
    #         'stim[0].elec[0].geom_type',2,
    #         'stim[0].elec[0].radius',500,
    #         'stim[0].elec[0].p0',(-10.,-10.,-10.),
    #         'stim[0].elec[0].p1',(10.,10.,-9.)]
    cmd += stim
    # recover phie's at given locations
    #ecg = ['-phie_rec_ptf', os.path.join(CALLER_DIR, 'ecg')]
    ecg = ['-phie_rec_ptf', meshname]
    cmd+= ecg
    # Run simulation
    print(f'Here is the command\n======\n {cmd}')
    job.carp(cmd)



if __name__ == '__main__':
    run()