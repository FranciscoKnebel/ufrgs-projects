const mysql = require('mysql');

const connection = mysql.createConnection({
  host    : 'localhost',
  user    : 'root',
  password: 'root',
  database: 'Spotify'
});

module.exports = (app) => {
  connection.connect();

  require('./comandos')(app, connection);

  app.get('/api/musicas/todas', (req, res) => {
    connection.query('SELECT * FROM Musica', (error, results, fields) => {
      if (error)
        throw error;

      res.send({ results, fields });
    });
  });

  app.get('/api/usuarios/todos', (req, res) => {
    connection.query('SELECT * FROM Usuario', (error, results, fields) => {
      if (error)
        throw error;

      res.send({ results, fields });
    });
  });

  app.get('/api/playlists/todas', (req, res) => {
    connection.query('SELECT * FROM Playlist', (error, results, fields) => {
      if (error)
        throw error;

      res.send({ results, fields });
    });
  });

  app.get('/api/playlists/creator/:id', (req, res) => {
    connection.query(
      `
        SELECT *
        FROM Playlist_Criacao
        WHERE id_playlist = ${req.params.id}
      `, (error, results, fields) => {
      if (error)
        throw error;

      res.send({ results, fields });
    });
  });
}
