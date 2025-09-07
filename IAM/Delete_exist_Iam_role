#!/bin/bash
ROLE_NAME="node-dev"

echo "开始删除 IAM 角色: $ROLE_NAME"

# 1. 分离所有附加的管理策略
echo "分离管理策略..."
ATTACHED_POLICIES=$(aws iam list-attached-role-policies --role-name $ROLE_NAME --query 'AttachedPolicies[].PolicyArn' --output text)
if [ -n "$ATTACHED_POLICIES" ]; then
    for policy_arn in $ATTACHED_POLICIES; do
        aws iam detach-role-policy --role-name $ROLE_NAME --policy-arn "$policy_arn"
        echo "已分离策略: $policy_arn"
    done
else
    echo "没有找到附加的管理策略"
fi

# 2. 删除所有内联策略
echo "删除内联策略..."
INLINE_POLICIES=$(aws iam list-role-policies --role-name $ROLE_NAME --query 'PolicyNames' --output text)
if [ -n "$INLINE_POLICIES" ]; then
    for policy_name in $INLINE_POLICIES; do
        aws iam delete-role-policy --role-name $ROLE_NAME --policy-name "$policy_name"
        echo "已删除内联策略: $policy_name"
    done
else
    echo "没有找到内联策略"
fi

# 3. 删除角色
echo "删除角色..."
aws iam delete-role --role-name $ROLE_NAME
echo "IAM 角色 $ROLE_NAME 已成功删除"
