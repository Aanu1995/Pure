import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../blocs/bloc.dart';
import '../../../../../../model/pure_user_model.dart';
import 'tabs/received_screen.dart';
import 'tabs/sent_screen.dart';

class InvitationScreen extends StatefulWidget {
  const InvitationScreen({Key? key}) : super(key: key);

  @override
  State<InvitationScreen> createState() => _InvitationScreenState();
}

class _InvitationScreenState extends State<InvitationScreen>
    with SingleTickerProviderStateMixin {
  late TabController _controller;
  int? currentValue = 0;

  TextStyle _style = const TextStyle(fontSize: 16.0);

  @override
  void initState() {
    super.initState();
    final currentUserId = CurrentUser.currentUserId;
    context.read<ReceivedInvitationCubit>().loadInviters(currentUserId);
    context.read<SentInvitationCubit>().loadInvitees(currentUserId);
    _controller = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size(double.maxFinite, 60.0),
        child: SafeArea(
          child: Row(
            children: [
              IconButton(
                onPressed: () {
                  FocusScope.of(context).unfocus();
                  Navigator.of(context).pop();
                },
                icon: Icon(Icons.west, color: Colors.grey.shade700),
              ),
              const SizedBox(width: 20.0),
              Expanded(
                child: ConstrainedBox(
                  constraints: BoxConstraints.expand(),
                  child: BlocBuilder<AuthCubit, AuthState>(
                    buildWhen: (prev, current) =>
                        (prev is Authenticated && current is Authenticated) &&
                        (prev.user.sentCounter != current.user.sentCounter ||
                            prev.user.receivedCounter !=
                                current.user.receivedCounter),
                    builder: (context, state) {
                      if (state is Authenticated) {
                        return CupertinoSegmentedControl<int>(
                          groupValue: _controller.index,
                          unselectedColor:
                              Theme.of(context).colorScheme.surface,
                          children: <int, Widget>{
                            0: Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8.0),
                              child: Text(
                                'Received (${state.user.receivedCounter})',
                                style: _style,
                              ),
                            ),
                            1: Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8.0),
                              child: Text(
                                'Sent (${state.user.sentCounter})',
                                style: _style,
                              ),
                            ),
                          },
                          onValueChanged: (newValue) {
                            setState(() {
                              FocusScope.of(context).unfocus();
                              _controller.animateTo(newValue);
                            });
                          },
                        );
                      }
                      return Offstage();
                    },
                  ),
                ),
              ),
              const SizedBox(width: 30.0),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          Divider(height: 1.2, thickness: 1.2),
          Expanded(
            child: TabBarView(
              controller: _controller,
              physics: NeverScrollableScrollPhysics(),
              children: [ReceivedScreen(), SentScreen()],
            ),
          )
        ],
      ),
    );
  }
}
