##!/usr/bin/env python
print('Version String 10')
import os

EXAMPLE_DESCRIPTIVE_NAME = 'Simple carputils Example'
EXAMPLE_AUTHOR = ''
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
                        type=float, default=20.,
                        help='Duration of simulation (ms). Run for longer to also see repolarization.')
    return parser

def jobID(args):
    """
    Generate name of top level output directory.
    """
    today = date.today()
    return '{}_simple_{}_{}_np{}'.format(today.isoformat(), args.tend,
                                         args.flv, args.np)

@tools.carpexample(parser, jobID)
def run(args, job):


    meshname = SCRIPT_DIR+'meshes/cubeGeom'

    
    # Get basic command line, including solver options from external .par file
    #cmd = tools.carp_cmd(tools.carp_path(os.path.join(EXAMPLE_DIR, 'simple.par')))
    cmd = tools.carp_cmd(tools.simfile_path(os.path.join(SCRIPT_DIR, 'boxTissue.par')))
    
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
            '-gregion[0].g_et',         0.236,  # extracellular conductivity in transverse direction
            '-gregion[0].g_en',         0.236,  # extracellular conductivity in sheet direction
            '-gregion[0].g_il',         0.174,  # intracellular conductivity in longitudinal direction
            '-gregion[0].g_it',         0.019,  # intracellular conductivity in transverse direction
            '-gregion[0].g_in',         0.019,  # intracellular conductivity in sheet direction
            '-gregion[0].g_mult',       0.01     # scale all conducitivites by a factor (to reduce conduction velocity)          
            ]




    stimFile = SCRIPT_DIR+'meshes/stimPoint.vtx'
            
    stim = ['-num_stim',1,
            '-stimulus[0].start', 1.,
            '-stimulus[0].vtx_file',  stimFile,
            # '-stimulus[0].x0',-10.,
            # '-stimulus[0].xd',20.,
            # '-stimulus[0].y0',-10.,
            # '-stimulus[0].yd',20.,
            # '-stimulus[0].z0',-10.,
            # '-stimulus[0].zd',1.,
            '-stimulus[0].npls',       1,
            '-stimulus[0].strength', 50.0,
            '-stimulus[0].duration',  5.0,
            '-stimulus[0].stimtype',  9,
            '-extracell_monodomain_stim', '1',
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