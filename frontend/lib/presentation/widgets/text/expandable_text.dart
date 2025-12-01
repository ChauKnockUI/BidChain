import 'package:flutter/material.dart';

class ExpandableInlineText extends StatefulWidget {
  final String text;
  final int maxLines;
  final TextStyle? style;
  final TextStyle? readMoreStyle;

  const ExpandableInlineText({
    super.key,
    required this.text,
    this.maxLines = 5,
    this.style,
    this.readMoreStyle,
  });

  @override
  State<ExpandableInlineText> createState() => _ExpandableInlineTextState();
}

class _ExpandableInlineTextState extends State<ExpandableInlineText> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final span = TextSpan(text: widget.text, style: widget.style);

        final tp = TextPainter(
          text: span,
          maxLines: widget.maxLines,
          textDirection: TextDirection.ltr,
        )..layout(maxWidth: constraints.maxWidth);

        final isOverflow = tp.didExceedMaxLines;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.text,
              maxLines: isExpanded ? null : widget.maxLines,
              overflow: isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
              textAlign: TextAlign.justify, 
              style: widget.style,
            ),

            if (isOverflow)
              GestureDetector(
                onTap: () => setState(() => isExpanded = !isExpanded),
                child: Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(
                    isExpanded ? "Thu gọn" : "Đọc thêm",
                    style: widget.readMoreStyle ??
                        const TextStyle(color: Colors.blue),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
