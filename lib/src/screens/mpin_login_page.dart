import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../screens/card_details_page.dart';
import 'package:flutter_js/flutter_js.dart';

class MPinLoginPage extends StatefulWidget {
  const MPinLoginPage({Key? key});

  @override
  State<MPinLoginPage> createState() => _MPinLoginPageState();
}

class _MPinLoginPageState extends State<MPinLoginPage> {
  List<int?> pinDigits = List.filled(4,null);

  late TextEditingController pinControllerOne;
  late TextEditingController pinControllerTwo;
  late TextEditingController pinControllerThree;
  late TextEditingController pinControllerFour;

  bool showInvalidPinText = false;
  bool showSomethingWentWrongText = false;

  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();

  // JavascriptRuntime runtime = getJavascriptRuntime();
  // dynamic path = rootBundle.loadString("assets/cms_sdk_js/index.js");

  late JavascriptRuntime runtime;
  late String jsFileContent;

  Future<void> loadJsFile() async {
    jsFileContent = await rootBundle.loadString('cms_sdk_js/cms-client.js');
    runtime = getJavascriptRuntime();
  }

  Future<void> _login() async {
    String mpin = pinDigits.join();

    // final jsFile = await path;
    // JsEvalResult response = runtime.evaluate("""${jsFile}cmsUserAuthenticate($mpin)""");
    //
    // print(response);

    if (jsFileContent.isNotEmpty) {
      JsEvalResult response = runtime.evaluate("""$jsFileContent
          const cmsClient = new CmsClient();
          cmsClient.authenticate('+919700000001', '$mpin');
          """);
      print(response);
    }

    // final response = await apiService.verifyMpin(mpin);
    // Map<String, dynamic> data = response.data;

    // if (data['status'] == 'success') {
    //   if (data['data'] != null && data['data']['status'] == true &&
    //       data['data']['token'] != null) {
    //     setState(() {
    //       showInvalidPinText = false;
    //     });
    //
    //     String? jwtToken = await secureStorage.read(key: 'jwt_token');
    //
    //     if (jwtToken != null) {
    //       await secureStorage.delete(key: 'jwt_token');
    //       await secureStorage.write(
    //           key: 'jwt_token', value: data['data']['token']);
    //
    //       Navigator.pushReplacement(
    //           context,
    //           MaterialPageRoute(builder: (context) => const CardDetailsPage())
    //       );
    //     } else {
    //       await secureStorage.write(
    //           key: 'jwt_token', value: data['data']['token']);
    //       Navigator.pushReplacement(
    //           context,
    //           MaterialPageRoute(builder: (context) => const CardDetailsPage())
    //       );
    //     }
    //   }
    // } else if (data['status'] == 'error' &&
    //     data['error']['message'] == 'invalid credentials') {
    //   setState(() {
    //     showInvalidPinText = true;
    //     pinDigits.fillRange(0, pinDigits.length, null);
    //     pinControllerOne.clear();
    //     pinControllerTwo.clear();
    //     pinControllerThree.clear();
    //     pinControllerFour.clear();
    //   });
    // } else {
    //   setState(() {
    //     showSomethingWentWrongText = true;
    //     pinDigits.fillRange(0, pinDigits.length, null);
    //   });
    // }
  }

  Widget inputWidget(int index, TextEditingController controller){
    final focusNode = FocusNode();

    return Container(
      width: 35,
      height: 35,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: focusNode.hasFocus ? const Color(0xFFe96341) : const Color(0xFFdee2e6),
          width: 1.5,
        ),
      ),
      child: Center(
        child: TextField(
          controller: controller,
          focusNode: focusNode,
          keyboardType: TextInputType.number,
          inputFormatters: <TextInputFormatter>[
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(1),
          ],
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.black,
          ),
          decoration: const InputDecoration(
            border: InputBorder.none,
            contentPadding: EdgeInsets.only(bottom: 16),
          ),
          onChanged: (value){
            if(value.isNotEmpty){
              pinDigits[index] = int.parse(value);
              controller.value = const TextEditingValue(
                text: "*",
                selection: TextSelection.collapsed(offset: 1),
              );
              showInvalidPinText = false;
              FocusScope.of(context).nextFocus();
            }else{
              pinDigits[index] = null;
            }
          },
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    loadJsFile();
    pinControllerOne = TextEditingController();
    pinControllerTwo = TextEditingController();
    pinControllerThree = TextEditingController();
    pinControllerFour = TextEditingController();
  }

  @override
  void dispose() {
    pinControllerOne.dispose();
    pinControllerTwo.dispose();
    pinControllerThree.dispose();
    pinControllerFour.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(40, 50, 40, 70),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 30,),
                  const Text(
                    'Enter M-PIN',
                    style: TextStyle(
                        fontFamily: 'primaryFont',
                        fontSize: 16,
                        color: Colors.black
                    ),
                  ),
                  const Text(
                    'Enter your M-PIN for a secure entry to your card',
                    style: TextStyle(
                      fontFamily: 'primaryFont',
                      fontSize: 15,
                      color: Colors.black54,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      inputWidget(0, pinControllerOne),
                      const SizedBox(width: 10,),
                      inputWidget(1, pinControllerTwo),
                      const SizedBox(width: 10,),
                      inputWidget(2, pinControllerThree),
                      const SizedBox(width: 10,),
                      inputWidget(3, pinControllerFour),
                    ],
                  ),
                ],
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (showInvalidPinText)
                    GestureDetector(
                      onTap: (){
                        setState(() {
                          showInvalidPinText = false;
                          pinDigits.fillRange(0, pinDigits.length, null);
                          pinControllerOne.clear();
                          pinControllerTwo.clear();
                          pinControllerThree.clear();
                          pinControllerFour.clear();
                        });
                      },
                      child: const Text(
                        'Invalid MPin. Click here to Retry',
                        style: TextStyle(
                          fontFamily: 'primaryFont',
                          fontSize: 16,
                          color: Color(0xFFe96341),
                          decoration: TextDecoration.underline,
                          decorationColor: Color(0xFFe96341),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  const SizedBox(height: 40,),
                  if (showSomethingWentWrongText)
                    GestureDetector(
                      onTap: (){
                        setState(() {
                          showSomethingWentWrongText = false;
                          pinDigits.fillRange(0, pinDigits.length, null);
                          pinControllerOne.clear();
                          pinControllerTwo.clear();
                          pinControllerThree.clear();
                          pinControllerFour.clear();
                        });
                      },
                      child: const Text(
                        'Something went wrong. Click here to Retry',
                        style: TextStyle(
                          fontFamily: 'primaryFont',
                          fontSize: 16,
                          color: Color(0xFFe96341),
                          decoration: TextDecoration.underline,
                          decorationColor: Color(0xFFe96341),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  const SizedBox(height: 40,),
                  SizedBox(
                    width: 180,
                    height: 40,
                    child: ElevatedButton(
                        onPressed: (){
                          _login();
                        },
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          backgroundColor: const Color(0xFFe96341),
                        ),
                        child: const Text(
                          "Login",
                          style: TextStyle(
                            fontFamily: 'primaryFont',
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        )
                    ),
                  ),
                  const SizedBox(height: 40,),
                  GestureDetector(
                    onTap: (){
                      // Navigator.pushReplacement(
                      //     context,
                      //     MaterialPageRoute(builder: (context) => const SetPinPage())
                      // );
                    },
                    child: const Text(
                      'Reset MPin',
                      style: TextStyle(
                        fontFamily: 'primaryFont',
                        fontSize: 16,
                        color: Color(0xFFe96341),
                        decoration: TextDecoration.underline,
                        decorationColor: Color(0xFFe96341),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
