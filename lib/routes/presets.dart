import 'dart:math';

import 'package:flutter/material.dart';
import 'package:rivia/constants/languages.dart';
import 'package:rivia/constants/route_names.dart';
import 'package:rivia/constants/ui_texts.dart';
import 'package:rivia/utilities/change_notifiers.dart';
import 'package:rivia/utilities/http_requests.dart';
import 'package:rivia/utilities/language_switcher.dart';
import 'package:rivia/utilities/log_out_button.dart';
import 'package:rivia/utilities/sized_button.dart';
import 'package:rivia/utilities/toast.dart';

class Presets extends StatefulWidget {
  const Presets({Key? key, required this.presets}) : super(key: key);
  final Set<String> presets;

  @override
  State<Presets> createState() => _PresetsState();
}

class _PresetsState extends State<Presets> {
  bool _isAddingPreset = false;
  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    final list = widget.presets.toList();

    return Scaffold(
      body: Stack(
        children: [
          Image.asset(
            'assets/images/general_bg.png',
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            fit: BoxFit.fill,
          ),
          ListView(
            children: [
              Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: height * 0.04),
                  child: Text(
                    LangText.presets.local,
                    style: UITexts.iconHeader,
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(
                  left: min(width * 0.07, max(0, width - 700)),
                  right: min(width * 0.07, max(0, width - 700)),
                  bottom: max(height * 0.05, 20.0),
                ),
                padding: const EdgeInsets.symmetric(
                  vertical: 16.0,
                  horizontal: 32.0,
                ),
                decoration: const BoxDecoration(
                  color: Color(0xFFE6E6E6),
                  borderRadius: BorderRadius.all(Radius.circular(48.0)),
                  boxShadow: [BoxShadow(offset: Offset(0, 1), blurRadius: 2.0)],
                ),
                child: Column(
                  children: [
                    ...List.generate(
                      widget.presets.length,
                      (index) {
                        return Container(
                          margin: const EdgeInsets.all(12.0),
                          width: width * 0.6,
                          height: 52.0,
                          decoration: BoxDecoration(
                            color: Colors.blue.shade100,
                            borderRadius: const BorderRadius.all(
                              Radius.circular(8.0),
                            ),
                            boxShadow: const [
                              BoxShadow(offset: Offset(0, 1), blurRadius: 2.0),
                            ],
                          ),
                          child: Center(
                            child: ListTile(
                              trailing: IconButton(
                                icon: Icon(
                                  Icons.delete,
                                  size: FontSizes.bigTextSize,
                                  color: Colors.black,
                                ),
                                onPressed: () async {
                                  setState(
                                    () => widget.presets.remove(list[index]),
                                  );
                                },
                              ),
                              title: Text(
                                list[index],
                                textAlign: TextAlign.center,
                                style: UITexts.mediumButtonText.copyWith(
                                  fontWeight: FontWeight.normal,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    SizedBox(height: height * 0.02),
                    SizedBox(
                      width: width * 0.3,
                      child: _isAddingPreset
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: width * 0.24,
                                  child: TextField(
                                    decoration: InputDecoration(
                                      labelText: LangText.newPreset.local,
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                          width: 3.0,
                                          color: Colors.blue,
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                          width: 3.0,
                                          color:
                                              Color.fromRGBO(190, 150, 100, 1),
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    controller: _controller,
                                  ),
                                ),
                                const Expanded(child: SizedBox()),
                                SizedButton(
                                  primaryColour: Colors.blue,
                                  height: 36.0,
                                  width: 36.0,
                                  radius: BorderRadius.circular(18.0),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 20.0,
                                  ),
                                  onPressed: (_) {
                                    widget.presets.add(_controller.text);
                                    _controller.text = '';
                                    setState(() => _isAddingPreset = false);
                                  },
                                  child: const Icon(
                                    Icons.add,
                                    size: FontSizes.mediumTextSize,
                                  ),
                                ),
                              ],
                            )
                          : SizedButton(
                              height: null,
                              width: width * 0.20,
                              radius: BorderRadius.circular(24.0),
                              padding:
                                  const EdgeInsets.symmetric(vertical: 20.0),
                              onPressed: (_) {
                                setState(() => _isAddingPreset = true);
                              },
                              child: Text(
                                LangText.newPreset.local,
                                style: UITexts.bigButtonText,
                              ),
                            ),
                    ),
                    SizedBox(height: height * 0.02),
                    SizedButton(
                      height: null,
                      width: width * 0.20,
                      radius: BorderRadius.circular(24.0),
                      padding: const EdgeInsets.symmetric(vertical: 20.0),
                      onPressed: (_) async {
                        await postPresets(widget.presets.toList());
                        showToast(
                          context: context,
                          text: 'Preset questions set',
                        );
                      },
                      isSelected: true,
                      child: Text(
                        LangText.submit.local,
                        style: UITexts.bigButtonText,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const LogOutButton(),
          LanguageSwitcher(callback: () => setState(() => {})),
          Positioned(
            left: 64.0,
            top: 24.0,
            child: SizedButton(
              backgroundColour: const Color.fromRGBO(239, 198, 135, 1),
              primaryColour: Colors.black,
              onPressedColour: const Color.fromRGBO(239, 198, 135, 1),
              height: 48.0,
              width: 48.0,
              radius: BorderRadius.circular(24.0),
              onPressed: (_) => (Navigator.of(context)
                    ..popUntil((route) => route.isFirst))
                  .pushNamed(
                RouteNames.login,
                arguments: true,
              ),
              child: const Icon(Icons.arrow_back, size: 32.0),
            ),
          ),
        ],
      ),
    );
  }
}
