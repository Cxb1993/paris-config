#!/usr/bin/env octave-qf

1; # make it a script

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

function data(fd)
  nvar = 3 + 1 + 1; # u, v, w, p, cvof
  buf = fscanf(fd, '%f');
  buf = reshape(buf, nvar, []);
  u = buf(1, :);
endfunction

function rbackup(f)
  fd = fopen(f, 'r');
  header(fd);
  data(fd);
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

f     = 'test_data/np8cube/backup_00000';
ginfo = limits(argv())

# rbackup(f)
