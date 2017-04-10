! Test file for VOF test case
!
! 4  grid points per dimension per domain
! 8  mpi processes

! The input file for running the PARIS code
! Parameters are read using a namelist statement.
! Blank lines and commented lines are ignored.
! Location of the parameters in the list is not important.

&PARAMETERS

! name of the namelist
!=================================================================================================
! General parameters

TWOPHASE = T         ! TwoPhase: Is the flow two-phase?
DoVOF	  = T
DoFront   = F
GetPropertiesFromFront = F ! T: uses Front-Tracking data to compute mu, rho and Surface Tension.
			   ! F: uses VOF data to compute mu and rho.

ZeroReynolds = F
Implicit  = F
hypre     = T       ! T: uses hyprepackage, F: uses SOR solver
restart   = F       ! T: start the domain from a previous simulation
restartFront = F    ! T: start the frontfrom  a previous simulation
restartAverages = F
nBackup  = 4000      ! number of time steps between  backups are kept.

NSTEP   = 10000000 ! maximum number of time steps
EndTime = 1.0      ! When to stop simulation

MaxDt   = 1e-1     ! maximum size of time step
dtFlag  = 2        ! 1: fixed dt;  2: fixed CFL
dt      = 5e-6     ! dt in case of dtFlag=1
CFL     = 0.2
MAXERROR= 1d-6     ! Residual for Poisson solver
MAXERRORVOL = 1d-4
		   ! Numerical parameters

ITIME_SCHEME = 1
		   ! time scheme: 1:first order Euler, 2: second order quasi Crank-Nicolson

MAXIT    =  50
BETA     = 1.2
		    ! parameters for linear solver
U_init   = 0.d0
!=================================================================================================
! Output parameters

termout  = 10
ICOut    = T            ! output initial condition
NOUT     = 100          ! write the solution to file every nout time steps
output_format = 5       ! 1:tecplot 2:vtk 5:silo
out_path = 'out'        ! name of the output directory

nstats   = 20           ! number of time steps between flow statistics calculations

!=================================================================================================
! Grid parameters
npx      = 2
npy      = 2
npz      = 2
		   ! number of processors in x,y,z direction

Nx      = 64
Ny      = 64
Nz      = 64
Ng      = 2
		   ! grid size in x,y,z direction and number of ghost cells

XLENGTH = 1.0
YLENGTH = 1.0
ZLENGTH = 1.0
		   ! domain size in x,y,z direction

read_x   = F       ! read the grid file for x-grid; If true xLength and xform are neglected
read_y   = F
read_z   = F

x_file   = 'xh.dat'	! input file for xh (Nx+1 points)
y_file   = 'yh.dat'
z_file   = 'zh.dat'

xform    = 0.0		!1.0
yform    = 0.0		!1.0
zform    = 0.0		! non-uniformity of the grid if not reading an input file
			! 0:uniform; +:clustered at center; -:clustered near ends

!=================================================================================================
! Flow parameters
GX      = 0.0
GY      = 0.0
GZ      = 0.0
		   ! Components of the gravity in x,y,z direction

BDRY_COND = 1    1    0   1   1  0
		   !Type of boundary condition in x,y,z direction: 0:wall  1:periodic  2:shear
		   !x- y- z- x+ y+ z+

dPdX      = -320.0
dPdY      =  0.0
dPdZ      =  0.0
		   ! Px, Py, Pz: pressure gradients in case of pressure driven channel flow
		   ! Px = (P(xLength)-P(0))/xLength

RHO1    = 1.0
MU1     = 1.0      !
		   ! rho1, mu1 : density and viscosity of the matrix phase

RHO2    = 8.0      !
MU2     = 8.0      !
		   ! rho2, mu2 : properties of the drop
SIGMA    = 800.0

NumBubble =  1
! number of bubbles
xyzrad(1, 1)  = 0.5
xyzrad(2, 1)  = 0.5
xyzrad(3, 1)  = 0.8263
xyzrad(4, 1)  = 0.125
		   ! Initial bubble size and location : x,y,z,radius

MaxPoint = 2000000
MaxElem  = 4000000
MaxFront = 100
amin     = 0.32
amax     = 0.96
aspmax   = 1.54

smooth   = T        !smooth the interface
nsmooth  = 10       !every nsmooth time steps
nregrid  = 10       !regrid the front every nregrid time steps

BUOYANCYCASE = 0
		   ! BuoyancyCase : determines what density will be subtracted from the gravity
		   ! body force.
		   ! 0: rro=0,  1: rro=rho1,  2: rro=rho2,  3: rro=average(rho)
!=================================================================================================

/
! end of the namelist
