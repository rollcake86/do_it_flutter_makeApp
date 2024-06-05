const functions = require("firebase-functions");
const admin = require("firebase-admin");
const axios = require("axios");

admin.initializeApp();

exports.sendPostNotification = functions
    .runWith({timeoutSeconds: 120}).https.onRequest(async (req, res) => {
      const linkId = req.body.link
      const title = req.body.title
      const payload = {
        notification: {
          title: "Crafty",
          body: title,
        },
        data: {
            link: linkId,
          },
      };

      try {
        const querySnapshot = await admin.firestore().collection("craftyusers")
            .get();
        const tokens = [];
        querySnapshot.forEach((doc) => {
          const data = doc.data();
          if (data.noti) {
            tokens.push(data.fcm);
            console.log(tokens);
          }
        });
        if (tokens.length > 0) {
          const chunks = [];
          const chunkSize = 1000;
          for (let i = 0; i < tokens.length; i += chunkSize) {
            chunks.push(tokens.slice(i, i + chunkSize));
          }
          const promises = chunks.map((chunk) =>
            admin.messaging().sendToDevice(chunk, payload));
          await Promise.all(promises);
          console.log("Successfully sent message:");
          res.status(200).send("Successfully sent message");
        } else {
          res.status(500).send("not found tokens");
        }
      } catch (error) {
        console.error("Error sending push notification:", error);
        res.status(500).send("Error sending message" + error);
      }
    });


exports.deleteOldData = functions.pubsub.
    schedule("every day 00:00").onRun(async (context) => {
      const db = admin.firestore();
      const snapshot = await db.collection("messages").
          where("timestamp", "<", Date.now() - 30 * 24 * 60 * 60 * 1000).get();
      const batch = db.batch();
      snapshot.docs.forEach((doc) => {
        batch.delete(doc.ref);
      });
      await batch.commit();
      console.log(`Deleted ${snapshot.size} old documents.`);
    });
