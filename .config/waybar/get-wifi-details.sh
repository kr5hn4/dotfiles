#!/bin/bash
nmcli -t -f ACTIVE,SIGNAL dev wifi | awk -F: '/^yes/ {
  s = $2;
  i = (s > 80 ? " " : s > 60 ? " " : s > 40 ? " " : s > 20 ? " " : " ");
  printf "%s %s%%\n", i, s;
  found = 1;
} END {
  if (!found) print "󰖪 0%";
}'
