terraform {
  required_version = ">= 0.12"
}

# AWS プロバイダの設定
provider "aws" {
  region = "ap-northeast-1"
}
