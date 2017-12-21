const randomNumber = require('./randomNumber');
const pad2 = require('./pad2');

module.exports = () => {
  let hour = `${pad2(randomNumber(0, 23))}`;
  let minute = `${pad2(randomNumber(0, 59))}`;
  let second = `${pad2(randomNumber(0, 59))}`;

  return `${hour}:${minute}:${second}`;
}
