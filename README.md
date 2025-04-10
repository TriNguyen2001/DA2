------------------------------------------------Python v 3.11.9----------------------------------------------

1. pip install pandas
2. pip install scikit-learn
3. pip install joblib
4. pip install matplotlib
5. pip install xgboost
6. pip install seaborn
7. pip install openpyxl


-------------------------------------------Mô hình đề xuất: KPCA–XGB–GRU------------------------------------
1. Tiền xử lý dữ liệu (Preprocessing)
    + Chuẩn hóa dữ liệu bằng chuẩn Min-Max.
    + Lọc chọn đặc trưng bằng 3 bước:
         - Phân tích tương quan Pearson → loại bỏ các đặc trưng dư thừa, không liên quan mạnh đến power.
         - XGBoost → đánh giá mức độ quan trọng của các đặc trưng dựa trên đóng góp vào mô hình.
         - Giảm chiều với Kernel PCA (KPCA) → giữ lại thông tin quan trọng theo cách phi tuyến.
2. Dự báo với mạng GRU phân cụm theo thời gian
    + Dữ liệu được chia theo thời gian trong ngày:
        - Buổi sáng (6-11am)
        - Buổi trưa (11-3pm)
        - Buổi chiều (3-6pm)
    🧠 Mỗi khung giờ sẽ được dự báo bởi một mô hình GRU riêng biệt để tối ưu hóa độ chính xác, do đặc điểm dữ liệu có thể khác nhau theo khung giờ.
3. Hậu xử lý (Postprocessing)
     + Hiệu chỉnh sai số bằng đường cong sai số trung bình bậc 4 (polynomial smoothing – cấp 4), để làm mượt kết quả đầu ra.
     + Tối ưu hóa kết quả đầu ra bằng cách:
         - Sử dụng dữ liệu ngoại lai và sai số để điều chỉnh dự báo cuối cùng.
         - Mục tiêu: giảm độ lệch và tăng độ chính xác tổng thể.

------------------------------------------------GRU------------------------------------------------------

Step 1: Chuẩn bị dữ liệu đầu vào 
      Dữ liệu X gồm:
            Các giá trị power(t–1) đến power(t–24).
            Các đặc trưng quan trọng khác từ bước tiền xử lý (KPCA, XGBoost...).
Step 2: Đưa dữ liệu vào GRU
      Mỗi hàng của X được chuẩn hóa và reshape theo định dạng [samples, timesteps, features].
      GRU có:
            2 lớp ẩn, mỗi lớp 100 nodes.
            Batch size: 16
            Epochs: 100
Step 3: Đầu ra GRU
      Kết quả từ lớp GRU được đưa vào một mạng fully connected (Dense).
      Đầu ra là một node duy nhất – đại diện cho công suất mặt trời dự báo.
      
Step 4: Tối ưu siêu tham số
      Tối ưu hidden_units và learning_rate bằng phương pháp như grid search hoặc random search.
      Kết quả tối ưu được tổng hợp trong bảng kết quả.
      
----------------------------------------------PVsyst------------------------------------------------------

![image](https://github.com/user-attachments/assets/d880ecea-036c-46ee-ac43-36e794d1fcea)

![image](https://github.com/user-attachments/assets/9886f7d1-d1b7-4f3c-a142-62ef571fbc5a)

![image](https://github.com/user-attachments/assets/3040dd90-b749-42fb-8d10-dce640f4e2cb)

![image](https://github.com/user-attachments/assets/053fd3e5-f480-4f8a-8b85-cf2363e23c86)

https://xbsolar.vn/san-pham/tam-pin-mat-troi-first-solar-fs6440w-fs-6440-fs6440a/






