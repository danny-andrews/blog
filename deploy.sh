#!/bin/bash

# Get task time assets
rm -r static/task-time
cp -r ../task-time/build static/task-time

zola build
surge public dannyandrews.net
