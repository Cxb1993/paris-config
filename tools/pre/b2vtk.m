#!/usr/bin/env octave-qf

global NVAR;
global u; global v; global w;
global p; global cvof;
NVAR = 3        + 1 + 1;

function i = header(fd)
  l = fgets(fd);
  [i.time, i.timestamp, i.imin, i.imax, i.jmin, i.jmax, i.kmin, i.kmax] = ...
     strread(l, '%f %d    %d %d %d   %d %d %d');
endfunction

function i = header_file(f)
  fd = fopen(f, 'r');
  i = header(fd);
  fclose(fd);
endfunction

function buf = data(fd)
  buf = fscanf(fd, '%f');
endfunction

function [info, buf] = rbackup(f)
  fd = fopen(f, 'r');
  info = header(fd);
  buf  = data(fd);
  fclose(fd);
endfunction

function g = maxmin(g, i)
  g.imin = min(g.imin, i.imin);
  g.jmin = min(g.jmin, i.jmin);
  g.kmin = min(g.kmin, i.kmin);

  g.imax = max(g.imax, i.imax);
  g.jmax = max(g.jmax, i.jmax);
  g.kmax = max(g.kmax, i.kmax);
endfunction

function ginfo = limits(fl) # get global domain info
  for ia=1:numel(fl); f = fl{ia};
      info = header_file(f);
      if ia == 1; ginfo = info; endif
      ginfo = maxmin(ginfo, info); # [g]lobal [i]nfo
  endfor
endfunction

function f = field_ini(g)
  f = zeros([g.imax, g.jmax, g.kmax]);
endfunction

ginfo = limits(argv());
fi = @(e) field_ini(ginfo);
u = fi(); v = fi(); w = fi(); p = fi(); cvof = fi();

#### should be a loop
ivar = 1;
[i, buf] = rbackup(argv(){1});
buf = reshape(buf, NVAR, []);
u0   = buf(ivar, :);
u0   = reshape(u0,
	       i.imax - i.imin + 1,
	       i.jmax - i.jmin + 1,
	       i.kmax - i.kmin + 1);
u(i.imin:i.imax, i.jmin:i.jmax, i.kmin:i.kmax) = u0;
####

function vtk_version(fd)
  p = @(varargin) fprintf(fd, varargin{:});
  p("# vtk DataFile Version 2.0\n");
endfunction

function vtk_header(fd)
  p = @(varargin) fprintf(fd, varargin{:});
  p("Created with b2vtk.m\n");
endfunction

function vtk_format(fd)
  p = @(varargin) fprintf(fd, varargin{:});
  p("ASCII\n");
endfunction

function vtk_topo(fd)
  p = @(varargin) fprintf(fd, varargin{:});
  global u
  X = 1; Y = 2; Z = 3;
  n = size(u);
  o = [0, 0, 0];  # origin
  s  = [1, 1, 1]; # spacing
  p("DATASET STRUCTURED_POINTS\n")
  p("DIMENSIONS %d %d %d\n",  n(X),  n(Y),  n(Z));
  p("ORIGIN %17.8g %17.8g %17.8g\n", o(X), o(Y), o(Z));
  p("SPACING %17.8g %17.8g %17.8g\n", s(X), s(Y), s(Z));
endfunction

function vtk_pdata_header(fd)
  p = @(varargin) fprintf(fd, varargin{:});
  global u
  p("POINT_DATA %d\n", numel(u));
endfunction

function vtk_scalar(fd)
  p = @(varargin) fprintf(fd, varargin{:});
  global u
  p("SCALARS %s %s\n", "u", "double")
  p("LOOKUP_TABLE default\n")
  dlmwrite(fd, u(:), ' ');
endfunction

fo = "o.vtk";
fd = fopen(fo, "w");
vtk_version(fd);
vtk_header(fd);
vtk_format(fd);
vtk_topo(fd);
vtk_pdata_header(fd);
vtk_scalar(fd);
fclose(fd);
