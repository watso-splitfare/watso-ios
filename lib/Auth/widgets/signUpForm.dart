import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:watso/Common/theme/text.dart';

import '../../Common/widget/outline_textformfield.dart';
import '../models/user_request_model.dart';
import 'duplicateCheckBtn.dart';
import 'signUpSubmitBtn.dart';
import 'validCheckBtn.dart';

class SignUpForm extends StatefulWidget {
  const SignUpForm({Key? key}) : super(key: key);

  @override
  State<SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  final _signUpFormKey = GlobalKey<FormState>();

  String username = '';
  String nickname = '';
  String name = '';
  String password = '';
  String checkPassword = '';
  String email = '';
  String emailValidationCode = '';
  String account = '';
  String token = '';

  //visible
  bool passwordVisible = false;
  bool checkPasswordVisible = false;

  //duplicate check
  bool checkUsernameDuplicate = false;
  bool checkNicknameDuplicate = false;
  bool checkEmailDuplicate = false;
  bool checkEmailValid = false;

  setDuplicationFlag(DuplicateCheckField field, bool value) {
    setState(() {
      switch (field) {
        case DuplicateCheckField.username:
          checkUsernameDuplicate = value;
          break;
        case DuplicateCheckField.nickname:
          checkNicknameDuplicate = value;
          break;
        case DuplicateCheckField.email:
          checkEmailDuplicate = value;
          break;
      }
    });
  }

  setValidFlag(bool value, String token) {
    setState(() {
      checkEmailValid = value;
      this.token = token;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _signUpFormKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 10),
          Text(
            "이름",
            style: WatsoText.lightBold,
          ),
          SizedBox(height: 5),
          outlineTextFromField(
            onChanged: (value) {
              setState(() {
                name = value;
              });
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '이름을 입력해주세요';
              }
              if (RegExp(r'[ㄱ-ㅎㅏ-ㅣ가-힣 ]').hasMatch(value) == false) {
                return '한글만 입력이 가능합니다.';
              }
              return null;
            },
            hintText: '이름',
            keyboardType: TextInputType.text,
          ),
          SizedBox(height: 16),
          Text(
            "아이디",
            style: WatsoText.lightBold,
          ),
          SizedBox(height: 5),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: outlineTextFromField(
                  onChanged: (value) {
                    setState(() {
                      username = value;
                      checkUsernameDuplicate = false;
                    });
                  },
                  hintText: '아이디',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '아이디를 입력해주세요';
                    }
                    if (RegExp(r'[a-zA-Z0-9]{5,20}$').hasMatch(value) ==
                        false) {
                      return '영문, 숫자 5~20자리로 입력해주세요';
                    }
                    if (!checkUsernameDuplicate) {
                      return '아이디 중복검사를 해주세요';
                    }
                    return null;
                  },
                ),
              ),
              SizedBox(width: 15),
              if (RegExp(r'[a-zA-Z0-9]{5,20}$').hasMatch(username))
                DuplicateCheckButton(
                  field: DuplicateCheckField.username,
                  setValid: setDuplicationFlag,
                  value: username,
                  isValid: checkUsernameDuplicate,
                ),
            ],
          ),
          SizedBox(height: 16),
          Text(
            "닉네임",
            style: WatsoText.lightBold,
          ),
          SizedBox(height: 5),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                  child: outlineTextFromField(
                hintText: '닉네임',
                onChanged: (value) {
                  setState(() {
                    nickname = value;
                    checkNicknameDuplicate = false;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '닉네임을 입력해주세요';
                  }
                  if (RegExp(r'[a-zA-Z가-힣0-9]{2,10}$').hasMatch(value) ==
                      false) {
                    return '한글, 영문, 숫자 2~10자리로 입력해주세요';
                  }
                  if (!checkNicknameDuplicate) {
                    return '닉네임 중복검사를 해주세요';
                  }
                  return null;
                },
              )),
              SizedBox(width: 15),
              if (RegExp(r'[a-zA-Z가-힣0-9]{2,10}$').hasMatch(nickname))
                DuplicateCheckButton(
                  field: DuplicateCheckField.nickname,
                  setValid: setDuplicationFlag,
                  value: nickname,
                  isValid: checkNicknameDuplicate,
                ),
            ],
          ),
          SizedBox(height: 16),
          Text(
            "이메일",
            style: WatsoText.lightBold,
          ),
          SizedBox(height: 5),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                  child: outlineTextFromField(
                hintText: '이메일',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '이메일을 입력해주세요';
                  }
                  if (!checkEmailDuplicate) {
                    return '인증코드를 발송 해주세요';
                  }
                  return null;
                },
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
                ],
                onChanged: (value) {
                  setState(() {
                    email = value;
                    checkEmailDuplicate = false;
                    checkEmailValid = false;
                    emailValidationCode = '';
                    token = '';
                  });
                },
                keyboardType: TextInputType.text,
              )),
              SizedBox(width: 10),
              Text(rootEmail),
              SizedBox(width: 15),
              DuplicateCheckButton(
                field: DuplicateCheckField.email,
                setValid: setDuplicationFlag,
                value: email,
                isValid: checkEmailDuplicate,
              ),
            ],
          ),
          if (checkEmailDuplicate) ...{
            SizedBox(height: 16),
            Text(
              "인증번호",
              style: WatsoText.lightBold,
            ),
            SizedBox(height: 5),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: outlineTextFromField(
                    hintText: '인증코드',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '인증코드를 입력해주세요';
                      }
                      if (!checkEmailValid) {
                        return '인증코드를 확인해주세요';
                      }
                      return null;
                    },
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        emailValidationCode = value;
                      });
                    },
                    keyboardType: TextInputType.number,
                  ),
                ),
                SizedBox(width: 25),
                ValidCheckButton(
                  setValidFlag: setValidFlag,
                  checkEmailValid: checkEmailValid,
                  emailValidationCode: emailValidationCode,
                  email: email,
                ),
              ],
            ),
          },
          SizedBox(height: 16),
          Text(
            "비밀번호",
            style: WatsoText.lightBold,
          ),
          SizedBox(height: 5),
          outlineTextFromField(
              hintText: '비밀번호',
              obscureText: !passwordVisible,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '비밀번호를 입력해주세요';
                }
                if (!RegExp(
                        r'^(?=.*[a-zA-Z])(?=.*[0-9])(?=.*[!@#\$%^&*(),.?:{}|<>~])[a-zA-Z0-9!@#\$%^&*(),.?:{}|<>~].{8,40}$')
                    .hasMatch(value)) {
                  return '비밀번호는 영문, 숫자, 특수문자를 포함하여 8자 이상이어야 합니다';
                }
                if (value.length < 6) {
                  return '비밀번호는 6자 이상이어야 합니다';
                }
                return null;
              },
              onChanged: (value) {
                setState(() {
                  password = value;
                });
              },
              inputFormatters: [
                FilteringTextInputFormatter.allow(
                    RegExp(r'[a-zA-Z0-9!@#\$%^&*(),.?:{}|<>~]')),
              ],
              //                    r'^(?=.*?[a-zA-Z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,40}$')),
              suffixIcon: IconButton(
                  onPressed: () {
                    setState(() {
                      passwordVisible = !passwordVisible;
                    });
                  },
                  icon: Icon(
                    passwordVisible ? Icons.visibility : Icons.visibility_off,
                    color: Colors.grey,
                  ))),
          SizedBox(height: 16),
          Text(
            "비밀번호 확인",
            style: WatsoText.lightBold,
          ),
          SizedBox(height: 5),
          outlineTextFromField(
              hintText: '비밀번호 확인',
              obscureText: !checkPasswordVisible,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '다시 한번 비밀번호를 입력해주세요';
                }
                if (value != password) {
                  return '비밀번호가 일치하지 않습니다';
                }
                return null;
              },
              onChanged: (value) {
                setState(() {
                  checkPassword = value;
                });
              },
              inputFormatters: [
                FilteringTextInputFormatter.allow(
                    RegExp(r'[a-zA-Z0-9!@#\$%^&*(),.?:{}|<>~]')),
              ],
              suffixIcon: IconButton(
                  onPressed: () {
                    setState(() {
                      checkPasswordVisible = !checkPasswordVisible;
                    });
                  },
                  icon: Icon(
                    checkPasswordVisible
                        ? Icons.visibility
                        : Icons.visibility_off,
                    color: Colors.grey,
                  ))),
          SizedBox(height: 16),
          Text(
            "계좌번호",
            style: WatsoText.lightBold,
          ),
          Text(
            "팀원들과 배달비를 편리하게 나누기 위한 계좌번호 입니다. 정확히 입력해주세요",
            style: WatsoText.normal,
          ),
          SizedBox(height: 5),
          outlineTextFromField(
            //account
            hintText: '계좌번호(ex 농협 12341111111)',
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '계좌번호를 입력해주세요';
              }
              if (!RegExp(
                      r'(?=.*?[a-zA-Zㄱ-ㅎㅏ-ㅣ가-힣])(?=.*?[0-9])[a-zA-Z0-9ㄱ-ㅎㅏ-ㅣ가-힣-\s]{8,30}$')
                  .hasMatch(value)) {
                return '계좌번호 형식이 올바르지 않습니다';
              }
              return null;
            },
            onChanged: (value) {
              setState(() {
                account = value;
              });
            },
            keyboardType: TextInputType.text,
            inputFormatters: [
              //number and korean and space
              FilteringTextInputFormatter.allow(
                  RegExp(r'[a-zA-Z0-9ㄱ-ㅎㅏ-ㅣ가-힣-\s]')),
            ],
          ),
          SizedBox(height: 16),
          SignUpSubmitButton(
            signUpFormKey: _signUpFormKey,
            username: username,
            nickname: nickname,
            name: name,
            password: password,
            email: email,
            account: account,
            token: token,
          ),
          SizedBox(height: 30),
        ],
      ),
    );
  }
}
