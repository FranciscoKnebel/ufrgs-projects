const notificationArea = document.getElementById('notificationarea');

// Adiciona eventListener de click no id e faz um fetch com query igual ao id.
const query = require('./query');
query(notificationArea, 'query/1');
query(notificationArea, 'query/2');
query(notificationArea, 'query/3');
query(notificationArea, 'query/4');
query(notificationArea, 'query/5');
query(notificationArea, 'query/6');

// Geração de reproduções
require('./generate')(notificationArea);
