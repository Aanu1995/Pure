import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../blocs/bloc.dart';
import '../../../widgets/failure_widget.dart';
import '../../../widgets/progress_indicator.dart';

class LoadMoreInvitees extends StatelessWidget {
  final void Function()? onTap;
  const LoadMoreInvitees({Key? key, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: BlocBuilder<LoadMoreInviteeCubit, SentInvitationState>(
          builder: (context, state) {
            if (state is LoadingInvitees) {
              return SizedBox(
                  width: 20.0,
                  height: 20.0,
                  child: CustomProgressIndicator(size: 16.0));
            } else if (state is InviteeLoadingFailed) {
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

class LoadMoreInviters extends StatelessWidget {
  final void Function()? onTap;
  const LoadMoreInviters({Key? key, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: BlocBuilder<LoadMoreInviteeCubit, SentInvitationState>(
          builder: (context, state) {
            if (state is LoadingInvitees) {
              return SizedBox(
                  width: 20.0,
                  height: 20.0,
                  child: CustomProgressIndicator(size: 16.0));
            } else if (state is InviteeLoadingFailed) {
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

class LoadMoreConnectors extends StatelessWidget {
  final void Function()? onTap;
  const LoadMoreConnectors({Key? key, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: BlocBuilder<LoadMoreConnectorCubit, ConnectorState>(
          builder: (context, state) {
            if (state is LoadingConnections) {
              return SizedBox(
                  width: 20.0,
                  height: 20.0,
                  child: CustomProgressIndicator(size: 16.0));
            } else if (state is ConnectionFailed) {
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
