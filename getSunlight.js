"use strict";

var
https = require("https"),
options,
reading,
weerstationId = 6350,
adres = "https://api.buienradar.nl/data/public/1.1/jsonfeed";

https.get(adres, function (resp) {
  var data = [];

  resp.on('data', function (chunk) {
    data.push(chunk);
  });

  resp.on('end', function () {
    var
    json,
    waarde = "";

    json = JSON.parse((Buffer.concat(data)).toString());
    json.buienradarnl.weergegevens.actueel_weer.weerstations.weerstation.forEach(function (curr) {
      if (curr.stationcode == weerstationId) {
        reading = {};
        reading.sun = curr.zonintensiteitWM2;
        reading.sunDate = curr.datum;

        options = {
          hostname: 'apex.oracle.com',
          port: '443',
          path: '/pls/apex/wi/readings/readings',
          method: 'POST',
          headers: {
            'Content-Type': 'application/json; charset=utf-8',
            'Content-Length': Buffer.byteLength(JSON.stringify(reading))
          }
        };

        var req = https.request(options, function (res) {
            res.on('data', function (chunk) {});
            res.on('error', function (err) {
              console.log(err);
            });
          });

        req.write(JSON.stringify(reading));
        req.end();

      }
    });
  });
});
