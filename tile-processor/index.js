var fs = require('fs');
var vt2geojson = require('@mapbox/vt2geojson');
var async = require('async');

var mapboxApiKey = 'pk.eyJ1IjoiYWRyaWFubmVudSIsImEiOiJjaXJhNXZ3djQwMDNzaWtubnM2Y2dxOXRiIn0.0G6mHmuOEPUFh-_juFBg7g'

var tasks = []

for (let i = 10483; i <= 10485; i++) {
    if (!fs.existsSync('data/' + i)){
        fs.mkdirSync('data/' + i);
    }
    for (let j = 25320; j <= 25335; j++) {
        tasks.push((done) => [
            vt2geojson({
                uri: 'http://api.mapbox.com/v4/mapbox.mapbox-streets-v8/16/' + i + '/' + j+ '.mvt?access_token=' + mapboxApiKey,
            }, function (err, result) {
                if (err) throw err;
                fs.writeFileSync('data/' + i + '/' + j + '.json', JSON.stringify(result))
                done(null);
            })
        ])
    }
}

async.parallelLimit(tasks, 10, (err, results) => {
    console.log('ALL DONE')
})