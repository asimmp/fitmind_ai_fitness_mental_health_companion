import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class MentalWellness extends StatefulWidget {
  const MentalWellness({super.key});

  @override
  State<MentalWellness> createState() => _MentalWellnessState();
}

class _MentalWellnessState extends State<MentalWellness> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, String>> _messages = [];
  bool _isLoading = false;

  // Get your FREE key at: https://console.groq.com/
  static const String _apiKey = String.fromEnvironment('GROQ_API_KEY');
  static const String _model = "llama-3.3-70b-versatile";
  static const String _systemPrompt =
      "You are FitMind AI, a compassionate and knowledgeable wellness coach. "
      "You specialise in mental health support, mindfulness, stress management, "
      "sleep hygiene, and healthy lifestyle habits. Give concise, warm, "
      "evidence-based advice. Keep responses under 3 short paragraphs.";

  late final List<Map<String, String>> _history;

  @override
  void initState() {
    super.initState();
    _history = [
      {"role": "system", "content": _systemPrompt},
    ];
    _messages.add({
      'role': 'ai',
      'text':
          "Hello! 👋 I'm your FitMind AI Wellness Coach, powered by Llama 3.3 on Groq.\n\nHow are you feeling today? I'm here to offer mental health tips, meditation guidance, stress relief techniques, or just a friendly chat!"
    });
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add({'role': 'user', 'text': text});
      _history.add({"role": "user", "content": text});
      _isLoading = true;
    });
    _controller.clear();
    _scrollToBottom();

    try {
      final response = await http.post(
        Uri.parse("https://api.groq.com/openai/v1/chat/completions"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $_apiKey",
        },
        body: jsonEncode({
          "model": _model,
          "messages": _history,
          "temperature": 0.8,
          "max_tokens": 512,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final reply = data['choices'][0]['message']['content'] as String;
        _history.add({"role": "assistant", "content": reply});
        setState(() {
          _messages.add({'role': 'ai', 'text': reply});
        });
      } else {
        final err = jsonDecode(response.body);
        setState(() {
          _messages.add({
            'role': 'ai',
            'text':
                "Error ${response.statusCode}: ${err['error']['message'] ?? 'Unknown error'}"
          });
        });
      }
    } catch (e) {
      setState(() {
        _messages.add({'role': 'ai', 'text': "Network error: $e"});
      });
    } finally {
      setState(() => _isLoading = false);
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Color _getBubbleColor(String role) =>
      role == 'ai' ? Colors.white : Theme.of(context).colorScheme.primary;

  Color _getTextColor(String role) =>
      role == 'ai' ? Colors.black87 : Colors.white;

  Alignment _getAlignment(String role) =>
      role == 'ai' ? Alignment.centerLeft : Alignment.centerRight;

  BorderRadius _getBorderRadius(String role) => BorderRadius.only(
        topLeft: const Radius.circular(20),
        topRight: const Radius.circular(20),
        bottomLeft: Radius.circular(role == 'ai' ? 4 : 20),
        bottomRight: Radius.circular(role == 'ai' ? 20 : 4),
      );

  Widget _buildQuickPrompt(String emoji, String label, String prompt) {
    return GestureDetector(
      onTap: () {
        _controller.text = prompt;
        _sendMessage();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.4)),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 4),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 6),
            Text(label,
                style:
                    const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.primary.withOpacity(0.8)
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.35),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child:
                    const Icon(Icons.psychology, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("AI Wellness Coach",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.bold)),
                    SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(Icons.circle, color: Color(0xFF4ADE80), size: 8),
                        SizedBox(width: 4),
                        Text("Groq · Llama 3.3 · Free",
                            style:
                                TextStyle(color: Colors.white70, fontSize: 12)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Quick prompts (only show if no user messages yet)
        if (_messages.length == 1)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildQuickPrompt(
                    "😰", "Stressed", "I'm feeling stressed, what can I do?"),
                _buildQuickPrompt(
                    "😴", "Can't sleep", "I can't sleep well. Any tips?"),
                _buildQuickPrompt("🧘", "Meditate",
                    "Guide me through a quick 5-minute meditation"),
                _buildQuickPrompt("😔", "Feeling low",
                    "I've been feeling low lately. Can you help?"),
              ],
            ),
          ),

        const SizedBox(height: 8),

        // Messages
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: _messages.length,
            itemBuilder: (context, index) {
              final msg = _messages[index];
              final role = msg['role']!;
              return Align(
                alignment: _getAlignment(role),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(14),
                  constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.78),
                  decoration: BoxDecoration(
                    color: _getBubbleColor(role),
                    borderRadius: _getBorderRadius(role),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    msg['text']!,
                    style: TextStyle(
                        color: _getTextColor(role),
                        fontSize: 14.5,
                        height: 1.5),
                  ),
                ),
              );
            },
          ),
        ),

        // Typing indicator
        if (_isLoading)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.05), blurRadius: 4)
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Text("Coach is thinking...",
                        style: TextStyle(color: Colors.grey, fontSize: 13)),
                  ],
                ),
              ),
            ),
          ),

        // Input Bar
        Container(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 12,
                  offset: const Offset(0, -3))
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  maxLines: 3,
                  minLines: 1,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    hintText: "Share how you're feeling...",
                    hintStyle: TextStyle(color: Colors.grey.shade400),
                    filled: true,
                    fillColor: const Color(0xFFF1F5F9),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 12),
                  ),
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: _isLoading ? null : _sendMessage,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(13),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).colorScheme.primary,
                        Theme.of(context).colorScheme.primary.withOpacity(0.8)
                      ],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                          color: Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 3))
                    ],
                  ),
                  child: const Icon(Icons.send_rounded,
                      color: Colors.white, size: 20),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
