import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chatgpt_tutorial_yt/models/consts.dart';
import 'package:flutter_chatgpt_tutorial_yt/utils/colors.dart';
import 'package:gap/gap.dart';

class ChatPage extends StatefulWidget {
  ChatPage({
    super.key,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _openAI = OpenAI.instance.build(
    token: OPENAI_API_KEY,
    baseOption: HttpSetup(
      receiveTimeout: const Duration(
        seconds: 5,
      ),
    ),
    enableLog: true,
  );

  final ChatUser _currentUser =
      ChatUser(id: '1', firstName: 'Zakariye', lastName: 'Hassan');

  final ChatUser _gptChatUser =
      ChatUser(id: '2', firstName: 'Ila', lastName: 'Hadal');

  List<ChatMessage> _messages = <ChatMessage>[];
  List<ChatUser> _typingUsers = <ChatUser>[];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 18),
            child: Icon(
              Icons.edit_outlined,
              size: 24,
              color: Colors.black,
            ),
          ),
        ],
        leading: Builder(
          builder: (context) => IconButton(
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
            icon: const Icon(
              Icons.short_text_outlined,
              size: 28,
              color: Colors.black,
            ),
          ),
        ),
        elevation: 1,
        backgroundColor: scaffoldBackgroundColor,
        title: const Text(
          'ila hadal',
          style: TextStyle(
            color: Colors.black,
          ),
        ),
      ),
      backgroundColor: cardColor,
      body: DashChat(
          currentUser: _currentUser,
          typingUsers: _typingUsers,
          messageOptions: const MessageOptions(
            currentUserContainerColor: Color.fromRGBO(0, 166, 126, 1),
            containerColor: Color.fromRGBO(
              0,
              166,
              126,
              1,
            ),
            textColor: Colors.white,
          ),
          onSend: (ChatMessage m) {
            getChatResponse(m);
          },
          messages: _messages),
      // drawer: Drawer(
      //   elevation: 0,
      //   shape: const RoundedRectangleBorder(
      //       borderRadius: BorderRadius.horizontal(right: Radius.circular(0))),
      //   child: Container(
      //     decoration: const BoxDecoration(
      //         borderRadius: BorderRadius.horizontal(right: Radius.circular(40)),
      //         boxShadow: [
      //           BoxShadow(
      //               color: Color(0x3D000000), spreadRadius: 30, blurRadius: 20)
      //         ]),
      //     child: Padding(
      //       padding: EdgeInsets.fromLTRB(20, 50, 20, 20),
      //       child: Column(
      //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //         children: [
      //           Expanded(
      //             child: Column(
      //               children: [
      //                 Row(
      //                   children: [],
      //                 ),
      //                 SizedBox(
      //                   height: 30,
      //                 ),
      //               ],
      //             ),
      //           ),
      //           Container(
      //             decoration: BoxDecoration(
      //               color: Color(0xff343541),
      //               borderRadius: BorderRadius.circular(4),
      //             ),
      //             child: ElevatedButton(
      //               style: ElevatedButton.styleFrom(
      //                   backgroundColor: Color(0xff343541),
      //                   minimumSize: const Size(double.infinity, 60)),
      //               onPressed: () {},
      //               child: Text('UserAccount'),
      //             ),
      //           ),
      //         ],
      //       ),
      //     ),
      //   ),
      // ),
      //drawer
      drawer: Drawer(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Column(
              children: [
                //header
                // DrawerHeader(
                //   child: Icon(Icons.abc),
                // ),
              ],
            ),
            Gap(100),
            Divider(),
            Row(
              children: [
                Icon(
                  Icons.person,
                  color: Colors.amber,
                ),
                Expanded(
                  child: Container(
                    color: Colors.amber,
                    child: TextButton(
                      onPressed: () {},
                      child: Text('logout'),
                    ),
                  ),
                )
              ],
            )
          ],
        ),
        //log
      ),
    );
  }

  Future<void> getChatResponse(ChatMessage m) async {
    setState(() {
      _messages.insert(0, m);
      _typingUsers.add(_gptChatUser);
    });
    List<Messages> _messagesHistory = _messages.reversed.map((m) {
      if (m.user == _currentUser) {
        return Messages(role: Role.user, content: m.text);
      } else {
        return Messages(role: Role.assistant, content: m.text);
      }
    }).toList();
    final request = ChatCompleteText(
      model: GptTurbo0301ChatModel(),
      messages: _messagesHistory,
      maxToken: 200,
    );
    final response = await _openAI.onChatCompletion(request: request);
    for (var element in response!.choices) {
      if (element.message != null) {
        setState(() {
          _messages.insert(
            0,
            ChatMessage(
                user: _gptChatUser,
                createdAt: DateTime.now(),
                text: element.message!.content),
          );
        });
      }
    }
    setState(() {
      _typingUsers.remove(_gptChatUser);
    });
  }
}
