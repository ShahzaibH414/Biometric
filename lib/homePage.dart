import 'package:fingerprint_scanner/mainPage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, });

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

enum SupportState{
  unknown,
  supported,
  unSupported,
}

class _MyHomePageState extends State<MyHomePage> {
  final LocalAuthentication auth = LocalAuthentication();

  SupportState supportState = SupportState.unknown;

  List<BiometricType>? availableBiometrics;

  @override
  void initState() {
    auth.isDeviceSupported().then((bool isSupported) =>
    setState(() => supportState = isSupported? SupportState.supported :
    SupportState.unSupported));
    super.initState();
    checkBiometric();
    getAvailableBiometrics();
  }

  Future<void> checkBiometric() async{
    late bool canCheckBiometric;
    try{
      canCheckBiometric = await auth.canCheckBiometrics;
      if (kDebugMode) {
        print('biometric supported : $canCheckBiometric');
      }
    } on PlatformException catch(r){
      if (kDebugMode) {
        print(r.details);
        print(r.code);
        print(r.message);
        print(r.stacktrace);
      }

      canCheckBiometric = false;
    }
  }

  Future<void> getAvailableBiometrics()async{
    late List<BiometricType> biometricTypes;
    try{
      biometricTypes = await auth.getAvailableBiometrics();
      if (kDebugMode) {
        print('supported biometric : $biometricTypes');
      }
    } on PlatformException catch(r){
      if (kDebugMode) {
        print(r.details);
        print(r.code);
        print(r.message);
        print(r.stacktrace);
      }

    }
    if(!mounted){
      return;
    }
    setState(() {
      availableBiometrics = biometricTypes;
    });
  }

  Future<void> authenticateBiometrics()async{
    try{
      final authenticated = await auth.authenticate(
          localizedReason: 'Authenticate with fingerprint to login',
      options: const AuthenticationOptions(
        stickyAuth: true,
        biometricOnly: true,
      ));

      if(!mounted){
        return;
      }
      if(authenticated){
        Navigator.push(context, MaterialPageRoute(builder: (context) =>
        const MainPage()));
      }
    } on PlatformException catch(r){
      if (kDebugMode) {
        print(r);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Biometric Validation'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                supportState == SupportState.supported?
                    'Biometric authentication is supported on this device':
                    supportState == SupportState.unSupported ?
                        'Biometric authentication is not supported on this device' :
                        'Checking biometric support...',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color:  supportState == SupportState.supported ?
                      Colors.green :
                  supportState == SupportState.unSupported ?
                      Colors.red :
                      Colors.yellow
                ),
              ),
              const SizedBox(height: 20,),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Supported Biometrics : \n$availableBiometrics'),
                ],
              ),
              const SizedBox(height: 60,),

              InkWell(
                onTap: authenticateBiometrics,
                  child: Container(
                    decoration: const BoxDecoration(
                        color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(20))
                    ),
                    padding: const EdgeInsets.all(10),
                      child: Image.asset('assets/fingerprint.png',height: 40,width: 40,))),
            ],
          ),
        ),
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}