#!/bin/bash
for d in gobyexample/* 
do
 echo "Test running:" $d 
 cd $d
 tardisgo -run *.go
 cd ~/go/src/github.com/tardisgo/tardisgo-samples
done

