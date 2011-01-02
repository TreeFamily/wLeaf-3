#! /bin/bash
nohup ./wLeaf.rb > wLeaf.log &
nohup ansifilter --html -e UTF-8 -i wLeaf.log -o web/log.html -t &
