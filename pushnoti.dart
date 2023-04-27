import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';

import 'package:http/http.dart' as http;
// ignore: library_prefixes
import 'package:encrypt/encrypt.dart' as EncryptPack;
// ignore: library_prefixes
import 'package:crypto/crypto.dart' as CryptoPack;
import 'package:visuals/testing/push_notification_manager.dart';

class ViewPage extends StatefulWidget {
  const ViewPage({Key? key}) : super(key: key);

  @override
  State<ViewPage> createState() => _ViewPageState();
}

class _ViewPageState extends State<ViewPage> {
  final ValueNotifier<bool> _loading = ValueNotifier<bool>(false);
  final flutterWebViewPlugin = FlutterWebviewPlugin();
  final Set<JavascriptChannel> jsChannels = {
    JavascriptChannel(
        name: 'userid',
        onMessageReceived: (JavascriptMessage message) {
          print('message received ${message.message}');
        }),
  };

  @override
  void initState() {
    flutterWebViewPlugin.onStateChanged.listen((event) {
      print('event type is ${event.type}');
      if (event.type == WebViewState.shouldStart) {
        _loading.value = true;
      } else if (event.type == WebViewState.finishLoad) {
        _loading.value = false;
      }
    });
    flutterWebViewPlugin.onProgressChanged.listen((event) {
      if (event == 1.0) {
        _loading.value = false;
      }
    });
    pushTokenSubmit('555');
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        bool canGoBack = await flutterWebViewPlugin.canGoBack();
        if (canGoBack) {
          flutterWebViewPlugin.goBack();
        }
        return !canGoBack;
      },
      child: SafeArea(
        child: Stack(
          alignment: Alignment.center,
          children: [
            WebviewScaffold(
              url: "https://visual.photo/",
              javascriptChannels: {
                JavascriptChannel(
                  name: "messageHandler",
                  onMessageReceived: (JavascriptMessage message) async {
                    var msg = message.message;
                    var data = jsonDecode(message.message);

                    var userid = data["userid"];

                    String strPwd =
                        "e4e9cd85"; //secret key generated in step 1 above

                    String token =
                        PushNotificationsManager.instance.token ?? '';

                    final iv = EncryptPack.IV.fromLength(16);

                    final key = EncryptPack.Key.fromUtf8(strPwd); //hardcode

                    final encrypter = EncryptPack.Encrypter(
                        EncryptPack.AES(key, mode: EncryptPack.AESMode.cbc));
                    final encrypted =
                        encrypter.encrypt(token.toString(), iv: iv);
                    var hmacSha256 = CryptoPack.Hmac(
                        CryptoPack.sha256, utf8.encode(strPwd)); // HMAC-SHA256
                    var hmacstring =
                        hmacSha256.convert(utf8.encode(token.toString()));
                    var encryptedsubscription =
                        "${encrypted.base64}:${iv.base64}:$hmacstring:$hmacstring";
                    var body = {
                      'token': encryptedsubscription,
                      'userid': userid.toString()
                    };

                    var responseOfAPI = await http.post(
                      Uri.parse(
                          'https://visual.photo/wp-json/PNFPBpush/v1/subscriptiontoken'),
                      body: body,
                    );
                    log("msssgg ${responseOfAPI.body}");
                    Map<String, dynamic> fResponse =
                        json.decode(responseOfAPI.body);
                  },
                ),
                JavascriptChannel(
                  name: 'frontendsubscriptionOptions',
                  onMessageReceived: (JavascriptMessage message) async {
                    print('messa ge is ${message.message}');
                    // Here you can take message.message and use
                    // your string from webview
                    /*Fluttertoast.showToast(
                              msg: message.message.toString(),
                              toastLength: Toast.LENGTH_LONG,
                              gravity: ToastGravity.CENTER,
                              timeInSecForIosWeb: 25,
                              fontSize: 16.0
                          );*/

                    String strPwd = "e4e9cd8552f87f76d75828439ab5e4cf";

                    var groupid = message.message.toString();

                    final iv = EncryptPack.IV.fromLength(16);

                    final key = EncryptPack.Key.fromUtf8(strPwd); //hardcode

                    final encrypter = EncryptPack.Encrypter(
                        EncryptPack.AES(key, mode: EncryptPack.AESMode.cbc));

                    final encrypted = encrypter.encrypt(
                        PushNotificationsManager.instance.token ?? '',
                        iv: iv);

                    var hmacSha256 = CryptoPack.Hmac(
                        CryptoPack.sha256, utf8.encode(strPwd)); // HMAC-SHA256

                    var hmacstring = hmacSha256.convert(utf8
                        .encode(PushNotificationsManager.instance.token ?? ''));

                    var encryptedsubscription =
                        "${encrypted.base64}:${iv.base64}:$hmacstring:$hmacstring";

                    var url = Uri.parse(
                        'https://visual.photo/wp-json/PNFPBpush/v1/subscriptiontoken');

                    var response = await http.post(url, body: {
                      'token': encryptedsubscription,
                      'subscription-type': 'unsubscribe-group',
                      'groupid': groupid,
                      'cookievalue': ''
                    });

                    var outputresponse =
                        '${response.statusCode} ${response.body}';
                    log(response.body);

                    /*Fluttertoast.showToast(
                              msg: outputresponse,
                              toastLength: Toast.LENGTH_LONG,
                              gravity: ToastGravity.CENTER,
                              timeInSecForIosWeb: 35,
                              fontSize: 16.0
                          );*/
                  },
                ),
                JavascriptChannel(
                  name: 'subscribeGroupid',
                  onMessageReceived: (JavascriptMessage message2) async {
                    // Here you can take message.message and use
                    // your string from webview
                    /*Fluttertoast.showToast(
                              msg: message2.message.toString(),
                              toastLength: Toast.LENGTH_LONG,
                              gravity: ToastGravity.CENTER,
                              timeInSecForIosWeb: 15,
                              fontSize: 16.0
                          );*/

                    String strPwd = "e4e9cd8552f87f76d75828439ab5e4cf";
                    print('messa ge2 is ${message2.message}');

                    var groupid = message2.message.toString();

                    final iv = EncryptPack.IV.fromLength(16);

                    final key = EncryptPack.Key.fromUtf8(strPwd); //hardcode

                    final encrypter = EncryptPack.Encrypter(
                        EncryptPack.AES(key, mode: EncryptPack.AESMode.cbc));

                    final encrypted = encrypter.encrypt(
                        PushNotificationsManager.instance.token ?? '',
                        iv: iv);

                    var hmacSha256 = CryptoPack.Hmac(
                        CryptoPack.sha256, utf8.encode(strPwd)); // HMAC-SHA256

                    var hmacstring = hmacSha256.convert(utf8
                        .encode(PushNotificationsManager.instance.token ?? ''));

                    var encryptedsubscription =
                        "${encrypted.base64}:${iv.base64}:$hmacstring:$hmacstring";

                    var url = Uri.parse(
                        'https://visual.photo/wp-json/PNFPBpush/v1/subscriptiontoken');

                    var response = await http.post(url, body: {
                      'token': encryptedsubscription,
                      'subscription-type': 'subscribe-group',
                      'groupid': groupid,
                      'cookievalue': ''
                    });

                    var outputresponse =
                        '${response.statusCode} ${response.body}';
                    log(response.body);
                    /*Fluttertoast.showToast(
                              msg: outputresponse,
                              toastLength: Toast.LENGTH_LONG,
                              gravity: ToastGravity.CENTER,
                              timeInSecForIosWeb: 35,
                              fontSize: 16.0
                          );*/
                  },
                ),
              },
              initialChild: Container(
                color: Colors.white,
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            ),
            Positioned(
              child: ValueListenableBuilder<bool>(
                  valueListenable: _loading,
                  builder: (context, loading, _) {
                    return loading
                        ? const CircularProgressIndicator()
                        : const SizedBox();
                  }),
            )
          ],
        ),
      ),
    );
  }

  pushTokenSubmit(String userid) async {
    print('called');
    String strPwd =
        "e4e9cd8552f87f"; //secret key generated in step 1 above

    String token = PushNotificationsManager.instance.token ?? '';
    print('token is $token');

    final iv = EncryptPack.IV.fromLength(16);

    final key = EncryptPack.Key.fromUtf8(strPwd); //hardcode

    final encrypter = EncryptPack.Encrypter(
        EncryptPack.AES(key, mode: EncryptPack.AESMode.cbc));
    final encrypted = encrypter.encrypt(token.toString(), iv: iv);
    var hmacSha256 =
        CryptoPack.Hmac(CryptoPack.sha256, utf8.encode(strPwd)); // HMAC-SHA256
    var hmacstring = hmacSha256.convert(utf8.encode(token.toString()));
    var encryptedsubscription =
        "${encrypted.base64}:${iv.base64}:$hmacstring:$hmacstring";
    var body = {'token': encryptedsubscription, 'userid': userid};
    print('body is $body');
    var responseOfAPI = await http.post(
      Uri.parse('https://visual.photo/wp-json/PNFPBpush/v1/subscriptiontoken'),
      body: body,
    );
    log(responseOfAPI.body);
    Map<String, dynamic> fResponse = json.decode(responseOfAPI.body);
  }
}
