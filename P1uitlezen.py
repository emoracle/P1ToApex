import sys
import serial

ser = serial.Serial()
ser.baudrate = 115200
ser.bytesize=serial.SEVENBITS
ser.parity=serial.PARITY_EVEN
ser.stopbits=serial.STOPBITS_ONE
ser.xonxoff=0
ser.rtscts=0
ser.timeout=20
ser.port="/dev/ttyUSB0"

try:
    ser.open()
except:
    sys.exit ("Fout bij het openen van %s."  % ser.name)      


p1_teller=0

while p1_teller < 50:
    p1_line=''
    try:
        p1_raw = ser.readline()
    except:
        sys.exit ("Seriele poort %s kan niet gelezen worden." % ser.name )      
    p1_str=str(p1_raw)
    p1_line=p1_str.strip()
    print (p1_line)
    p1_teller = p1_teller +1

try:
    ser.close()
except:
    sys.exit ("Oops %s. Programma afgebroken. Kon de seriele poort niet sluiten." % ser.name )      
