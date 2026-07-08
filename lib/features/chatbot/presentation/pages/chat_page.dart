import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/providers/providers.dart';

class ChatPage extends StatefulWidget {
  final VoidCallback? onBack;

  const ChatPage({super.key, this.onBack});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  void _sendMessage() {
    final text = _controller.text;
    if (text.trim().isNotEmpty) {
      final profile = context.read<ProfileProvider>().healthMetrics;
      context.read<ChatProvider>().sendMessage(text, profile: profile);
      _controller.clear();
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

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Widget _buildMessageText(BuildContext context, ChatMessage msg, ColorScheme colorScheme) {
    final bool isArabic = RegExp(r'[\u0600-\u06FF]').hasMatch(msg.text);
    final TextDirection direction = isArabic ? TextDirection.rtl : TextDirection.ltr;
    final TextAlign align = isArabic ? TextAlign.right : TextAlign.left;

    final RegExp urlRegExp = RegExp(r'(https?:\/\/[^\s]+)', caseSensitive: false);
    final Iterable<RegExpMatch> matches = urlRegExp.allMatches(msg.text);

    final textStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
      color: msg.isUser ? colorScheme.onPrimary : colorScheme.onSurfaceVariant,
    );

    if (matches.isEmpty) {
      return Directionality(
        textDirection: direction,
        child: Text(
          msg.text,
          textAlign: align,
          style: textStyle,
        ),
      );
    }

    final List<TextSpan> spans = [];
    final linkStyle = textStyle?.copyWith(
      color: msg.isUser ? Colors.white : colorScheme.primary,
      decoration: TextDecoration.underline,
    );

    int currentIndex = 0;
    for (final match in matches) {
      if (match.start > currentIndex) {
        spans.add(TextSpan(text: msg.text.substring(currentIndex, match.start)));
      }
      final String url = match.group(0)!;
      spans.add(
        TextSpan(
          text: url,
          style: linkStyle,
          recognizer: TapGestureRecognizer()
            ..onTap = () async {
              final uri = Uri.tryParse(url);
              if (uri != null && await canLaunchUrl(uri)) {
                await launchUrl(uri);
              }
            },
        ),
      );
      currentIndex = match.end;
    }

    if (currentIndex < msg.text.length) {
      spans.add(TextSpan(text: msg.text.substring(currentIndex)));
    }

    return Directionality(
      textDirection: direction,
      child: RichText(
        textAlign: align,
        textDirection: direction,
        text: TextSpan(style: textStyle, children: spans),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = context.watch<ChatProvider>();
    final messages = chatProvider.messages;
    final colorScheme = Theme.of(context).colorScheme;

    // Scroll to bottom when new messages arrive
    _scrollToBottom();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        titleSpacing: 0, // Decreases whitespace between the leading button and the title
        leading: widget.onBack != null 
          ? IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
              onPressed: widget.onBack,
              color: colorScheme.onSurface,
            )
          : null,
        title: Text(
          'AI Assistant',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () {
              context.read<ChatProvider>().clearSession();
            },
            tooltip: 'Clear Chat',
            color: colorScheme.onSurface,
          ),
        ],
      ),
      body: Column(
        children: [
          // Chat Messages
          Expanded(
            child: messages.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.auto_awesome, size: 64, color: colorScheme.primary.withValues(alpha: 0.5)),
                        const SizedBox(height: 16),
                        Text(
                          'How can I help you today?',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: messages.length + (chatProvider.isLoading ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == messages.length && chatProvider.isLoading) {
                        return Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                        );
                      }
                      
                      final msg = messages[index];
                      return Align(
                        alignment: msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.75,
                          ),
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: msg.isUser ? colorScheme.primary : colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.only(
                              topLeft: const Radius.circular(20),
                              topRight: const Radius.circular(20),
                              bottomLeft: Radius.circular(msg.isUser ? 20 : 4),
                              bottomRight: Radius.circular(msg.isUser ? 4 : 20),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              )
                            ],
                          ),
                          child: _buildMessageText(context, msg, colorScheme),
                        ),
                      );
                    },
                  ),
          ),

          // Input Area
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              border: Border(top: BorderSide(color: colorScheme.outline.withValues(alpha: 0.1))),
            ),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      textInputAction: TextInputAction.send,
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        color: colorScheme.onSurface.withValues(alpha: 0.7),
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                      onSubmitted: (_) => _sendMessage(),
                      decoration: InputDecoration(
                        hintText: 'Message AI Assistant...',
                        hintStyle: TextStyle(
                          color: colorScheme.onSurface.withValues(alpha: 0.5),
                          fontSize: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(100),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: colorScheme.surfaceContainerHighest,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  AspectRatio(
                    aspectRatio: 1,
                    child: Container(
                      decoration: BoxDecoration(
                        color: colorScheme.primary,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: colorScheme.primary.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        icon: Icon(Icons.send, color: colorScheme.onPrimary, size: 24),
                        onPressed: _sendMessage,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Space for bottom navigation bar when not hidden, though user said remove nav bar
          SizedBox(height: MediaQuery.of(context).padding.bottom > 0 ? 0 : 8),
        ],
      ),
    );
  }
}
