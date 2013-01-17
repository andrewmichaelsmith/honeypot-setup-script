#apt-get install python-pip
#pip install netifaces
import netifaces

def select_iface(iface):
   return "eth0"

print "Please choose a network interface to run the honeypot on:\r\n"

i = 0

for ifaces in netifaces.interfaces():
    print "\t[",i,"]",ifaces,"(",netifaces.ifaddresses(ifaces)[netifaces.AF_INET],")"
    i = i+1

print "\r\n"

found = []
while(not found):
    found=select_iface(input('Chosen interface: '))


print found


