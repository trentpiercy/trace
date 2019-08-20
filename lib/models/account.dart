class Account {
  String id;
  final int blockchain;
  final int accountType;
  final String symbol;
  final String address;
  final String userID;
  final String nickname;

  Account(this.blockchain, this.accountType, this.symbol, this.address, this.nickname,  this.userID);
  Account.withId(this.id, this.blockchain, this.accountType, this.symbol, this.address, this.nickname,  this.userID);

  Account.fromJSON(Map<String, dynamic> jsonMap) :
        id          = jsonMap['id'],
        blockchain  = jsonMap['blockchain'],
        accountType = jsonMap['account_type'],
        symbol      = jsonMap['symbol'],
        address     = jsonMap['address'],
        userID      = jsonMap['userid'],
        nickname    = jsonMap['nickname'];

  Map<String, dynamic> toJson() =>
      {
        'id': id,
        'account_type': accountType,
        'address': address,
        'blockchain': blockchain,
        'symbol': symbol,
        'userid': userID,
        'nickname': nickname,
      };
}