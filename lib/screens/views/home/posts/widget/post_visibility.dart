import 'package:flutter/material.dart';

class PostVisibility extends StatefulWidget {
  final int visibilityStatus;
  final ValueChanged<int> onPostVisibilityChanged;
  const PostVisibility(
      {Key? key,
      required this.visibilityStatus,
      required this.onPostVisibilityChanged})
      : super(key: key);

  @override
  _PostVisibilityState createState() => _PostVisibilityState();
}

class _PostVisibilityState extends State<PostVisibility> {
  int visibilityStatus = 0;
  List<IconData> postVisibilityIcons = [Icons.public, Icons.people_alt];
  List<String> postVisibilityText = ["Anyone", "Connections only"];

  final _style = const TextStyle(
    fontSize: 20.0,
    fontWeight: FontWeight.w500,
  );

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
                const SizedBox(height: 30.0),
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
                ListTile(
                  leading: Icon(Icons.public),
                  horizontalTitleGap: 0.0,
                  contentPadding: EdgeInsets.all(0.0),
                  dense: true,
                  title: Text("Anyone", style: _style.copyWith(fontSize: 17)),
                  subtitle: Text(
                    "Anyone on or off Pure",
                    style: _style.copyWith(fontSize: 12),
                  ),
                  onTap: () => Navigator.of(context).pop(0),
                ),
                ListTile(
                  leading: Icon(Icons.people),
                  horizontalTitleGap: 0.0,
                  contentPadding: EdgeInsets.all(0.0),
                  dense: true,
                  title: Text(
                    "Connections only",
                    style: _style.copyWith(fontSize: 17),
                  ),
                  subtitle: Text(
                    "Connections on Pure",
                    style: _style.copyWith(fontSize: 12),
                  ),
                  onTap: () => Navigator.of(context).pop(1),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
