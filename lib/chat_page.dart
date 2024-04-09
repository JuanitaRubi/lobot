import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:mqtt_client/mqtt_client.dart';
import 'package:app_proyecto/message_utils.dart';
import 'package:typed_data/typed_data.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chat App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const ChatPage(),
    );
  }
}

class ChatPage extends StatefulWidget {
  const ChatPage({Key? key}) : super(key: key);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final List<ChatMessage> _messages = [];
  final ChatMessage _botMessage = const ChatMessage(
    message: '¡Hola! ¿En qué puedo ayudarte?',
    isBot: true,
  );
  final ChatMessage _noConnectionMessage = const ChatMessage(
    message:
        'Perdón, ahora no tengo conexión. Espera unos minutos mientras lo soluciono para poder responder a tu solicitud.',
    isBot: true,
  );

  final MqttClient client = MqttClient('localhost', '');
  bool mqttConnected = false;

  late stt.SpeechToText _speech;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    connectToMQTTBroker();
  }

  @override
  void dispose() {
    _messageController.dispose();
    disconnectFromMQTTBroker();
    super.dispose();
  }

  void connectToMQTTBroker() async {
    try {
      await client.connect();
      print('Conectado al broker MQTT');
      setState(() {
        mqttConnected = true;
      });
      subscribeToPythonModelResponses();
      // Check if there are unsent messages
      if (_messages.isNotEmpty) {
        _messages.forEach((msg) {
          if (!msg.isBot) {
            sendMessageToPythonModel(msg.message);
          }
        });
        _messages.clear();
      }
    } catch (e) {
      print('Error al conectar al broker MQTT: $e');
      setState(() {
        mqttConnected = false;
      });
    }
  }

  void disconnectFromMQTTBroker() {
    client.disconnect();
    print('Desconectado del broker MQTT');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: true,
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return _messages[index];
              },
            ),
          ),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: const InputDecoration(
                hintText: 'Ingrese su mensaje...',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send, color: Colors.blue),
            onPressed: () {
              String message = _messageController.text;
              if (message.isNotEmpty) {
                if (mqttConnected) {
                  sendMessageToPythonModel(message);
                  setState(() {
                    _messages.insert(
                      0,
                      ChatMessage(
                        message: message,
                        isBot: false,
                      ),
                    );
                    _messages.insert(0, _botMessage);
                  });
                  _messageController.clear();
                } else {
                  _messages.insert(0, ChatMessage(message: message, isBot: false));
                  _messages.insert(0, _noConnectionMessage);
                  _messageController.clear();
                  setState(() {});
                }
              } else {
                sendMessageToUser(
                  context,
                  'Por favor, ingresa un mensaje antes de enviar.',
                );
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.mic),
            onPressed: () {
              startListening();
            },
          ),
        ],
      ),
    );
  }

void startListening() async {
  bool available = await _speech.initialize();
  if (available) {
    try {
      bool? result = await _speech.listen(
        onResult: (result) {
          setState(() {
            _messageController.text = result.recognizedWords;
          });
          if (mqttConnected) {
            sendMessageToPythonModel(result.recognizedWords);
            setState(() {
              _messages.insert(
                0,
                ChatMessage(
                  message: result.recognizedWords,
                  isBot: false,
                ),
              );
              _messages.insert(0, _botMessage);
            });
          } else {
            _messages.insert(
              0,
              ChatMessage(
                message: result.recognizedWords,
                isBot: false,
              ),
            );
            _messages.insert(0, _noConnectionMessage);
            _messageController.clear();
            setState(() {});
          }
        },
      );
      if (result == null) {
        throw Exception('Error al iniciar la grabación');
      }
    } catch (e) {
      print('Error al iniciar la grabación: $e');
    }
  } else {
    print('Reconocimiento de voz no disponible');
  }
}


  void sendMessageToPythonModel(String message) {
    client.publishMessage(
      'lm_studio/request',
      MqttQos.exactlyOnce,
      message as Uint8Buffer,
    );
    print('Mensaje enviado al modelo de Python: $message');
  }

  void subscribeToPythonModelResponses() {
    client.subscribe('lm_studio/response', MqttQos.exactlyOnce);
    client.updates?.listen((List<MqttReceivedMessage<MqttMessage>> c) {
      final MqttPublishMessage recMess = c[0].payload as MqttPublishMessage;
      final String message =
          MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
      print('Mensaje recibido del modelo de Python: $message');
      setState(() {
        _messages.insert(
          0,
          ChatMessage(
            message: message,
            isBot: true,
          ),
        );
      });
    });
  }
}

class ChatMessage extends StatelessWidget {
  final String message;
  final bool isBot;

  const ChatMessage({
    required this.message,
    this.isBot = false,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: isBot ? Alignment.centerLeft : Alignment.centerRight,
      child: ListTile(
        leading: isBot ? Image.asset('assets/juancho.png') : null,
        title: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isBot ? Colors.lightBlue[100] : Colors.grey[300],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            message,
            style: TextStyle(
              color: isBot ? Colors.blue[900] : Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}
