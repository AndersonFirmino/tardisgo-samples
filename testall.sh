#!/bin/bash
for d in gobyexample/* gohaxelib/*
do
 cd $d
 tardisgo -testall *.go
 cd ~/go/src/github.com/tardisgo/tardisgo-samples
done

