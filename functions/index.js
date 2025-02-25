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
const functions1 = require('firebase-functions/v1');
const admin = require('firebase-admin');
const {projectID} = require('firebase-functions/params');
admin.initializeApp();
const db = admin.firestore();


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


exports.deleteHospitalOrder = functions1.firestore
    .document("orders/{orderId}")
    .onDelete(async (snap, context) => {
      const deletedOrder = snap.data();
      if (!deletedOrder || !deletedOrder.hospital || !deletedOrder.hospital.id) {
        console.log("No hospital ID found, skipping delete.");
        return;
      }

      const hospitalId = deletedOrder.hospital.id;
      const orderId = context.params.orderId;

      const hospitalOrderRef = db
          .collection("hospitals")
          .doc(hospitalId)
          .collection("orders")
          .doc(orderId);

      await hospitalOrderRef.delete();

      console.log(`Deleted order ${orderId} from /hospitals/${hospitalId}/orders`);
    });
exports.updateSalesAnalytics = functions1.firestore
    .document("orders/{orderId}")
    .onWrite(async (change, context) => {
      const analyticsRef = db.collection("analytics").doc("totals");
      const topHospitalsRef = db.collection("analytics").doc("topHospitals");
      const topProductsRef = db.collection("analytics").doc("topProducts");

      const orderId = context.params.orderId;
      let totalChange = 0;
      let orderChange = 0;
      let productChange = 0;
      let orderDate = new Date();
      const productSales = {};
      const hospitalSales = {};

      let hospitalId = null;
      let hospitalName = "Unknown Hospital";
      let isNewHospital = false;
      let isHospitalRemoved = false;

      if (change.after.exists) {
        const newData = change.after.data();
        totalChange += newData.total || 0;
        productChange += newData.productCount || 0;
        if (!change.before.exists) orderChange += 1;
        if (newData.date) orderDate = newData.date.toDate();

        newData.products.forEach((product) => {
          const {id, description, quantity, price} = product;
          if (!productSales[id]) {
            productSales[id] = {name: description, salesCount: 0, revenue: 0};
          }
          productSales[id].salesCount += quantity;
          productSales[id].revenue += quantity * price;
        });

        hospitalId = newData.hospital.id;
        hospitalName = newData.hospital.name;
        if (!hospitalSales[hospitalId]) {
          hospitalSales[hospitalId] = {name: hospitalName, totalOrders: 0, totalSpent: 0};
        }
        hospitalSales[hospitalId].totalOrders += 1;
        hospitalSales[hospitalId].totalSpent += newData.total || 0;

        const hospitalDocSnapshot = await topHospitalsRef
            .collection("hospitals")
            .doc(hospitalId)
            .get();

        isNewHospital = !hospitalDocSnapshot.exists;
      }

      if (change.before.exists && !change.after.exists) {
        const oldData = change.before.data();
        totalChange -= oldData.total || 0;
        productChange -= oldData.productCount || 0;
        orderChange -= 1;
        if (oldData.date) orderDate = oldData.date.toDate();

        oldData.products.forEach((product) => {
          const {id, description, quantity, price} = product;
          if (!productSales[id]) {
            productSales[id] = {name: description, salesCount: 0, revenue: 0};
          }
          productSales[id].salesCount -= quantity;
          productSales[id].revenue -= quantity * price;
        });

        hospitalId = oldData.hospital.id;
        hospitalName = oldData.hospital.name;
        if (!hospitalSales[hospitalId]) {
          hospitalSales[hospitalId] = {name: hospitalName, totalOrders: 0, totalSpent: 0};
        }
        hospitalSales[hospitalId].totalOrders -= 1;
        hospitalSales[hospitalId].totalSpent -= oldData.total || 0;

        const hospitalAnalyticsSnapshot = await topHospitalsRef
            .collection("hospitals")
            .doc(hospitalId)
            .get();

        const data = hospitalAnalyticsSnapshot.data();
        const remainingOrders = ((data && data.totalOrders) || 1) - 1;
        isHospitalRemoved = remainingOrders <= 0;
      }

      const year = orderDate.getFullYear().toString();
      const month = orderDate.toISOString().slice(0, 7);
      const yearlyRef = db.collection("analytics").doc(`yearly_${year}`);
      const monthlyRef = yearlyRef.collection("monthly").doc(month);
      const monthlyOrdersRef = monthlyRef.collection("orders").doc(orderId);

      const updates = {
        totalRevenue: admin.firestore.FieldValue.increment(totalChange),
        totalOrders: admin.firestore.FieldValue.increment(orderChange),
        totalProductsSold: admin.firestore.FieldValue.increment(productChange),
      };

      await analyticsRef.set(updates, {merge: true});
      await yearlyRef.set(updates, {merge: true});
      await monthlyRef.set(updates, {merge: true});

      // ✅ Add/Update/Delete individual orders for monthly analytics
      if (change.after.exists) {
        const newData = change.after.data();
        await monthlyOrdersRef.set({
          orderId,
          orderDate: newData.date,
          total: newData.total,
        });
      } else if (!change.after.exists && change.before.exists) {
        await monthlyOrdersRef.delete();
      }

      const updateAOV = async (ref) => {
        const snap = await ref.get();
        const data = snap.data() || {};
        const revenue = data.totalRevenue || 0;
        const orders = data.totalOrders || 0;
        const aov = orders > 0 ? revenue / orders : 0;
        await ref.update({averageOrderValue: aov});
      };

      await updateAOV(analyticsRef);
      await updateAOV(yearlyRef);
      await updateAOV(monthlyRef);

      for (const [productId, {name, salesCount, revenue}] of Object.entries(productSales)) {
        const productDoc = topProductsRef.collection("products").doc(productId);
        await productDoc.set(
            {
              name,
              salesCount: admin.firestore.FieldValue.increment(salesCount),
              revenue: admin.firestore.FieldValue.increment(revenue),
            },
            {merge: true},
        );
      }

      for (const [hId, {name, totalOrders, totalSpent}] of Object.entries(hospitalSales)) {
        const hospitalDoc = topHospitalsRef.collection("hospitals").doc(hId);
        await hospitalDoc.set(
            {
              name,
              totalOrders: admin.firestore.FieldValue.increment(totalOrders),
              totalSpent: admin.firestore.FieldValue.increment(totalSpent),
            },
            {merge: true},
        );
      }

      if (isNewHospital) {
        await analyticsRef.set({totalHospitals: admin.firestore.FieldValue.increment(1)}, {merge: true});
      }

      if (isHospitalRemoved) {
        await analyticsRef.set({totalHospitals: admin.firestore.FieldValue.increment(-1)}, {merge: true});
        await topHospitalsRef.collection("hospitals").doc(hospitalId).delete();
      }
    });


exports.updatePreviousWeekAnalytics = functions1.pubsub
    .schedule("every Sunday 00:00")
    .timeZone("America/New_York") // Adjust timezone as needed
    .onRun(async (context) => {
      const analyticsRef = db.collection("analytics").doc("totals");

      try {
        const totalsSnapshot = await analyticsRef.get();
        const totalsData = totalsSnapshot.exists ? totalsSnapshot.data() : {};

        // Save the current values as "previous" for next week comparison
        await analyticsRef.set(
            {
              previousTotalRevenue: totalsData.totalRevenue || 0,
              previousTotalOrders: totalsData.totalOrders || 0,
              previousTotalProductsSold: totalsData.totalProductsSold || 0,
              previousTotalHospitals: totalsData.totalHospitals || 0,
              previousAverageOrderValue:
                totalsData.totalOrders > 0 ?
                    (totalsData.totalRevenue || 0) / totalsData.totalOrders :
                    0,
            },
            {merge: true},
        );

        console.log("✅ Weekly analytics snapshot saved successfully.");
      } catch (error) {
        console.error("❌ Error updating previous week analytics:", error);
      }
    });

