import pandas as pd
import numpy as np

# ===================== 核心参数（只需确认文件名） =====================
input_file = "C:\\Users\\12195\\Desktop\\TanimotoSimilarity.xlsx"  # 你的输入文件
output_file = "C:\\Users\\12195\\Desktop\\TanimotoSimilarity_整数版.xlsx"  # 生成的输出文件

# ===================== 自动处理流程 =====================
# 1. 读取Excel文件（支持矩阵格式/列表格式）
try:
    # 情况1：文件是矩阵格式（行/列是分子名称，单元格是数值）
    df = pd.read_excel(input_file, index_col=0)  # 第一列作为行索引（分子名称）
    print(f"✅ 成功读取矩阵格式文件，数据形状：{df.shape}")
except:
    # 情况2：文件是列表格式（分子1、分子2、CosineSimilarity三列）
    df = pd.read_excel(input_file)
    print(f"✅ 成功读取列表格式文件，数据形状：{df.shape}")

# 2. 找到相似性数值列，乘以100并保留整数
# 自动识别数值列（排除分子名称列）
numeric_cols = df.select_dtypes(include=[np.number]).columns.tolist()
for col in numeric_cols:
    # 核心操作：×100 + 四舍五入保留整数
    df[col] = np.round(df[col] * 100).astype(int)
    print(f"✅ 已处理列：{col}（×100+保留整数）")

# 3. 保存到新Excel文件
df.to_excel(output_file, index=True)  # 保留行索引（分子名称）
print(f"\n✅ 处理完成！文件已保存为：{output_file}")

# 4. 显示处理前后对比（前5行）
print("\n📊 处理前后对比（前5行）：")
print("原始数据（示例，未×100）：")
original_df = pd.read_excel(input_file, index_col=0) if "index_col" in locals() else pd.read_excel(input_file)
print(original_df[numeric_cols].head())
print("\n处理后数据（×100+整数）：")
print(df[numeric_cols].head())