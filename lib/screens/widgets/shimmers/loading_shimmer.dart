import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class LoadingShimmer extends StatelessWidget {
  final int? itemCount;
  final bool hideCircle;
  const LoadingShimmer({Key? key, this.itemCount, this.hideCircle = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Theme.of(context).dialogBackgroundColor,
      highlightColor: Theme.of(context).colorScheme.secondaryVariant,
      child: ListView.builder(
        itemCount: itemCount ?? 3,
        shrinkWrap: true,
        itemBuilder: (_, __) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              if (!hideCircle)
                Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: CircleAvatar(
                    radius: 40,
                    backgroundColor: Theme.of(context).colorScheme.surface,
                  ),
                ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 150,
                    height: 16.0,
                    color: Theme.of(context).colorScheme.surface,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 3.0),
                    child: Container(
                      width: 80,
                      height: 10.0,
                      color: Theme.of(context).colorScheme.surface,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Container(
                width: 60,
                height: 24.0,
                color: Theme.of(context).colorScheme.surface,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SingleShimmer extends StatelessWidget {
  const SingleShimmer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Shimmer.fromColors(
        baseColor: Theme.of(context).dialogBackgroundColor,
        highlightColor: Theme.of(context).colorScheme.secondaryVariant,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: CircleAvatar(
                radius: 40,
                backgroundColor: Theme.of(context).colorScheme.surface,
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 150,
                  height: 16.0,
                  color: Colors.white,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 3.0),
                  child: Container(
                    width: 80,
                    height: 10.0,
                    color: Theme.of(context).colorScheme.surface,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Container(
              width: 60,
              height: 24.0,
              color: Theme.of(context).colorScheme.surface,
            ),
          ],
        ),
      ),
    );
  }
}
