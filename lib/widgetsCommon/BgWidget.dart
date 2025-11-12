import 'package:ezzybill/consts/consts.dart';

Widget BgWidget({Widget? child}) {
  return Container(
    decoration: BoxDecoration(
        image: DecorationImage(
      image: AssetImage(imgBackground),
      fit: BoxFit.cover,
    )),
    child: child,
  );
}
