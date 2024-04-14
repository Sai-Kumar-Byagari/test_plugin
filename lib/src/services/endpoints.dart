enum Endpoint {
  verifyMpin,
  getCardDetails,
  getCardBalance,
  getCvv,
  getUnbilledTransactions
}

extension EndpointExtension on Endpoint{
  String get value{
    switch (this){
      case Endpoint.verifyMpin:
        return '/user/verify/mpin';
      case Endpoint.getCardDetails:
        return '/card/get/details';
      case Endpoint.getCardBalance:
        return '/card/get/balance';
      case Endpoint.getCvv:
        return '/card/get/cvv';
      case Endpoint.getUnbilledTransactions:
        return '/card/get/unbilled/transactions';
    }
  }
}