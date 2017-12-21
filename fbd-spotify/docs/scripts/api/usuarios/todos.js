module.exports = () => {
  return fetch(`api/usuarios/todos`)
    .then((res) => {
      if(res.ok) {
        return res.json();
      } else {
        throw new Error(`Network response was not ok. Status: ${res.status}. Text: ${res.statusText}.`);
      }
    })
    .then(usuarios => usuarios.results)
    .catch(err => console.error(err));
}
