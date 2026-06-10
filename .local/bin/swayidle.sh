#!/usr/bin/env bash

swayidle -w \
  timeout 180 'dms dpms off' \
  resume 'dms dpms on'
