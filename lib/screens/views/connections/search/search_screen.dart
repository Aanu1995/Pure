import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../blocs/bloc.dart';
import '../../../../services/invitation_service.dart';
import '../../../../services/search_service.dart';
import 'search_all_connections.dart';
import 'widgets/search_small.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
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
              const SizedBox(width: 8.0),
              IconButton(
                onPressed: () {
                  FocusScope.of(context).unfocus();
                  Navigator.of(context).pop();
                },
                icon: Icon(Icons.west, color: Colors.grey.shade700),
              ),
              Expanded(
                child: CupertinoSearchTextField(
                  focusNode: _focusNode,
                  controller: _searchController,
                  autofocus: true,
                  prefixInsets:
                      const EdgeInsetsDirectional.fromSTEB(6, 0, 8, 4),
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w400,
                    color: Theme.of(context).colorScheme.primaryVariant,
                  ),
                  onChanged: search,
                  onSubmitted: (_) => seeAllConnectionResults(context),
                ),
              ),
              const SizedBox(width: 16.0),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          Divider(height: 1.2, thickness: 1.2),
          Expanded(
            child: SearchSmallConnection(
              onSearchAllResultTapped: () => seeAllConnectionResults(context),
            ),
          )
        ],
      ),
    );
  }

  void search(String query) {
    context.read<SearchConnBloc>().add(SearchConnTextChanged(text: query));
  }

  Future<void> seeAllConnectionResults(BuildContext context) async {
    final query = _searchController.text.trim();
    final navigator = Navigator.of(context);

    await navigator.push<bool>(MaterialPageRoute(builder: (context) {
      return MultiBlocProvider(
        providers: [
          BlocProvider(
            lazy: false,
            create: (_) =>
                SeeAllUsersCubit(SearchServiceImpl())..searchUsers(query),
          ),
          BlocProvider(create: (_) => LoadMoreUsersCubit(SearchServiceImpl())),
          BlocProvider(
            create: (_) => SendInvitationCubit(
              InvitationServiceImp(isPersistentEnabled: false),
            ),
          )
        ],
        child: SearchAllConnectionResults(title: query),
      );
    }));
    FocusScope.of(context).requestFocus(_focusNode);
  }
}
