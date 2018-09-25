const functions = require('firebase-functions');

// The firebase admin SDK to access the firebase realtime database
const admin = require('firebase-admin');
admin.initializeApp(functions.config().firebase);

// // Create and Deploy Your First Cloud Functions
// // https://firebase.google.com/docs/functions/write-firebase-functions
//
exports.helloWorld = functions.https.onRequest((request, response) => {
 response.send("Hello from Firebase Yuiso!");
});

exports.sendPushNotifications = functions.https.onRequest((request,response) => {
    response.send("Attempting to send push notification... by yuiso")
    var uid = 'U1wQ4cIvdegBYIx0pSvccfoqqmG2';

    return admin.database().ref('/users/' + uid).once('value', snapshot => {
        var user = snapshot.val();
        console.log("Sent notification to user: " + user.username + " fcmToken: " + user.fcmToken);     

        // See documentation on defining a message payload.
        var message = {
            notification: {
                title: "Push notification title",
                body: "Message Body"
            },
            token: user.fcmToken
        };
        // Send a message to the device corresponding to the provided
        // registration token.
        admin.messaging().send(message)
          .then((response) => {
            // Response is a message ID string.
            console.log('Successfully sent message:', response);
            return response
          })
          .catch((error) => {
            console.log('Error sending message:', error);
          });
    })
})


// when userA is following userB
// listen for following events and trigger a push notification
exports.observeFollowing = functions.database.ref('/following/{userAID}/{userBID}').onCreate((snapshot,context) => {
        var userAID = context.params.userAID;
        var userBID = context.params.userBID;
        console.log('User: ' + userAID + 'is following: ' + userBID);

        
        return admin.database().ref('/users/' + userBID).once('value', snapshot => {
            var userB = snapshot.val();

            return admin.database().ref('/users/' + userAID).once('value', snapshot =>{
                var userA = snapshot.val();

                // send message to the user who got followed
                var message = {
                    notification: {
                        title: "You have a new follower",
                        body: userA.username + " is now following you"
                    },
                    data: {
                        followerID: userAID 
                    },
                    token: userB.fcmToken
                };
                admin.messaging().send(message)
                  .then((response) => {
                    // Response is a message ID string.
                    console.log('Successfully sent message:', response);
                    return response
                  })
                  .catch((error) => {
                    console.log('Error sending message:', error);
                  });
            })
        })
    })


// when userA commented on userB's posts
// listen for following events and trigger a push notification
exports.observeCommenting = functions.database.ref('/comment/{postID}/{commentID}').onCreate((snapshot,context) => {
        var postID = context.params.postID;
        var commentID = context.params.commentID;
        console.log('post ' + postID + 'has a new comment: ' + commentID);

        // find userB's ID
        return admin.database().ref('/comment/' + postID + '/postOwnerID').once('value', snapshot => {
            var userBID = snapshot.val();
                
            return admin.database().ref('/comment/' + postID + '/' + commentID).once('value', snapshot => {
                
                // find userA's ID
                var comment = snapshot.val();
                var userAID = comment.uid;
                var text = comment.text;

                return admin.database().ref('/users/' + userBID).once('value', snapshot => {
                    var userB = snapshot.val();

                    return admin.database().ref('/users/' + userAID).once('value', snapshot =>{
                        var userA = snapshot.val();

                        // send message to the user who got followed
                        var message = {
                            notification: {
                                title: "You got a new comment from " + userA.username,
                                body: text
                            },
                            
                            data: {
                                // not used yet
                            },
                            token: userB.fcmToken
                        };
                        admin.messaging().send(message)
                          .then((response) => {
                            // Response is a message ID string.
                            console.log('Successfully sent message:', response);
                            return response
                          })
                          .catch((error) => {
                            console.log('Error sending message:', error);
                          });
                    })
                })
            })
        })
    })