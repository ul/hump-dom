var path = require('path')

var cfg = {
  devtool: 'source-map',
  entry: './lib/js/src/main_entry.js',
  output: {
    path: path.join(__dirname, 'public'),
    filename: 'bundle.js'
  }
}

module.exports = cfg
