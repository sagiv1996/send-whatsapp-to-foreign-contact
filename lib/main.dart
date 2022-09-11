import 'package:flutter/material.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:auto_size_text/auto_size_text.dart';
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
      home: MyHomePage(),
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

  Future<void> sendAWhatsappMessage() async {
    if (!isValid) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: new Text('The phone number is not a valid.')));
      return;
    }
    try {
      await launchUrl(getUriToWhatsApp());
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: new Text('The system failed to open WhatsApp')));
    }
  }

  Uri getUriToWhatsApp() => Uri.parse('whatsapp://send?phone=$phoneNumber');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
            decoration: BoxDecoration(
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
                ListTile(
                    title: new Center(
                        child: Padding(
                      padding: const EdgeInsets.only(bottom: 0),
                      child: AutoSizeText("Enter a phone number",
                          maxLines: 1, minFontSize: 35),
                    )),
                    subtitle: new Center(
                      child: AutoSizeText(
                        "we do not share your information with anyone",
                        maxLines: 1,
                        minFontSize: 15,
                      ),
                    )),
                InternationalPhoneNumberInput(
                  initialValue:
                      PhoneNumber(isoCode: Platform.localeName.split('_')[1]),
                  onInputChanged: (phoneNumber) {
                    setState(() {
                      this.phoneNumber = phoneNumber.toString();
                    });
                  },
                  onInputValidated: (bool isValid) async {
                    if (isValid) {
                      setState(() {
                        this.isValid = isValid;
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
                  selectorConfig: SelectorConfig(
                      selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
                      useEmoji: true,
                      showFlags: true),
                  autoValidateMode: AutovalidateMode.onUserInteraction,
                  selectorTextStyle: TextStyle(color: Colors.black),
                  inputBorder: OutlineInputBorder(),
                ),
                Center(
                  child: Text(
                      'Note: You can also enter phone numbers with spaces and dashes.'),
                )
              ],
            )));
  }
}
