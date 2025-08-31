const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

// Callable function to delete user by email
exports.deleteUserByEmail = functions.https.onCall(async (data, context) => {
  // Optional: check if the caller is an admin
  if (!context.auth || context.auth.token.role !== "admin") {
    throw new functions.https.HttpsError(
        "permission-denied",
        "Only admins can delete users.",
    );
  }

  const email = data.email;

  try {
    const user = await admin.auth().getUserByEmail(email);
    await admin.auth().deleteUser(user.uid);
    return {success: true, message: "User deleted successfully"};
  } catch (error) {
    return {success: false, message: error.message};
  }
});
