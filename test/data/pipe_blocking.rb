#!/usr/bin/ruby

watchdog = Time.now.tv_sec
sleep 1 while Time.now.tv_sec - watchdog < 10
