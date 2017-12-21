const pad2 = require('./pad2');
const randomNumber = require('./randomNumber');

module.exports = () => {
  let day = `${pad2(randomNumber(1, 30))}`;
  let month = `${pad2(randomNumber(10, 12))}`;
  let year = `2017`;

  if(month === '12') {
    day = `${pad2(randomNumber(1, 15))}`;
  }

  return `${year}-${month}-${day}`;
}
