const functions = require("firebase-functions");
const admin = require("firebase-admin");

const serviceAccount = require("./privatekey.json");

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  databaseURL: "https://example-20efe-default-rtdb.firebaseio.com",
});

exports.sendPostNotification = functions
    .runWith({timeoutSeconds: 120}).https.onRequest(async (req, res) => {
      const hobby = req.body.hobby;

      const payload = {
        notification: {
          title: "새로운 Post 추가",
          body: "당신의 취미에 새로운 글이 추가되었습니다",
        },
      };

      try {
        const querySnapshot = await admin.firestore().collection("users")
            .where("hobby", "==", hobby).get();
        const tokens = [];
        querySnapshot.forEach((doc) => {
          const data = doc.data();
          if (data.hobbyNoti) {
            tokens.push(data.fcm);
            console.log(tokens);
          }
        });
        if (tokens.length > 0) {
          const response = await admin.messaging()
              .sendToDevice(tokens, payload);
          console.log("Successfully sent message:", response);
          res.status(200).send("Successfully sent message");
        } else {
          res.status(500).send("not found tokens");
        }
      } catch (error) {
        console.error("Error sending push notification:", error);
        res.status(500).send("Error sending message" + error);
      }
    });


exports.commentPushNotification = functions
    .firestore.document("posts/{postId}/comments/{commentId}")
    .onCreate(async (snapshot, context) => {
      const postId = context.params.postId;
      const postSnapshot = await admin.firestore()
          .collection("posts").doc(postId).get();
      const post = postSnapshot.data();
      const user = post.user;

      const payload = {
        notification: {
          title: "새로운 댓글",
          body: post.content,
        },
      };

      const userSnapshot = await admin.firestore()
          .collection("users").doc(user).get();
      if (userSnapshot.data().commentNoti) {
        const userToken = userSnapshot.data().fcm;
        await admin.messaging().sendToDevice(userToken, payload);
      }
    });
