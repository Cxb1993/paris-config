#!/usr/bin/env octave-qf

1; # make it a script

function rbackup_header(fd)
  l = fgets(fd);
  [time, timestamp, imin, imax, jmin, jmax, kmin, kmax] = ...
     strread(l, '%f %d    %d %d %d   %d %d %d');
endfunction

function rbackup_data(fd)
  nvar = 3 + 1 + 1; # u, v, w, p, cvof
  buf = fscanf(fd, '%f');
  buf = reshape(buf, nvar, []);
  u = buf(1, :);
endfunction

function rbackup(f)
  fd = fopen(f, 'r');
  rbackup_header(fd);
  rbackup_data(fd);
  fclose(fd);
endfunction

f = 'test_data/np8cube/backup_00000'
rbackup(f)
