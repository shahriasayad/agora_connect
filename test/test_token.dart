import 'package:agora_token_service/agora_token_service.dart';

void main() {
  final t = RtcTokenBuilder.build(
    appId: "123",
    appCertificate: "456",
    channelName: "test",
    uid: "0",
    role: RtcRole.publisher,
    expireTimestamp: 1234567,
  );
  print(t);
}
