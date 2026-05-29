import 'package:flutter/material.dart';

class SettingsScreen
    extends StatefulWidget {

  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState()
      => _SettingsScreenState();
}

class _SettingsScreenState
    extends State<SettingsScreen> {

  bool darkMode = false;

  final TextEditingController
      vaultController =
          TextEditingController();

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Settings"),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(

          children: [

            TextField(
              controller: vaultController,

              decoration:
                  const InputDecoration(
                labelText: "Vault Path",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            SwitchListTile(
              title: const Text(
                  "Dark Mode"),

              value: darkMode,

              onChanged: (value) {

                setState(() {
                  darkMode = value;
                });
              },
            ),

            const SizedBox(height: 20),

            DropdownButtonFormField(

              items: const [

                DropdownMenuItem(
                  value: "llama3",
                  child: Text("Llama 3"),
                ),

                DropdownMenuItem(
                  value: "mixtral",
                  child: Text("Mixtral"),
                ),
              ],

              onChanged: (value) {},
            ),
          ],
        ),
      ),
    );
  }
}