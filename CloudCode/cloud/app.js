
// These two lines are required to initialize Express in Cloud Code.
var express = require('express');
var app = express();
var urls = [
"http://www.theguardian.com/technology/rss",
        "http://feeds.bbci.co.uk/news/technology/rss.xml",
        "http://feeds.skynews.com/feeds/rss/technology.xml",
        "http://www.techmeme.com/feed.xml"
    ]; // Example RSS Feeds]

// Global app configuration section
app.set('views', 'cloud/views');  // Specify the folder to find templates
app.set('view engine', 'ejs');    // Set the template engine
app.use(express.bodyParser());    // Middleware for reading request body


// This is an example of hooking up a request handler with a specific request
// path and HTTP verb using the Express routing API.
app.get('/hello', function(req, res) {
  res.render('hello', { message: 'Congrats, you just set up your app!' });
});

app.get('/hi-there', function(req, res) {
	res.send('Hi there!');
});

app.get('/test-api', function(req, res) {
	res.send({name: "Emily", age: 31});
});

// // Example reading from the request query string of an HTTP get request.
// app.get('/test', function(req, res) {
//   // GET http://example.parseapp.com/test?message=hello
//   res.send(req.query.message);
// });

// // Example reading from the request body of an HTTP post request.
// app.post('/test', function(req, res) {
//   // POST http://example.parseapp.com/test (with request body "message=hello")
//   res.send(req.body.message);
// });

// Attach the Express app to Cloud Code.
app.listen();
