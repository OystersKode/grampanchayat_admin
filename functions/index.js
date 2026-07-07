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

exports.onAdvertisementCreated = onDocumentCreated("advertisements/{adId}", async (event) => {
    const ad = event.data.data();
    if (!ad) return null;

    if (ad.send_notification && !ad.notification_sent) {
        return sendNotificationToAll("advertisement", event.params.adId, ad.title, "New Advertisement");
    }
    return null;
});

exports.onInstituteCreated = onDocumentCreated("institutes/{instituteId}", async (event) => {
    const institute = event.data.data();
    if (!institute) return null;

    if (institute.send_notification && !institute.notification_sent) {
        return sendNotificationToAll("institute", event.params.instituteId, institute.name, "New School/College Added");
    }
    return null;
});

exports.onNewsUpdated = onDocumentUpdated("news/{newsId}", async (event) => {
    const before = event.data.before.data();
    const after = event.data.after.data();

    // Trigger if newly published OR if notification_sent was reset to false manually
    if ((!before.is_published && after.is_published && after.send_notification && !after.notification_sent) ||
        (before.notification_sent && !after.notification_sent && after.send_notification)) {
        return sendNotificationToAll("news", event.params.newsId, after.title, after.category || "News Update");
    }
    return null;
});

exports.onAnnouncementUpdated = onDocumentUpdated("announcements/{announcementId}", async (event) => {
    const before = event.data.before.data();
    const after = event.data.after.data();

    if (before.notification_sent && !after.notification_sent && after.send_notification) {
        return sendNotificationToAll("announcement", event.params.announcementId, after.title, after.category || "Announcement Update");
    }
    return null;
});

exports.onWishUpdated = onDocumentUpdated("wishes/{wishId}", async (event) => {
    const before = event.data.before.data();
    const after = event.data.after.data();

    if (before.notification_sent && !after.notification_sent && after.send_notification) {
        return sendNotificationToAll("wishes", event.params.wishId, after.title, after.tag || "Wishes Update");
    }
    return null;
});

exports.onAdvertisementUpdated = onDocumentUpdated("advertisements/{adId}", async (event) => {
    const before = event.data.before.data();
    const after = event.data.after.data();

    if (before.notification_sent && !after.notification_sent && after.send_notification) {
        return sendNotificationToAll("advertisement", event.params.adId, after.title, "Advertisement Update");
    }
    return null;
});

exports.onInstituteUpdated = onDocumentUpdated("institutes/{instituteId}", async (event) => {
    const before = event.data.before.data();
    const after = event.data.after.data();

    if (before.notification_sent && !after.notification_sent && after.send_notification) {
        return sendNotificationToAll("institute", event.params.instituteId, after.name, "Institute Update");
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

        const collectionMap = {
            'announcement': 'announcements',
            'wishes': 'wishes',
            'news': 'news',
            'advertisement': 'advertisements',
            'institute': 'institutes'
        };
        const collection = collectionMap[type] || 'news';

        await db.collection(collection).doc(id).update({
            notification_sent: true,
        });

        return response;
    } catch (error) {
        console.log("Error sending message:", error);
        return null;
    }
}
