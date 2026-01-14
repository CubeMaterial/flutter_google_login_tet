import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';


Future<void> signOutGoogle() async {
  await GoogleSignIn().signOut();
  await FirebaseAuth.instance.signOut();
}
class Home extends StatelessWidget {
   const Home({super.key});

  Future<void> _signIn() async {
    final googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) return; // 취소

    final googleAuth = await googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    await FirebaseAuth.instance.signInWithCredential(credential);
  }

  Future<void> _signOut() async {
    await GoogleSignIn().signOut();
    await FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snap) {
        final user = snap.data;

        // 로그인 전
        if (user == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('로그인')),
            body: Center(
              child: ElevatedButton(
                onPressed: _signIn,
                child: const Text('Google로 로그인'),
              ),
            ),
          );
        }

        // 로그인 후(상태 유지됨)
        return Scaffold(
          appBar: AppBar(
            title: const Text('내 계정'),
            actions: [
              TextButton(
                onPressed: _signOut,
                child: const Text('로그아웃', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('이름: ${user.displayName ?? ""}', style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 8),
                Text('이메일: ${user.email ?? ""}', style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 16),
                Text('UID: ${user.uid}'),
              ],
            ),
          ),
        );
      },
    );
  }
}