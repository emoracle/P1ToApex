function getValue(line) {
  try {
    var value = line.match(/\(([^)]+)\)/)[1].split("*")[0];
    return value;
  } catch (e) {
    return "";
  }
}

var
value,
reading,
https = require('https'),
options,
lineReader = require('readline').createInterface({
    input: require('fs').createReadStream('/home/pi/werkdir/sm/data/test.log')
  });

lineReader.on('line', function (line) {
  line = line.replace(/\0/g, '');
  if (line) {
    if (line.startsWith("1-3:0.2.8")) {
      reading = {};
      reading.version = line.match(/\(([^)]+)\)/)[1];
    } else if (reading) {
      if (line.startsWith("0-1:24.2.1")) {
        reading.gastijd = line.match(/\(([^)]+)\)/)[1];
        reading.gas = (line.split("(")[2].slice(0, -1)).split("*")[0];

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

      } else if (line.startsWith("0-0:1.0.0")) {
        reading.elektijd = getValue(line);
      } else if (line.startsWith("1-0:1.8.1")) {
        reading.e1 = getValue(line);
      } else if (line.startsWith("1-0:1.8.2")) {
        reading.e2 = getValue(line);
      } else if (line.startsWith("1-0:2.8.1")) {
        reading.et1 = getValue(line);
      } else if (line.startsWith("1-0:2.8.2")) {
        reading.et2 = getValue(line);
      } else if (line.startsWith("1-0:1.7.0")) {
        reading.actueelVermogen = getValue(line);
      } else if (line.startsWith("1-0:2.7.0")) {
        reading.actueelTerugleverVermogen = getValue(line);
      }
    }
  }
});
