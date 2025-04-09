import pandas as pd
import joblib

# 1. Đọc dữ liệu và thay ',' thành '.' cho tất cả các ô
forecast = pd.read_csv('forecast_data.csv', dtype=str)
forecast = forecast.applymap(lambda x: x.replace(',', '.') if isinstance(x, str) else x)

# 2. Chuyển toàn bộ sang float nếu có thể
forecast = forecast.astype(float, errors='ignore')  # những cột datetime sẽ chuyển sau

# 3. Xử lý thời gian (sau khi ép số xong)
forecast['period'] = pd.to_datetime(forecast['period'], errors='coerce')
forecast['hour'] = forecast['period'].dt.hour
forecast['dayofweek'] = forecast['period'].dt.dayofweek
forecast['month'] = forecast['period'].dt.month
forecast = forecast.drop(columns=['period'])

# 4. Load scaler
scaler_X = joblib.load('scaler_X.save')

# 5. Đảm bảo đúng cột
forecast = forecast[scaler_X.feature_names_in_]

# 6. Chuẩn hóa
forecast_scaled = scaler_X.transform(forecast)
forecast_scaled_df = pd.DataFrame(forecast_scaled, columns=forecast.columns)

# 7. Lưu lại
forecast_scaled_df.to_csv('forecast_data_scaled.csv', index=False)

print("forecast_data.csv đã được chuẩn hóa thành công.")
