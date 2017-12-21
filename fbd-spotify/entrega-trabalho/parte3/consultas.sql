use Spotify;

/* QUERY 1 */
-- Artistas mais ouvidos por um usuário (artista, album, musica, reproduções, usuario)
SELECT count(Artista.id_artista) as reproducoes, Artista.nome as artista
FROM Usuario
JOIN Reproducao ON (Usuario.id_usuario = Reproducao.id_usuario)
NATURAL JOIN Musica
JOIN Album USING (id_album)
JOIN Artista USING (id_artista)
WHERE Usuario.nome = 'Francisco Knebel'
GROUP BY Artista.id_artista
ORDER BY reproducoes DESC

/* QUERY 2 */
-- Todas as musicas do Daft Punk que não tem participação de outro artista --
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

/* QUERY 3 */
-- Concertos dos artistas na mesma cidade do usuário Mateus Salvi e a data do concerto (Concerto, artista, usuario)
SELECT a.nome, c.titulo, c.data_e_hora
FROM Artista as a
NATURAL JOIN concerto as c
JOIN Usuario as u ON (c.local = u.cidade)
WHERE u.nome = 'Mateus Salvi';

/* QUERY 4 */
-- As cidades onde a música 'Get Lucky' é ouvida com o número de reproduções,
-- ordenando pelo número de reproduções em forma decrescente.
SELECT count(cidade) as reproducoes, cidade
FROM Reproducao
JOIN Musica ON (Musica.titulo = 'Get Lucky' AND Reproducao.id_musica = Musica.id_musica)
JOIN Usuario USING (id_usuario)
GROUP BY cidade
ORDER BY reproducoes DESC

/* QUERY 5 */
-- Todas as músicas do gênero Rock (Gênero, Categorização, Álbum, Música)
SELECT *
FROM Musica
WHERE Musica.id_album IN
(
  SELECT Album.id_album -- Álbuns de Rock
  FROM Album
  JOIN Categorizacao ON
    (Categorizacao.id_album = Album.id_album)
  JOIN Genero ON
    (Genero.nome = 'Rock' AND Categorizacao.id_genero = Genero.id_genero)
);

/* QUERY 6 */
-- Todas musicas que aparecem em alguma playlist --
SELECT DISTINCT(m.titulo)
FROM Playlist AS p
JOIN Playlist_Composicao AS pc ON (p.id_playlist = pc.id_playlist)
JOIN Musica as m ON (m.id_musica = pc.id_musica);
