var restify = require('restify'),
  fs = require('fs')

var server = restify.createServer({
  maxParamLength: 1000000000
})

server.get('/tiles/:tiles', function (req, res, next) {
  var data = []

  let buff = new Buffer(req.params.tiles, 'base64');
let text = buff.toString('ascii');
console.log(text)

  JSON.parse(text).forEach(function(tile) {
    data.push(JSON.parse(fs.readFileSync('./tiles/' + tile[0] + '/' + tile[1] + '.json', 'utf8')))
  })
  res.send(data)
  next()
})


server.listen(3000, function(){
  console.log('Listening on *:' + 3000)
})