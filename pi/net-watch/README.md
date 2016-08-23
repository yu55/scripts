# pi_network_watchdog
Scripts that will reboot Raspberry Pi if network connection isn't working properly.

##Problem
My Raspberry Pi (Model B Revision 2.0, kernel 3.12.22+ #691 PREEMPT) sometimes has problems with USB subsystem which ends up with whole networking shutdown and leaving me unable to remotely login via ssh. Reboots always fix this situation ;) This is why I need some kind of watchdog.

##Solution
Basically `pi_network_watchdog.bash` is the main script that periodically pings a given ip address (network gateway) and reboots Raspberry Pi if too many failures occures.
`net-watch` is a management script to start or stop the main script.

##Requirements
- screen

##Installation
- move (or symlink) `pi_network_watchdog.bash` into `/usr/local/bin/`
- move (or symlink) `net-watch` into `/etc/init.d/`
- make scripts executable
- check (syslog, htop) that `sudo /etc/init.d/net-watch start` starts the script properly
- check (syslog, htop) that `sudo /etc/init.d/net-watch stop` stops the script properly
- setup scripts to start at boot time: `sudo update-rc.d net-watch defaults` (more on that here: http://www.stuffaboutcode.com/2012/06/raspberry-pi-run-program-at-start-up.html)



And that's all folks!
Greetings and have a nice day :)
