/* eslint-disable no-undef */
importScripts('https://www.gstatic.com/firebasejs/9.6.11/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/9.6.11/firebase-messaging-compat.js');

firebase.initializeApp({
  apiKey: "AIzaSyBNOtUKQxjnPxmd64iOaT7XcvmdEr_xfcU",
  appId: "1:720570909629:web:6d2223197b1a96079288d4",
  messagingSenderId: "720570909629",
  projectId: "farmwise-93a2e",
  authDomain: "farmwise-93a2e.firebaseapp.com",
  storageBucket: "farmwise-93a2e.firebasestorage.app",
});

const messaging = firebase.messaging();

messaging.onBackgroundMessage(function(payload) {
  const notificationTitle = payload.notification?.title || 'Notification';
  const notificationOptions = {
    body: payload.notification?.body || '',
    icon: '/icons/Icon-192.png',
  };
  self.registration.showNotification(notificationTitle, notificationOptions);
});


