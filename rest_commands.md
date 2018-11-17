# start
POST https://tds.blogcheck.tripled.io/start HTTP/1.1
content-type: application/json

{
    "playerCount": 3
}

# stop
POST https://tds.blogcheck.tripled.io/stop HTTP/1.1
content-type: application/json

# join

POST https://tds.blogcheck.tripled.io/join HTTP/1.1
content-type: application/json

{
    "secretToken": "player1"
}

POST https://tds.blogcheck.tripled.io/join HTTP/1.1
content-type: application/json

{
    "secretToken": "player2"
}

POST https://tds.blogcheck.tripled.io/join HTTP/1.1
content-type: application/json

{
    "secretToken": "player3"
}

# table

GET https://tds.blogcheck.tripled.io/table
content-type: application/json

# my-rooms
GET https://tds.blogcheck.tripled.io/my-rooms/player1
content-type: application/json

GET https://tds.blogcheck.tripled.io/my-rooms/player2
content-type: application/json

GET https://tds.blogcheck.tripled.io/my-rooms/player3
content-type: application/json

# open

POST https://tds.blogcheck.tripled.io/open HTTP/1.1
content-type: application/json

{
    "secretToken": "player1",
    "targetPlayerId": "2"
}

# table

GET https://tds.blogcheck.tripled.io/table
content-type: application/json

# open

POST https://tds.blogcheck.tripled.io/open HTTP/1.1
content-type: application/json

{
    "secretToken": "player2",
    "targetPlayerId": "3"
}

# table

GET https://tds.blogcheck.tripled.io/table
content-type: application/json

# open

POST https://tds.blogcheck.tripled.io/open HTTP/1.1
content-type: application/json

{
    "secretToken": "player3",
    "targetPlayerId": "1"
}

# table

GET https://tds.blogcheck.tripled.io/table
content-type: application/json