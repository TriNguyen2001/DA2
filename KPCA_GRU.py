#-------------------------------------------------------Preprocessing--------------------------------------------
import pandas as pd
import numpy as np
import seaborn as sns
import matplotlib.pyplot as plt
import os

from sklearn.preprocessing import MinMaxScaler
from sklearn.feature_selection import SelectKBest, f_regression
from sklearn.decomposition import KernelPCA

# ------------------------
# 1. Đọc , xuất dữ liệu
data = pd.read_excel(r"D:\TriNguyen\242\DA2\visual code\Data\example_solar_forecast_input.xlsx")
output_dir = r"D:\TriNguyen\242\DA2\visual code\Data"
os.makedirs(output_dir, exist_ok=True)  # Tạo thư mục nếu chưa có

# 2. Loại bỏ cột không phải số (như datetime hoặc object)
data = data.select_dtypes(include=["number"])

# 3. Xử lý giá trị thiếu
data = data.fillna(data.mean())

# 4. Đặt X và y
y = data["power"]
X = data.drop(columns=["power"])

# 5. Chuẩn hóa dữ liệu
scaler = MinMaxScaler()
X_scaled = scaler.fit_transform(X)
X_scaled_df = pd.DataFrame(X_scaled, columns=X.columns)

# ------------------------
# 📌 1. Heatmap Pearson toàn bộ
cols_to_exclude = ['hour', 'day', 'month']
heatmap_data = data.drop(columns=[col for col in cols_to_exclude if col in data.columns])

plt.figure(figsize=(12, 8))
sns.heatmap(heatmap_data.corr(), annot=True, cmap="coolwarm")
plt.title("Heatmap Pearson Correlation Matrix (loại hour/day/month)")
plt.tight_layout()
plt.show()

# ------------------------
# 📌 2. Heatmap giữa power hiện tại và quá khứ (t-1 đến t-24)
for lag in range(1, 25):
    data[f'power_t-{lag}'] = data['power'].shift(lag)

data_lagged = data.dropna()
power_lags = [f'power_t-{i}' for i in range(1, 25)]
corr_lag = data_lagged[power_lags + ['power']].corr()

plt.figure(figsize=(14, 5))
sns.heatmap(corr_lag[['power']].T, annot=True, cmap="YlGnBu")
plt.title("Tương quan giữa công suất hiện tại và quá khứ (t-1 đến t-24)")
plt.xlabel("Công suất hiện tại (power)")
plt.ylabel("Lùi thời gian")
plt.tight_layout()
plt.show()

# Tạo danh sách các cột trễ
lag_features = [f'power_t-{i}' for i in range(1, 25)]

# Tạo DataFrame so sánh giữa power hiện tại và quá khứ
comparison_df = data_lagged[lag_features + ['power']].copy()

# Xuất ra file Excel
output_path = os.path.join(output_dir, "power_comparison.xlsx")
comparison_df.to_excel(output_path, index=False)

print("✅ Đã lưu file power__comparison.xlsx để so sánh!")


# ------------------------
# 📌 3. F-score - Feature Importance
X_filtered = X_scaled_df.drop(columns=[col for col in ['hour', 'day', 'month'] if col in X_scaled_df.columns])
f_score_selector = SelectKBest(score_func=f_regression, k='all')
f_score_selector.fit(X_filtered, y)
f_scores = f_score_selector.scores_

plt.figure(figsize=(12, 5))
sns.barplot(x=X_filtered.columns, y=f_scores, palette='viridis')
plt.title("Mức độ quan trọng của đặc trưng (F-score) - loại bỏ hour/day/month")
plt.ylabel("F-score")
plt.xticks(rotation=45)
plt.tight_layout()
plt.show()

# ------------------------
# 📌 4. Giảm chiều bằng Kernel PCA
kpca = KernelPCA(n_components=2, kernel='rbf', gamma=0.1)
X_kpca = kpca.fit_transform(X_scaled)

explained_variance = np.var(X_kpca, axis=0)
explained_ratio = explained_variance / np.sum(explained_variance)

print("📊 Đóng góp phương sai của từng thành phần KPCA:", explained_ratio)

plt.figure(figsize=(6, 4))
plt.bar(['PC1', 'PC2'], explained_ratio * 100, color='steelblue')
plt.title("Đóng góp phương sai các thành phần KPCA")
plt.ylabel("Tỷ lệ (%)")
plt.grid(True, linestyle='--', alpha=0.5)
plt.tight_layout()
plt.show()


# ------------------------------------------------ TRAINING GRU------------------------------------------------
# 📦 Tạo X_final từ lag features và KPCA

# Bước 1: Thêm lại power lag features vì trước đó đã dropna rồi
for lag in range(1, 25):
    data[f'power_t-{lag}'] = data['power'].shift(lag)


# Bước 2: Tạo lại data_lagged sau khi có KPCA
data_lagged = data.dropna().reset_index(drop=True)

# Bước 3: Tạo DataFrame từ KPCA
kpca_df = pd.DataFrame(X_kpca, columns=["PC1", "PC2"])
kpca_df = kpca_df.iloc[-len(data_lagged):].reset_index(drop=True)  # khớp chiều

# Bước 4: Kết hợp thành X_final
lag_features = [f'power_t-{i}' for i in range(1, 25)]
X_final = pd.concat([
    data_lagged[lag_features].reset_index(drop=True),
    kpca_df
], axis=1)

# Bước 5: Tạo y_final
y_final = data_lagged["power"].reset_index(drop=True)

# Bước 6: Xuất ra file Excel hoặc CSV
X_final["target_power"] = y_final
output_path_for_GRU = os.path.join(output_dir, "X_final_for_GRU.xlsx")
X_final.to_excel(output_path_for_GRU, index=False)
print("✅ Xuất file X_final_for_GRU.xlsx thành công!")