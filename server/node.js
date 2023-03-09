const app = require('express')();
const http = require('http').createServer(app);
const io = require('socket.io')(http);

var userList = [];
var groupList = [];

io.on('connection', (socket) => {
  console.log('a user connected');

  socket.on('SignUp', (data) => {
    console.log(`received SignUp event with data: ${data['email']}`);
    // Perform signup logic here
    for (let i = 0; i < userList.length; i++) { 
      if (userList[i]['email']==data['email']) {
        console.log('email is duplicate');
        //  io.emit('SignUp', data['username'],false);
         io.emit('SignUpConfirm', {'username': data['username'], 'check': false,})
          break;
      }else if(i==userList.length-1){
        console.log('email do not duplicate');
         userList.push(data);
         io.emit('SignUpConfirm', {'username': data['username'], 'check': true,})
        //  io.emit('SignUpConfirm',(data['username'], true));
         io.emit('get all user', userList);    
      }
    }
   if(userList.length==0){
    console.log('emailslist = 0, add frist acc: ' + userList.length.toString);
         userList.push(data);
         io.emit('SignUpConfirm', {'username': data['username'], 'check': true,});
         io.emit('get all user', userList);
      }

    
  });

  socket.on('SignIn', (data)=>{
    let isOnline = false;
    console.log(`received SignIn event with acc:  ${data['email']}`);
    for (let i = 0; i < userList.length; i++) { 
      if (userList[i]['email']==data['email'] && userList[i]['password']==data['password'] ) {
        isOnline = true;
        userList[i]['isOnline'] = true;
        console.log(`Account is registed  + ${data['username']}`);
         io.emit('SignInCon', {'username': data['username'], 'userList': userList[i],'check': true});
          break;
      }else if(i==userList.length-1){
        io.emit('SignInCon', {'username': data['username'], 'userList': userList[i],'check': false});
        console.log('Account does not registed');
      }
    }
  });

  socket.on('get all user', () =>{
    console.log('run in to emit get all user: ' + userList.length);
    io.emit('get all user', userList);
  });

  socket.on('connect user', (data)=>{
    console.log(`User ${data.username} connected`);
    io.emit('connect user', {'username': data['username'], 'username': data['username']});
  });

  socket.on('connect group', (data)=>{
    console.log(`User ${data.groupName} connected`);
    io.emit('connect group', {'username': data['username'], 'username': data['username']});
  });

  socket.on('on typing', (data)=>{
    io.emit('on typing', {'username': data['username'], 'typing': data['username']});
  });

  socket.on('chat message', (data) => {
    console.log(`Message from ${data.senderUsername} to ${data.receiverUsername}: ${data.message}`);

    io.emit('chat message', {
      'recieverUsername': data.receiverUsername,
      senderUsername: data.senderUsername,
      message: data.message,
      timestamp: data.timestamp
    });
  });

  socket.on('chat group', (data) => {
    console.log(`Message from ${data.senderUsername} to ${data.groupName}: ${data.message}`);

  
    io.emit('chat message', {
      'recieverUsername': data.receiverUsername,
      senderUsername: data.senderUsername,
      message: data.message,
      timestamp: data.timestamp
    });
  });

  socket.on('get all groups', () => {
    console.log('Received get all groups event');
    socket.emit('get all groups', groupList);
  });

 

  socket.on('create group', (data) => {
    console.log('Received create group event');
    const groupName = data.name;
    const selectedUsers = data.users;
    const newGroup = { name: groupName, users: selectedUsers };
    groupList.push(newGroup);
    io.emit('get all groups', groupList);
  });

  socket.on('dataUpdate', (data) =>{
    console.log("dataUpdate")
    for (let i = 0; i < userList.length; i++) { 
      if (userList[i]['username']==data['username']) {
        userList[i]['isOnline']=data['isOnline'];
         // io.emit('dataUpdate',userList[i]);
         io.emit('get all user', userList);
          break;
      }
    }
});



});

http.listen(3000, () => {
  console.log('listening on *:3000');
});
