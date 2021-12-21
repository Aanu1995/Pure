import 'package:flutter/material.dart';

class PostVisibility extends StatefulWidget {
  final int visibilityStatus;
  final ValueChanged<int> onPostVisibilityChanged;
  const PostVisibility({
    Key? key,
    required this.visibilityStatus,
    required this.onPostVisibilityChanged,
  }) : super(key: key);

  @override
  _PostVisibilityState createState() => _PostVisibilityState();
}

class _PostVisibilityState extends State<PostVisibility> {
  int visibilityStatus = 0;
  final postVisibilityIcons = const [Icons.public, Icons.people_alt];
  final postVisibilityText = const ["Anyone", "Connections only"];

  final _style = const TextStyle(fontSize: 20.0, fontWeight: FontWeight.w500);

  @override
  void initState() {
    super.initState();
    visibilityStatus = widget.visibilityStatus;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0),
      child: TextButton(
        onPressed: () async {
          final result = await onVisibilityTapped();
          if (result != null) {
            widget.onPostVisibilityChanged.call(result);
            setState(() => visibilityStatus = result);
          }
        },
        child: FittedBox(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(postVisibilityIcons[visibilityStatus], size: 18),
              const SizedBox(width: 8.0),
              Text(
                postVisibilityText[visibilityStatus],
                style: _style.copyWith(
                  fontSize: 16.0,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<int?> onVisibilityTapped() async {
    return await showModalBottomSheet<int?>(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return ConstrainedBox(
          constraints: BoxConstraints.tightFor(height: 300),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    height: 6.0,
                    width: 40.0,
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 26.0),
                Text(
                  "Who can see your post?",
                  style: _style.copyWith(
                    fontSize: 20.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8.0),
                Text(
                  "Your post will be visible on the feed, on your profile, and in search results",
                  style: _style.copyWith(fontSize: 13.0),
                ),
                const SizedBox(height: 16.0),
                _PostItem(
                  leading: Icons.public,
                  title: postVisibilityText[0],
                  subtitle: "Anyone on or off Pure",
                  onTap: () => Navigator.of(context).pop(0),
                ),
                _PostItem(
                  leading: Icons.people,
                  title: postVisibilityText[1],
                  subtitle: "Connections on Pure",
                  onTap: () => Navigator.of(context).pop(1),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _PostItem extends StatelessWidget {
  final IconData leading;
  final String title;
  final String subtitle;
  final Function()? onTap;

  const _PostItem({
    Key? key,
    required this.leading,
    required this.title,
    required this.subtitle,
    required this.onTap,
  }) : super(key: key);

  final _style = const TextStyle(fontSize: 17.0, fontWeight: FontWeight.w500);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(leading),
      horizontalTitleGap: 0.0,
      contentPadding: EdgeInsets.all(0.0),
      minVerticalPadding: 0.0,
      dense: true,
      title: Text(title, style: _style),
      subtitle: Text(
        subtitle,
        style: _style.copyWith(fontSize: 12),
      ),
      onTap: onTap,
    );
  }
}
