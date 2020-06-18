//
//  LoginViewController.swift
//  MarketBroccoli
//
//  Created by Hailey Lee on 2020/03/20.
//  Copyright © 2020 Team3. All rights reserved.

import UIKit
import Alamofire

class LoginViewController: UIViewController {
  private lazy var loginView = LoginView().then {
    $0.delegate = self
  }
    
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    self.view.endEditing(true)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupNavigation()
    setupUI()
  }
// MARK: - UI
  private func setupUI() {
    view.addSubview(loginView)
    
    let guide = view.safeAreaLayoutGuide
    loginView.snp.makeConstraints {
      $0.top.leading.trailing.equalTo(guide)
      $0.bottom.equalToSuperview()
    }
  }
  // MARK: - ACTIONS
  private func setupNavigation() {
     self.navigationController?.navigationBar.barTintColor = .white
     self.navigationItem.title = "로그인"
     self.navigationItem.leftBarButtonItem = UIBarButtonItem(
       image: UIImage.init(systemName: "xmark"),
       style: .done,
       target: self,
       action: #selector(didTapCancelButton)
     )
     self.navigationItem.leftBarButtonItem?.tintColor = .black
   }
  @objc private func didTapCancelButton() {
    self.dismiss(animated: true, completion: nil)
  }
}
extension LoginViewController: LoginViewDelegate {
  func signupButtonTouched(_ sender: UIButton) {
    let nextVC = SignUpViewController()
    self.navigationController?.pushViewController(nextVC, animated: true)
  }
  
  func loginButtonTouched() {
    AF.request(
          "http://15.164.49.32/accounts/auth-token/",
          method: .post,
          parameters: UserAuthToken(
            userName: loginView.idTextField.text ?? "",
            password: loginView.pwTextField.text ?? ""),
          encoder: JSONParameterEncoder.default,
          headers: ["Content-Type": "application/json"]
        ).validate(statusCode: 200..<300)
          .responseData { response in
            switch response.result {
            case .success(let data):
    
              guard let decodedData = try? JSONDecoder().decode(
                UserAuthTokenResponse.self,
                from: data
                ) else { return }
              
              UserDefaultManager.shared.set(decodedData.token, for: .token)
              UserDefaultManager.shared.set(decodedData.user.name, for: .userName)
              print(decodedData)
              
              guard
                let marketBroccoliTabBar = self.presentingViewController as? MartketBroccoliTabBarController,
                let settingNavigationController = marketBroccoliTabBar
                  .viewControllers?.last as? UINavigationController,
                let settingViewController = settingNavigationController
                  .viewControllers.first as? SettingsViewController
              else { return }
              
              settingViewController.isLogin = true
              CartManager.shared.synchronizeCart()
              self.dismiss(animated: true)
    
            case .failure(let error):
              print(error.localizedDescription)
              let warning = KurlyNotification.shared
              warning.show(text: "아이디, 비밀번호를 확인해주세요.", type: .warning)
//              warning.notification(text: "아이디, 비밀번호를 확인해주세요.", textColor: .kurlyPurple1, backgroundColor: .white)
            }
        }
  }
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    if textField == loginView.idTextField {
      loginView.pwTextField.becomeFirstResponder()
    } else {
      loginView.pwTextField.resignFirstResponder()
      loginButtonTouched()
    }
    return true
  }
  
  func idAndSecretFindButtonTouched(_ sender: UIButton) {
    let idFindVC = IDFindViewController()
    let pwFindVC = PWFindViewController()
    switch sender {
    case loginView.idFindButton:
      self.navigationController?.pushViewController(idFindVC, animated: true)
    default:
      self.navigationController?.pushViewController(pwFindVC, animated: true)
    }
  }
}
