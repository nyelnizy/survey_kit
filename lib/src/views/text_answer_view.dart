import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:survey_kit/src/answer_format/text_answer_format.dart';
import 'package:survey_kit/src/views/decoration/input_decoration.dart';
import 'package:survey_kit/src/result/question/text_question_result.dart';
import 'package:survey_kit/src/steps/predefined_steps/question_step.dart';
import 'package:survey_kit/src/views/widget/step_view.dart';

class TextAnswerView extends StatefulWidget {
  final QuestionStep questionStep;
  final TextQuestionResult? result;

  const TextAnswerView({
    Key? key,
    required this.questionStep,
    required this.result,
  }) : super(key: key);

  @override
  _TextAnswerViewState createState() => _TextAnswerViewState();
}

class _TextAnswerViewState extends State<TextAnswerView> {
  late final TextAnswerFormat _textAnswerFormat;
  late final DateTime _startDate;
  bool _isKeyboardVisible = false;
  late final TextEditingController _controller;
  bool _isValid = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _controller.text = widget.result?.result ?? '';
    _textAnswerFormat = widget.questionStep.answerFormat as TextAnswerFormat;
    _controller.text = _textAnswerFormat.defaultValue ?? '';
    _checkValidation(_controller.text);
    _startDate = DateTime.now();
  }

  void _checkValidation(String text) {
    setState(() {
      if (_textAnswerFormat.validationRegEx != null) {
        RegExp regExp = new RegExp(_textAnswerFormat.validationRegEx!);
        _isValid = regExp.hasMatch(text);
      } else {
        _isValid = true;
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (_isKeyboardVisible) {
          FocusScope.of(context).unfocus();
          _isKeyboardVisible = false;
        }
      },
      child: StepView(
        step: widget.questionStep,
        resultFunction: () => TextQuestionResult(
          id: widget.questionStep.stepIdentifier,
          startDate: _startDate,
          endDate: DateTime.now(),
          valueIdentifier: _controller.text,
          result: _controller.text,
        ),
        title: widget.questionStep.title.isNotEmpty
            ? Text(
                widget.questionStep.title,
                style: Theme.of(context).textTheme.headline2,
                textAlign: TextAlign.center,
              )
            : widget.questionStep.content,
        isValid: _isValid || widget.questionStep.isOptional,
        child: Column(
          children: [
            Padding(
              padding:
                  const EdgeInsets.only(bottom: 32.0, left: 14.0, right: 14.0),
              child: Text(
                widget.questionStep.text,
                style: Theme.of(context).textTheme.bodyText2,
                textAlign: TextAlign.center,
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              child: TextField(
                decoration: textFieldInputDecoration(
                  hint: _textAnswerFormat.hint,
                ),
                minLines: 2,
                onTap: () {
                  setState(() {
                    _isKeyboardVisible = true;
                  });
                },
                // inputFormatters: [
                //   TextCapitalizationFormatter(),
                // ],
                autocorrect: true,
                maxLines: _textAnswerFormat.maxLines,
                controller: _controller,
                onChanged: (String text) {
                  _checkValidation(text);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TextCapitalizationFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final String newString = newValue.text;
    if (newString == "") {
      return newValue.copyWith(text: "");
    } else {
      final String capitalized = newString
          .split('. ')
          .map((sentence) => sentence.trim().capitalize())
          .join('. ');

      return TextEditingValue(
        text: capitalized,
        selection: TextSelection.collapsed(offset: capitalized.length),
      );
    }
  }
}

extension StringExtensions on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1)}";
  }
}
