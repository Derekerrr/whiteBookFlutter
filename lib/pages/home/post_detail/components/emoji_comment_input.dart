import 'package:flutter/material.dart';

class EmojiCommentInput extends StatefulWidget {
  final ValueChanged<String> onSend;

  final String? repliedUserNickname;

  const EmojiCommentInput({super.key, required this.onSend, this.repliedUserNickname});

  @override
  State<EmojiCommentInput> createState() => _EmojiCommentInputState();
}

class _EmojiCommentInputState extends State<EmojiCommentInput> {
  final TextEditingController _controller = TextEditingController();
  bool _showEmojiPicker = false;

  // 简单 Emoji 列表，你可以自由扩展
  final List<String> _emojis = [
    '😀', '😁', '😂', '🤣', '😃', '😄', '😅', '😆',
    '😉', '😊', '😋', '😎', '😍', '😘', '🥰', '😗',
    '😙', '😚', '🙂', '🤗', '🤔', '😐', '😑', '😶',
    '🙄', '😏', '😣', '😥', '😮', '🤐', '😯', '😪',
  ];

  void _handleSend() {
    final text = _controller.text.trim();
    if (text.isNotEmpty) {
      widget.onSend(text);
      _controller.clear();
      setState(() => _showEmojiPicker = false);
    }
  }

  void _onEmojiSelected(String emoji) {
    final text = _controller.text;
    final selection = _controller.selection;

    final newText = text.replaceRange(
      selection.start,
      selection.end,
      emoji,
    );

    final emojiLength = emoji.length;

    _controller.text = newText;
    _controller.selection = TextSelection.collapsed(
      offset: selection.start + emojiLength,
    );
  }

  void _toggleEmojiPicker() {
    if (_showEmojiPicker) {
      setState(() => _showEmojiPicker = false);
      FocusScope.of(context).requestFocus(FocusNode());
    } else {
      FocusScope.of(context).unfocus();
      setState(() => _showEmojiPicker = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.of(context).viewInsets;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: _showEmojiPicker ? 0 : viewInsets.bottom,
          left: 12,
          right: 12,
          top: 12,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                IconButton(
                  icon: Icon(
                    _showEmojiPicker ? Icons.keyboard_alt_outlined : Icons.emoji_emotions_outlined,
                    color: _showEmojiPicker ? Colors.blueAccent : null,
                  ),
                  onPressed: _toggleEmojiPicker,
                ),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    autofocus: true,
                    minLines: 1,
                    maxLines: 5,
                    decoration: InputDecoration(
                      hintText: widget.repliedUserNickname == null ? '写评论...' : '回复${widget.repliedUserNickname}',
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[200],
                    ),
                    onTap: () {
                      if (_showEmojiPicker) {
                        setState(() => _showEmojiPicker = false);
                      }
                    },
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.blueAccent),
                  onPressed: _handleSend,
                ),
              ],
            ),
            Offstage(
              offstage: !_showEmojiPicker,
              child: SizedBox(
                height: 200,
                child: GridView.builder(
                  padding: const EdgeInsets.all(8),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 8,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                  ),
                  itemCount: _emojis.length,
                  itemBuilder: (context, index) {
                    final emoji = _emojis[index];
                    return GestureDetector(
                      onTap: () => _onEmojiSelected(emoji),
                      child: Center(
                        child: Text(
                          emoji,
                          style: const TextStyle(fontSize: 24),
                        ),
                      ),
                    );
                  },
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
