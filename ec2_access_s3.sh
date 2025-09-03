# 给EC2 instance 访问 S3 设置权限 

#1， 书写策略文档文件 如：trust_policy.json

cat > trust_policy.json << EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::s3eastusiloveyou2000/*"
    }
  ]
}
EOF

#2, 利用 策略文档来创建策略 

aws iam create-policy \
  --policy-name Ec2S3AccessPolicy \
  --policy-document file://trust_policy.json

#生成的自定义策略arn 为 ： "arn:aws:iam::319998871902:policy/Ec2S3AccessPolicy"


#创建一个 JSON 文件，定义哪个服务（这里是 EC2）可以扮演（Assume）这个角色

cat > ec2-trust-policy.json << EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Service": "ec2.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
        }
    ]
}
EOF

#4 利用json 文件创建角色
aws iam create-role \
  --role-name MyEC2Role --assume-role-policy-document file://ec2-trust-policy.json
# 得到角色的arn arn:aws:iam::319998871902:role/MyEC2Role

# 5 给角色附加一个策略
aws iam attach-role-policy \
  --role-name MyEC2Role \
  --policy-arn arn:aws:iam::319998871902:policy/Ec2S3AccessPolicy

#6 查看角色上附加的策略

aws iam list-attached-role-policies --role-name MyEC2Role

#7,创建实例配置文件，instance-profile
aws iam create-instance-profile \
  --instance-profile-name YmEC2InstanceProfile 

#8,将角色放在instance-profile里
aws iam add-role-to-instance-profile \
  --instance-profile-name YmEC2InstanceProfile \
  --role-name MyEC2Role

#9，查看instance-profile里有哪些角色
aws iam list-instance-profiles

#10, 将instance-profile 关联到具体的 EC2 instance
aws ec2 associate-iam-instance-profile \
  --instance-id i-0f170df4d5e821418 --iam-instance-profile Name=YmEC2InstanceProfile

返回 "State": "associating" 表示关联成功
