'use strict';

const express = require('express');
const PORT = 8080;
const HOST = '0.0.0.0';
const app = express();

app.use((request, response, next) => {

    var fullUrl = request.protocol + '://' + request.get('host') + request.originalUrl;
	console.log(`Request[${new Date()}] ${fullUrl}`);
	next();
});

app.get('/', (request, response) => {

    response.send(`Hello world - ${new Date()} <br/>
        http://localhost:8080/api/items <br/>
        http://localhost:8080/api/items/1 <br/>
        http://localhost:8080/api/items/2 <br/>
    `);
});

const ITEMS = [
    { id:1, name:'aaaa'},
    { id:2, name:'bbb'},
];

/* 
    http://localhost:8080/api/items
    http://localhost:8080/api/items/1
    http://localhost:8080/api/items/2
*/
app.route('/api/items').get(
    (request, response) => {
		response.json(ITEMS);
	}
);

app.route('/api/items/:id').get(
    (request, response) => {
        try {
            var id = request.params.id;
            const item = ITEMS.find((item) => item.id === Number(id));
            console.log(`id:${id}, item:${JSON.stringify(item)}`);
            response.json(item ? item : null);
        }
        catch(ex) {
            console.log(ex);
        }
	}
);

app.listen(PORT, HOST);
console.log(`Running on http://${HOST}:${PORT}`);
