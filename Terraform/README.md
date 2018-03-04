
# Terraform

## About
Terraform を使って単一サーバを作成するやつ

## terraform.tfvars
以下の要領で.tvfarsを作成する

``` json
aws_access_key="<AWSクレデンシャル>"
aws_secret_key="<AWSシークレットキー>"
key_name="<公開鍵の名前>"
public_key_path="<公開鍵のパス>"
public_ip="<SSH元パブリックIP/CIDRブロック>"
```

## デプロイ
初回は以下を実行

``` bash
$ terraform init
```

以下でDry Run

``` bash
$ terraform plan
```

以下でデプロイ

``` bash
$ terraform apply
# 質問に 'yes' と入力する
```

## 状態確認

``` bash
$ terraform show
```

## 削除

``` bash
$ terraform destroy
# 質問に 'yes' と入力する
```

