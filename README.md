# P1ToApex
Lees de P1 port van een slimme meter (DLMS 4.2) en ontsluit de data in een Oracle APEX applicatie op apex.oracle.com.

Het geheel scant om de 15 minuten de P1 poort, parsed de gegevens en laat de standen en verbruiken in wat grafieken zien. Bij teruglevering (productie door bijv. zonnepanelen), worden de netto verbruiken getoond.

## Infrastructuur
De infrastructuur van dit geheel bestaat uit een aantal zaken:
- een Raspberry PI 
- een P1-naar-USB kabel die de PI verbindt met de slimme meter
- een kabel om de PI met de router te verbinden
- een APEX applicatie op apex.oracle.com

## De raspberry PI
Op de PI draait er een shell script `go.sh` via CRON om de 15 minuten dat op zijn beurt weer een python script opstart die de slimme meter uitleest en een bestand klaarzet.

Daarna wordt er in het shell script een nodejs script opgestart om het bestand uit te parsen en de webservices op apex.oracle.com aan te roepen.

In apex.oracle.com staat de applicatie geinstalleerd die op zijn beurt de tabellen, die door de webservice gevuld wordt, te onsluiten als grafieken ed.

f40652.sql   - De export van de APEX applicatie. 

## Restful webservice
Op de ORDS van de APEX applicatie is er een service aangemaakt met een POST resource handler:
- source type : PL/SQL
- MIME type : application/json
- source : 

```
begin
  hqvm_sm.handle_readings(:body);
end;
``` 

## Beveiliging
De Webservices dienen normaal gesproken netjes beveiligd te zijn. Gezien het POC gehalte van dit projectje heb ik echter volstaan met het checken op IP-adres in de ontvangende package. Vul hier het publieke IP-adres van de router in.

## NB.
Wanneer men de standen wil omzetten in dag-standen of de dag-standen wil omzetten in maandstanden, dan dient men op dit moment op een knop te drukken. Het is echter vrij eenvoudig onderliggende code in een job/schedule te bouwen in de database.