import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../blocs/bloc.dart';
import '../../../../widgets/progress_indicator.dart';
import 'search_user_profile.dart';

class SearchSmallConnection extends StatelessWidget {
  final Function()? onSearchAllResultTapped;
  const SearchSmallConnection({Key? key, this.onSearchAllResultTapped})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16.0),
      child: SingleChildScrollView(
        child: BlocBuilder<SearchConnBloc, SearchConnectionState>(
          builder: (context, state) {
            if (state is SearchConnEmpty) return Offstage();

            if (state is SearchConnSuccess) {
              final users = state.users;
              return Column(
                children: [
                  // show user profile
                  ListView.builder(
                    padding:
                        EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0),
                    itemCount: users.length,
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      final user = users[index];
                      return ShortUserProfile(user: user);
                    },
                  ),
                  Divider(height: 0.0),
                  // See all results
                  TextButton(
                    onPressed: onSearchAllResultTapped,
                    child: Text(
                      "See all results",
                      style: const TextStyle(
                        fontSize: 16.5,
                        letterSpacing: 0.20,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  )
                ],
              );
            } else if (state is SearchConnFailure) {
              return Center(
                child: Text(
                  state.message,
                  style: const TextStyle(
                    fontSize: 15.0,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }

            return Center(child: CustomProgressIndicator(size: 20.0));
          },
        ),
      ),
    );
  }
}
