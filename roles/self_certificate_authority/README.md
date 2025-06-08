self_certificate_authority
=========

社内向け自己署名 CA（Certificate Authority）およびサーバー証明書を生成・配布します。

要件
------------
- Ansible 2.9 以上  
- OpenSSL が利用可能な環境  

ロール変数
--------------
| 変数名                     | 説明                                      | デフォルト値                                                |
| -------------------------- | ----------------------------------------- | ----------------------------------------------------------- |
| `common_name`              | サーバー証明書・CA で使用する共通名       | `{{ ansible_hostname }}`                                    |
| `ca_common_name`           | CA 証明書の共通名                         | `{{ common_name }}-CA`                                      |
| `country_name`             | 国名                                      | `JP`                                                        |
| `state_or_province_name`   | 都道府県名                                | `Tokyo`                                                     |
| `locality_name`            | 市区町村名                                | `Tokyo`                                                     |
| `organization_name`        | 組織名                                    | `ExampleOrg`                                                |
| `organizational_unit_name` | 組織単位名                                | `IT`                                                        |
| `ca_key_type`              | CA 鍵のタイプ（RSA, EC など）              | `RSA`                                                       |
| `ca_key_size`              | CA 鍵のビット長                            | `4096`                                                      |
| `ca_validity_days`         | CA 証明書の有効期間（日数）               | `3650`                                                      |
| `key_type`                 | サーバー鍵のタイプ                        | `RSA`                                                       |
| `key_size`                 | サーバー鍵のビット長                      | `2048`                                                      |
| `server_validity_days`     | サーバー証明書の有効期間（日数）          | `825`                                                       |
| `tls_dir`                  | TLS 関連ディレクトリのルート             | `/etc/pki/tls`                                              |
| `tls_private_key_dir`      | プライベートキー保存ディレクトリ          | `{{ tls_dir }}/private`                                     |
| `tls_certificate_dir`      | 証明書保存ディレクトリ                    | `{{ tls_dir }}/certs`                                       |
| `dhparam_file`             | Diffie-Hellman パラメータファイルパス     | `{{ tls_dir }}/dhparam.pem`                                 |

依存関係
------------
- `common`

サンプル Playbook
----------------
```yaml
- hosts: ca
  roles:
    - role: self_certificate_authority
      common_name: "internal.example.com"
      organization_name: "MyOrg"
````

## ライセンス

This role is licensed under the Apache License, Version 2.0.
See [LICENSE](../../LICENSE) for details.
