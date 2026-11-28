{{flutter_js}}
{{flutter_build_config}}

_flutter.loader.load().catch((error) => {
  console.error('Failed to start Flutter:', error);
  document.getElementById('loading-message').textContent =
    'Unable to load the app. Please refresh the page.';
});

if ('serviceWorker' in navigator) {
  navigator.serviceWorker.getRegistration()
    .then((registration) => registration && registration.update())
    .catch((error) => console.warn('Failed to update the service worker:', error));
}
