// ignore_for_file: use_build_context_synchronously, unused_result, deprecated_member_use

import 'package:fineplay/presentation/view/PrifileEditView/profile_edit_view.dart';
import 'package:fineplay/presentation/view/account_info_view/account_info_view.dart';
import 'package:fineplay/presentation/view/home_view/favorite_user_view.dart';
import 'package:fineplay/presentation/view/home_view/finding_user_view.dart';
import 'package:fineplay/presentation/view/notice_view/notice_detail_view.dart';
import 'package:fineplay/presentation/view/notice_view/notice_list_view.dart';
import 'package:fineplay/presentation/view/notification_view/notification_view.dart';
import 'package:fineplay/presentation/view/team_view/allMatch_view.dart';
import 'package:fineplay/presentation/view/team_view/manage_request_view.dart';
import 'package:fineplay/presentation/view/team_view/searched_team_view.dart';
import 'package:fineplay/presentation/view/team_view/team_editing_view.dart';
import 'package:fineplay/presentation/view/team_view/team_making_view.dart';
import 'package:fineplay/presentation/view/team_view/team_memberlist_view.dart';
import 'package:fineplay/presentation/view/team_view/team_setting_view.dart';
import 'package:fineplay/presentation/view/team_view/teamserch_view.dart';
import 'package:fineplay/presentation/viewmodel/myteam_list_provider.dart';
import 'package:fineplay/services/team_info_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fineplay/presentation/view/home_view/main_home_view.dart';
import 'package:fineplay/presentation/view/mypage_view/mypage_view.dart';
import 'package:fineplay/presentation/view/team_view/team_view.dart';
import 'package:fineplay/presentation/view/team_view/myteam_view.dart';
import 'package:fineplay/presentation/view/sign_in_up_view/mainlogin_view.dart';
import 'package:fineplay/presentation/view/sign_in_up_view/sign_in_view.dart';
import 'package:fineplay/presentation/view/sign_in_up_view/findid_view.dart';
import 'package:fineplay/presentation/view/sign_in_up_view/idfound_view.dart';
import 'package:fineplay/presentation/view/sign_in_up_view/Pwre_view.dart';
import 'package:fineplay/presentation/view/sign_in_up_view/Sendemail_view.dart';
import 'package:fineplay/utils/navibar_view.dart';
import 'package:fineplay/presentation/view/setting_view/setting_view.dart';
import 'package:fineplay/presentation/view/mypage_view/statpage_view.dart';
import 'package:fineplay/presentation/view/team_view/game_result_view.dart';
import 'package:fineplay/presentation/view/team_view/match_detail_view.dart';
import 'package:tuple/tuple.dart' show Tuple3, Tuple4;
// SystemNavigator.pop()

/// 라우트 경로를 상수로 관리합니다.
class AppRoutes {
  static const String mainLogin = '/';
  static const String signIn = 'signin';
  static const String findId = 'findid';
  static const String idFound = 'idFound';
  static const String rePassword = 'repassword';
  static const String sendEmail = 'sendemail';
  static const String naviBar = '/navibar';
  static const String home = 'home';
  static const String mypage = 'mypage';
  static const String team = 'team';
  static const String myTeam = 'my_team';
}

class BackButtonHandler extends StatelessWidget {
  final Widget child;
  final bool block; // 필요할 때만 true
  const BackButtonHandler({super.key, required this.child, this.block = false});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !block,          // block=true면 pop을 내가 처리
      onPopInvoked: (didPop) {
        if (didPop || !block) return;
        // 필요시 여기서만 확인 모달 띄우기
      },
      child: child,
    );
  }
}


final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.mainLogin, // 초기 경로
    observers: [ routeObserver ],
    routes: [
      /// 메인 로그인 라우트
      GoRoute(
        path: AppRoutes.mainLogin,
        builder: (context, state) => const BackButtonHandler(
          child: mainlogin_view(),
        ),
        routes: [
          GoRoute(
            path: AppRoutes.signIn,
            builder: (context, state) => const BackButtonHandler(
              child: Signin_view(),
            ),
          ),
          GoRoute(
            path: AppRoutes.findId,
            builder: (context, state) => const BackButtonHandler(
              child: FindID_view(),
            ),
          ),
          GoRoute(
            path: AppRoutes.idFound,
            builder: (context, state) => const BackButtonHandler(
              child: Idfound_view(),
            ),
          ),
          GoRoute(
            path: AppRoutes.rePassword,
            builder: (context, state) => const BackButtonHandler(
              child: Pwre_view(),
            ),
          ),
          GoRoute(
            path: AppRoutes.sendEmail,
            builder: (context, state) => const BackButtonHandler(
              child: Sendemail_view(),
            ),
          ),
        ],
      ),

      /// 네비게이션 바 라우트
      // 기존 GoRoute(path: AppRoutes.naviBar, ...) 부분만 교체

      GoRoute(
        path: AppRoutes.naviBar,
        pageBuilder: (context, state) => const NoTransitionPage(
          child: _NavibarGuard(
            child: NaviBar(title: 'Navi'),
          ),
        ),
        routes: [
          GoRoute(
            path: AppRoutes.home,
            builder: (context, state) => const Main_home_view(),
          ),
          GoRoute(
            path: AppRoutes.mypage,
            builder: (context, state) => const Mypage_view(),
          ),
          GoRoute(
            path: AppRoutes.team,
            builder: (context, state) {
              return Consumer(builder: (context, ref, _) {
                ref.refresh(myTeamListProvider);
                return const Team_view();
              });
            },
          ),
        ],
      ),

      /// 추가 라우트
      GoRoute(
              path: "/setting",
              builder: (context, state) {
                return const SettingView();
              },
            ),
      GoRoute(
        path: "/accountinfo",
        builder: (context, state) {
          return const AccountInfoView();
        },
      ),
      GoRoute(
        path: "/noticelist",
        builder: (context, state) {
          return const NoticeListView();
        },
      ),
      GoRoute(
        path: "/noticedetail",
        builder: (context, state) {
          final extra = state.extra as Map<String, Object>?;

          return NoticeDetailView(
            id: (extra?['id'] as int?) ?? 0, // 기본값 "PAC"
            token: (extra?['token'] as String?) ?? "", // 기본값 0 (비회원)
          );
        },
      ),
      GoRoute(
        path: "/profileedit",
        builder: (context, state) {
          return const ProfileEditView();
        },
      ),

      GoRoute(
        path: "/notification",
        builder: (context, state) {
          return const Notification_view();
        },
      ),

      GoRoute(
        path: "/favorite",
        builder: (context, state) {
          return const Favorite_User_view();
        },
      ),

      GoRoute(
        path: "/findinguser",
        builder: (context, state) {
          return const Finding_User_view();
        },
      ),


      GoRoute(
        path: '/mypage/:id',
        name: 'mypage',
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return Mypage_view(userIdArg: id);
        },
      ),

      GoRoute(
        path: "/statpage",
        builder: (context, state) {
          final extra = state.extra as Map<String, Object>?;

          return Statpage_view(
            feature: (extra?['feature'] as String?) ?? "", // 기본값 "PAC"
            userId: (extra?['userId'] as int?) ?? 0, // 기본값 0 (비회원)
            userToken: (extra?['userToken'] as String?) ?? "", // 기본 토큰 ""
          );
        },
      ),

      GoRoute(
        path: "/findingteam",
        builder: (context, state) {
          return const Teamsearch_view();
        },
      ),

      GoRoute(
        path: "/makingteam",
        builder: (context, state) {
          return const TeamMaking_view();
        },
      ),

      GoRoute(
        path: '/myteam/:teamId',
        name: 'myteam',
        builder: (context, state) {
          final teamId = int.parse(state.pathParameters['teamId']!);
          return MyTeam_view(teamId: teamId);
        },
      ),
      GoRoute(
        path: '/searchedteam/:teamId',
        name:'searchedteam',
        builder: (context, state){
          final teamId = int.parse(state.pathParameters['teamId']!);
          return Searched_team_view(teamId: teamId);
        }
      ),
      GoRoute(
        path: '/teammemberlist/:teamId',
        name: 'teammemberlist',
        builder: (context, state) {
          final teamId = int.parse(state.pathParameters['teamId']!);
          return TeamMemberlistView(teamId: teamId);
        },
      ),
      GoRoute(
        path: '/teamsetting/:teamId',
        name: 'teamsetting',
        builder: (context, state) {
          final teamId = int.parse(state.pathParameters['teamId']!);
          return TeamSettingView(teamId: teamId);
        },
      ),

      GoRoute(
        path: '/managerequest/:teamId',
        name: 'managerequest',
        builder: (context, state) {
          final teamId = int.parse(state.pathParameters['teamId']!);
          return ManageRequestView(teamId: teamId);
        },
      ),

      GoRoute(
        path: '/teamediting/:teamId',
        name: 'teamediting',
        builder: (context, state) {
          final teamId = int.parse(state.pathParameters['teamId']!);
          return TeamEditing_view(teamId: teamId);
        },
      ),

      GoRoute(
          path: '/allmatchview/:teamId/:userId',
          name:'allmatchview',
          builder: (context, state){
            final TeamInfo? teamFromExtra =
            state.extra is TeamInfo ? state.extra as TeamInfo : null; // ✅ 안전
            final userToken = state.uri.queryParameters['userToken']!;
            final teamId = int.parse(state.pathParameters['teamId']!);
            final userId = int.parse(state.pathParameters['userId']!);

            return _AllMatchEntry(
              teamId: teamId,
              userId: userId,
              userToken: userToken,
              teamFromExtra: teamFromExtra,
            );
          }
      ),

      GoRoute(
        path: "/game_result/:token/:userId/:teamId/:gameNum",
        name: "gameresult",
        builder: (context, state) {
          // 1) 기본은 path params
          String? token   = state.pathParameters['token'];
          String? userIdS = state.pathParameters['userId'];
          String? teamIdS = state.pathParameters['teamId'];
          String? gameS   = state.pathParameters['gameNum'];

          // 2) 만약 히스토리에 /game_result 로 남아 돌아왔거나(비상 케이스),
          //    query로만 온 경우를 대비한 보강
          token   ??= state.uri.queryParameters['userToken'];
          userIdS ??= state.uri.queryParameters['userId'];
          teamIdS ??= state.uri.queryParameters['teamId'];
          gameS   ??= state.uri.queryParameters['gameNum'];

          // 3) 마지막 보루: 누군가 extra로만 보냈다면(extra는 웹에서 뒤로가기로 복원 X)
          final ex = state.extra;
          if ((token == null || userIdS == null || teamIdS == null || gameS == null) && ex is Tuple4<String,int,int,int>) {
            token   ??= ex.item1;
            userIdS ??= ex.item2.toString();
            teamIdS ??= ex.item3.toString();
            gameS   ??= ex.item4.toString();
          }

          // 4) 여전히 부족하면 에러 처리(404 대용)
          if (token == null || userIdS == null || teamIdS == null || gameS == null) {
            return const Center(child: Text('Invalid game_result route'));
          }

          final userId  = int.tryParse(userIdS)!;
          final teamId  = int.tryParse(teamIdS)!;
          final gameNum = int.tryParse(gameS)!;

          return Game_result_view(
            userToken: token,
            userId:    userId,
            teamId:    teamId,
            game_num:  gameNum,
          );
        },
      ),


      GoRoute(
     path: "/match_detail/:token/:teamId/:matchId",
     builder: (context, state) {
       final token   = state.pathParameters['token']!;
       final teamId  = int.parse(state.pathParameters['teamId']!);
       final matchId = int.parse(state.pathParameters['matchId']!);
       return Match_detail_view(
         userToken: token,
         teamId:    teamId,
         matchId:   matchId,
       );
     },
  ),
    ],
  );
});

class _AllMatchEntry extends ConsumerWidget {
  final int teamId;
  final int userId;
  final String userToken;
  final TeamInfo? teamFromExtra;

  const _AllMatchEntry({
    required this.teamId,
    required this.userId,
    required this.userToken,
    this.teamFromExtra,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // extra 있으면 그대로 사용
    if (teamFromExtra != null) {
      return AllMatchView(
        team: teamFromExtra!,
        userToken: userToken,
        teamId: teamId,
        userId: userId,
      );
    }

    // extra 없으면 provider로 로드 (뒤로가기/새로고침에서도 안전)
    final teamAsync = ref.watch(
      teamInfoProvider(Tuple3(userToken, userId, teamId)),
    );

    return teamAsync.when(
      data: (team) => AllMatchView(
        team: team,
        userToken: userToken,
        teamId: teamId,
        userId: userId,
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('팀 정보를 불러오지 못했습니다.\n$e')),
    );
  }


}

class _NavibarGuard extends StatelessWidget {
  final Widget child;
  const _NavibarGuard({required this.child});

  Future<bool?> _confirm(BuildContext context) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('로그아웃'),
        content: const Text('로그아웃하시겠습니까?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('아니오')),
          TextButton(onPressed: () => Navigator.pop(context, true),  child: const Text('예')),
        ],
      ),
    );
  }

  Future<void> _logoutAndGoRoot(BuildContext context) async {
    // TODO: 토큰/상태 정리 (너의 앱 로직에 맞게)
    // context.read(tokenProvider.notifier).state = '';
    // context.read(userIdProvider.notifier).state = null;

    if (context.mounted) {
      context.go('/'); // 메인 로그인으로 이동
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      // ✅ 여기서 브라우저 back(pop)을 '항상' 내가 처리
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return; // 이미 pop된 경우 무시

        // 🔸 /navibar에서 뒤로가기 → 원래는 '/'로 나가려는 타이밍
        //     => pop을 먹고, 모달을 띄운 뒤 사용자가 '예' 하면 직접 이동
        Future.microtask(() async {
          final ok = await _confirm(context);
          if (ok == true) {
            await _logoutAndGoRoot(context);
          }
          // '아니오'면 아무 것도 하지 않음 → 현재 /navibar 유지
        });
      },
      child: child,
    );
  }
}

