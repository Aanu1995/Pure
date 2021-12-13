import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../blocs/bloc.dart';
import '../../../../model/chat/chat_model.dart';
import '../../../../model/pure_user_model.dart';
import '../../../../services/chat/chat_service.dart';
import '../../../../services/search_service.dart';
import '../../../../utils/app_theme.dart';
import '../../../../utils/navigate.dart';
import '../../../widgets/snackbars.dart';
import 'add_participants_screen.dart';
import 'edit_group_description_screen.dart';
import 'edit_group_subject_screen.dart';
import 'widget/group_banner.dart';
import 'widget/participants.dart';

class GroupInfoScreen extends StatefulWidget {
  final ChatModel chat;
  final List<PureUser> participants;
  final ValueChanged<ChatModel> onChatChanged;
  const GroupInfoScreen({
    Key? key,
    required this.chat,
    required this.participants,
    required this.onChatChanged,
  }) : super(key: key);
  @override
  State<GroupInfoScreen> createState() => _GroupInfoScreenState();
}

class _GroupInfoScreenState extends State<GroupInfoScreen> {
  late ChatModel chat;

  final _style = const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.05,
  );

  @override
  void initState() {
    super.initState();
    chat = widget.chat;
    sortByAdmin();
  }

  // update as state in Bloc Listener updates
  void participantStateListener(BuildContext context, ParticipantState state) {
    if (state is RemovingParticipant) {
      setState(() => widget.participants.remove(state.participant));
    } else if (state is AddingAdmin) {
      final newChat = chat.copyWithForAdmin(state.memberId, true);
      widget.onChatChanged.call(newChat);
      setState(() => chat = newChat);
      sortByAdmin();
    } else if (state is RemovingAdmin) {
      final newChat = chat.copyWithForAdmin(state.memberId, false);
      widget.onChatChanged.call(newChat);
      setState(() => chat = newChat);
      sortByAdmin();
    } else if (state is FailedToRemoveParticipant) {
      widget.participants.insert(state.index, state.participant);
    } else if (state is ExitingGroup) {
      EasyLoading.show(status: 'Creating...');
    } else if (state is GroupExited) {
      EasyLoading.dismiss();
      context.read<ChatCubit>().removeChat(state.chatId);
      Navigator.of(context).popUntil((route) => route.isFirst);
    } else if (state is FailedToExitGroup) {
      EasyLoading.dismiss();
      showFailureFlash(context, state.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1.0,
        title: Text(
          chat.groupName!,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 17.5,
            fontFamily: Palette.sanFontFamily,
            color: Palette.tintColor,
            letterSpacing: 0.5,
          ),
        ),
      ),
      body: BlocListener<ParticipantCubit, ParticipantState>(
        listener: participantStateListener,
        child: BlocListener<GroupChatCubit, GroupChatState>(
          listenWhen: (pre, current) => current is GroupChatUpdated,
          listener: (context, state) {
            if (state is GroupChatUpdated) {
              widget.onChatChanged.call(state.chatModel);
              setState(() => chat = state.chatModel);
            }
          },
          child: NestedScrollView(
            headerSliverBuilder: (context, innerIsScrolled) {
              return <Widget>[
                SliverAppBar(
                  automaticallyImplyLeading: false,
                  expandedHeight: 1.sw * 0.5,
                  backgroundColor: Colors.black45,
                  flexibleSpace: GroupBanner(chat: chat),
                )
              ];
            },
            body: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Add group Name and Description
                    Column(
                      children: [
                        ListTile(
                          dense: true,
                          title: Text(
                            chat.groupName!,
                            style: _style.copyWith(fontWeight: FontWeight.bold),
                          ),
                          trailing: Icon(Icons.chevron_right),
                          onTap: () => editGroupSubject(),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 20.0),
                          child: Divider(height: 0.0),
                        ),
                        ListTile(
                          dense: true,
                          title: Text(
                            chat.groupDescription!.isEmpty
                                ? "Add group description"
                                : chat.groupDescription!,
                            style: _style.copyWith(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: Theme.of(context)
                                  .colorScheme
                                  .secondaryVariant,
                            ),
                          ),
                          trailing: Icon(Icons.chevron_right),
                          onTap: () => editGroupDescription(),
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),
                    // Participants
                    Participants(
                      chat: widget.chat,
                      participants: widget.participants,
                      onAddNewParticipantstapped: () => addParticipant(context),
                    ),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Divider(height: 0.0),
                          ListTile(
                            dense: true,
                            contentPadding: EdgeInsets.all(0.0),
                            onTap: () => exitGroup(),
                            title: Text(
                              "Exit Group",
                              style: _style.copyWith(
                                fontSize: 17.0,
                                fontWeight: FontWeight.w500,
                                color: Colors.red,
                              ),
                            ),
                          ),
                          Divider(height: 0.0),
                          const SizedBox(height: 8.0),
                          Text(
                            "Created ${chat.chatCreatedDate()}",
                            style: _style.copyWith(
                              fontSize: 13.0,
                              fontWeight: FontWeight.w400,
                              color: Theme.of(context)
                                  .colorScheme
                                  .secondaryVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 50.0),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> editGroupSubject() async {
    push(
      context: context,
      page: BlocProvider.value(
        value: context.read<GroupChatCubit>(),
        child: EditGroupSubject(chat: chat),
      ),
    );
  }

  Future<void> editGroupDescription() async {
    push(
      context: context,
      page: BlocProvider.value(
        value: context.read<GroupChatCubit>(),
        child: EditGroupDescription(chat: chat),
      ),
    );
  }

  void addParticipant(BuildContext context) {
    Navigator.of(context).push<void>(
      MaterialPageRoute(builder: (context) {
        return MultiBlocProvider(
          providers: [
            BlocProvider(create: (_) => AddParticipantCubit(ChatServiceImp())),
            BlocProvider(create: (_) => SearchFriendBloc(SearchServiceImpl())),
            BlocProvider(create: (_) => ParticipantCubit(ChatServiceImp())),
          ],
          child: AddNewParticipant(
            chat: chat,
            groupMembers:
                widget.participants.toList().map((e) => e.id).toList(),
            onNewParticipantsAdded: (newMembers) {
              setState(() {
                widget.participants.addAll(newMembers);
                widget.participants
                    .sort((a, b) => a.fullName.compareTo(b.fullName));
              });
            },
          ),
        );
      }),
    );
  }

  Future<void> exitGroup() async {
    final result = await showOkCancelAlertDialog(
      context: context,
      title: 'Exit Group',
      message: "Are you sure you want to exit this group?",
      okLabel: "Exit",
      isDestructiveAction: true,
    );

    if (result == OkCancelResult.ok) {
      final userId = CurrentUser.currentUserId;
      context.read<ParticipantCubit>().exitGroup(chat.chatId, userId);
    }
  }

  // sort by admin
  void sortByAdmin() {
    widget.participants.sort((a, b) => a.fullName.compareTo(b.fullName));
    List<PureUser> admins = [];
    for (final user in widget.participants) {
      if (chat.isAdmin(user.id)) admins.add(user);
    }
    widget.participants.removeWhere((element) => admins.contains(element));
    widget.participants.insertAll(0, admins);
    final user = widget.participants
        .firstWhere((element) => element.id == CurrentUser.currentUserId);
    widget.participants.remove(user);
    widget.participants.insert(0, user);
  }
}
