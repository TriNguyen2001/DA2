# #-------------------------------------------------------Preprocessing--------------------------------------------
# import pandas as pd
# import numpy as np
# import seaborn as sns
# import matplotlib.pyplot as plt
# import os

# from sklearn.preprocessing import MinMaxScaler
# from sklearn.feature_selection import SelectKBest, f_regression
# from sklearn.decomposition import KernelPCA

# # ------------------------
# # 1. Đọc , xuất dữ liệu
# data = pd.read_excel(r"D:\TriNguyen\242\DA2\visual code\Data\example_solar_forecast_input.xlsx")
# output_dir = r"D:\TriNguyen\242\DA2\visual code\Data"
# os.makedirs(output_dir, exist_ok=True)  # Tạo thư mục nếu chưa có

# # 2. Loại bỏ cột không phải số (như datetime hoặc object)
# data = data.select_dtypes(include=["number"])

# # 3. Xử lý giá trị thiếu
# data = data.fillna(data.mean())

# # 4. Đặt X và y
# y = data["power"]
# X = data.drop(columns=["power"])

# # 5. Chuẩn hóa dữ liệu
# scaler = MinMaxScaler()
# X_scaled = scaler.fit_transform(X)
# X_scaled_df = pd.DataFrame(X_scaled, columns=X.columns)

# # ------------------------
# # 📌 1. Heatmap Pearson toàn bộ
# cols_to_exclude = ['hour', 'day', 'month']
# heatmap_data = data.drop(columns=[col for col in cols_to_exclude if col in data.columns])

# plt.figure(figsize=(12, 8))
# sns.heatmap(heatmap_data.corr(), annot=True, cmap="coolwarm")
# plt.title("Heatmap Pearson Correlation Matrix")
# plt.tight_layout()
# plt.show()

# # ------------------------
# # 📌 2. Heatmap giữa power hiện tại và quá khứ (t-1 đến t-24)
# for lag in range(1, 25):
#     data[f'power_t-{lag}'] = data['power'].shift(lag)

# data_lagged = data.dropna()
# power_lags = [f'power_t-{i}' for i in range(1, 25)]
# corr_lag = data_lagged[power_lags + ['power']].corr()

# plt.figure(figsize=(14, 5))
# sns.heatmap(corr_lag[['power']].T, annot=True, cmap="YlGnBu")
# plt.title("Tương quan giữa công suất hiện tại và quá khứ (t-1 đến t-24)")
# plt.xlabel("Công suất hiện tại (power)")
# plt.ylabel("Lùi thời gian")
# plt.tight_layout()
# plt.show()

# # Tạo danh sách các cột trễ
# lag_features = [f'power_t-{i}' for i in range(1, 25)]

# # Tạo DataFrame so sánh giữa power hiện tại và quá khứ
# comparison_df = data_lagged[lag_features + ['power']].copy()

# # Xuất ra file Excel
# output_path = os.path.join(output_dir, "power_comparison.xlsx")
# comparison_df.to_excel(output_path, index=False)

# print("✅ Đã lưu file power__comparison.xlsx để so sánh!")


# # ------------------------
# # 📌 3. F-score - Feature Importance
# X_filtered = X_scaled_df.drop(columns=[col for col in ['hour', 'day', 'month'] if col in X_scaled_df.columns])
# f_score_selector = SelectKBest(score_func=f_regression, k='all')
# f_score_selector.fit(X_filtered, y)
# f_scores = f_score_selector.scores_

# plt.figure(figsize=(12, 5))
# sns.barplot(x=X_filtered.columns, y=f_scores, palette='viridis')
# plt.title("Mức độ quan trọng của đặc trưng (F-score) - loại bỏ hour/day/month")
# plt.ylabel("F-score")
# plt.xticks(rotation=45)
# plt.tight_layout()
# plt.show()

# # ------------------------
# # 📌 4. Giảm chiều bằng Kernel PCA
# kpca = KernelPCA(n_components=2, kernel='rbf', gamma=0.1)
# X_kpca = kpca.fit_transform(X_scaled)

# explained_variance = np.var(X_kpca, axis=0)
# explained_ratio = explained_variance / np.sum(explained_variance)

# print("📊 Đóng góp phương sai của từng thành phần KPCA:", explained_ratio)

# plt.figure(figsize=(6, 4))
# plt.bar(['PC1', 'PC2'], explained_ratio * 100, color='steelblue')
# plt.title("Đóng góp phương sai các thành phần KPCA")
# plt.ylabel("Tỷ lệ (%)")
# plt.grid(True, linestyle='--', alpha=0.5)
# plt.tight_layout()
# plt.show()


# # ------------------------------------------------ TRAINING GRU------------------------------------------------
# # 📦 Tạo X_final từ lag features và KPCA


# # Bước 1: Thêm lại power lag features vì trước đó đã dropna rồi
# for lag in range(1, 25):
#     data[f'power_t-{lag}'] = data['power'].shift(lag)

# # Bước 2: Tạo lại data_lagged sau khi có KPCA
# data_lagged = data.dropna().reset_index(drop=True)

# # Bước 3: Tạo DataFrame từ KPCA
# kpca_df = pd.DataFrame(X_kpca, columns=["PC1", "PC2"])
# kpca_df = kpca_df.iloc[-len(data_lagged):].reset_index(drop=True)  # khớp chiều

# # Bước 4: Kết hợp thành X_final
# lag_features = [f'power_t-{i}' for i in range(1, 25)]
# X_final = pd.concat([
#     data_lagged[lag_features].reset_index(drop=True),
#     kpca_df
# ], axis=1)

# # Bước 5: Tạo y_final
# y_final = data_lagged["power"].reset_index(drop=True)

# # Bước 6: Xuất ra file Excel hoặc CSV
# X_final["target_power"] = y_final
# output_path_for_GRU = os.path.join(output_dir, "X_final_for_GRU.xlsx")
# X_final.to_excel(output_path_for_GRU, index=False)
# print("✅ Xuất file X_final_for_GRU.xlsx thành công!")








# #---------------------------------------------------new-----------------------------------------------------------


import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
from keras.models import Sequential
from keras.layers import GRU, Dense
from sklearn.preprocessing import MinMaxScaler

# === 1. ĐỌC FILE LỊCH SỬ ===
history_df = pd.read_excel(r"D:\TriNguyen\242\DA2\visual code\Data\History_power_and_rad.xlsx")
history_df['Datetime'] = pd.to_datetime(history_df['Datetime'])
history_df.set_index('Datetime', inplace=True)
history_df = history_df.dropna()

# === 2. TIỀN XỬ LÝ + SCALE ===
features = ['Temp', 'Hum', 'Wind', 'Rad']
target = 'Power'

scaler_X = MinMaxScaler()
scaler_y = MinMaxScaler()

X_scaled = scaler_X.fit_transform(history_df[features])
y_scaled = scaler_y.fit_transform(history_df[[target]])

# === 3. TẠO DỮ LIỆU THEO SEQ (ví dụ: 6 bước quá khứ) ===
def create_sequences(X, y, time_steps=6):
    Xs, ys = [], []
    for i in range(time_steps, len(X)):
        Xs.append(X[i-time_steps:i])
        ys.append(y[i])
    return np.array(Xs), np.array(ys)

X_seq, y_seq = create_sequences(X_scaled, y_scaled)

# === 4. TẠO VÀ HUẤN LUYỆN MÔ HÌNH GRU ===
model = Sequential([
    GRU(64, input_shape=(X_seq.shape[1], X_seq.shape[2]), return_sequences=False),
    Dense(1)
])
model.compile(loss='mse', optimizer='adam')
model.fit(X_seq, y_seq, epochs=20, batch_size=32, verbose=1)




# === 5. ĐỌC FILE DỰ BÁO THỜI TIẾT ===
nwp_df = pd.read_excel(r"D:\TriNguyen\242\DA2\visual code\Data\NWP.xlsx")
nwp_df['Datetime'] = pd.to_datetime(nwp_df['Datetime'])
nwp_df.set_index('Datetime', inplace=True)
nwp_df = nwp_df.dropna()

# === 6. CHUẨN HÓA INPUT DỰ BÁO ===
nwp_scaled = scaler_X.transform(nwp_df[features])

# Tạo chuỗi input (dùng chính data dự báo 6 bước gần nhất)
time_steps = 6
X_forecast = []

for i in range(time_steps, len(nwp_scaled)):
    X_forecast.append(nwp_scaled[i-time_steps:i])

X_forecast = np.array(X_forecast)

# === 7. DỰ BÁO VÀ INVERSE SCALE ===
y_pred_scaled = model.predict(X_forecast)
y_pred = scaler_y.inverse_transform(y_pred_scaled)

# === 8. VẼ BIỂU ĐỒ ===
forecast_time = nwp_df.index[time_steps:]

plt.figure(figsize=(12, 5))
plt.plot(forecast_time, y_pred, label="Dự đoán công suất GRU", color='orange')
plt.title("Dự báo công suất từ dữ liệu dự báo thời tiết (GRU)")
plt.xlabel("Thời gian")
plt.ylabel("Công suất (W)")
plt.grid(True)
plt.legend()
plt.tight_layout()
plt.show()
