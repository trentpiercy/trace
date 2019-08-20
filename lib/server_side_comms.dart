import 'package:encrypt/encrypt.dart';

void encryptString(String stringToEncrypt) {
  final key = Key.fromUtf8('~ZLQ+[>>sEH,ci))=M-H54q>pxNBh<C@');
  final iv = IV.fromLength(16);

  final encryptor = Encrypter(AES(key));

  final encrypted = encryptor.encrypt(stringToEncrypt, iv: iv);
  final decrypted = encryptor.decrypt(encrypted, iv: iv);

  print(decrypted); // Lorem ipsum dolor sit amet, consectetur adipiscing elit
  print(encrypted.base64); // R4PxiU3h8YoIRqVowBXm36ZcCeNeZ4s1OvVBTfFlZRdmohQqOpPQqD1Ye cJeZMAop/hZ4OxqgC1WtwvX/hP9mw==
}