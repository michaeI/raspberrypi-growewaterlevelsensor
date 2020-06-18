#!/bin/bash
# author: michal.owsinski@gmail.com
# Script to display liquid level (%) from Grove water level sensor (10cm) via i2c interface
# https://wiki.seeedstudio.com/Grove-Water-Level-Sensor/
# bc is required! (sudo apt install bc)

i2c=(/usr/sbin/i2cget -y -a 1)

# the sensor is equiped with 20 measurement points - low 8 and high 12

low8=0x77
high12=0x78
totalpoints=20
# min measurement point value to count as active
minval=0xf6

while true; do
    level=0
    i2c=(/usr/sbin/i2cget -y -a 1)
    i2c+=("$low8")

    # check low 8
    for i in {0..7}
    do
        i2c=(/usr/sbin/i2cget -y -a 1)
        i2c+=("$low8")
        i2c+=("0x5${i}")
        checkaddr=$("${i2c[@]}")

       if [ "$(($checkaddr))" -gt "$(($minval))" ]
         then
             level=$((level+1))
       fi
    done
    
    if [ $level -gt 4 ]
        then
          # dont check high 12 if last low is not active (less than 5) - should be less than 8 but in some cases some measurement points were malfunctioning
         for j in {0..11}
         do
                i2c=(/usr/sbin/i2cget -y -a 1)
                i2c+=("$high12")
                # convert dec to hex
                hex=$(echo "obase=16;ibase=10; ${j}" | bc )
                i2c+=("0x$hex")
                checkaddr=$("${i2c[@]}")
                if [ "$(($checkaddr))" -lt "$(($minval))" ]
                then
                    break
                fi

                level=$((level+1))

         done
        fi
    echo -n -e "\b\b\b$((100/$totalpoints*$level))"
    sleep 1
done
