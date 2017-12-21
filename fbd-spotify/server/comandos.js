module.exports = (app, connection) => {
  app.get('/query/1', (req, res) => {
    // Artistas mais ouvidos por um usuário (artista, album, musica, reproduções, usuario)
    connection.query(
      `
        SELECT count(Artista.id_artista) as reproducoes, Artista.nome as artista
        FROM Usuario
        JOIN Reproducao ON
          (Usuario.id_usuario = Reproducao.id_usuario)
        NATURAL JOIN Musica
        JOIN Album USING (id_album)
        JOIN Artista USING (id_artista)
        WHERE Usuario.nome = 'Francisco Knebel'
        GROUP BY Artista.id_artista
        ORDER BY reproducoes DESC
      `, (error, results, fields) => {
      res.send({ error, results, fields });
    });
  });

  app.get('/query/2', (req, res) => {
    // Todas as musicas do Daft Punk que não tem participação de outro artista
    connection.query(
      `
        SELECT m.titulo
        FROM Artista as a
        JOIN Album as alb ON (alb.id_artista = a.id_artista)
        JOIN Musica as m ON (alb.id_album = m.id_album)
        WHERE a.nome = 'Daft Punk' AND NOT EXISTS
        (
        	SELECT *
          FROM Musica_Participacao as mp
          WHERE mp.id_musica = m.id_musica
        );
      `, (error, results, fields) => {
      res.send({ error, results, fields });
    });
  });

  app.get('/query/3', (req, res) => {
    // Concertos dos artistas na mesma cidade do usuário Mateus Salvi e a data do concerto (Concerto, artista, usuario)
    connection.query(
      `
        SELECT a.nome, c.titulo, c.data_e_hora
        FROM Artista as a
        NATURAL JOIN Concerto as c
        JOIN Usuario as u ON (c.local = u.cidade)
        WHERE u.nome = 'Mateus Salvi';
      `, (error, results, fields) => {
      res.send({ error, results, fields });
    });
  });

  app.get('/query/4', (req, res) => {
    // As cidades onde a música 'Get Lucky' é ouvida com o número de reproduções,
    // ordenando pelo número de reproduções em forma decrescente.
    connection.query(
      `
        SELECT count(cidade) as reproducoes, cidade
        FROM Reproducao
        JOIN Musica ON
          (Musica.titulo = 'Get Lucky' AND Reproducao.id_musica = Musica.id_musica)
        JOIN Usuario USING (id_usuario)
        GROUP BY cidade
        ORDER BY reproducoes DESC
      `, (error, results, fields) => {
      res.send({ error, results, fields });
    });
  });

  app.get('/query/5', (req, res) => {
    // Todas as músicas do gênero Rock (Gênero, Categorização, Álbum, Música)
    connection.query(
      `
        SELECT *
        FROM Musica
        WHERE Musica.id_album IN
        (
          SELECT Album.id_album
          FROM Album
          JOIN Categorizacao ON
            (Categorizacao.id_album = Album.id_album)
          JOIN Genero ON
            (Genero.nome = 'Rock' AND Categorizacao.id_genero = Genero.id_genero)
        );
      `, (error, results, fields) => {
      res.send({ error, results, fields });
    });
  });

  app.get('/query/6', (req, res) => {
    // Todas musicas que aparecem em alguma playlist
    connection.query(
      `
        SELECT DISTINCT(m.titulo)
        FROM Playlist AS p
        JOIN Playlist_Composicao AS pc ON (p.id_playlist = pc.id_playlist)
        JOIN Musica as m ON (m.id_musica = pc.id_musica);
      `, (error, results, fields) => {
      res.send({ error, results, fields });
    });
  });
}
