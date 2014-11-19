import netifaces
import os
import sys

def select_iface(iface):
    try:
        iface = int(iface)
        if(iface < 0):
            raise IndexError

        return netifaces.interfaces()[iface]

    except IndexError:
        print("Number provided was too big or small")
        return []
    except ValueError:
        print("Please enter an interface number")
        return []


def get_args():
    if len(sys.argv) > 1:
        return netifaces.interfaces()[int(sys.argv[1])]

def get_user_input():

    print("Please choose a network interface to run the honeypot on:\r\n")

    for i, ifaces in enumerate(netifaces.interfaces()):
        try:
            iface_text = "\t[%d] %s (%s)" % (i,ifaces,netifaces.ifaddresses(ifaces)[netifaces.AF_INET])
            print(iface_text)
        except Exception:
            pass

    print("\r\n")

    found = []
    while(not found):
        found=select_iface(raw_input('Chosen interface: '))
    return found

def run():


    args = get_args()

    found = get_args()  if get_args() else get_user_input()

    print found

    f = open(os.path.expanduser('~/.honey_iface'), 'w')
    f.write(found)

if __name__ == "__main__":
    run()


