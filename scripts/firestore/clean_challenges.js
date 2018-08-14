const admin = require('firebase-admin');

"use strict";

var serviceAccount = require('../../service-key.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

// NOTE: WARNING from the Firebase API when not set.
const settings = {
  timestampsInSnapshots: true
};

const db = admin.firestore();
db.settings(settings);

db
  .collection('challenges')
  .get()
  .then((querySnap) => {
    const batch = db.batch();
    querySnap.docs.forEach((doc) => {
      batch.delete(doc.ref  );
    });
    batch.commit();
  })
  .then(() => {
    console.log("Deleted all challenges...Hope you knew what you were doing.");
  })