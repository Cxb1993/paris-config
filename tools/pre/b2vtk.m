#!/usr/bin/env octave-qf

global u v w p cvof
global NVAR
NVAR = 3        + 1 + 1;
global fd # file descriptor

function i = header()
  global fd
  l = fgets(fd);
  [i.time, i.timestamp, i.imin, i.imax, i.jmin, i.jmax, i.kmin, i.kmax] = ...
     strread(l, '%f %d    %d %d %d   %d %d %d');
endfunction

function i = header_file(f)
  global fd
  fd = fopen(f, 'r');
  i = header(fd);
  fclose(fd);
endfunction

function buf = data()
  global fd
  buf = fscanf(fd, '%f');
endfunction

function [info, buf] = rbackup(f)
  global fd
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

function field_ini(g)
  global u v w p cvof
  fi = @() zeros([g.imax, g.jmax, g.kmax]);
  u = fi(); v = fi(); w = fi(); p = fi(); cvof = fi();
endfunction

function field_read(fl)
  global u v w p cvof
  global NVAR
  for f = 1:numel(fl); f = fl{f};
      [i, B] = rbackup(f); % info and buffer
      si = i.imin : i.imax;
      sj = i.jmin : i.jmax; % slice of the global array
      sk = i.kmin : i.kmax;
      ni = numel(si); nj = numel(sj); nk = numel(sk);
      B = reshape(B, NVAR, ni, nj, nk);
      iv = 1; % variable
      u   (si, sj, sk) = B(iv++, :, :, :);
      v   (si, sj, sk) = B(iv++, :, :, :);
      w   (si, sj, sk) = B(iv++, :, :, :);
      p   (si, sj, sk) = B(iv++, :, :, :);
      cvof(si, sj, sk) = B(iv++, :, :, :);
  endfor
endfunction

function vtk_version()
  global fd
  p = @(varargin) fprintf(fd, varargin{:});
  p("# vtk DataFile Version 2.0\n");
endfunction

function vtk_header()
  global fd
  p = @(varargin) fprintf(fd, varargin{:});
  p("Created with b2vtk.m\n");
endfunction

function vtk_format()
  global fd
  p = @(varargin) fprintf(fd, varargin{:});
  p("BINARY\n"); % ASCII
endfunction

function vtk_topo() # topology
  global fd
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

function vtk_pdata_header()
  global fd
  p = @(varargin) fprintf(fd, varargin{:});
  global u
  p("POINT_DATA %d\n", numel(u));
endfunction

function vtk_scalar()
  global fd u
  p = @(varargin) fprintf(fd, varargin{:});
  type = "double";
  p("SCALARS %s %s\n", "u", type)
  p("LOOKUP_TABLE default\n")
  ### ASCII:  dlmwrite(fd, u(:), ' ');
  byte_skip = 0; arch = "ieee-be";
  fwrite(fd, u, type, byte_skip, arch);
endfunction

flist = argv();
ginfo = limits(flist);
field_ini(ginfo);
field_read(flist);

fo = "o.vtk";
fd = fopen(fo, "w");
vtk_version(); vtk_header(); vtk_format();
vtk_topo();
vtk_pdata_header(); vtk_scalar();
fclose(fd);
