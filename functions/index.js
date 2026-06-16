const {onDocumentCreated, onDocumentUpdated} = require("firebase-functions/v2/firestore");
const {setGlobalOptions} = require("firebase-functions/v2");
const admin = require("firebase-admin");

// Set global options for all functions
setGlobalOptions({region: "asia-south1"});

admin.initializeApp();

const db = admin.firestore();
const fcm = admin.messaging();

exports.onNewsCreated = onDocumentCreated("news/{newsId}", async (event) => {
    const news = event.data.data();
    if (!news) return null;

    if (news.send_notification && !news.notification_sent && (news.is_published || !news.scheduled_at)) {
        return sendNotificationToAll("news", event.params.newsId, news.title, news.category || "New News Update");
    }
    return null;
});

exports.onWishCreated = onDocumentCreated("wishes/{wishId}", async (event) => {
    const wish = event.data.data();
    if (!wish) return null;

    if (wish.send_notification && !wish.notification_sent && (wish.is_published || !wish.scheduled_at)) {
        return sendNotificationToAll("wishes", event.params.wishId, wish.title, wish.tag || "New Celebration");
    }
    return null;
});

exports.onAnnouncementCreated = onDocumentCreated("announcements/{announcementId}", async (event) => {
    const announcement = event.data.data();
    if (!announcement) return null;

    if (announcement.send_notification && !announcement.notification_sent) {
        return sendNotificationToAll("announcement", event.params.announcementId, announcement.title, announcement.category || "New Announcement");
    }
    return null;
});

exports.onNewsUpdated = onDocumentUpdated("news/{newsId}", async (event) => {
    const before = event.data.before.data();
    const after = event.data.after.data();

    if (!before.is_published && after.is_published && after.send_notification && !after.notification_sent) {
        return sendNotificationToAll("news", event.params.newsId, after.title, after.category || "New News Update");
    }
    return null;
});

async function sendNotificationToAll(type, id, title, body) {
    const tokensSnapshot = await db.collection("user_tokens").get();
    const tokens = tokensSnapshot.docs.map((doc) => doc.id);

    if (tokens.length === 0) {
        console.log("No tokens found");
        return null;
    }

    const message = {
        notification: {
            title: title,
            body: body,
        },
        data: {
            type: type,
            id: id,
            click_action: "FLUTTER_NOTIFICATION_CLICK",
        },
        tokens: tokens,
    };

    try {
        const response = await fcm.sendEachForMulticast(message);
        console.log("Successfully sent message:", response);

        const collection = type === "announcement" ? "announcements" : (type === "wishes" ? "wishes" : "news");
        await db.collection(collection).doc(id).update({
            notification_sent: true,
        });

        return response;
    } catch (error) {
        console.log("Error sending message:", error);
        return null;
    }
}
