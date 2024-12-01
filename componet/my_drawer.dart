import 'package:chatapp/componet/my_emoji.dart';
import 'package:chatapp/services/auth/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:chatapp/pages/setting_page.dart';
import 'package:chatapp/pages/profile_page.dart'; // Import the ProfilePage

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  void logout() async {
    // get auth service
    final auth = AuthService();
    auth.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Theme.of(context).colorScheme.surface,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                // logo
                DrawerHeader(
                  child: Center(
                    child: Icon(
                      Icons.message,
                      color: Theme.of(context).colorScheme.primary,
                      size: 80,
                    ),
                  ),
                ),

                // profile list tile
                Padding(
                  padding: const EdgeInsets.only(left: 25),
                  child: ListTile(
                    leading: Icon(Icons.person, color: Theme.of(context).colorScheme.primary,),
                    title: Text('PROFILE', style: TextStyle(color: Theme.of(context).colorScheme.primary,),),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfilePage()));
                    },
                  ),
                ),

                // home list tile
                Padding(
                  padding: const EdgeInsets.only(left: 25),
                  child: ListTile(
                    leading: Icon(Icons.home, color: Theme.of(context).colorScheme.primary,),
                    title: Text('HOME', style: TextStyle(color: Theme.of(context).colorScheme.primary,),),
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                ),

                // settings list tile
                Padding(
                  padding: const EdgeInsets.only(left: 25),
                  child: ListTile(
                    leading: Icon(Icons.settings, color: Theme.of(context).colorScheme.primary,),
                    title: Text('SETTINGS', style: TextStyle(color: Theme.of(context).colorScheme.primary,),),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingPage()));
                    },
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.only(left: 25),
                  child: ListTile(
                    leading: Icon(Icons.picture_in_picture, color: Theme.of(context).colorScheme.primary,),
                    title: Text('EMOJI', style: TextStyle(color: Theme.of(context).colorScheme.primary,),),
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => MyEmoji(onImageSelected: (p0) => null ,)));
                    },
                  ),
                ),
              ],
            ),
          ),

          // logout list tile
          Padding(
            padding: const EdgeInsets.only(left: 25, bottom: 26),
            child: ListTile(
              leading: Icon(Icons.logout, color: Theme.of(context).colorScheme.primary,),
              title: Text('LOGOUT', style: TextStyle(color: Theme.of(context).colorScheme.primary,),),
              onTap: logout,
            ),
          ),
        ],
      ),
    );
  }
}
