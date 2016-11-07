#!/usr/bin/awk -f

# Makes velocity in vtk file relative to the center of mass of the
# droplet (defined by `VOF').  Keeps only scalar filed listed in
# `string_scalars' (by default "VOF")

# Usage:
# ./vcm.awk profile.in.vtk > profile.out.vtk

function abs(x) {return x > 0 ? x : -x}

function error(s) {
    printf "(vcm.awk) %s\n", s | "cat 1>&1"
    exit
}

function init(   string_scalars) {
    string_scalars = "VOF Kappa P" # scalars to read
    asplit(string_scalars, list_scalars)
    X = 1; Y = 2; Z = 3 # dimensions of the vectors

    T = 1 # period of the domain
}

function get_line(   rc) {  # sets `line', array `aline', and `nf'
			    # (number of fields)
    rc = getline line < fn
    nf = split(line, aline)
    return rc  # [r]eturn [c]ode
}

function emptyp(s) { return s ~ /^[ \t]*$/ } # is empty string?

function get_notempty(   ) {                 # next not empty
    while (get_line() > 0 && emptyp(line)) ;
}

function read_version () {
    get_notempty()
    version_line = line
}

function read_header() {
    get_notempty()
    header_line = line
    time = aline[3]
}

function read_format() {
    get_notempty()
    format_line = line
}

function read_topology() {
    read_decl()
}

function read_decl() { # setx `nx', `ny', `nz'; `xl', `yl', `zl'; `dx', `dy', `dz'; `npoints'
    get_notempty()
    dataset_line = line
    if (aline[2] != "STRUCTURED_POINTS") error("works only for STRUCTURED_POINT (found " aline[2] ")")

    get_notempty()
    nx = aline[2]; ny = aline[3]; nz = aline[4]
    npoints = nx * ny * nz

    get_notempty() # ORIGIN
    xl = aline[2]; yl = aline[3]; zl = aline[4]

    get_notempty() # SPACING
    dx = aline[2]; dy = aline[3]; dz = aline[4]
}


function upd_pshift(np) {
    _npoints += np
}


function ps(ip) { # "point shift" (local to global id of a point)
    return ip + _npoints + 0
}

function scalarp() { # is current line a scalar declaration?
    return aline[1]=="SCALARS"
}

function vectorp() { # is current line a vector declaration?
    return aline[1]=="VECTORS"
}

function read_data() {
    get_notempty()             # POINT_DATA <n>
    while (read_vector())  ;
    while (read_scalar())  ;
}

function read_vector(    name, ip, ipg) {
    get_notempty();
    if (!vectorp()) return 0   # not a vector
    
    name = aline[2] # name of a vector
    
    for (ip = 0; ip<npoints; ip++) {
	get_notempty()
	ipg = ps(ip)
	vec[name,X,ipg]=aline[X]; vec[name,Y,ipg]=aline[Y]; vec[name,Z,ipg]=aline[Z]
    }
    return 1 # OK
}

function read_scalar(   name, ip, ipg) {
    if (!scalarp()) return 0   # not a scalar
    name = aline[2] # name of a scalar
    get_notempty()  # skip "LOOKUP_TABLE default" line

    for (ip = 0; ip<npoints; ip++) {
	get_notempty()
	ipg = ps(ip)
	sc[name, ipg] = line
    }
    return 1 # OK
}

function asplit(str, arr,   n, temp) {  # make an assoc array from str
    n = split(str, temp)
    for (i = 1; i <= n; i++)
        arr[temp[i]]++
    return n
}

function check_if_present(ip) {
    if (!(  ip        in  xx)) error("cannot find `x' for point id: " ip)
    if (!(("VOF", ip) in  sc)) error("cannot find `VOF' for point id: " ip)    
}

function unpack_point(ip) { # setx coordinates, VOF, velocity
    check_if_present(ip)
    x = xx[ip]; y = yy[ip]; z = zz[ip]
    VOF = sc["VOF", ip];
    vx=vec["velocity",X,ip]; vy=vec["velocity",Y,ip]; vz=vec["velocity",Z,ip]
}


function ref_bubble_point(    ip, goodVOF) {
    goodVOF = 2/10
    for (ip=0; ip<npoints; ip++) {
	unpack_point(ip)
	if (VOF > goodVOF) {x0 = x; y0 = y; z0 = z; return}
    }
    error("cannot find a ref point on a bubble");
}

function wrap_to(r, r0) {
    if      (abs(r + T - r0)<abs(r - r0)) return r + T
    else if (abs(r - T - r0)<abs(r - r0)) return r - T
    else                                  return r
}

function get_vcm(   ip, volume, vxcm, vycm, vzcm, xcm, ycm, zcm) {
    ref_bubble_point() # sets x0, y0, z0; any point on a bubble
    
    for (ip=0; ip<npoints; ip++) {
	unpack_point(ip)
	x = wrap_to(x, x0); y = wrap_to(y, y0); z = wrap_to(z, z0)
	
	volume += VOF
	vxcm += vx*VOF; vycm += vy*VOF; vzcm += vz*VOF
	xcm  += x*VOF ; ycm  += y*VOF; zcm  += z*VOF
    }
    vxcm/=volume; vycm/=volume; vzcm/=volume
    xcm/=volume; ycm/=volume; zcm/=volume
    
    print time, xcm, ycm, zcm, vxcm, vycm, vzcm
}

function ijk2xyz(i, j, k) { # setx `x', `y', `z'
    x = xl + i*dx; y = yl + j*dy; z = zl + k*dz
}

function set_xyz(   ip, ipg, i, j, k) {
    ip = 0
    for (k=0; k<nz; k++)
	for (j=0; j<ny; j++)
	    for (i=0; i<nx; i++) {
		ijk2xyz(i, j, k)
		ipg = ps(ip)
		xx[ipg] = x; yy[ipg] = y; zz[ipg] = z
		ip++
	    }
}

BEGIN {
    fn = ARGC==1 ?  "-" : ARGV[1] # input file name
    init()

    for (iarg=1; iarg<ARGC; iarg++) {
	fn = ARGV[iarg]
	read_version()
	read_header()
	read_format()
	read_topology()
	set_xyz()
	read_data()
	close(fn)
	upd_pshift(npoints)
    }

    npoints = _npoints
    get_vcm()
}

