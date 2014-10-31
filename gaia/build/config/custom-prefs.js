//pref("app.update.url", "http://owd.tid.es/updates/flame/update.xml");
//pref("app.update.url", "http://192.168.2.2:4576/ota/update.xml");
pref("services.push.serverURL", "wss://ua.push.tefdigital.com");
// Movistar Spain: 29 minutes, our ping is 28 minutes to be safe
pref("services.push.pingInterval", "1680000");
pref("network.proxy.no_proxies_on", "localhost, 127.0.0.1, *.push.tefdigital.com");
pref("dom.mozApps.signed_apps_installable_from","https://marketplace.firefox.com,https://owd.tid.es");
pref("media.peerconnection.video.h264_enabled", true);
