class Device {
  String id;
  final int platform;
  final bool active;
  final String userID;
  final String identifier;

  Device(this.platform, this.active, this.userID, this.identifier);
  Device.withId(this.id, this.platform, this.active, this.userID, this.identifier);

  Device.fromJSON(Map<String, dynamic> jsonMap) :
        id         = jsonMap['id'],
        active     = jsonMap['active'],
        platform   = jsonMap['platform'],
        identifier = jsonMap['identifier'],
        userID     = jsonMap['userid'];
  Map<String, dynamic> toJson() =>
      {
        'id': id,
        'platfom': platform,
        'active': active,
        'userid': userID,
        'identifier': identifier,
      };
}