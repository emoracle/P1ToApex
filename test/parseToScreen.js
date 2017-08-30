var
value,
reading,
lineReader = require('readline').createInterface({
    input : require('fs').createReadStream('./data/test.log')
  });

lineReader.on('line', function (line) {
  if (line) {
    if (line.startsWith("1-3:0.2.8")) {
      reading = {};
      reading.version = line.match(/\(([^)]+)\)/)[1];
    } else if (reading) {
      if (line.startsWith("0-1:24.2.1")) {
        reading.gastijd = line.match(/\(([^)]+)\)/)[1];
        reading.gas = (line.split("(")[2].slice(0, -1)).split("*")[0];
        console.log(reading);
      } else if (line.startsWith("0-0:1.0.0")) {
        reading.elektijd = line.match(/\(([^)]+)\)/)[1].split("*")[0];
      } else if (line.startsWith("1-0:1.8.1")) {
        reading.e1 = line.match(/\(([^)]+)\)/)[1].split("*")[0];
      } else if (line.startsWith("1-0:1.8.2")) {
        reading.e2 = line.match(/\(([^)]+)\)/)[1].split("*")[0];
      } else if (line.startsWith("1-0:2.8.1")) {
        reading.et1 = line.match(/\(([^)]+)\)/)[1].split("*")[0];
      } else if (line.startsWith("1-0:2.8.2")) {
        reading.et2 = line.match(/\(([^)]+)\)/)[1].split("*")[0];
      } else if (line.startsWith("1-0:1.7.0")) {
        reading.actueelVermogen = line.match(/\(([^)]+)\)/)[1].split("*")[0];
      } else if (line.startsWith("1-0:2.7.0")) {
        reading.actueelTerugleverVermogen = line.match(/\(([^)]+)\)/)[1].split("*")[0];
      }	  
    }
  }
});

