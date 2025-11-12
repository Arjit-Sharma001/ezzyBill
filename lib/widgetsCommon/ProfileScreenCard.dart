import 'package:ezzybill/consts/consts.dart';

Widget ProfilescreenCard(
    {required String? icon, required String? title, String? description}) {
  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 10),
    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
    decoration: BoxDecoration(
      color: secondaryColor2,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.black26,
          blurRadius: 6,
          spreadRadius: 1,
          offset: Offset(2, 3),
        ),
      ],
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ClipOval(
          child: Container(
            color: Colors.white,
            padding: const EdgeInsets.all(8),
            child: Image.asset(
              icon!,
              width: 48,
              height: 48,
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title!,
                style: TextStyle(
                  fontFamily: semibold,
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description ?? '',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ),
        Icon(Icons.arrow_forward_ios_rounded, size: 20, color: Colors.black),
      ],
    ),
  );
}
