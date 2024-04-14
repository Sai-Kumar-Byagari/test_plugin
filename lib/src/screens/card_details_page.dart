import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import '../utils/user_authentication.dart';
import '../services/api_service.dart';

enum ApiStatus {
  initial,
  inProgress,
  success,
  failure,
}

enum UserCardDetails {
  userName,
  cardNumber,
  isPinSetUp,
  cardType,
  networkType,
  status,
  cardBalance,
  cardCvv,
}

class CardDetailsPage extends StatefulWidget {
  const CardDetailsPage({super.key});

  @override
  State<CardDetailsPage> createState() => _CardDetailsPageState();
}

class _CardDetailsPageState extends State<CardDetailsPage> {
  ApiStatus cardDetailsApiStatus = ApiStatus.initial;
  ApiStatus unbilledTransactionsApiStatus = ApiStatus.initial;

  List<dynamic> unbilledTransactionsList = [];
  bool showAllTransactions = false;

  ValueNotifier<bool> showCvvNotifier = ValueNotifier<bool>(false);

  final ApiService apiService = ApiService();
  Map<UserCardDetails, String> cardDetails = {};

  late String kitNumber;
  late String userDob;
  late String expiryDate;

  String maskCardNumber(String cardNumber){
    if (cardNumber.length == 16) {
      String maskedNumber = "${cardNumber.substring(0,4)} **** **** ${cardNumber.substring(12,cardNumber.length)}";
      return maskedNumber;
    } else {
      return "Invalid card Number";
    }
  }

  String formatExpiryDate(String expiryDate){
    if (expiryDate.length == 4) {
      String formattedDate = "Expiry: ${expiryDate.substring(0,2)}/${expiryDate.substring(2,4)}";
      return formattedDate;
    } else {
      return "Invalid expiry date";
    }
  }

  Future<void> _getCardDetailsData(String? token) async {
    setState(() {
      cardDetailsApiStatus = ApiStatus.inProgress;
    });

    try{
      final response = await apiService.getCardDetails(token!);
      Map<String, dynamic> data = response.data;

      if(data['status'] == "success" && data['data'] != null){
        setState(() {
          kitNumber = data['kitNo'];
          userDob = data['dob'];
          expiryDate = data['cardExpiry'];
          cardDetails = {
            UserCardDetails.userName: data['name'],
            UserCardDetails.cardNumber: data['cardNo'],
            UserCardDetails.isPinSetUp: data['isPinSetup'].toString(),
            UserCardDetails.cardType: data['cardType'],
            UserCardDetails.networkType: data['networkType'],
            UserCardDetails.status: data['status'],
          };
        });
      }else{
        setState(() {
          cardDetailsApiStatus = ApiStatus.failure;
        });
      }
    }catch(error){
      setState(() {
        cardDetailsApiStatus = ApiStatus.failure;
      });
    }
  }

  Future<void> _getCardBalanceData(String? token) async {
    setState(() {
      cardDetailsApiStatus = ApiStatus.inProgress;
    });

    try{
      final response = await apiService.getCardBalance(token!);
      Map<String, dynamic> data = response.data;

      if(data['status'] == "success" && data['data'] != null){
        setState(() {
          cardDetails = {
            UserCardDetails.cardBalance: data['data'][0]['balance'].toString(),
          };
          cardDetailsApiStatus = ApiStatus.success;
        });
      }else{
        setState(() {
          cardDetailsApiStatus = ApiStatus.failure;
        });
      }
    }catch(error){
      setState(() {
        cardDetailsApiStatus = ApiStatus.failure;
      });
    }
  }

  Future<void> _getCvvData(String? token) async {
    try{
      final response = await apiService.getCvv(token!,kitNumber,userDob,expiryDate);
      Map<String, dynamic> data = response.data;

      if(data['status'] == "success" && data['data'] != null) {
        setState(() {
          cardDetails = {
            UserCardDetails.cardCvv: data['data']['cvv'].toString(),
          };
          cardDetailsApiStatus = ApiStatus.success;
        });
      }
    }catch(error){
      setState(() {
        cardDetailsApiStatus = ApiStatus.failure;
      });
    }
  }

  Future<void> _getUnbilledTransactionsData(String? token) async {
    setState(() {
      unbilledTransactionsApiStatus = ApiStatus.inProgress;
    });

    try{
      final response = await apiService.getUnbilledTransactions(token!);
      Map<String, dynamic> data = response.data;

      if(data['status'] == "success" && data['data'] != null) {
        setState(() {
          List<dynamic> unbilledTransactionsListData = data['data'];
          List<dynamic> filteredUnbilledTransactionsList = unbilledTransactionsListData.sublist(0,unbilledTransactionsListData.length -1);
          unbilledTransactionsList = filteredUnbilledTransactionsList;
          unbilledTransactionsApiStatus = ApiStatus.success;
        });
      }else{
        setState(() {
          unbilledTransactionsApiStatus = ApiStatus.failure;
        });
      }
    }catch(error){
      setState(() {
        unbilledTransactionsApiStatus = ApiStatus.failure;
      });
    }
  }

  String formatDate(String inputDate) {
    DateTime dateTime = DateTime.parse(inputDate);
    String formattedDate = DateFormat('MMMM dd, yyyy, hh:mm:ss a').format(dateTime);
    return formattedDate;
  }

  Widget _buildTransactionRow(String transactionType, String description, String transactionDate,int amount){
    final transactionIcon = transactionType == 'CREDIT' ? FontAwesomeIcons.circlePlus : FontAwesomeIcons.circleMinus;
    final transactionIconColor = transactionType == 'CREDIT' ? Colors.green : Colors.orange;
    final String formattedExternalTransactionId;

    if(description.length > 27){
      String slicedExternalTransactionId = description.substring(0,26);
      formattedExternalTransactionId = slicedExternalTransactionId;
    }else{
      formattedExternalTransactionId = description;
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                FaIcon(
                  transactionIcon,
                  size: 24,
                  color: transactionIconColor,
                ),
                const SizedBox(width: 13,),
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      formattedExternalTransactionId,
                      style: const TextStyle(
                        fontFamily: 'primaryFont',
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                    Text(
                      formatDate(transactionDate),
                      style: const TextStyle(
                        fontFamily: 'primaryFont',
                        fontSize: 12,
                        color: Colors.black45,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  "\u20B9 $amount",
                  style: const TextStyle(
                    fontFamily: 'primaryFont',
                    fontSize: 14,
                    color: Colors.black,
                  ),
                ),
                Text(
                  "\u20B9 4.75",
                  style: TextStyle(
                    fontFamily: 'primaryFont',
                    fontSize: 12,
                    color: transactionIconColor,
                  ),
                ),
              ],
            ),
          ],
        ),
        const Divider(color: Color(0xFFe1e8e6),),
        const SizedBox(height: 10,),
      ],
    );
    // return ListView(
    //   children: [
    //       for (int i = 0;
    //       i < (showAllTransactions ? transactionsList.length : 5);
    //       i++)
    //         ListTile(
    //           leading: FaIcon(transactionsList[i]['icon']),
    //           title: Text(transactionsList[i]['day']),
    //           subtitle: Text(transactionsList[i]['subAmount']),
    //         ),
    //   ],
    // );
  }

  Widget _buildCardDetailsLoadingView(){
    return const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
      ),
    );
  }

  Widget _buildCardDetailsSuccessView(){
    String? cardBalance = cardDetails[UserCardDetails.cardBalance];
    String? cardNumber = cardDetails[UserCardDetails.cardNumber];
    String? cardCvv = cardDetails[UserCardDetails.cardCvv];
    String? networkType = cardDetails[UserCardDetails.networkType];

    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 16, 18, 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Current balance",
                style: TextStyle(
                  fontFamily: 'primaryFont',
                  fontSize: 16,
                  color: Colors.white54,
                ),
              ),
              Text(
                "\u20B9 $cardBalance",
                style: const TextStyle(
                  fontFamily: 'primaryFont',
                  fontSize: 26,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    maskCardNumber(cardNumber!),
                    style: const TextStyle(
                      fontFamily: 'primaryFont',
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            showCvvNotifier.value ? "CVV: $cardCvv " : "CVV: *** ",
                            style: const TextStyle(
                              fontFamily: 'primaryFont',
                              fontSize: 14,
                              color: Colors.white,
                            ),
                          ),
                          GestureDetector(
                            onTap: (){
                              showCvvNotifier.value = !showCvvNotifier.value;
                            },
                            child: Icon(
                              showCvvNotifier.value ? Icons.remove_red_eye : Icons.remove_red_eye_outlined,
                              size: 14,
                              color: Colors.white,
                            ),
                          ),

                        ],
                      ),
                      const SizedBox(width: 10,),
                      Text(
                        formatExpiryDate(expiryDate),
                        style: const TextStyle(
                          fontFamily: 'primaryFont',
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                margin: const EdgeInsets.only(right: 15),
                width: 90,
                height: 25,
                child: Image.asset(
                  'assets/images/$networkType.png',
                  fit: BoxFit.cover,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCardDetailsFailureView(){
    return Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Something went wrong. Retry  ",
              style: TextStyle(
                fontFamily: 'primaryFont',
                fontSize: 14,
                color: Colors.white,
              ),
            ),
            GestureDetector(
              onTap: (){
                null;
              },
              child: const Icon(
                Icons.refresh_outlined,
                size: 18,
                color: Colors.white,
              ),
            ),
          ],
        )
    );
  }

  Widget _buildCardDetailsContent(){
    switch (cardDetailsApiStatus){
      case ApiStatus.inProgress:
        return _buildCardDetailsLoadingView();
      case ApiStatus.success:
        return _buildCardDetailsSuccessView();
      case ApiStatus.failure:
        return _buildCardDetailsFailureView();
      default:
        return Container();
    }
  }

  Widget _buildUnbilledTransactionsLoadingView(){
    return const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFe96341)),
      ),
    );
  }

  Widget _buildUnbilledTransactionsSuccessView(){
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(25),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "Transactions",
                      style: TextStyle(
                        fontFamily: 'primaryFont',
                        fontSize: 18,
                        color: Colors.black87,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "show all",
                          style: TextStyle(
                            fontFamily: 'primaryFont',
                            fontSize: 12,
                            color: Colors.black54,
                          ),
                        ),
                        Icon(
                          Icons.keyboard_arrow_right,
                          size: 25,
                          color: Colors.black54,
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20,),
                Column(
                  children: unbilledTransactionsList.map((eachUnbilledTransaction) {
                    return _buildTransactionRow(
                        eachUnbilledTransaction['transactionType'],
                        eachUnbilledTransaction['description'],
                        eachUnbilledTransaction['transactionDate'],
                        eachUnbilledTransaction['amount']
                    );
                  }).toList(),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildUnbilledTransactionsFailureView(){
    return Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Something went wrong. Retry ",
              style: TextStyle(
                fontFamily: 'primaryFont',
                fontSize: 16,
                color: Color(0xFFe96341),
              ),
            ),
            GestureDetector(
              onTap: (){
                null;
              },
              child: const Icon(
                Icons.refresh_outlined,
                size: 20,
                color: Color(0xFFe96341),
              ),
            ),
          ],
        )
    );
  }

  Widget _buildUnbilledTransactionsContent(){
    switch (unbilledTransactionsApiStatus){
      case ApiStatus.inProgress:
        return _buildUnbilledTransactionsLoadingView();
      case ApiStatus.success:
        return _buildUnbilledTransactionsSuccessView();
      case ApiStatus.failure:
        return _buildUnbilledTransactionsFailureView();
      default:
        return Container();
    }
  }

  void userAuthentication() async {
    String? token = await UserAuthentication.isLoggedIn(context);
    setState(() {
      cardDetailsApiStatus = ApiStatus.inProgress;
      unbilledTransactionsApiStatus = ApiStatus.inProgress;
    });

    await _getCardDetailsData(token);
    await _getCardBalanceData(token);
    await _getCvvData(token);
    await _getUnbilledTransactionsData(token);
  }

  @override
  initState(){
    super.initState();
    userAuthentication();

    // transactionsList = List.generate(
    //   10,
    //       (index) => {
    //     "icon": FontAwesomeIcons.circlePlus,
    //     "iconColor": Colors.green,
    //     "day": "Today. 10:21 AM",
    //     "subAmount": "+ \u20B9 ${47.25 + index}",
    //   },
    // );
  }

  @override
  Widget build(BuildContext context) {
    String? userName = cardDetails[UserCardDetails.userName];

    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              height: 60,
              width: double.infinity,
              color: const Color(0xFF404d6b),
              padding: const EdgeInsets.only(top: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(width: 15,),
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          color: const Color(0xFF2d364b),
                        ),
                        child: const Icon(
                          Icons.person,
                          size: 25,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 10,),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            userName != null && userName.isNotEmpty ? userName : "***",
                            style: const TextStyle(
                              fontFamily: 'primaryFont',
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                          const Text(
                            "Welcome back",
                            style: TextStyle(
                              fontFamily: 'primaryFont',
                              fontSize: 12,
                              color: Colors.white38,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.alarm,
                        size: 18,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 18,),
                      GestureDetector(
                        onTap: (){
                          // Navigator.pushReplacement(
                          //     context,
                          //     MaterialPageRoute(builder: (context) => CardControlsPage()));
                        },
                        child: const Icon(
                          Icons.settings,
                          size: 18,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 15,),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              height: 250,
              width: double.infinity,
              child: Stack(
                children: [
                  Positioned(
                      top: 0,
                      right: 0,
                      left: 0,
                      height: 125,
                      child: Container(
                        color: const Color(0xFF404d6b),
                      )
                  ),
                  Positioned(
                      bottom: 0,
                      right: 0,
                      left: 0,
                      height: 125,
                      child: Container(
                        color: Colors.white,
                      )
                  ),
                  Positioned(
                    top: 30,
                    right: 0,
                    left: 0,
                    child: Container(
                      height: 200,
                      margin: const EdgeInsets.only(left: 20,right: 20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        color: const Color(0xFFe96341),
                      ),
                      child: _buildCardDetailsContent(),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _buildUnbilledTransactionsContent(),
            ),
          ],
        ),
      ),
    );
  }
}
