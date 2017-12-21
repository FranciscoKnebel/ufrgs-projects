module.exports = (notificationArea, query) => {
  let table = '';

  let queryButton = document.getElementById(query)

  queryButton.addEventListener('click', () => {
    fetch(query)
      .then((res) => {
        if(res.ok) {
          return res.json();
        } else {
          throw new Error(`Network response was not ok. Status: ${res.status}. Text: ${res.statusText}.`);
        }
      })
      .then(res => {
        const title = document.getElementById('notificationtitle');
        title.innerHTML = `<h1 class="subtitle"><strong>${queryButton.innerHTML}</strong><br>Tuplas: <strong>${res.results.length}</strong>.</h1>`;
        title.classList.remove('is-invisible');

        let head = '';
        for (field of res.fields) {
          head += `<th>${field.name}</th>`;
        }
        table = `<table class="table"><thead><tr>${head}</tr></thead>`;

        return res.results;
      })
      .then(results => {
        let lines = '';
        for (result of results) {
          lines += `<tr>`;
          for (key in result) {
            lines += `<td>${result[key]}</td>`;
          }
          lines += `</tr>`;
        }
        table += `<tbody>${lines}</tbody></table>`;

        notificationArea.innerHTML = table;
        notificationArea.classList.remove('is-invisible');
      })
      .catch(err => console.error(err));
  });
}
