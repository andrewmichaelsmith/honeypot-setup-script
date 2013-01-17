#apt-get install python-pip
#pip install netifaces
import netifaces
import os 

def select_iface(iface):
    try:
        iface = int(iface)
        if(iface < 0):
            raise IndexError
        return netifaces.interfaces()[iface]
    except IndexError:
        print "Number provided was too big or small"
        return []
    except ValueError:
        print "Please enter an interface number"
        return []


print "Please choose a network interface to run the honeypot on:\r\n"

i = 0
for ifaces in netifaces.interfaces():
    print "\t[",i,"]",ifaces,"(",netifaces.ifaddresses(ifaces)[netifaces.AF_INET],")"
    i = i+1

print "\r\n"

found = []
while(not found):
    found=select_iface(raw_input('Chosen interface: '))

f = open(os.path.expanduser('~/.honey_iface'), 'w')
f.write(found)



