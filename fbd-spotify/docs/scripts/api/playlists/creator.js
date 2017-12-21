module.exports = (id) => {
  return fetch(`api/playlists/creator/${id}`)
    .then((res) => {
      if(res.ok) {
        return res.json();
      } else {
        throw new Error(`Network response was not ok. Status: ${res.status}. Text: ${res.statusText}.`);
      }
    })
    .then(playlist => playlist.results)
    .catch(err => console.error(err));
}
