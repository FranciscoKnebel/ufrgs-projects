module.exports = (notificationArea) => {
  document.getElementById('genReproducoes').addEventListener('click', () => {
    const getMusicas = require('./api/musicas/todas')();
    const getUsuarios = require('./api/usuarios/todos')();

    const { randomNumber, randomDate, randomTime } = require('./helpers');

    getMusicas.then(musicas => {
      getUsuarios.then(usuarios => {
        let insertionsLeft = 100;
        notificationArea.innerHTML = `<h3>Gerando ${insertionsLeft} inserts de reproduções...</h3>`;
        notificationArea.classList.remove('is-invisible');

        for (let i = insertionsLeft; i > 0; i--) {
          insert = `START TRANSACTION; INSERT INTO Reproducao VALUES ('${usuarios[randomNumber(0, usuarios.length)].id_usuario}', '${randomDate()} ${randomTime()}', '${musicas[randomNumber(0, musicas.length)].id_musica}'); COMMIT;<br>`;
          notificationArea.innerHTML += insert;
        }
      });
    });
  });

  document.getElementById('genPlaylist').addEventListener('click', () => {
    const getPlaylists = require('./api/playlists/todas')();
    const getUsuarios = require('./api/usuarios/todos')();
    const getPlaylistCreator = require('./api/playlists/creator');

    const { randomNumber, randomDate, randomTime } = require('./helpers');

    getPlaylists.then(playlists => {
      getUsuarios.then(usuarios => {
        notificationArea.innerHTML = `<h3>Gerando inserts de seguidores para playlists...</h3>`;
        notificationArea.classList.remove('is-invisible');

        notificationArea.innerHTML += `START TRANSACTION;<br>INSERT INTO Playlist_Seguir VALUES<br>`;

        let possibleUsers = [...Array(usuarios.length || 0)].map((v,i) => i); // gera array 0, 1, ..., usuarios.length -1
        for (let i = possibleUsers.length; i > 0; i--) {
          let index = {};
          index.playlist = randomNumber(0, playlists.length);
          index.user = possibleUsers.pop();

          const getPlaylistCreator = require('./api/playlists/creator');
          console.log(index);

          getPlaylistCreator(playlists[index.playlist].id_playlist)
          .then(playlist => {
            // Usuário escolhido é o criador.
            if(playlist[0].id_usuario == usuarios[index.user].id_usuario) {
              if(index.user == 0) {
                index.user = 2; // Escolhe o próximo indíce
              } else {
                index.user--; // Escolhe o índice anterior
              }
            }

            notificationArea.innerHTML += `('${playlists[index.playlist].id_playlist}', '${usuarios[index.user].id_usuario}', '${'2017-12-13'}'),<br>`;;
          });
        }
      });
    });
  });
}
