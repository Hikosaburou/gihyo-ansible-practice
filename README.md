
# gihyo-ansible-practice
## About
技術評論社『サーバ/インフラエンジニア養成読本 DevOps編』の特集1『最速攻略!Ansible2 によるサーバ構築』をAWS環境でやってみる。

## ディレクトリ構成
```
$ tree
.
├── README.md
├── Terraform
│   ├── README.md
│   ├── main.tf
│   ├── terraform.tfstate
│   ├── terraform.tfstate.backup
│   ├── terraform.tfvars
│   └── variables.tf
├── files
└── hosts
    ├── ec2.ini
    ├── ec2.py
    └── tag_Name_web01
```

## テキストとの差分
テキストではVagrantを用いてローカル環境に仮想サーバを作成しているが、今回はAWS上のインスタンスに対してデプロイを行う。したがって、以下の点がテキストと異なる。

- Vagrantで仮想サーバを作成する代わりにTerraformを用いてEC2インスタンスを構築する。
- EC2インスタンスのPublic IPを取得するためにDynamic Inventoryを利用する。

### Terraform
省略。1台のEC2インスタンス(Amazon Linux)を作成する.tf

### EC2インスタンスのIPを動的に取得するインベントリ
テキストではhostsという単体の静的なインベントリ用いていたが、EC2インスタンスのPublic IPを取り出すためにDynamic Inventoryを使う。
hostsディレクトリ配下に以下ファイルを設置する。

```
hosts
├── ec2.ini
├── ec2.py
└── tag_Name_web01
```

ec2.ini, ec2.py は[AnsibleのGithubページ](https://github.com/ansible/ansible/tree/devel/contrib/inventory)から取得する。
ec2.ini に種々の設定情報を記載することで、例えば以下の要素に基づくグループ設定ができる

- EC2インスタンスのタグ
- EC2インスタンスのインスタンスID

今回は以下設定を記載した。Nameタグの値が `web0*` に当てはまるインスタンスをグループに指定している。

```ini
instance_filters = tag:Name=web0*
```

hosts と同階層に静的なインベントリも配置している。 (hostsディレクトリ配下にgroup\_varsディレクトリを掘ってインベントリファイルを配置したらエラーが出て怒られた)

この状態で `ansible` を実行してみる。

```bash
$ ansible -i hosts tag_Name_web01 -m shell -a 'uname -a'
54.250.13.20 | SUCCESS | rc=0 >>
Linux ip-10-1-1-227 4.9.62-21.56.amzn1.x86_64 #1 SMP Thu Nov 16 05:37:08 UTC 2017 x86_64 x86_64 x86_64 GNU/Linux
```

-i でインベントリファイル or ファイルの入ったパスを指定、-m でモジュールを指定。shellモジュールは対象のサーバ内でシェルコマンドを実行する。-a でシェルコマンドを指定できる。
