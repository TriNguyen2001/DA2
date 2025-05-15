#--------------------------------------------PRE-PROCESSING------------------------------------------------

#--------------------------------------------xem tổng quát data tuần ------------------------------
# import pandas as pd
# import matplotlib.pyplot as plt
# import matplotlib.dates as mdates

# # 1. Đọc dữ liệu
# df = pd.read_excel(r"D:\TriNguyen\242\DA2\visual code\Data\new\observation.xlsx")

# # 2. Tạo datetime
# df['Datetime'] = pd.to_datetime({
#     'year': df['Year'],
#     'month': df['Month'],
#     'day': df['Day'],
#     'hour': df['Hour'],
#     'minute': df['minute'],
#     'second': df['second']
# })
# df = df.sort_values('Datetime')
# df.set_index('Datetime', inplace=True)

# # 3. Chọn tuần cần vẽ
# week_index = 1  # 👈 Tuần thứ 2 (bắt đầu từ 0)
# week_starts = df.resample('W').first().index
# start_time = week_starts[week_index]
# end_time = start_time + pd.Timedelta(days=7)
# week_df = df[start_time:end_time]

# # 4. Vẽ biểu đồ
# plt.figure(figsize=(14, 8))
# plt.plot(week_df.index, week_df['Temperature'], label='Nhiệt độ (°C)', color='red')
# plt.plot(week_df.index, week_df['Humidity'], label='Độ ẩm (%)', color='blue')
# plt.plot(week_df.index, week_df['Pressure'], label='Áp suất (hPa)', color='green')
# plt.plot(week_df.index, week_df['GHI'], label='Bức xạ mặt trời (GHI)', color='orange')
# plt.plot(week_df.index, week_df['Power (watts)'], label='Công suất phát (W)', color='purple')

# # ➕ Thêm ngày/tháng/năm vào tiêu đề
# start_str = start_time.strftime('%d/%m/%Y')
# end_str = end_time.strftime('%d/%m/%Y')
# plt.title(f"Thông số môi trường và công suất phát – Tuần {week_index + 1} ({start_str} - {end_str})")

# plt.xlabel("Thời gian")
# plt.ylabel("Giá trị")
# plt.legend()
# plt.grid(True)
# plt.gca().xaxis.set_major_locator(mdates.HourLocator(interval=6))
# plt.gca().xaxis.set_major_formatter(mdates.DateFormatter('%d/%m\n%H:%M'))
# plt.xticks(rotation=45)
# plt.tight_layout()

# # Lưu biểu đồ
# plt.savefig(f"week_{week_index + 1}_{start_str.replace('/', '-')}_to_{end_str.replace('/', '-')}.png")

# plt.show()

# #------------------------------xem tổng quát data tháng ----------------------------
# import pandas as pd
# import matplotlib.pyplot as plt
# import matplotlib.dates as mdates

# # 1. Đọc dữ liệu
# df = pd.read_excel("D:\\TriNguyen\\242\\DA2\\visual code\\Data\\new\\Historical Data (t11-t12).xlsx")

# # 2. Tạo datetime
# df['Datetime'] = pd.to_datetime({
#     'year': df['Year'],
#     'month': df['Month'],
#     'day': df['Day'],
#     'hour': df['Hour'],
#     'minute': df['minute'],
#     'second': df['second']
# })
# df = df.sort_values('Datetime')
# df.set_index('Datetime', inplace=True)

# # 3. Lọc dữ liệu theo tháng bạn muốn (VD: tháng 11 năm 2023)
# target_month = 11
# target_year = 2024
# month_df = df[(df.index.month == target_month) & (df.index.year == target_year)]

# # 4. Vẽ biểu đồ
# plt.figure(figsize=(14, 8))
# plt.plot(month_df.index, month_df['Temperature'], label='Nhiệt độ (°C)', color='red')
# plt.plot(month_df.index, month_df['Humidity'], label='Độ ẩm (%)', color='blue')
# plt.plot(month_df.index, month_df['Pressure'], label='Áp suất (hPa)', color='green')
# plt.plot(month_df.index, month_df['GHI'], label='Bức xạ mặt trời (GHI)', color='orange')
# plt.plot(month_df.index, month_df['Power (watts)'], label='Công suất phát (W)', color='purple')

# # Tiêu đề tháng
# plt.title(f"Thông số môi trường và công suất phát – Tháng {target_month}/{target_year}")

# plt.xlabel("Thời gian")
# plt.ylabel("Giá trị")
# plt.legend()
# plt.grid(True)
# plt.gca().xaxis.set_major_locator(mdates.DayLocator(interval=2))
# plt.gca().xaxis.set_major_formatter(mdates.DateFormatter('%d/%m'))
# plt.xticks(rotation=45)
# plt.tight_layout()
# plt.show()

#----------------------------------------nôi suy dữ liêu nếu bị thiếu-----------------------------

# import pandas as pd
# import numpy as np
# import matplotlib.pyplot as plt
# import matplotlib.dates as mdates
# from sklearn.linear_model import LinearRegression

# # 1. Đọc dữ liệu
# df = pd.read_excel(r"D:\TriNguyen\242\DA2\visual code\Data\new\Historical Data - missing.xlsx")

# # 2. Tạo datetime
# df['Datetime'] = pd.to_datetime({
#     'year': df['Year'],
#     'month': df['Month'],
#     'day': df['Day'],
#     'hour': df['Hour'],
#     'minute': df['minute'],
#     'second': df['second']
# })
# df.sort_values('Datetime', inplace=True)
# df.set_index('Datetime', inplace=True)

# # 3. Nội suy các cột khác theo thời gian
# for col in ['Temperature', 'Humidity', 'Pressure']:
#     df[col] = df[col].interpolate(method='time', limit_direction='both')

# # 4. Hồi quy Power từ GHI (chỉ cho những ô bị thiếu Power nhưng có GHI)
# mask_train_power = df['Power (watts)'].notna() & df['GHI'].notna()
# mask_predict_power = df['Power (watts)'].isna() & df['GHI'].notna()

# if mask_train_power.sum() > 0:
#     model = LinearRegression()
#     model.fit(df.loc[mask_train_power, ['GHI']], df.loc[mask_train_power, 'Power (watts)'])
#     df.loc[mask_predict_power, 'Power (watts)'] = model.predict(df.loc[mask_predict_power, ['GHI']])


# # 5. Hồi quy GHI từ Power (chỉ cho những ô bị thiếu GHI nhưng có Power)
# mask_train_ghi = df['GHI'].notna() & df['Power (watts)'].notna()
# mask_predict_ghi = df['GHI'].isna() & df['Power (watts)'].notna()

# if mask_train_ghi.sum() > 0 and mask_predict_ghi.sum() > 0:
#     model2 = LinearRegression()
#     model2.fit(df.loc[mask_train_ghi, ['Power (watts)']], df.loc[mask_train_ghi, 'GHI'])
#     df.loc[mask_predict_ghi, 'GHI'] = model2.predict(df.loc[mask_predict_ghi, ['Power (watts)']])


# # 6. Nếu GHI = 0 thì Power = 0 và ngược lại
# df.loc[df['GHI'] == 0, 'Power (watts)'] = 0
# df.loc[df['Power (watts)'] == 0, 'GHI'] = 0

# # 7. Kiểm tra lại số giá trị bị thiếu
# print("\n🔍 Số giá trị bị thiếu sau hồi quy từng ô + xử lý GHI = 0 ↔ Power = 0:")
# print(df[['GHI', 'Power (watts)']].isna().sum())

# # 8. Xuất ra file Excel
# output_path = r"D:\TriNguyen\242\DA2\visual code\Data\new\Data_after_regression_with_zero_rule.xlsx"
# df.to_excel(output_path)
# print(f"\n✅ Đã lưu dữ liệu sau khi nội suy và áp dụng quy tắc GHI = 0 ↔ Power = 0 tại: {output_path}")








# # #-------------------heatmap heatmap Pearson correlation----------
# import pandas as pd
# import seaborn as sns
# import numpy as np
# import matplotlib.pyplot as plt

# # input 
# history_df = pd.read_excel(r"D:\TriNguyen\242\DA2\visual code\Data\newest\Historical_data_newest (T11-T5).xlsx")

# # --- Định nghĩa features ---
# features = ['Temperature', 'Humidity', 'Pressure', 'GHI']

# # === TÍNH MA TRẬN TƯƠNG QUAN ===
# corr_matrix = history_df[features + ['Power (watts)']].corr(method='pearson')

# # === TẠO MẶT NẠ ĐỂ ẨN TAM GIÁC TRÊN ===
# mask = np.triu(np.ones_like(corr_matrix, dtype=bool))

# # === VẼ HEATMAP TAM GIÁC DƯỚI ===
# plt.figure(figsize=(8, 6))
# sns.heatmap(corr_matrix, mask=mask, annot=True, fmt=".2f", cmap="coolwarm", square=True, vmin=-1, vmax=1)
# plt.title("Heatmap of Pearson Correlation Matrix")
# plt.tight_layout()
# plt.show()






##--------------------------------------------------PROCESSING------------------------------------


# # #----------------------------gru---------------------------------

# import pandas as pd
# import numpy as np
# import matplotlib.pyplot as plt
# import matplotlib.dates as mdates
# from keras.models import Sequential
# from keras.layers import GRU, Dense
# from sklearn.preprocessing import MinMaxScaler
# # input 
# history_df = pd.read_excel(r"D:\TriNguyen\242\DA2\visual code\Data\newest\Historical_data_newest (T11-T5).xlsx")

# nwp_df = pd.read_excel(r"D:\TriNguyen\242\DA2\visual code\Data\newest\NWP (DAY8).xlsx")

# obs_df = pd.read_excel(
#     r"D:\TriNguyen\242\DA2\visual code\Data\newest\observation(DAY8).xlsx",
#     skiprows=3,
#     usecols=[0, 1]
# )

# obs_df = pd.read_excel(
#     r"D:\TriNguyen\242\DA2\visual code\Data\newest\observation(DAY8).xlsx",
#     skiprows=6,
#     usecols=[0, 1]
# )

# output_path = r"D:\TriNguyen\242\DA2\visual code\Data\newest\Model1_output.xlsx"

# # === 1. ĐỌC FILE LỊCH SỬ ===
# # history_df = pd.read_excel(r"D:\TriNguyen\242\DA2\visual code\Data\new\Historical Data (t11-t12).xlsx")

# # Tạo cột datetime
# history_df['Datetime'] = pd.to_datetime({
#     'year': history_df['Year'],
#     'month': history_df['Month'],
#     'day': history_df['Day'],
#     'hour': history_df['Hour'],
#     'minute': history_df['minute'],
#     'second': history_df['second']
# })
# history_df.set_index('Datetime', inplace=True)
# history_df = history_df.dropna()

# # === 2. SCALE DỮ LIỆU ===
# features = ['Temperature', 'Humidity', 'Pressure', 'GHI']
# target = 'Power (watts)'

# scaler_X = MinMaxScaler()
# scaler_y = MinMaxScaler()

# X_scaled = scaler_X.fit_transform(history_df[features])
# y_scaled = scaler_y.fit_transform(history_df[[target]])

# # === 3. TẠO SEQUENCE DỮ LIỆU ===
# def create_sequences(X, y, time_steps=6):
#     Xs, ys = [], []
#     for i in range(time_steps, len(X)):
#         Xs.append(X[i-time_steps:i])
#         ys.append(y[i])
#     return np.array(Xs), np.array(ys)

# time_steps = 6
# X_seq, y_seq = create_sequences(X_scaled, y_scaled)

# # === 4. MÔ HÌNH GRU ===
# model = Sequential([
#     GRU(64, input_shape=(X_seq.shape[1], X_seq.shape[2]), return_sequences=False),
#     Dense(1)
# ])
# model.compile(loss='mse', optimizer='adam')
# model.fit(X_seq, y_seq, epochs=30, batch_size=16, verbose=1)

# # === 5. ĐỌC DỮ LIỆU DỰ BÁO ===
# # nwp_df = pd.read_excel(r"D:\TriNguyen\242\DA2\visual code\Data\new\NWP.xlsx")
# nwp_df['Datetime'] = pd.to_datetime({
#     'year': nwp_df['Year'],
#     'month': nwp_df['Month'],
#     'day': nwp_df['Day'],
#     'hour': nwp_df['Hour'],
#     'minute': nwp_df['minute'],
#     'second': nwp_df['second']
# })
# nwp_df.set_index('Datetime', inplace=True)
# nwp_df = nwp_df.dropna()

# # === 6. CHUẨN HÓA DỮ LIỆU DỰ BÁO ===
# nwp_scaled = scaler_X.transform(nwp_df[features])

# X_forecast = []
# for i in range(time_steps, len(nwp_scaled)):
#     X_forecast.append(nwp_scaled[i-time_steps:i])
# X_forecast = np.array(X_forecast)

# # === 7. DỰ BÁO ===
# y_pred_scaled = model.predict(X_forecast)
# y_pred = scaler_y.inverse_transform(y_pred_scaled).flatten()
# forecast_time = nwp_df.index[time_steps:time_steps + len(y_pred)]

# # === 8. ĐỌC DỮ LIỆU QUAN SÁT THỰC TẾ (CHỈ CẦN MỘT LẦN) ===
# # obs_df = pd.read_excel(
# #     r"D:\TriNguyen\242\DA2\visual code\Data\new\observation.xlsx",
# #     skiprows=3,
# #     usecols=[0, 1]
# # )
# obs_df.columns = ['Datetime', 'Power_observed']
# obs_df['Datetime'] = pd.to_datetime(obs_df['Datetime'])

# # === 9. ĐỒNG BỘ THỜI GIAN GIỮA FORECAST VÀ OBSERVATION ===
# # Đọc dữ liệu quan sát

# # obs_df = pd.read_excel(
# #     r"D:\TriNguyen\242\DA2\visual code\Data\new\observation.xlsx",
# #     skiprows=6,
# #     usecols=[0, 1]
# # )
# obs_df.columns = ['Datetime', 'Power_observed']
# obs_df['Datetime'] = pd.to_datetime(obs_df['Datetime'])

# # Loại bỏ giá trị thiếu thời gian (rất quan trọng!)
# obs_df = obs_df.dropna(subset=['Datetime'])
# obs_df = obs_df.sort_values('Datetime').reset_index(drop=True)

# # Tạo khung thời gian dự báo
# forecast_df = pd.DataFrame({'Datetime': forecast_time})

# # Ghép dự báo với quan sát thực tế theo thời gian gần nhất trong khoảng 15 phút
# merged_df = pd.merge_asof(
#     forecast_df, obs_df,
#     on='Datetime',
#     direction='nearest',
#     tolerance=pd.Timedelta('15min')
# )
# merged_df.dropna(subset=['Power_observed'], inplace=True)

# # Cập nhật forecast_time và dữ liệu quan sát thực tế sau khi merge
# forecast_time = merged_df['Datetime']
# obs_power = merged_df['Power_observed'].values

# # === 10. XỬ LÝ GHI = 0 VÀ LỌC ÂM ===
# ghi_forecast = nwp_df['GHI'].values[time_steps:len(forecast_time) + time_steps]

# # Dự báo GRU đã tính rồi, ta cắt theo chiều dài mới của forecast_time
# y_pred_adjusted = np.where(ghi_forecast == 0, 0, y_pred[:len(forecast_time)])
# y_pred_adjusted = np.where(y_pred_adjusted < 0, 0, y_pred_adjusted)

# obs_power_adjusted = np.where(ghi_forecast == 0, 0, obs_power)
# obs_power_adjusted = np.where(obs_power_adjusted < 0, 0, obs_power_adjusted)


# # # Vẽ biểu đồ


# # === 11. XUẤT FILE KẾT QUẢ ===
# result_df = nwp_df.iloc[time_steps:].copy().reset_index()
# result_df['Month'] = result_df['Datetime'].dt.month
# result_df['Day'] = result_df['Datetime'].dt.day
# result_df['Hour'] = result_df['Datetime'].dt.hour
# result_df['minute'] = result_df['Datetime'].dt.minute
# result_df['second'] = result_df['Datetime'].dt.second
# result_df['Power (watts)'] = y_pred_adjusted

# final_df = result_df[['Month', 'Day', 'Hour', 'minute', 'second',
#                       'Temperature', 'Humidity', 'Pressure', 'GHI', 'Power (watts)']]

# # output_path = r"D:\TriNguyen\242\DA2\visual code\Data\new\Model1_output.xlsx"
# final_df.to_excel(output_path, index=False, sheet_name="Model 1")
# print(f"✅ Đã xuất kết quả ra file: {output_path}")









# #--------------------------LSTM--------------------------------

import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import matplotlib.dates as mdates
from keras.models import Sequential
from keras.layers import LSTM, Dense
from sklearn.preprocessing import MinMaxScaler
# input 
history_df = pd.read_excel(r"D:\TriNguyen\242\DA2\visual code\Data\newest\Historical_data_newest (T11-T5).xlsx")

nwp_df = pd.read_excel(r"D:\TriNguyen\242\DA2\visual code\Data\newest\NWP (DAY8).xlsx")

obs_df = pd.read_excel(
    r"D:\TriNguyen\242\DA2\visual code\Data\newest\observation(DAY8).xlsx",
    skiprows=3,
    usecols=[0, 1]
)

obs_df = pd.read_excel(
    r"D:\TriNguyen\242\DA2\visual code\Data\newest\observation(DAY8).xlsx",
    skiprows=6,
    usecols=[0, 1]
)

output_path = r"D:\TriNguyen\242\DA2\visual code\Data\newest\Model2_output.xlsx"

# === 1. ĐỌC FILE LỊCH SỬ ===
# history_df = pd.read_excel(r"D:\TriNguyen\242\DA2\visual code\Data\new\Historical Data (t11-t12).xlsx")

# Tạo cột datetime
history_df['Datetime'] = pd.to_datetime({
    'year': history_df['Year'],
    'month': history_df['Month'],
    'day': history_df['Day'],
    'hour': history_df['Hour'],
    'minute': history_df['minute'],
    'second': history_df['second']
})
history_df.set_index('Datetime', inplace=True)
history_df = history_df.dropna()

# === 2. SCALE DỮ LIỆU ===
features = ['Temperature', 'Humidity', 'Pressure', 'GHI']
target = 'Power (watts)'

scaler_X = MinMaxScaler()
scaler_y = MinMaxScaler()

X_scaled = scaler_X.fit_transform(history_df[features])
y_scaled = scaler_y.fit_transform(history_df[[target]])

# === 3. TẠO SEQUENCE DỮ LIỆU ===
def create_sequences(X, y, time_steps=6):
    Xs, ys = [], []
    for i in range(time_steps, len(X)):
        Xs.append(X[i-time_steps:i])
        ys.append(y[i])
    return np.array(Xs), np.array(ys)

time_steps = 6
X_seq, y_seq = create_sequences(X_scaled, y_scaled)

# === 4. MÔ HÌNH LSTM ===
model = Sequential([
    LSTM(64, input_shape=(X_seq.shape[1], X_seq.shape[2]), return_sequences=False),
    Dense(1)
])
model.compile(loss='mse', optimizer='adam')
model.fit(X_seq, y_seq, epochs=10, batch_size=16, verbose=1)

# === 5. ĐỌC DỮ LIỆU DỰ BÁO ===
# nwp_df = pd.read_excel(r"D:\TriNguyen\242\DA2\visual code\Data\new\NWP.xlsx")
nwp_df['Datetime'] = pd.to_datetime({
    'year': nwp_df['Year'],
    'month': nwp_df['Month'],
    'day': nwp_df['Day'],
    'hour': nwp_df['Hour'],
    'minute': nwp_df['minute'],
    'second': nwp_df['second']
})
nwp_df.set_index('Datetime', inplace=True)
nwp_df = nwp_df.dropna()

# === 6. CHUẨN HÓA DỮ LIỆU DỰ BÁO ===
nwp_scaled = scaler_X.transform(nwp_df[features])

X_forecast = []
for i in range(time_steps, len(nwp_scaled)):
    X_forecast.append(nwp_scaled[i-time_steps:i])
X_forecast = np.array(X_forecast)

# === 7. DỰ BÁO ===
y_pred_scaled = model.predict(X_forecast)
y_pred = scaler_y.inverse_transform(y_pred_scaled).flatten()
forecast_time = nwp_df.index[time_steps:time_steps + len(y_pred)]

# === 8. ĐỌC DỮ LIỆU QUAN SÁT THỰC TẾ (CHỈ CẦN MỘT LẦN) ===
# obs_df = pd.read_excel(
#     r"D:\TriNguyen\242\DA2\visual code\Data\new\observation.xlsx",
#     skiprows=3,
#     usecols=[0, 1]
# )
obs_df.columns = ['Datetime', 'Power_observed']
obs_df['Datetime'] = pd.to_datetime(obs_df['Datetime'])

# === 9. ĐỒNG BỘ THỜI GIAN GIỮA FORECAST VÀ OBSERVATION ===
# Đọc dữ liệu quan sát

# obs_df = pd.read_excel(
#     r"D:\TriNguyen\242\DA2\visual code\Data\new\observation.xlsx",
#     skiprows=6,
#     usecols=[0, 1]
# )
obs_df.columns = ['Datetime', 'Power_observed']
obs_df['Datetime'] = pd.to_datetime(obs_df['Datetime'])

# Loại bỏ giá trị thiếu thời gian (rất quan trọng!)
obs_df = obs_df.dropna(subset=['Datetime'])
obs_df = obs_df.sort_values('Datetime').reset_index(drop=True)

# Tạo khung thời gian dự báo
forecast_df = pd.DataFrame({'Datetime': forecast_time})

# Ghép dự báo với quan sát thực tế theo thời gian gần nhất trong khoảng 15 phút
merged_df = pd.merge_asof(
    forecast_df, obs_df,
    on='Datetime',
    direction='nearest',
    tolerance=pd.Timedelta('15min')
)
merged_df.dropna(subset=['Power_observed'], inplace=True)

# Cập nhật forecast_time và dữ liệu quan sát thực tế sau khi merge
forecast_time = merged_df['Datetime']
obs_power = merged_df['Power_observed'].values

# === 10. XỬ LÝ GHI = 0 VÀ LỌC ÂM ===
ghi_forecast = nwp_df['GHI'].values[time_steps:len(forecast_time) + time_steps]

# Dự báo GRU đã tính rồi, ta cắt theo chiều dài mới của forecast_time
y_pred_adjusted = np.where(ghi_forecast == 0, 0, y_pred[:len(forecast_time)])
y_pred_adjusted = np.where(y_pred_adjusted < 0, 0, y_pred_adjusted)

obs_power_adjusted = np.where(ghi_forecast == 0, 0, obs_power)
obs_power_adjusted = np.where(obs_power_adjusted < 0, 0, obs_power_adjusted)


# === 11. XUẤT FILE KẾT QUẢ ===
result_df = nwp_df.iloc[time_steps:].copy().reset_index()
result_df['Month'] = result_df['Datetime'].dt.month
result_df['Day'] = result_df['Datetime'].dt.day
result_df['Hour'] = result_df['Datetime'].dt.hour
result_df['minute'] = result_df['Datetime'].dt.minute
result_df['second'] = result_df['Datetime'].dt.second
result_df['Power (watts)'] = y_pred_adjusted

final_df = result_df[['Month', 'Day', 'Hour', 'minute', 'second',
                      'Temperature', 'Humidity', 'Pressure', 'GHI', 'Power (watts)']]

# output_path = r"D:\TriNguyen\242\DA2\visual code\Data\new\Model1_output.xlsx"
final_df.to_excel(output_path, index=False, sheet_name="Model 1")
print(f"✅ Đã xuất kết quả ra file: {output_path}")












#------------------------------VẼ BIỂU ĐỒ----------------------------
# import pandas as pd
# import matplotlib.pyplot as plt
# import matplotlib.dates as mdates

# # Đường dẫn file
# model1_path = r"D:\TriNguyen\242\DA2\visual code\Data\newest\Model1_output.xlsx"
# model2_path = r"D:\TriNguyen\242\DA2\visual code\Data\newest\Model2_output.xlsx"
# obs_path    = r"D:\TriNguyen\242\DA2\visual code\Data\newest\observation(DAY8).xlsx"

# # Đọc model 1
# df1 = pd.read_excel(model1_path)
# df1['Datetime'] = pd.to_datetime({
#     'year': 2025,
#     'month': df1['Month'],
#     'day': df1['Day'],
#     'hour': df1['Hour'],
#     'minute': df1['minute'],
#     'second': df1['second']
# })

# # Đọc model 2
# df2 = pd.read_excel(model2_path)
# df2['Datetime'] = pd.to_datetime({
#     'year': 2025,
#     'month': df2['Month'],
#     'day': df2['Day'],
#     'hour': df2['Hour'],
#     'minute': df2['minute'],
#     'second': df2['second']
# })

# # Đọc quan sát thực tế
# obs_df = pd.read_excel(obs_path, skiprows=6, usecols=[0, 1])
# obs_df.columns = ['Datetime', 'Power_observed']
# obs_df['Datetime'] = pd.to_datetime(obs_df['Datetime'])
# obs_df = obs_df.dropna(subset=['Datetime', 'Power_observed'])

# # Khớp thời gian gần nhất (tolerance 15 phút)
# forecast_df = pd.DataFrame({'Datetime': df1['Datetime']})
# merged_obs = pd.merge_asof(forecast_df, obs_df, on='Datetime', direction='nearest', tolerance=pd.Timedelta('15min'))

# # Vẽ biểu đồ
# plt.figure(figsize=(12, 6))
# plt.plot(df1['Datetime'], df1['Power (watts)'], label="Model 1 (GRU)", color='orange')
# plt.plot(df2['Datetime'], df2['Power (watts)'], label="Model 2 (LSTM)", color='blue')
# plt.plot(merged_obs['Datetime'], merged_obs['Power_observed'], label="Observed", color='green')

# plt.title("So sánh công suất dự báo giữa các mô hình và quan sát thực tế")
# plt.xlabel("Thời gian")
# plt.ylabel("Công suất (W)")
# plt.legend()
# plt.grid(True)

# plt.gca().xaxis.set_major_locator(mdates.HourLocator(interval=1))
# plt.gca().xaxis.set_major_formatter(mdates.DateFormatter('%H:%M'))
# plt.xticks(rotation=45)

# plt.tight_layout()
# plt.show()






##-------------------------------------POST-PROCESSING--------------------------------------





# #--------------TÍNH RMSE------------------------
# from sklearn.metrics import mean_squared_error
# import numpy as np

# # === 1. TÍNH RMSE ===
# mse = mean_squared_error(obs_power_adjusted, y_pred_adjusted)
# rmse = np.sqrt(mse)
# print(f"📊 RMSE: {rmse:.2f} W")

# # === 2. BIỂU ĐỒ SO SÁNH CÓ GHI RMSE ===
# plt.figure(figsize=(12, 5))
# plt.plot(forecast_time, y_pred_adjusted, label="Dự báo GRU", color='orange')
# plt.plot(forecast_time, obs_power_adjusted, label="Quan sát thực tế", color='green')
# plt.title(f"So sánh công suất dự báo và thực tế - RMSE: {rmse:.2f} W")
# plt.xlabel("Thời gian")
# plt.ylabel("Công suất (W)")
# plt.legend()
# plt.grid(True)
# plt.gca().xaxis.set_major_locator(mdates.HourLocator(interval=1))
# plt.gca().xaxis.set_major_formatter(mdates.DateFormatter('%H'))
# plt.xticks(rotation=45)
# plt.tight_layout()
# plt.show()

# # === 3. BIỂU ĐỒ SAI SỐ THEO THỜI GIAN ===
# errors = y_pred_adjusted - obs_power_adjusted

# plt.figure(figsize=(12, 4))
# plt.plot(forecast_time, errors, label="Sai số (dự báo - thực tế)", color='red')
# plt.axhline(0, linestyle='--', color='gray')
# plt.title("Biểu đồ sai số dự báo theo thời gian")
# plt.xlabel("Thời gian")
# plt.ylabel("Sai số (W)")
# plt.grid(True)
# plt.legend()
# plt.tight_layout()
# plt.show()

# # === 4. BIỂU ĐỒ PHÂN BỐ SAI SỐ (HISTOGRAM) ===
# plt.figure(figsize=(6, 4))
# plt.hist(errors, bins=30, color='purple', edgecolor='black')
# plt.title("Phân bố sai số giữa dự báo và thực tế")
# plt.xlabel("Sai số (W)")
# plt.ylabel("Số lượng")
# plt.grid(True)
# plt.tight_layout()
# plt.show()
