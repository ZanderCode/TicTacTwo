/**
 * Import function triggers from their respective submodules:
 *
 * const {onCall} = require("firebase-functions/v2/https");
 * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

const {setGlobalOptions, params, config} = require("firebase-functions");
const { onRequest } = require("firebase-functions/v2/https");
const logger = require("firebase-functions/logger");

const admin = require("firebase-admin");
const axios = require("axios");

admin.initializeApp();

// For cost control, you can set the maximum number of containers that can be
// running at the same time. This helps mitigate the impact of unexpected
// traffic spikes by instead downgrading performance. This limit is a
// per-function limit. You can override the limit for each function using the
// `maxInstances` option in the function's options, e.g.
// `onRequest({ maxInstances: 5 }, (req, res) => { ... })`.
// NOTE: setGlobalOptions does not apply to functions using the v1 API. V1
// functions should each use functions.runWith({ maxInstances: 10 }) instead.
// In the v1 API, each function can only serve one request per container, so
// this will be the maximum concurrent request count.
setGlobalOptions({ maxInstances: 10 });

// Create and deploy your first functions
// https://firebase.google.com/docs/functions/get-started


// Check if running in emulator
// ran firebase functions:config:set google.client_id="YOUR_CLIENT_ID" google.client_secret="YOUR_CLIENT_SECRET"

exports.getTokenData = onRequest(async (request, response) => {
  logger.info("Hello logs!", {structuredData: true});

  const { code, redirectUri } = request.body;
  const clientId = process.env.GOOGLE_CLIENT_ID;
  const clientSecret =  process.env.GOOGLE_CLIENT_SECRET;

  const tokenRes = await axios.post("https://oauth2.googleapis.com/token", null, {
    params: {
      code,
      client_id: clientId,
      client_secret: clientSecret,
      redirect_uri: redirectUri,
      grant_type: "authorization_code",
    },
  });

  const { id_token, access_token} = tokenRes.data;

  const payload = JSON.parse(
    Buffer.from(id_token.split(".")[1], "base64").toString("utf8")
  );

  const uid = payload.sub;

  // Step 3: Create Firebase custom token
  const customToken = await admin.auth().createCustomToken(uid);

  // Step 4: Return the Firebase custom token
  response.json({ firebaseToken: customToken, googleIdToken: id_token, googleAccessToken: access_token, });
});