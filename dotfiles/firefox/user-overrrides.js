//https://gitlab.com/trafotin/dotfiles/-/blob/main/user-overrides.js

//I read the wiki
//https://github.com/arkenfox/user.js/wiki/3.2-Overrides-%5BCommon%5D

//Disable Safe Browsing, this phones home to Google.
user_pref("browser.safebrowsing.malware.enabled", false);
user_pref("browser.safebrowsing.phishing.enabled", false);
user_pref("browser.safebrowsing.downloads.enabled", false);

// Leave IPv6 enabled
user_pref("network.dns.disableIPv6", false);

//Reenable search engines
user_pref("keyword.enabled", true);
//Enable Search Engine suggestion
user_pref("browser.search.suggest.enabled", false);
user_pref("browser.urlbar.suggest.searches", false);
// Disk caching, which might improve performance if enabled.
user_pref("browser.cache.disk.enable", false);
//Enable favicons, the icons in bookmarks
user_pref("browser.shell.shortcutFavicons", true);

// Strict third party requests, may cause images/video to break.
user_pref("network.http.referer.XOriginPolicy", 2);

//WebRTC settings, things like video calls
   // user_pref("media.peerconnection.enabled", false);
// Disable Media Plugins
   // user_pref("media.gmp-provider.enabled", false);
// Disable DRM, FCKDRM
   // user_pref("media.gmp-widevinecdm.enabled", false);
user_pref("media.eme.enabled", false);
//Autoplaying settings
//0=Allow all, 1=Block non-muted media (default), 5=Block all
   // user_pref("media.autoplay.default", 5);
//If some websites REALLY need autoplaying...
//0=sticky (default), 1=transient, 2=user
user_pref("media.autoplay.blocking_policy", 2);

//Use Disconnect's blocklist to block ads
user_pref("browser.contentblocking.category", "strict");

//Delete cookies on close, but see below to make exceptions
/* 2801: delete cookies and site data on exit
 //* 0=keep until they expire (default), 2=keep until you close Firefox
 * [NOTE] A "cookie" block permission also controls localStorage/sessionStorage, indexedDB,
 * sharedWorkers and serviceWorkers. serviceWorkers require an "Allow" permission
 * [SETTING] Privacy & Security>Cookies and Site Data>Delete cookies and site data when Firefox is closed
 * [SETTING] to add site exceptions: Ctrl+I>Permissions>Cookies>Allow
 * [SETTING] to manage site exceptions: Options>Privacy & Security>Permissions>Settings ***/
user_pref("network.cookie.lifetimePolicy", 2);
//Disabling disk cache is better, but try this if you like performance
   // user_pref("privacy.clearsitedata.cache.enabled", true);

//Clear data on shutdown
user_pref("privacy.sanitize.sanitizeOnShutdown", true);
user_pref("privacy.clearOnShutdown.cache", true);     // [DEFAULT: true]
user_pref("privacy.clearOnShutdown.downloads", true); // [DEFAULT: true]
user_pref("privacy.clearOnShutdown.formdata", true);  // [DEFAULT: true]
user_pref("privacy.clearOnShutdown.history", true);   // [DEFAULT: true]
user_pref("privacy.clearOnShutdown.sessions", true);  // [DEFAULT: true]
user_pref("privacy.clearOnShutdown.offlineApps", false); // [DEFAULT: false]
user_pref("privacy.clearOnShutdown.cookies", false);
   // user_pref("privacy.clearOnShutdown.siteSettings", false); // [DEFAULT: false]
// Manual wiping, such as the forget-me-not button
user_pref("privacy.cpd.cache", true);    // [DEFAULT: true]
user_pref("privacy.cpd.formdata", true); // [DEFAULT: true]
user_pref("privacy.cpd.history", true);  // [DEFAULT: true]
user_pref("privacy.cpd.sessions", true); // [DEFAULT: true]
user_pref("privacy.cpd.offlineApps", false); // [DEFAULT: false]
user_pref("privacy.cpd.cookies", false);
   // user_pref("privacy.cpd.downloads", true); // not used, see note above
   // user_pref("privacy.cpd.passwords", false); // [DEFAULT: false] not listed
   // user_pref("privacy.cpd.siteSettings", false); // [DEFAULT: false]
// Delete everything ever.
user_pref("privacy.sanitize.timeSpan", 0);
//Delete history, although might be security theater.
//Helps against forensic tools.
user_pref("places.history.enabled", false);

//WebGL is a security risk, but sometimes breaks things like 23andMe
//or Google Maps (not always).
user_pref("webgl.disabled", true);

//Firefox stores passwords in plain text and obsolete if you use a password manager.
//Mozilla also told people to stop using their password manager.
user_pref("signon.rememberSignons", false);
//Disable Pocket, it's proprietary trash
user_pref("extensions.pocket.enabled", false);
// Disable Mozilla account
user_pref("identity.fxaccounts.enabled", false);
