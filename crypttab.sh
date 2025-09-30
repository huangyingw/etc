#!/bin/zsh

# 设置并发限制（可根据需要调整）
MAX_PARALLEL=4
current_jobs=0

# 存储所有后台任务的PID
typeset -a pids
pids=()

# 定义解密函数
decrypt_device() {
    local name=$1
    local dev=$2
    local key=$3
    local opts=$4

    # 执行解密（使用sudo）
    if sudo cryptsetup luksOpen "$dev" "$name" --key-file "$key" 2>/dev/null; then
        echo "[✓] 成功解密设备: $name"
        return 0
    else
        echo "[✗] 解密设备 $name 失败"
        return 1
    fi
}

# 等待任务槽位函数
wait_for_slot() {
    while (( $(jobs -r | wc -l) >= MAX_PARALLEL )); do
        sleep 0.1
    done
}

# 统计变量
total_devices=0
successful_devices=0
failed_devices=0

echo "开始并发解密设备..."
echo "最大并发数: $MAX_PARALLEL"
echo "----------------------------"

# 解析crypttab文件并并发解密设备
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
        echo "[!] 警告: 无效的行: $line"
        continue
    fi

    # 等待有可用的任务槽位
    wait_for_slot

    # 后台执行解密任务
    (
        decrypt_device "$name" "$dev" "$key" "$opts"
        exit $?
    ) &

    # 记录PID
    pids+=($!)
    ((total_devices++))
    echo "[→] 启动解密任务: $name (PID: $!)"

done < /etc/crypttab

echo "----------------------------"
echo "等待所有解密任务完成..."

# 等待所有后台任务完成并收集结果
for pid in $pids; do
    wait $pid
    if [[ $? -eq 0 ]]; then
        ((successful_devices++))
    else
        ((failed_devices++))
    fi
done

echo "----------------------------"
echo "解密任务完成统计:"
echo "  总设备数: $total_devices"
echo "  成功: $successful_devices"
echo "  失败: $failed_devices"

# 根据结果返回适当的退出码
if [[ $failed_devices -eq 0 ]]; then
    echo "[✓] 所有设备解密成功!"
    exit 0
else
    echo "[!] 有 $failed_devices 个设备解密失败"
    exit 1
fi
