import pandas as pd

# Đọc file dữ liệu lịch sử
data = pd.read_csv(r'C:\Users\ngoch\OneDrive\Desktop\giáo trình\2025-2026\Đồ án 2\data\DATA.csv')
print("DATA.csv:")
print(data.head())

# Đọc file dữ liệu dự báo thời tiết
forecast = pd.read_csv(r'C:\Users\ngoch\OneDrive\Desktop\giáo trình\2025-2026\Đồ án 2\data\forecast_data.csv')
print("\nforecast_data.csv:")
print(forecast.head())
print("Input complete")