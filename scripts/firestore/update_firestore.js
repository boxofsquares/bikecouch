const admin = require('firebase-admin');
const fs = require('fs');

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

const YAML = require('yaml').default;
const file = fs.readFileSync('./provision.yaml', 'utf8');
const doc = YAML.parse(file);

const categoriesObject = doc['categories'];

var allCategories =
  db.collection('category')
  .get()
  .then((query) => {
    var batch = db.batch();
    var promiseArray = query.docs.map((doc) => {
      return deleteCollection(doc.ref.collection('words'), doc.id).then(() => {
        batch.delete(doc.ref);
      });
    });
    return Promise.all(promiseArray).then(() => {
      batch.commit().then(() => {
        console.log(`Deleted ${query.size} categories.`);
      })
    });
  })
  .then(() => {
    const batch = db.batch();
    var categories = Object.keys(categoriesObject);
    categories.forEach((key) => {
      var doc = db.collection('category').doc(key);
      batch.set(doc, {});
    });
    return batch.commit()
      .then(() => {
        console.log(`Wrote ${categories.length} categories.`);
      })
  })
  .then(() => {
    var promiseArray = Object.keys(categoriesObject).map((key) => {
      var catDocRef = db.collection('category').doc(key);
      return writeWordsCollection(catDocRef, categoriesObject[key], key);
    });
    return Promise.all(promiseArray);
  });

/*
  Deletes a collection with NO sub-collections.
*/
function deleteCollection(collectionRef, parentCollection = '') {
  return collectionRef
    .get()
    .then((query) => {
      var batch = db.batch();
      query.docs.forEach((doc) => {
        batch.delete(doc.ref);
      });
      return batch.commit().then(() => {
        console.log(`Deleted ${query.size} objects in collection ${parentCollection}/${collectionRef.id}.`)
      });
    })
    .catch((e) => {
      console.log(e);
    });
}

function writeWordsCollection(docRef, wordsToWrite, parentCollection = '') {
  const batch = db.batch();
  wordsToWrite.forEach((word) => {
    var wordDocRef = docRef
      .collection('words')
      .doc(word);
    batch.set(wordDocRef, {});
  });
  return batch.commit().then(() => {
    console.log(`Wrote ${wordsToWrite.lengtgith} words to ${parentCollection}/${docRef.id}.`)
  });
}