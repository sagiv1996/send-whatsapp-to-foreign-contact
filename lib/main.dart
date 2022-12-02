import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'dart:io' show Platform;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Send whatsapp to foreign contact',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String? phoneNumber;
  bool isValid = false;
  PhoneNumber initialPhoneNumber =
      PhoneNumber(isoCode: Platform.localeName.split('_').last);

  @override
  void initState() {
    super.initState();

    ReceiveSharingIntent.getInitialText().then((String? value) {
      if (value == null) {
        return;
      }
      setState(() {
        initialPhoneNumber = PhoneNumber(
            phoneNumber: value, isoCode: Platform.localeName.split('_').last);
      });
    });
  }

  Future<void> sendAWhatsappMessage() async {
    if (!isValid) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('The phone number is not a valid.')));
      return;
    }
    try {
      await launchUrl(getUriToWhatsApp());
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('The system failed to open WhatsApp')));
    }
  }

  Uri getUriToWhatsApp() => Uri.parse('whatsapp://send?phone=$phoneNumber');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color.fromRGBO(18, 140, 126, 0.3),
                  Color.fromRGBO(7, 94, 84, 0.6),
                  Color.fromRGBO(37, 211, 102, 1),
                  Color.fromRGBO(52, 183, 241, 0.7),
                ],
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                const ListTile(
                    title: Center(
                        child: Padding(
                      padding: EdgeInsets.only(bottom: 0),
                      child: AutoSizeText("Enter a phone number",
                          maxLines: 1, minFontSize: 35),
                    )),
                    subtitle: Center(
                      child: AutoSizeText(
                        "we do not share your information with anyone",
                        maxLines: 1,
                        minFontSize: 15,
                      ),
                    )),
                InternationalPhoneNumberInput(
                  initialValue: initialPhoneNumber,
                  onInputChanged: (phoneNumber) {
                    setState(() {
                      this.phoneNumber = phoneNumber.phoneNumber;
                    });
                  },
                  onInputValidated: (bool isValid) async {
                    if (isValid) {
                      setState(() {
                        this.isValid = isValid;
                        /**/
                      });
                      sendAWhatsappMessage();
                    }
                  },
                  onFieldSubmitted: (phoneNumber) {
                    setState(() {
                      this.phoneNumber = phoneNumber;
                      sendAWhatsappMessage();
                    });
                  },
                  selectorConfig: const SelectorConfig(
                    selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
                    useEmoji: true,
                    showFlags: true,
                  ),
                  // autoValidateMode: AutovalidateMode.onUserInteraction,
                  selectorTextStyle: const TextStyle(color: Colors.black),
                  inputBorder: const OutlineInputBorder(),
                ),
                const Center(
                  child: Text(
                      'Note: You can also enter phone numbers with spaces and dashes.',
                  textAlign: TextAlign.center,)
                )
              ],
            )));
  }
}
