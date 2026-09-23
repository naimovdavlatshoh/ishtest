import 'package:url_launcher/url_launcher.dart';

Future<void> openStoreListing(String url) async {
  final Uri? uri = Uri.tryParse(url);
  if (uri == null || !uri.hasScheme) return;
  await launchUrl(uri, mode: LaunchMode.externalApplication);
}
