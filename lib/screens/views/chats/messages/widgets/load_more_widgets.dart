import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../blocs/bloc.dart';
import '../../../../widgets/failure_widget.dart';
import '../../../../widgets/progress_indicator.dart';

class LoadMoreMessagesWidget extends StatelessWidget {
  final void Function()? onTap;
  const LoadMoreMessagesWidget({Key? key, required this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: BlocBuilder<LoadMoreMessageCubit, MessageState>(
          builder: (context, state) {
            if (state is LoadingMessages) {
              return SizedBox(
                  width: 20.0,
                  height: 20.0,
                  child: CustomProgressIndicator(size: 16.0));
            } else if (state is MessagesFailed) {
              return LoadMoreErrorWidget(
                onTap: onTap,
                message: "Failed to load more",
              );
            }
            return Offstage();
          },
        ),
      ),
    );
  }
}
