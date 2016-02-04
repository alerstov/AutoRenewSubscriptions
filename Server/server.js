var http = require('http');
var request = require('request');
var url = require('url');
var util = require('util');
var qs = require('querystring');


var ipaddress = process.env.OPENSHIFT_NODEJS_IP || "0.0.0.0";
var port = process.env.OPENSHIFT_NODEJS_PORT || 8124;


http.createServer(function(req, res) {

	var method = req.method.toLowerCase();
	var parts = url.parse(req.url, true);
	var path = parts.pathname;
	var query = parts.query;


	if (path == '/favicon.ico') {
		res.writeHead(200, {
			'Content-Type': 'image/x-icon'
		});
		res.end();
	} else if (path == '/verify' || path == '/verify/') {

		if (method == 'post') {
			var body = '';

			req.on('data', function(data) {
				body += data;
			});

			req.on('end', function() {
				var post = qs.parse(body);
				verifyReceipt(post);
			});
		} else {
			verifyReceipt(query);
		}

		function verifyReceipt(query) {
			var receiptBase64 = query.receipt || '';
			var sandbox = query.sandbox == '1';

			var prodUrl = 'https://buy.itunes.apple.com/verifyReceipt';
			var sandUrl = 'https://sandbox.itunes.apple.com/verifyReceipt';

			var verifyUrl = sandbox ? sandUrl : prodUrl;
			var opt = {
				url: verifyUrl,
				json: {
					'receipt-data': receiptBase64,
					'password': '2c5997ad3a2e40c69b3130da90e1f6b8' // secret key from iTunesConnect
				}
			};
			request.post(opt, function(err, res1, body) {
				if (err) {
					res.writeHead(500, {
						'Content-Type': 'application/json'
					});
					res.end(JSON.stringify(err, null, 2));
					return;
				}

				res.writeHead(200, {
					'Content-Type': 'application/json'
				});
				res.end(JSON.stringify(body), null, 2);
			});
		}

	} else {
		res.writeHead(200, {
			'Content-Type': 'text/plain'
		});
		res.end('Hello World\n');
	}

}).listen(port, ipaddress);

console.log('Server running at %s:%d', ipaddress, port);