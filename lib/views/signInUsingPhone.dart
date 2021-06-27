import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:mytask/config/config.dart';

class SignInUsingPhone extends StatefulWidget {
  SignInUsingPhone({Key key}) : super(key: key);

  @override
  _SignInUsingPhoneState createState() => _SignInUsingPhoneState();
}

class _SignInUsingPhoneState extends State<SignInUsingPhone> {
  PhoneNumber _phoneNumber;
  TextEditingController _otpController = TextEditingController();
  bool isSmsSent = false;
  String message;
  String _verificationId;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("SignIn using Phone"),
      ),
      body: SingleChildScrollView(
        child: Container(
          width: MediaQuery.of(context).size.width,
          child: Column(
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(top: 20),
                padding: EdgeInsets.all(10.0),
                child: InternationalPhoneNumberInput(
                  selectorConfig: SelectorConfig(
                      selectorType: PhoneInputSelectorType.DIALOG),
                  onInputChanged: (phoneNumberTxt) {
                    _phoneNumber = phoneNumberTxt;
                    print(phoneNumberTxt);
                  },
                  inputBorder: OutlineInputBorder(),
                  keyboardType: TextInputType.phone,
                ),
              ),
              isSmsSent
                  ? Container(
                      margin: EdgeInsets.all(10),
                      padding: EdgeInsets.all(10),
                      child: TextField(
                        controller: _otpController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: "OTP",
                          hintText: "OTP here",
                        ),
                        maxLength: 6,
                        keyboardType: TextInputType.number,
                      ),
                    )
                  : Container(),
              !isSmsSent
                  ? InkWell(
                      onTap: () {
                        setState(() {
                          isSmsSent = true;
                        });
                        _verifyNumber();
                      },
                      child: Container(
                        margin:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                            gradient: LinearGradient(
                                colors: [primaryColor, secondaryColor]),
                            borderRadius: BorderRadius.circular(16)),
                        child: Center(
                          child: Text(
                            "Send OTP",
                            style: TextStyle(color: Colors.white, fontSize: 20),
                          ),
                        ),
                      ),
                    )
                  : InkWell(
                      onTap: () {
                        _singInWithPhoneNumber();
                      },
                      child: Container(
                        margin:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                            gradient: LinearGradient(
                                colors: [primaryColor, secondaryColor]),
                            borderRadius: BorderRadius.circular(16)),
                        child: Center(
                          child: Text(
                            "Verify OTP",
                            style: TextStyle(color: Colors.white, fontSize: 20),
                          ),
                        ),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  void _verifyNumber() async {
    setState(() {
      message = "";
    });

    final PhoneVerificationCompleted verificationCompleted =
        (PhoneAuthCredential _phoneAuthCredential) {
      setState(() {
        message = 'Recieved Phone Auth credential: $_phoneAuthCredential';
      });
    };

    final PhoneVerificationFailed verificationFailed =
        (FirebaseAuthException _authException) {
      setState(() {
        message =
            'Phone number verification failed. Code: ${_authException.code}. Message: ${_authException.message}';
      });
    };

    final PhoneCodeSent codeSent =
        (String verificationId, int forceResendingToken) async {
      _verificationId = verificationId;
    };

    final PhoneCodeAutoRetrievalTimeout codeAutoRetrievalTimeout =
        (String verficaionId) {
      _verificationId = verficaionId;
    };

    _auth.verifyPhoneNumber(
        phoneNumber: _phoneNumber.phoneNumber,
        timeout: const Duration(seconds: 60),
        verificationCompleted: verificationCompleted,
        verificationFailed: verificationFailed,
        codeSent: codeSent,
        codeAutoRetrievalTimeout: codeAutoRetrievalTimeout);
  }

  void _singInWithPhoneNumber() async {
    final PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId, smsCode: _otpController.text);

    final User user = (await _auth.signInWithCredential(credential)).user;

    final User currentUser = _auth.currentUser;
    assert(user.uid == currentUser.uid);
    setState(() {
      if (user != null) {
        _db.collection('users').doc(user.uid.toString()).set({
          'phone_number': user.phoneNumber,
          'lastseen': DateTime.now(),

          
          
        });
        Navigator.of(context).pop();
        message = 'Sccesfully signed in. UID:${user.uid}';
        print(message);
      } else {
        message = 'Sign in failed.';
        print(message);
      }
    });
  }
}
