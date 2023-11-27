# Supervisor-Extended-APIs


## Broadcast messages

### supervisor message
Sent to all supervisor clients. Indicates that the supervisor need to deal with a student. The server should remove the student from the queue at the same time, and switch supervisor's status to *occupied*. 

Sent by: server
Topic: *\<name of supervisor\>*

```
{
    "ticket": <index>,
    "name": "<name>"
}
```

### Queue status
Sent to all clients in response to any changes in the queue, for example new clients entering the queue or students receiving supervision. The queue status is an ordered array of Queue tickets, where the first element represent the first student in the queue.

Sent by: server
Topic: *queue*

```
[ 
    {"ticket": <index>, "name": "<name>"}, ... 
]
```

### Supervisor status
Sent to all clients in response to any changes in the list of supervisors, for example new supervisors connecting or when the status of a supervisor changes.

Sent by: server
Topic: *supervisors*

```
[ 
    {"name": <name>, "status": "pending"|"available"|"occupied", "client": undefined|{"ticket":<index>,"name":"<name>"}}, ... 
]
```

### User messages
The server will also publish messages directly to individual users (students). These messages should received by all clients representing that user. These messages are typically indicating that it's the user's turn to receive supervision, with instructions on how/where to find the supervisor.

Sent by: server
Topic: *\<name of user\>*

```
{
    "supervisor":"<name of supervisor>",
    "message":"<message from supervisor>"
}
```

---


## Req/rep messages

### Supervisor login

Sent by: client.
Expected response from server: *Login Status*

```
{
    "supervisor": true,
    “enterQueue": true
    "name": "<name>",
    "clientId": "<unique id string>"
}
```

> Having a password maybe better.

### Login Status

Sent by: server.

```
{
    "login": true,
    "name": "<name>"
}
```

### Heartbeat

Sent by: client.
Expected response from server:`{}`.

```
{
    "name": "<name>",
    "supervisor": true,
    "clientId": "<unique id string>"
}
```

### Switch supervisor status
Sent by: client.
Expected response from server: `{"status": "pending" | "available" | "occupied"}`

```
{
    "supervisor": true,
    "name": "<supervisor name>",
    "clientId": "<unique id string>",
    "status": "pending" | "available",
    "optionalMessage": "<optional message>"
}
```

### Supervisor broadcast
Sent by: client.



Expected response from server: `{}`

```
{
    "supervisor": true,
    "name": "<supervisor name>",
    "clientId": "<unique id string>",
    "message": "<broadcast message>"
}
```



The broadcast is same as the broadcast to a specific user.

Topic of this broadcast: `supervisorBroadcast`

```
{
	"name": "<supervisor name>",
	"message": "<broadcast message>"
}
```




### Error message
Sent by: server
```
{
    "error": "<error type>",
    "msg": "<error description>"
}
```

### Enter queue
Indicates that a user with specified name want to enter the queue.

A single user may connect through several clients. If another client with the same name is already connected, both clients hold the same place in the queue.
Sent by: client.
Expected response from server: `Queue ticket`.
```
{
    "enterQueue": true,
    "name": "<name>",
    "clientId": "<unique id string>"
}
```

### Queue ticket
Indicates that the client with specified name and ticket has entered the queue.
Sent by: server. 
```
{
    "ticket": <index>,
    "name": "<name>"
}
```

### Heartbeat
Indicates that a user with specified name want to enter the queue.

All clients are expected to send a regular messages (heartbeats) to indicate that they want to maintain their plaice in the queue. Clients with a heartbeat interval larger than 4 seconds will be considered inactive, and will be removed from queue.
Send by: client.
Expected response from server: `{}`.
```
{
    "name": "<name>",
    "clientId": "<unique id string>"
}
```

### Error message
Indicates that a user with specified name want to enter the queue.

Sent in response to any client message that does not follow the specified API. The server may also use this message type to indicate other types of errors, for example invalid name strings.
Sent by: server. 
```
{
    "error": "<error type>",
    "msg": "<error description>"
}
```
