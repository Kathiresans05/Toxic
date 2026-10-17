importScripts("https://www.gstatic.com/firebasejs/10.7.1/firebase-app-compat.js");
importScripts("https://www.gstatic.com/firebasejs/10.7.1/firebase-messaging-compat.js");

firebase.initializeApp({
  apiKey: "AIzaSyBbpcZZ6idslJqVvYbpDoT9s5ItIKpvDqU",
  authDomain: "friendapp-bba60.firebaseapp.com",
  projectId: "friendapp-bba60",
  storageBucket: "friendapp-bba60.firebasestorage.app",
  messagingSenderId: "433548051767",
  appId: "1:433548051767:web:3a73afb8e199c9107386b2"
});

const messaging = firebase.messaging();

messaging.onBackgroundMessage((payload) => {
  console.log("Background message received: ", payload);
  const notificationTitle = payload.notification.title || "Incoming Call";
  const notificationOptions = {
    body: payload.notification.body || "You have an incoming call",
    icon: "/favicon.png",
    data: payload.data
  };

  self.registration.showNotification(notificationTitle, notificationOptions);
});
