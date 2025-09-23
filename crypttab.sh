#!/bin/zsh

# 解析crypttab文件并解密设备
while IFS= read -r line || [[ -n "$line" ]]; do
    # 忽略空行和注释行
    if [[ -z "$line" || "$line" =~ ^# ]]; then
        continue
    fi

    # 解析每一行
    local name dev key opts
    read -r name dev key opts <<< "$line"

    # 检查是否有足够的字段
    if [[ -z "$name" || -z "$dev" || -z "$key" ]]; then
        echo "警告: 无效的行: $line"
        continue
    fi

    # 执行解密（使用sudo）
    if sudo cryptsetup luksOpen "$dev" "$name" --key-file "$key"; then
        echo "成功解密设备: $name"
    else
        echo "解密设备 $name 失败"
    fi
done < /etc/crypttab

echo "所有设备处理完毕"
