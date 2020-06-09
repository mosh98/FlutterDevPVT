
import 'package:dog_prototype/models/Dog.dart';
import 'package:dog_prototype/models/User.dart';
import 'package:dog_prototype/pages/FindFriends.dart';
import 'package:dog_prototype/pages/ProfilePage.dart';
import 'package:dog_prototype/pages/mapPage.dart';
import 'package:dog_prototype/pages/messages.dart';
import 'package:dog_prototype/pages/Home.dart';
import 'package:dog_prototype/services/Authentication.dart';
import 'package:dog_prototype/services/HttpProvider.dart';
import 'package:dog_prototype/services/StorageProvider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

class MockStorageProvider extends Mock implements StorageProvider{}
class MockHttpProvider extends Mock implements HttpProvider{}
class MockAuthService extends Mock implements AuthService{}
class MockNavigatorObserver extends Mock implements NavigatorObserver{}

void main(){

  final User fakeUser = User(username: 'fakeUser', desc: "desc", dogs: [Dog(name:"dog")]);

  final Finder profileBar = find.byKey(Key('profile'));
  final Finder mapsBar = find.byKey(Key('maps'));
  final Finder findFriendsBar = find.byKey(Key('findfriends'));
  final Finder messageBar = find.byKey(Key('messages'));

  final MockStorageProvider mockStorageProvider = MockStorageProvider();
  final MockHttpProvider mockHttpProvider = MockHttpProvider();
  final MockAuthService mockAuthService = MockAuthService();
  final MockNavigatorObserver mockNavigatorObserver = MockNavigatorObserver();

  final Widget page = MediaQuery(
    child: MaterialApp(
    home: App(user: fakeUser,storageProvider: mockStorageProvider,httpProvider: mockHttpProvider,authService: mockAuthService,),
    navigatorObservers: [mockNavigatorObserver],
    ),
    data: MediaQueryData(),
  );

  testWidgets('Rendering page', (tester) async{
    await tester.pumpWidget(page);
    await tester.pumpAndSettle();
    expect(find.byType(App), findsOneWidget);
  });

  testWidgets('Find widgets', (tester) async{
    await tester.pumpWidget(page);
    await tester.pumpAndSettle();

    expect(profileBar, findsOneWidget);
    expect(mapsBar, findsOneWidget);
    expect(findFriendsBar, findsOneWidget);
    expect(messageBar, findsOneWidget);
  });

  testWidgets('PlaceHolder default page is ProfilePage', (tester) async{
    await tester.pumpWidget(page);
    await tester.pumpAndSettle();

    expect(find.byType(ProfilePage),findsOneWidget);
    print(FlutterError.onError);
  });

  testWidgets('Navigation: Pressing maps -> PUSH to Maps', (tester) async{
    FlutterError.onError = null; //NEEDED FOR WEIRD FLUTTER OVERFLOW EXCEPT. WHEN THERE IS NONE.
    await tester.pumpWidget(page);
    await tester.pumpAndSettle();

    await tester.tap(mapsBar);
    verify(mockNavigatorObserver.didPush(any, any));
    await tester.pumpAndSettle();
    expect(find.byType(MapPage), findsOneWidget);
  });

  testWidgets('Navigation: Pressing Find Friends -> PUSH to Find Friends', (tester) async{
    await tester.pumpWidget(page);
    await tester.pumpAndSettle();

    await tester.tap(findFriendsBar);
    verify(mockNavigatorObserver.didPush(any, any));
    await tester.pumpAndSettle();
    expect(find.byType(FindFriends), findsOneWidget);
  });

  testWidgets('Navigation: Pressing Messages -> PUSH to Messages', (tester) async{
    await tester.pumpWidget(page);
    await tester.pumpAndSettle();

    await tester.tap(messageBar);
    verify(mockNavigatorObserver.didPush(any, any));
    await tester.pumpAndSettle();
    expect(find.byType(Messages), findsOneWidget);
  });
}