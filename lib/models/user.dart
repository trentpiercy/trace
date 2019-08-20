class User {
  String id;
  final int type;
  final String uid;
  final String email;
  final String nickname;

  User(this.type, this.uid, this.nickname, this.email);
  User.withId(this.id, this.type, this.uid, this.nickname, this.email);

  User.fromJSON(Map<String, dynamic> jsonMap) :
        id       = jsonMap['id'],
        uid      = jsonMap['uid'],
        type     = jsonMap['type'],
        email     = jsonMap['email'],
        nickname = jsonMap['nickname'];

  Map<String, dynamic> toJson() =>
      {
        'id': id,
        'uid': uid,
        'type': type,
        'email': email,
        'nickname': nickname,
      };
}