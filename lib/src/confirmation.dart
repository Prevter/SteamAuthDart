library steam_auth;

class Confirmation {
  int id;
  int key;
  int intType;
  int creator;
  late ConfirmationType type;

  Confirmation(
      {required this.id,
      required this.key,
      required this.intType,
      required this.creator}) {
    switch (intType) {
      case 1:
        type = ConfirmationType.genericConfirmation;
        break;
      case 2:
        type = ConfirmationType.trade;
        break;
      case 3:
        type = ConfirmationType.marketSellTransaction;
        break;
      default:
        type = ConfirmationType.unknown;
    }
  }
}

enum ConfirmationType {
  genericConfirmation,
  trade,
  marketSellTransaction,
  unknown
}
