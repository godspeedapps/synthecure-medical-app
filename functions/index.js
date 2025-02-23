/**
 * Import function triggers from their respective submodules:
 *
 * const {onCall} = require("firebase-functions/v2/https");
 * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

// const { onRequest } = require("firebase-functions/v2/https");
// const logger = require("firebase-functions/logger");

// Create and deploy your first functions
// https://firebase.google.com/docs/functions/get-started

// exports.helloWorld = onRequest((request, response) => {
//   logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });


const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

exports.addUser = functions.https.onCall(async (req) => {
  console.log("Data received: ", req);

  const firstName = req.data.firstName;
  const lastName = req.data.lastName;
  const email = req.data.email;
  const password = req.data.password;
  const isAdmin = req.data.isAdmin;

  try {
    if (!email || !password || !firstName || !lastName) {
      throw new functions.https.HttpsError(
          "invalid-argument",
          "All fields (firstName, lastName, email, password) are required.",
      );
    }

    // Ensure only authenticated users can call this function
    if (!req.auth) {
      throw new functions.https.HttpsError(
          "unauthenticated",
          "Only authenticated users can make this request.",
      );
    }

    // Optional: Ensure only existing admins can call this function
    const userClaims = req.auth.token;
    if (!userClaims.admin) {
      throw new functions.https.HttpsError(
          "permission-denied",
          "Only admins can assign admin privileges.",
      );
    }

    // Create the user in Firebase Authentication
    const userRecord = await admin.auth().createUser({
      email: email,
      password: password,
      displayName: `${firstName} ${lastName}`, // Combine first and last name
    });

    // Optionally set custom claims (admin privileges)
    if (isAdmin) {
      await admin.auth().setCustomUserClaims(userRecord.uid, {admin: true});
    }

    // Add the user data to Firestore
    const userDocData = {
      firstName,
      lastName,
      email,
      isAdmin,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    };

    // Store user details in the 'users' collection
    await admin
        .firestore()
        .collection('users')
        .doc(userRecord.uid)
        .set(userDocData);

    return {
      message: "User created successfully and Firestore document added!",
      uid: userRecord.uid,
      email: userRecord.email,
      displayName: userRecord.displayName,
    };
  } catch (error) {
    console.error("Error creating user:", error);
    throw new functions.https.HttpsError(
        "internal",
        error.message || "Unable to create user.",
    );
  }
});

exports.deleteUser = functions.https.onCall(async (req) => {
  console.log("Data received: ", req);

  const email = req.data.email; // The email of the user to be deleted

  try {
    // Ensure only authenticated users can call this function
    if (!req.auth) {
      throw new functions.https.HttpsError(
          "unauthenticated",
          "Only authenticated users can make this request.",
      );
    }

    // Optional: Ensure only existing admins can call this function
    const userClaims = req.auth.token;
    if (!userClaims.admin) {
      throw new functions.https.HttpsError(
          "permission-denied",
          "Only admins can delete users.",
      );
    }

    // Get user by email from Firebase Authentication
    const userRecord = await admin.auth().getUserByEmail(email);

    // Delete the user's orders subcollection
    const ordersCollectionRef = admin.firestore()
        .collection('users')
        .doc(userRecord.uid)
        .collection('orders');

    const ordersSnapshot = await ordersCollectionRef.get();

    const deletePromises = ordersSnapshot.docs.map((doc) => doc.ref.delete());
    await Promise.all(deletePromises);

    // Delete the user's Firestore document
    await admin.firestore().collection('users').doc(userRecord.uid).delete();

    // Delete the user from Firebase Authentication
    await admin.auth().deleteUser(userRecord.uid);

    return {
      message:
      `User with email ${email}
      and their orders have been deleted successfully.`,
    };
  } catch (error) {
    console.error("Error deleting user:", error);
    throw new functions.https.HttpsError(
        "internal",
        error.message || "Unable to delete user.",
    );
  }
});


// Callable function to update user to admin
exports.updateUserToAdmin = functions.https.onCall(async (req) => {
  const email = req.data.email; // The email of the user to be updated


  // Ensure only authenticated users can call this function
  if (!req.auth) {
    throw new functions.https.HttpsError(
        "unauthenticated",
        "Only authenticated users can make this request.",
    );
  }

  // Optional: Ensure only existing admins can call this function
  const userClaims = req.auth.token;
  if (!userClaims.admin) {
    throw new functions.https.HttpsError(
        "permission-denied",
        "Only admins can assign admin privileges.",
    );
  }

  try {
    // Get user by email
    const userRecord = await admin.auth().getUserByEmail(email);

    // Set custom user claims
    await admin.auth().setCustomUserClaims(userRecord.uid, {admin: true});

    return {
      message: `User with email ${email} has been granted admin privileges.`,
    };
  } catch (error) {
    console.error("Error updating user to admin:", error);
    throw new functions.https.HttpsError(
        "internal",
        error.message || "Unable to update user to admin.",
    );
  }
});


// Callable function to update user details
exports.updateUserName = functions.https.onCall(async (req) => {
  const firstName = req.data.firstName;
  const lastName = req.data.lastName;
  const id = req.data.id;

  // Ensure only authenticated users can call this function
  if (!req.auth) {
    throw new functions.https.HttpsError(
        "unauthenticated",
        "Only authenticated users can make this request.",
    );
  }


  try {
    // Update user details
    await admin.auth().updateUser(id, {
      displayName: `${firstName} ${lastName}`,
    });

    return {
      message: "User name updated successfully!",
    };
  } catch (error) {
    console.error("Error updating user details:", error);
    throw new functions.https.HttpsError(
        "internal",
        error.message || "Unable to update user details.",
    );
  }
});


