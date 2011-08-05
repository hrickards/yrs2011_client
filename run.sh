#!/bin/sh
shoes &
ssh -t -t -L 3307:127.0.0.1:3306 deploy@ec2-107-20-214-102.compute-1.amazonaws.com
