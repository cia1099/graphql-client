# GraphQL Client

A GraphQL application project.
This project used local stream notification instead of subscription.
[Local stream example](https://github.com/CoderJava/flutter-graphql-sample)

visit this site: https://graphql-test.web.app/


 * force web for http request and disable security
 * https://stackoverflow.com/questions/65630743/how-to-solve-flutter-web-api-cors-error-only-with-dart-code
 * https://blog.bal.al/how-to-fix-cors-error-for-your-flutter-web-app

 * change icons refs:
 * https://stackoverflow.com/questions/56745525/how-to-configure-icon-for-my-flutter-web-application
 * https://icons8.com/icons/set/graphql

### Deploy step

1. [install firebase nad initialized project in terminal](https://firebase.google.com/docs/hosting/quickstart)

2. First, we need login machine in firbase then get token
```shell
firebase login:ci
>>>> 1//0ee2ndomhKWaLCgYIARAAGA4SNwF-L9IrI_bZ1nDAXWc4vFVrvIdksGJGFMUWEl-****MY Token
```
add --token $TOKEN to command of firebase every time in terminal

3. [Test and preview](https://firebase.google.com/docs/hosting/manage-hosting-resources)

在發布預覽前，先在**firebase Hosting**網頁新增其他網站，自己另命名一個Site-Id，之後這個Site-Id要在先前執行`firebase init hosting`生成的`firebase.json`，裡面標記deploy的域名地方：
```json
// firebase.json
"hosting": {
    "site": "graphql-test", //加入目的地，不然預設是project-Id
    "public": "build/web",
    "ignore": [
      "firebase.json",
      "**/.*",
      "**/node_modules/**"
    ],
    "rewrites": [
      {
        "source": "**",
        "destination": "/index.html"
      }
    ]
  }

```
之後可以清除先前的建置，重新建一個release版

```shell
flutter clean
flutter build web
# deploy to preview channel within 1 day
firebase hosting:channel:deploy preview-version --expires 1d
# if you satisfied this preview, you can clone to live channel
firebase hosting:clone graphql-test:preview-version graphql-test:live
```
---
## Server side

* In server, must to access other browser policy
* https://www.youtube.com/watch?v=PNtFSVU-YTI
* https://errorsfixing.com/enabling-cors-in-firebase-hosting-2/

