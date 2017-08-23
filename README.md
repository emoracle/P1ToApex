# P1ToApex
Read the P1 port of a dutch smart meter and send it to an APEX application on apex.oracle.com

[dutch only]
De infrastructuur van dit geheel bestaat uit een aantal zaken:
- een Raspberry PI met een p1-to-usb kabel
- een APEX applicatie op apex.oracle.com

Op de PI draait er een python script die de slimme meter uitleest en een bestand klaarzet.
Daarna wordt er een nodejs script opgestart om het bestand uit te parsen en de webservices op apex.oracle.com aan te roepen.

In apex.oracle.com staat de applicatie geinstalleerd die op zijn beurt de tabellen, die door de webservice gevuld wordt, te onsluiten als grafieken ed.

f40652.sql   - De export van de APEX applicatie. De workspace waarop de applicatie gemaakt is, is WI.
