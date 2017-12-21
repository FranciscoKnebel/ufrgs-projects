module.exports = () => {
  return fetch(`api/playlists/todas`)
    .then((res) => {
      if(res.ok) {
        return res.json();
      } else {
        throw new Error(`Network response was not ok. Status: ${res.status}. Text: ${res.statusText}.`);
      }
    })
    .then(playlists => playlists.results)
    .catch(err => console.error(err));
}
