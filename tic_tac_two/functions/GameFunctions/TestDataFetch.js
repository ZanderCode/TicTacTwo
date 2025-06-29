const functions = require('firebase-functions');
const admin = require('firebase-admin');


exports.getDisplayNameTest = functions.https.onRequest(async (req, res) => {
  // Your function code here

    admin.firestore().doc()
});