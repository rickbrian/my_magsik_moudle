MODDIR=${0%/*}

# This script will be executed in late_start service mode

# wait for boot to complete
while [ "$(getprop sys.boot_completed)" != 1 ]; do
    sleep 1
done

# ensure boot has actually completed
sleep 5

# restart on crash
while true; do
    fs16-4-7 -l 0.0.0.0:12345
    sleep 1
done