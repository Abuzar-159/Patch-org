var connection = new WebSocket('ws://127.0.0.1:22137/aqxolt');
connection.onopen = function () {
};
connection.onerror = function (error) {
  console.log('WebSocket Error: ' + error);
};
connection.onmessage = function (e) {
  console.log('Server Port Data: ' + e.data);
  var fnval = e.data.replace(/ /g,'');
  if(Number(fnval.replace(/[^0-9\.]+/g,"")) != 0) document.getElementById("WeightStr").value = fnval;
};