import pandas as pd
from sklearn.preprocessing import MinMaxScaler
import joblib

# 1. Đọc dữ liệu
data = pd.read_csv('DATA.csv')

# 2. Xử lý cột thời gian
data['period'] = pd.to_datetime(data['period'])
data['hour'] = data['period'].dt.hour
data['dayofweek'] = data['period'].dt.dayofweek
data['month'] = data['period'].dt.month

# 3. Tách y và loại bỏ 'period'
y = data['power']
X = data.drop(columns=['power', 'period'])

# 4. Chuẩn hóa X
scaler_X = MinMaxScaler()
X_scaled = scaler_X.fit_transform(X)

# 5. Tạo lại DataFrame
scaled_df = pd.DataFrame(X_scaled, columns=X.columns)
scaled_df['power'] = y.reset_index(drop=True)

# 6. Lưu
scaled_df.to_csv('DATA_scaled.csv', index=False)
joblib.dump(scaler_X, 'scaler_X.save')

print(" Đã chuẩn hóa DATA.csv thành công.")
