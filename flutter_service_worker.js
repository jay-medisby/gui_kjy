'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"assets/AssetManifest.bin": "fd32443f6d27ad6d3df6a40bc52ac8fa",
"assets/AssetManifest.bin.json": "edc78aab4782d8bdd4cf3ad4e2aeb34a",
"assets/assets/images/img_arm.png": "544a4b209e2d4aa62cd37a8a0400f749",
"assets/assets/images/img_ems.png": "b0d023952a1b32c3e4c3d89b19b2b141",
"assets/assets/images/img_fullbody.png": "41f5658cc123846256215e9f079fdb20",
"assets/assets/images/img_group1.png": "1d248084b656d4f1de53f5376e5fba57",
"assets/assets/images/img_group2.png": "71e5841ecac7ed09aa75aa49a9660f88",
"assets/assets/images/img_group3.png": "2bd94572cc8a1488024887a05a62b468",
"assets/assets/images/img_handswitch.png": "0b2e0d7001a756e1ceeffbd815776a3e",
"assets/assets/images/img_lower_left3.png": "bfc5bf1ed38fb2585ec15d7d23c508d0",
"assets/assets/images/img_lower_right3.png": "630f17405c3dd5d8ce1ab8feb497ac17",
"assets/assets/images/img_oneway.png": "86295785ee9ab8796aab121c94666118",
"assets/assets/images/img_position_lower_left.png": "dc9f6394d72af9edcb5bdfc70e62649e",
"assets/assets/images/img_position_lower_left2.png": "0878f4cc39b648a868fa7846f08b1505",
"assets/assets/images/img_position_lower_right.png": "62b6c15f044cbc5c72a16ef07ef89e03",
"assets/assets/images/img_position_lower_right2.png": "5ab1d90014021440e4f90628cb601b95",
"assets/assets/images/img_position_upper_left.png": "a4eaabdf00a0ee0a5c7ffdace91247f8",
"assets/assets/images/img_position_upper_left2.png": "56399c5e8574b1ef6b0f36c6893a5041",
"assets/assets/images/img_position_upper_right.png": "d3b83e10f33754871e7f1f05417939f6",
"assets/assets/images/img_position_upper_right2.png": "98cccb3638002d53aa3bf88247d75c34",
"assets/assets/images/img_roboarm.png": "f323674c7f9daef3b2f37dc86eb50520",
"assets/assets/images/img_stepper_ver1_notext.png": "63fe13197038c2498657f393b6bca76a",
"assets/assets/images/img_stepper_ver1_text.png": "e5f71debc2eab403beda042320733f41",
"assets/assets/images/img_stepper_ver2_notext.png": "81da339d4d45b5fbbec6378ee6ea2e07",
"assets/assets/images/img_stepper_ver2_text.png": "d8f2f74abcb60cb7220419a80d519be0",
"assets/assets/images/img_upper_left3.png": "8c2230c33e1f69813262310458151ceb",
"assets/assets/images/img_upper_right3.png": "aad5674b4462cc171d0bcac88534197f",
"assets/assets/images/img_wheel_front.png": "0b542e195f89b9b068d0f58b2dfb3df6",
"assets/assets/images/img_wheel_rear.png": "b8347fc1772f63a7a3c86971d5bf8286",
"assets/FontManifest.json": "dc3d03800ccca4601324923c0b1d6d57",
"assets/fonts/MaterialIcons-Regular.otf": "49e8575f802e2f4dd5d8ce21da4a454b",
"assets/NOTICES": "cd0ad432df616f29f656b30aad44dabb",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "33b7d9392238c04c131b6ce224e13711",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"assets/shaders/stretch_effect.frag": "40d68efbbf360632f614c731219e95f0",
"canvaskit/canvaskit.js": "8331fe38e66b3a898c4f37648aaf7ee2",
"canvaskit/canvaskit.js.symbols": "a3c9f77715b642d0437d9c275caba91e",
"canvaskit/canvaskit.wasm": "9b6a7830bf26959b200594729d73538e",
"canvaskit/chromium/canvaskit.js": "a80c765aaa8af8645c9fb1aae53f9abf",
"canvaskit/chromium/canvaskit.js.symbols": "e2d09f0e434bc118bf67dae526737d07",
"canvaskit/chromium/canvaskit.wasm": "a726e3f75a84fcdf495a15817c63a35d",
"canvaskit/skwasm.js": "8060d46e9a4901ca9991edd3a26be4f0",
"canvaskit/skwasm.js.symbols": "3a4aadf4e8141f284bd524976b1d6bdc",
"canvaskit/skwasm.wasm": "7e5f3afdd3b0747a1fd4517cea239898",
"canvaskit/skwasm_heavy.js": "740d43a6b8240ef9e23eed8c48840da4",
"canvaskit/skwasm_heavy.js.symbols": "0755b4fb399918388d71b59ad390b055",
"canvaskit/skwasm_heavy.wasm": "b0be7910760d205ea4e011458df6ee01",
"favicon.png": "5dcef449791fa27946b3d35ad8803796",
"flutter.js": "24bc71911b75b5f8135c949e27a2984e",
"flutter_bootstrap.js": "1652fcd6bf81da6d1ba5f717523218a5",
"icons/Icon-192.png": "ac9a721a12bbc803b44f645561ecb1e1",
"icons/Icon-512.png": "96e752610906ba2a93c65f8abe1645f1",
"icons/Icon-maskable-192.png": "c457ef57daa1d16f64b27b786ec2ea3c",
"icons/Icon-maskable-512.png": "301a7604d45b3e739efc881eb04896ea",
"index.html": "722667ecf4269dff4addd31b272d8920",
"/": "722667ecf4269dff4addd31b272d8920",
"main.dart.js": "de8fe5a620ce2104da5ab29b96981d62",
"manifest.json": "e6acbcb2986c0bf6cb069706d4236b6e",
"version.json": "19969bc44ce354cc091b42354f2e91c5"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
"index.html",
"flutter_bootstrap.js",
"assets/AssetManifest.bin.json",
"assets/FontManifest.json"];

// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
    })
  );
});
// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        // Claim client to enable caching on first launch
        self.clients.claim();
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      // Claim client to enable caching on first launch
      self.clients.claim();
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});
// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache only if the resource was successfully fetched.
        return response || fetch(event.request).then((response) => {
          if (response && Boolean(response.ok)) {
            cache.put(event.request, response.clone());
          }
          return response;
        });
      })
    })
  );
});
self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});
// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}
// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}
