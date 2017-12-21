const port = 3000;

const express = require('express');
const path = require('path');
const morgan = require('morgan');

const app = express();

app.use(morgan('dev'));

app.use(express.static(path.join(__dirname, 'docs')));
app.set('views', __dirname + '/docs');
app.set('view engine', 'html');

app.get('/', (req, res) => {
  res.render('index.html');
});

require('./server/api')(app);

app.listen(port, () => {
  console.log(`Ouvindo na porta ${port}.`);
})
