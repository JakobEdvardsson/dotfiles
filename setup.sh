#!/usr/bin/env bash
sudo xargs dnf install -y <dnf-packages.txt
stow .
