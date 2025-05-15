;--------------------------------buổi 1--------------------------------------
;Bài 1: Viết chương trình đọc liên tục trạng thái của DIP Switch và gửi ra LED. Nếu Swich ở trạng thái OFF, LED tương ứng sẽ tắt.
;port A ket noi voi dip switch 
; port B ket noi voi bar led 

.ORG 0
RJMP MAIN             ; Nhảy đến chương trình chính (MAIN)

.ORG 0x40             ; Đưa chương trình ra khỏi vùng ngắt (interrupt vector)

MAIN:
    ; === Thiết lập Stack Pointer ===
    LDI R16, HIGH(RAMEND)
    OUT SPH, R16       ; Ghi byte cao của địa chỉ stack
    LDI R16, LOW(RAMEND)
    OUT SPL, R16       ; Ghi byte thấp của địa chỉ stack

    ; === Cấu hình PORTB là output (LED) ===
    LDI R16, 0xFF
    OUT DDRB, R16      ; Thiết lập toàn bộ PORTB là output (PB0–PB7)

    ; === Cấu hình PORTA là input (DIP Switch) ===
    LDI R16, 0x00
    OUT DDRA, R16      ; Thiết lập toàn bộ PORTA là input (PA0–PA7)

    ; === Bật điện trở kéo lên (pull-up) cho PORTA ===
    LDI R16, 0xFF
    OUT PORTA, R16     ; Kéo lên tất cả các chân input để tránh nhiễu

LOOP:
    IN R16, PINA       ; Đọc trạng thái DIP Switch từ PORTA vào R16
    LDI R17, 0xFF      ; R17 = 0xFF để dùng trong phép XOR đảo bit

    EOR R16, R17       ; Đảo bit trong R16: DIP OFF (1) thành 0 (LED tắt), DIP ON (0) thành 1 (LED sáng)

    OUT PORTB, R16     ; Gửi giá trị đã đảo ra PORTB để điều khiển LED

    RJMP LOOP          ; Quay lại vòng lặp để đọc lại DIP switch




;Bài 2: a)	Kết nối PA0 vào 1 Switch đơn và PA1 vào 1 LED đơn trên khối LED (lưu ý là cùng 1 Port)
;       b)	Viết chương trình bật LED nếu SW nhấn, tắt LED nếu SW nhả.

; AssemblerApplication2.asm  
 ; Created: 2/14/2025 12:15:01 AM   
; Author : KhuongNguyen 
 ; Replace with your application code 
 ; PA0 NOI VOI SWITCH DON  
; PA1 NOI VOI LED DON  
;-------------------------------------------------------------
; Đọc trạng thái DIP Switch (PA0) để điều khiển LED (PA1)
; Nếu nhấn switch → LED sáng
; Nếu thả switch → LED tắt
; Có delay chống dội phím ~10ms
;-------------------------------------------------------------

.ORG 0
    RJMP MAIN             ; Nhảy đến chương trình chính

.ORG 0x40                 ; Bỏ vùng vector ngắt, bắt đầu chương trình tại địa chỉ an toàn

MAIN:
    ; === Cấu hình Stack Pointer ===
    LDI R16, HIGH(RAMEND)
    OUT SPH, R16
    LDI R16, LOW(RAMEND)
    OUT SPL, R16

    ; === Cấu hình PORTA ===
    SBI DDRA, 1            ; PA1 là output → nối LED
    CBI DDRA, 0            ; PA0 là input  → nối công tắc

    SBI PORTA, 0           ; Bật điện trở kéo lên cho PA0 (pull-up)
    CBI PORTA, 1           ; Đặt PA1 ban đầu = 0 (LED tắt)

;-------------------------------------------------------------
; Vòng lặp chính kiểm tra trạng thái công tắc
;-------------------------------------------------------------

LED_ON:
    SBIC PINA, 0           ; Nếu PA0 = 1 (chưa nhấn) → bỏ qua dòng sau
    RJMP LED_OFF           ; Nếu PA0 = 0 (đã nhấn) → chuyển sang bật LED

    SBI PORTA, 1           ; PA1 = 1 → bật LED
    RCALL DL10ms           ; Delay chống dội
    RJMP LED_ON            ; Quay lại kiểm tra switch

LED_OFF:
    SBIS PINA, 0           ; Nếu PA0 = 0 (vẫn đang nhấn) → bỏ qua dòng sau
    RJMP LED_ON            ; Nếu PA0 = 1 (thả ra) → quay lại bật LED

    CBI PORTA, 1           ; PA1 = 0 → tắt LED
    RCALL DL10ms           ; Delay chống dội
    RJMP LED_OFF           ; Quay lại kiểm tra switch


DL10ms:
    LDI R21, 10            ; Vòng lặp ngoài: m = 10
LP2:
    LDI R20, 250           ; Vòng lặp trong: n = 250
LPI:
    NOP                    ; Không làm gì (1 chu kỳ)
    DEC R20                ; Giảm n
    BRNE LPI               ; Nếu n ≠ 0 → lặp tiếp
    DEC R21                ; Giảm m
    BRNE LP2               ; Nếu m ≠ 0 → lặp lại
    RET                    ; Kết thúc hàm delay


;Bài 3: a)	Viết chương trình con Delay1ms và dùng nó để viết chương trình tạo xung vuông tần số 1Khz trên PA0.

;-------------------------------------------------------
; Phát xung vuông tại PA0 với chu kỳ ~8ms (tần số ~125Hz)
;-------------------------------------------------------

.ORG 0
    RJMP MAIN             ; Nhảy đến chương trình chính khi khởi động

.ORG 0x40                 ; Đặt chương trình ra khỏi vùng vector ngắt

MAIN:
    ; === Cấu hình Stack Pointer ===
    LDI R16, HIGH(RAMEND)
    OUT SPH, R16
    LDI R16, LOW(RAMEND)
    OUT SPL, R16          ; Đưa stack lên vùng địa chỉ cao

    ; === Cấu hình PORTA ===
    SBI DDRA, 0           ; PA0 là output (kết nối tín hiệu xung)

;-------------------------------------------------------
; Vòng lặp tạo xung vuông: 4ms HIGH → 4ms LOW
;-------------------------------------------------------
LOOP:
    SBI PORTA, 0          ; Đặt PA0 = 1 (mức cao)
    RCALL Delay1ms        ; Delay 1ms
    RCALL Delay1ms        ; Delay 1ms
    RCALL Delay1ms        ; Delay 1ms
    RCALL Delay1ms        ; Delay 1ms (tổng 4ms)

    CBI PORTA, 0          ; Đặt PA0 = 0 (mức thấp)
    RCALL Delay1ms        ; Delay 1ms
    RCALL Delay1ms        ; Delay 1ms
    RCALL Delay1ms        ; Delay 1ms
    RCALL Delay1ms        ; Delay 1ms (tổng 4ms)

    RJMP LOOP             ; Quay lại tạo xung liên tục

;-------------------------------------------------------
; Subroutine Delay 1ms = 2 x Delay500us
;-------------------------------------------------------
Delay1ms:
    RCALL Delay500us
    RCALL Delay500us
    RET

;-------------------------------------------------------
; Subroutine Delay ~500us (gần đúng)
; Tần số hoạt động của vi điều khiển (giả sử là 1 MHz)
; 1 chu kỳ lệnh ≈ 1 μs  1/1000000hz = 1μs 
; số lần lặp 500us/4us=125 lần lặp 
;-------------------------------------------------------
Delay500us:
    LDI R20, 124          ; Lặp 124 lần
LPA:                                                  ; tổng là 4 chu kỳ
    NOP                   ; Không làm gì (1 chu kỳ)             1 chu kỳ
    DEC R20               ; Giảm bộ đếm                         1 chu kỳ
    BRNE LPA              ; Nếu chưa về 0 thì lặp tiếp    2 chu kỳ (nếu nhảy)
    RET



;Bài 4 : bật tắt đèn delay 1ms; 10ms ; 100ms; 1s

.ORG 0
    RJMP MAIN           ; Nhảy tới phần MAIN để bắt đầu chương trình
.ORG 0X40              ; Đưa chương trình ra khỏi vùng Interrupts

MAIN:
    ; Thiết lập Stack Pointer
    LDI R16, HIGH(RAMEND)  
    OUT SPH, R16        ; Cài đặt địa chỉ stack cao
    LDI R16, LOW(RAMEND)  
    OUT SPL, R16        ; Cài đặt địa chỉ stack thấp

    ; Cấu hình PA0 là OUTPUT
    SBI DDRA, 0         ; PA0 là OUTPUT
    ; Cấu hình PA1 là INPUT
    CBI DDRA, 1         ; PA1 là INPUT (DIP switch hoặc công tắc)

    ; Tạo xung vuông trên PA0
LOOP:
    SBI PORTA, 0        ; Tạo xung cao (1) trên PA0
    RCALL Delay1ms      ; Gọi hàm Delay1ms (1ms)
    CBI PORTA, 0        ; Tạo xung thấp (0) trên PA0
    RCALL Delay1ms      ; Gọi hàm Delay1ms (1ms)
    RJMP LOOP           ; Lặp lại vô hạn

; Hàm Delay500us
Delay500us:
    LDI R20, 124        ; Lặp 124 lần (để tạo độ trễ 500us)
LPA:
    NOP                 ; Lệnh không làm gì (1 chu kỳ)
    DEC R20             ; Giảm giá trị R20
    BRNE LPA            ; Nếu R20 chưa bằng 0 thì lặp lại
    RET                 ; Quay lại hàm gọi

; Hàm Delay1ms
Delay1ms:
    RCALL Delay500us    ; Gọi hàm Delay500us
    RCALL Delay500us    ; Gọi lại hàm Delay500us để tạo độ trễ 1ms
    RET                 ; Quay lại hàm gọi

; Hàm Delay10ms
Delay10ms:
    LDI R21, 10         ; Lặp 10 lần
LPB:
    RCALL Delay1ms      ; Gọi hàm Delay1ms
    DEC R21             ; Giảm giá trị R21
    BRNE LPB            ; Nếu R21 chưa về 0 thì lặp lại
    RET                 ; Quay lại hàm gọi

; Hàm Delay100ms
Delay100ms:
    LDI R21, 100        ; Lặp 100 lần
LPC:
    RCALL Delay1ms      ; Gọi hàm Delay1ms
    DEC R21             ; Giảm giá trị R21
    BRNE LPC            ; Nếu R21 chưa về 0 thì lặp lại
    RET                 ; Quay lại hàm gọi

; Hàm Delay1s
Delay1s:
    LDI R22, 24         ; Lặp 24 lần (mỗi lần lặp sẽ mất 250ms)
LP2:
    LDI R21, 250        ; Lặp 250 lần
LP1:
    RCALL Delay1ms      ; Gọi hàm Delay1ms
    DEC R21             ; Giảm giá trị R21
    BRNE LP1            ; Nếu R21 chưa về 0 thì lặp lại
    DEC R22             ; Giảm giá trị R22
    BRNE LP2            ; Nếu R22 chưa về 0 thì lặp lại
    RET                 ; Quay lại hàm gọi


;Bài 5: viết chương trình tạo hiệu ứng LED sáng dần từ trái qua phải, sau đo tắt dần từ trái qua phải sau mỗi khoảng thời gian 500ms.

.ORG 0
    RJMP MAIN           ; Nhảy tới phần MAIN để bắt đầu chương trình

.ORG 0X40              ; Đưa chương trình ra khỏi vùng Interrupts

MAIN:
    ; Thiết lập Stack Pointer
    LDI R16, HIGH(RAMEND)  
    OUT SPH, R16        ; Cài đặt địa chỉ stack cao
    LDI R16, LOW(RAMEND)  
    OUT SPL, R16        ; Cài đặt địa chỉ stack thấp

    ; Cấu hình PA0 là OUTPUT
    SBI DDRA, 0         ; PA0 là OUTPUT
    ; Cấu hình PA1 là INPUT
    CBI DDRA, 1         ; PA1 là INPUT (DIP switch hoặc công tắc)

    ; Tạo xung vuông trên PA0
LOOP:
    SBI PORTA, 0        ; Tạo xung cao (1) trên PA0
    RCALL Delay1s       ; Gọi hàm Delay1s (1 giây)
    CBI PORTA, 0        ; Tạo xung thấp (0) trên PA0
    RCALL Delay1s       ; Gọi hàm Delay1s (1 giây)
    RJMP LOOP           ; Lặp lại vô hạn

; Hàm Delay500us
Delay500us:
    LDI R20, 124        ; Lặp 124 lần (để tạo độ trễ 500us)
LPA:
    NOP                 ; Lệnh không làm gì (1 chu kỳ)
    DEC R20             ; Giảm giá trị R20
    BRNE LPA            ; Nếu R20 chưa bằng 0 thì lặp lại
    RET                 ; Quay lại hàm gọi

; Hàm Delay1ms
Delay1ms:
    RCALL Delay500us    ; Gọi hàm Delay500us
    RCALL Delay500us    ; Gọi lại hàm Delay500us để tạo độ trễ 1ms
    RET                 ; Quay lại hàm gọi

; Hàm Delay1msnew
Delay1msnew:
    RCALL Delay1ms      ; Gọi hàm Delay1ms
    RCALL Delay1ms      ; Gọi lại hàm Delay1ms
    RCALL Delay1ms      ; Gọi lại hàm Delay1ms
    RCALL Delay1ms      ; Gọi lại hàm Delay1ms
    RET                 ; Quay lại hàm gọi

; Hàm Delay10msnew
Delay10msnew:
    RCALL Delay1msnew   ; Gọi hàm Delay1msnew
    RCALL Delay1msnew   ; Gọi lại hàm Delay1msnew
    RCALL Delay1msnew   ; Gọi lại hàm Delay1msnew
    RCALL Delay1msnew   ; Gọi lại hàm Delay1msnew
    RCALL Delay1msnew   ; Gọi lại hàm Delay1msnew
    RCALL Delay1msnew   ; Gọi lại hàm Delay1msnew
    RCALL Delay1msnew   ; Gọi lại hàm Delay1msnew
    RCALL Delay1msnew   ; Gọi lại hàm Delay1msnew
    RCALL Delay1msnew   ; Gọi lại hàm Delay1msnew
    RET                 ; Quay lại hàm gọi

; Hàm Delay100msnew
Delay100msnew:
    RCALL Delay10msnew  ; Gọi hàm Delay10msnew
    RCALL Delay10msnew  ; Gọi lại hàm Delay10msnew
    RCALL Delay10msnew  ; Gọi lại hàm Delay10msnew
    RCALL Delay10msnew  ; Gọi lại hàm Delay10msnew
    RCALL Delay10msnew  ; Gọi lại hàm Delay10msnew
    RCALL Delay10msnew  ; Gọi lại hàm Delay10msnew
    RCALL Delay10msnew  ; Gọi lại hàm Delay10msnew
    RCALL Delay10msnew  ; Gọi lại hàm Delay10msnew
    RCALL Delay10msnew  ; Gọi lại hàm Delay10msnew
    RET                 ; Quay lại hàm gọi

; Hàm Delay1s
Delay1s:
    LDI R22, 24         ; Lặp 24 lần (mỗi lần lặp sẽ mất 250ms)
LP2:
    LDI R21, 250        ; Lặp 250 lần
LP1:
    RCALL Delay1ms      ; Gọi hàm Delay1ms
    DEC R21             ; Giảm giá trị R21
    BRNE LP1            ; Nếu R21 chưa về 0 thì lặp lại
    DEC R22             ; Giảm giá trị R22
    BRNE LP2            ; Nếu R22 chưa về 0 thì lặp lại
    RET                 ; Quay lại hàm gọi


;--------------------------------buổi 2-------------------------------------

;Bài 1: hiển thị số 5 hàng chục led 7 đoạn

.ORG 0
main: 
    ldi r27, 5              ; Đặt giá trị 5 vào thanh ghi R27
    ldi r26, 2              ; Đặt chỉ số LED (LED index) vào R26
    call display_7seg       ; Gọi hàm hiển thị giá trị trên LED 7 đoạn

; Lookup table for 7-segment codes (dùng cho LED 7 đoạn)
table_7seg_data: 
    .DB 0XC0, 0XF9, 0XA4, 0XB0, 0X99, 0X92, 0X82, 0XF8, 0X80, 0X90, 0X88, 0XC6, 0XA1, 0X86, 0X8E

; Lookup table for LED control (điều khiển các chân để chọn LED)
table_7seg_control: 
    .DB 0b00001110, 0b00001101, 0b00001011, 0b00000111

; Cấu hình cổng và chân điều khiển LED
.equ LED7SEGPORT = PORTD
.equ LED7SEGDIR = DDRD
.equ LED7SEGLatchPORT = PORTB
.equ LED7SEGLatchDIR = DDRB
.equ nLE0Pin = 4
.equ nLE1Pin = 5

led7seg_portinit: 
    push r20
    ldi r20, 0b11111111       ; Cấu hình cổng LED 7 đoạn là output
    out LED7SEGDIR, r20
    in r20, LED7SEGLatchDIR    ; Đọc giá trị của cổng latch
    ori r20, (1<<nLE0Pin) | (1 << nLE1Pin)  ; Cấu hình các chân điều khiển LED
    out LED7SEGLatchDIR, r20
    pop r20
    ret

; Hàm hiển thị giá trị trên LED 7 đoạn
; Input: R27 chứa giá trị cần hiển thị (0..9)
;        R26 chứa chỉ số của LED (0..3)
; Output: Hiển thị giá trị của R27 trên LED 7 đoạn tương ứng
display_7seg: 
    push r16                 ; Lưu tạm thanh ghi R16
    ; Lấy mã 7-segment từ bảng tra cứu
    ldi zh, high(table_7seg_data)   ; Địa chỉ của bảng mã 7-segment
    ldi zl, low(table_7seg_data)
    clr r16
    add r30, r27             ; Tính địa chỉ của phần tử trong bảng (R27 là giá trị 0..9)
    adc r31, r16
    lpm r16, z               ; Lấy mã 7-segment cho giá trị từ bảng
    out LED7SEGPORT, r16     ; Gửi mã vào cổng LED

    ; Điều khiển chân nLE0 để latch giá trị vào LED
    sbi LED7SEGLatchPORT, nLE0Pin
    nop
    cbi LED7SEGLatchPORT, nLE0Pin

    ; Lấy mã điều khiển LED từ bảng tra cứu
    ldi zh, high(table_7seg_control)  ; Địa chỉ của bảng mã điều khiển LED
    ldi zl, low(table_7seg_control)
    clr r16
    add r30, r26             ; Tính địa chỉ của phần tử trong bảng (R26 là chỉ số LED)
    adc r31, r16
    lpm r16, z               ; Lấy mã điều khiển cho LED
    out LED7SEGPORT, r16     ; Gửi mã điều khiển vào cổng LED

    ; Điều khiển chân nLE1 để latch giá trị vào LED
    sbi LED7SEGLatchPORT, nLE1Pin
    nop
    cbi LED7SEGLatchPORT, nLE1Pin

    pop r16                  ; Khôi phục thanh ghi R16
    ret                      ; Trở về từ hàm


;Bài 2: hiển thị 2025 lên led 7 đoạn 

.EQU OUTLED = PORTD              ; Cổng xuất dữ liệu điều khiển LED 7 đoạn
.EQU OUTLED_DDR = DDRD           ; Cổng điều khiển hướng của PORTD
.EQU SL_LED = PORTB               ; Cổng điều khiển chọn LED (nLE0, nLE1)
.EQU SL_LED_DDR = DDRB            ; Cổng điều khiển hướng của PORTB
.EQU nLE0 = PB0                   ; Chân điều khiển nLE0
.EQU nLE1 = PB1                   ; Chân điều khiển nLE1

.ORG 0
RJMP MAIN                        ; Nhảy đến MAIN

.ORG 0x40
MAIN: 
    SER R16                       ; Đặt tất cả các bit của R16 bằng 1
    OUT OUTLED_DDR, R16           ; Cấu hình PORTD là output (điều khiển LED 7 đoạn)
    LDI R16, (1<<nLE0) | (1<<nLE1) ; Đặt các bit nLE0 và nLE1 là 1 (cổng điều khiển LED)
    OUT SL_LED_DDR, R16           ; Cấu hình PORTB là output (điều khiển chọn LED)

START: 
    RCALL SCAN_4LA                ; Gọi hàm SCAN_4LA để quét và hiển thị
    RJMP START                     ; Quay lại START để tiếp tục

;------------------------------- 
SCAN_4LA: 
    LDI R18, 4                    ; Lặp lại 4 lần (số LED cần điều khiển)
    LDI R19, 0xF7                 ; Khởi tạo R19 với giá trị 0xF7
    CLR R20                        ; Xóa R20

LOOP: 
    LDI R17, 0xFF                 ; Đặt giá trị R17 là 0xFF
    OUT OUTLED, R17               ; Gửi giá trị 0xFF đến LED
    SBI SL_LED, nLE1              ; Bật chân nLE1
    CBI SL_LED, nLE1              ; Tắt chân nLE1

    MOV R17, R20                  ; Di chuyển giá trị của R20 vào R17
    RCALL GET_7SEG                ; Lấy mã 7-segment cho giá trị trong R17
    OUT OUTLED, R17               ; Gửi mã 7-segment ra LED
    SBI SL_LED, nLE0              ; Bật chân nLE0
    CBI SL_LED, nLE0              ; Tắt chân nLE0
    INC R20                        ; Tăng R20 để chọn LED kế tiếp
    OUT OUTLED, R19               ; Gửi giá trị R19 (0xF7) để điều khiển LED
    SBI SL_LED, nLE1              ; Bật chân nLE1
    CBI SL_LED, nLE1              ; Tắt chân nLE1

    RCALL DELAY_5MS               ; Gọi hàm tạo độ trễ 5ms
    SEC                           ; Dịch bit phải R19
    ROR R19
    DEC R18                       ; Giảm R18 (đếm số lần quét)
    BRNE LOOP                     ; Nếu R18 != 0 thì tiếp tục lặp

    RET                            ; Trả về từ hàm SCAN_4LA

;-------------------------------
; Hàm DELAY_5MS sử dụng Timer0 CTC mode
DELAY_5MS: 
    PUSH R17                      ; Lưu giá trị của R17
    PUSH R16                      ; Lưu giá trị của R16
    LDI R16, 39-1                 ; Đặt giá trị OCR0A (39 cho độ trễ 5ms)
    OUT OCR0A, R16                ; Gửi giá trị OCR0A vào thanh ghi
    LDI R16, (1 << WGM01)         ; Cấu hình chế độ CTC cho Timer0
    OUT TCCR0A, R16
    LDI R16, (1 << CS02) | (1 << CS00) ; Chọn bộ chia tần số là 1024
    OUT TCCR0B, R16
WAIT: 
    SBIS TIFR0, OCF0A             ; Kiểm tra cờ OCF0A (giải phóng Timer0)
    RJMP WAIT                     ; Nếu chưa có tín hiệu, quay lại WAIT
    SBI TIFR0, OCF0A              ; Xóa cờ OCF0A để chuẩn bị cho lần sau
    POP R16                       ; Khôi phục giá trị của R16
    POP R17                       ; Khôi phục giá trị của R17
    RET                           ; Trả về từ hàm DELAY_5MS

;-------------------------------
; Hàm GET_7SEG để tra cứu mã 7-segment
GET_7SEG: 
    LDI ZH, HIGH(TAB_7SA<<1)      ; Địa chỉ bảng mã 7-segment
    LDI ZL, LOW(TAB_7SA<<1)
    ADD R30, R17                   ; Tính địa chỉ của mã cần lấy
    LDI R17, 0
    ADC R31, R17
    LPM R17, Z                     ; Lấy mã 7-segment từ bảng tra cứu
    RET                            ; Trả về từ hàm GET_7SEG

;-------------------------------
; Bảng mã 7-segment
TAB_7SA: 
    .DB 0XA4, 0XC0, 0XA4, 0X92    ; Mã 7-segment cho các chữ số (0, 1, 2, 3...)


;Bài 3: nhập giá trị nhị phân 8 bit Dip sw, chuyển đổi sang 3 số BCD hiển thị lên led 7 đoạn hàng đơn vị, chục, trăm

.EQU INPUT_DDR = DDRA              ; Cấu hình cổng A làm đầu vào (DIP switch hoặc phím điều khiển)
.EQU INPUT = PINA                  ; Đọc dữ liệu từ cổng A
.EQU INPUT_RES = PORTA             ; Cấu hình PORTA với điện trở kéo lên (pull-up)
.EQU OUTLED = PORTD                ; Đầu ra màn hình 7 đoạn
.EQU OUTLED_DDR = DDRD             ; Cấu hình PORTD làm đầu ra
.EQU SL_LED = PORTB                ; Cổng điều khiển LED chọn chế độ
.EQU SL_LED_DDR = DDRB             ; Cấu hình PORTB làm đầu ra
.EQU nLE0 = PB0                    ; Đầu ra LED điều khiển chọn chế độ 0
.EQU nLE1 = PB1                    ; Đầu ra LED điều khiển chọn chế độ 1
.DEF CONT9 = R9                    ; Lưu trữ giá trị của CONT9 (hằng số 9)
.DEF REG_IN = R10                  ; Lưu trữ giá trị đầu vào từ DIP switch
.EQU BCD_BUF = 0X100               ; Địa chỉ bộ nhớ lưu trữ giá trị BCD (4 chữ số)
.DEF OPD1_L = R20                  ; Phần thấp của giá trị 16-bit
.DEF OPD1_H = R21                  ; Phần cao của giá trị 16-bit
.DEF OPD2 = R23                    ; Lưu trữ số chia (ở đây là 10)
.DEF OPD3 = R8                     ; Dự trữ số dư của phép chia
.DEF COUNT = R16                   ; Bộ đếm
.ORG 0                             ; Đặt vị trí bắt đầu chương trình
RJMP MAIN                          ; Nhảy đến nhãn MAIN

.ORG 40                            ; Đặt vị trí bắt đầu mã MAIN
MAIN:                              
    CLR R16                        ; Xóa thanh ghi R16 (giá trị 0)
    OUT INPUT_DDR, R16             ; Cấu hình cổng A làm đầu vào
    OUT OUTLED_DDR, R16            ; Cấu hình cổng D làm đầu ra
    OUT INPUT_RES, R16             ; Cấu hình cổng A với điện trở kéo lên
    LDI R16, (1 << nLE0) | (1 << nLE1)  ; Lưu giá trị điều khiển các LED
    OUT SL_LED_DDR, R16            ; Cấu hình cổng B làm đầu ra
    LDI R16, 9                     ; Đặt giá trị CONT9 là 9
    MOV CONT9, R16                 ; Lưu giá trị CONT9 vào thanh ghi

START:
    IN REG_IN, INPUT               ; Đọc dữ liệu từ cổng A vào REG_IN
    COM REG_IN                     ; Đảo ngược giá trị REG_IN
    MUL CONT9, REG_IN              ; Nhân CONT9 với REG_IN
    MOV OPD1_L, R0                 ; Lưu phần thấp kết quả vào OPD1_L
    MOV OPD1_H, R1                 ; Lưu phần cao kết quả vào OPD1_H
    RCALL BIN16_BCD4DG             ; Chuyển đổi số nhị phân 16-bit sang BCD
    RCALL SCAN_4LA                 ; Quét và cập nhật màn hình 7 đoạn
    RJMP START                      ; Quay lại đầu vòng lặp

; Chuyển đổi số nhị phân 16-bit sang BCD 4 chữ số
BIN16_BCD4DG:
    LDI XH, HIGH(BCD_BUF)          ; Đặt con trỏ X đến địa chỉ bắt đầu của BCD_BUF
    LDI XL, LOW(BCD_BUF)           ; Đặt phần thấp của con trỏ X
    LDI COUNT, 4                   ; Đếm 4 chữ số BCD
    LDI R17, 0x00                  ; Khởi tạo giá trị đầu vào là 0
LP_CL:
    ST X+, R17                     ; Xóa giá trị trong bộ đệm BCD
    DEC COUNT                      ; Giảm bộ đếm
    BRNE LP_CL                     ; Nếu chưa đủ 4 chữ số, tiếp tục xóa
    LDI OPD2, 10                   ; Đặt số chia là 10 (cho phép chia thập phân)
DIV_NXT:
    RCALL DIV16_8                  ; Chia số nhị phân 16-bit cho 10
    BIT CHO 10                     ; Kiểm tra bit
    ST -X, OPD3                    ; Lưu số dư vào bộ đệm
    CPI OPD1_L, 0                  ; Kiểm tra nếu phần thấp bằng 0
    BRNE DIV_NXT                   ; Nếu chưa hết số, tiếp tục chia
    RET

; Chia số nhị phân 16-bit cho một số 8-bit
DIV16_8:
    LDI COUNT, 16                  ; Đếm 16 lần dịch bit
    CLR OPD3                       ; Xóa phần dư
SH_NXT:
    CLC                            ; Xóa cờ Carry
    LSL OPD1_L                     ; Dịch trái phần thấp của số chia
    ROL OPD1_H                     ; Quay trái phần cao của số chia
    ROL OPD3                        ; Quay trái dư số
    BRCS OV_C                      ; Nếu có tràn, xử lý lỗi
    SUB OPD3, OPD2                 ; Trừ dư số với số chia
    BRCC GT_TH                     ; Nếu không có carry, tiếp tục chia
    ADD OPD3, OPD2                 ; Nếu có carry, cộng lại
    RJMP NEXT
OV_C:
    SUB OPD3, OPD2                 ; Trừ dư số với số chia
GT_TH:
    SBR OPD1_L, 1                  ; Cập nhật thương số
NEXT:
    DEC COUNT                      ; Giảm bộ đếm
    BRNE SH_NXT                    ; Nếu chưa đủ, tiếp tục dịch bit
    RET

; Quét màn hình LED 7 đoạn
SCAN_4LA:
    LDI R18, 4                     ; Đặt số lần quét LED
    LDI R19, 0xF7                  ; Mã quét LED anode
    LDI XH, HIGH(BCD_BUF)          ; Đặt con trỏ X tới bộ đệm BCD
    LDI XL, LOW(BCD_BUF)           ; Đặt phần thấp của con trỏ X
LOOP:
    LDI R17, 0xFF                  ; Tắt tất cả các LED
    OUT OUTLED, R17                ; Gửi giá trị này ra PORTD
    SBI SL_LED, nLE1               ; Mở LED nLE1
    CBI SL_LED, nLE1               ; Đóng LED nLE1
    LD R17, X+                     ; Lấy giá trị từ bộ đệm BCD
    RCALL GET_7SEG                 ; Lấy mã 7 đoạn tương ứng
    OUT OUTLED, R17                ; Hiển thị giá trị lên màn hình
    SBI SL_LED, nLE0               ; Mở LED nLE0
    CBI SL_LED, nLE0               ; Đóng LED nLE0
    OUT OUTLED, R19                ; Xuất mã quét anode
    SBI SL_LED, nLE1               ; Mở LED nLE1
    CBI SL_LED, nLE1               ; Đóng LED nLE1
    RCALL DELAY_5MS                ; Tạo độ trễ 5ms
    SEC                            ; Chuẩn bị quay bit của mã quét
    ROR R19                        ; Quay mã quét
    DEC R18                        ; Giảm số lần quét
    BRNE LOOP                      ; Nếu chưa quét đủ 4 lần, quay lại vòng lặp
    RET

; Hàm tạo độ trễ 5ms bằng Timer0
DELAY_5MS:
    PUSH R17
    PUSH R16
    LDI R16, 39-1                  ; Đặt giá trị TOP của Timer0
    OUT OCR0A, R16                 ; Cấu hình giá trị so sánh
    LDI R16, (1 << WGM01)          ; Cấu hình chế độ CTC
    OUT TCCR0A, R16
    LDI R16, (1 << CS02) | (1 << CS00)  ; Cấu hình bộ chia tần số 1024
    OUT TCCR0B, R16
WAIT:
    SBIS TIFR0, OCF0A              ; Chờ cờ OCF0A
    RJMP WAIT                      ; Nếu chưa có, tiếp tục chờ
    SBI TIFR0, OCF0A               ; Xóa cờ OCF0A
    POP R16
    POP R17
    RET

; Hàm lấy mã 7 đoạn cho giá trị đầu vào
GET_7SEG:
    LDI ZH, HIGH(TAB_7SA << 1)    ; Đặt con trỏ Z tới bảng mã 7 đoạn
    LDI ZL, LOW(TAB_7SA << 1)
    ADD R30, R17                   ; Thêm offset vào chỉ số
    LDI R17, 0
    ADC R31, R17                   ; Cộng carry vào ZH
    LPM R17, Z                     ; Lấy mã từ bộ nhớ Flash
    RET

TAB_7SA:                             ; Bảng mã 7 đoạn
    .DB 0xC0, 0xF9, 0xA4, 0xB0, 0x99, 0x92, 0x82, 0xF8, 0x80, 0x90
    .DB 0x88, 0x83, 0xC6, 0xA1, 0x86, 0x8E

; BÀI 4: hiển thị 1 điểm sáng góc trai led ma trận

; Định nghĩa cổng điều khiển LED ma trận
.EQU LEDMATRIXPORT = PORTD           ; Cổng điều khiển LED ma trận, gán PORTD
.EQU LEDMATRIXDIR = DDRD             ; Định hướng cổng LED ma trận, gán DDRD

; Thanh ghi dịch - PORTB
.EQU SHIFTCLOCKPORT = PORTB         ; Cổng điều khiển tín hiệu đồng hồ (clock) cho thanh ghi dịch
.EQU SHIFTCLOCKPIN = 2              ; Chân điều khiển tín hiệu đồng hồ (clock) của thanh ghi dịch
.EQU LATCHPORT = PORTB              ; Cổng điều khiển tín hiệu latch (chốt) cho thanh ghi dịch
.EQU LATCHPIN = 1                   ; Chân điều khiển tín hiệu latch (chốt) của thanh ghi dịch
.EQU SHIFTDATAPORT = PORTB          ; Cổng điều khiển dữ liệu của thanh ghi dịch
.EQU SHIFTDATAPIN = 0               ; Chân điều khiển dữ liệu của thanh ghi dịch

.ORG 0x0000                         ; Đặt địa chỉ bắt đầu chương trình tại 0x0000
RJMP RESET_HANDLER                  ; Nhảy đến nhãn RESET_HANDLER để khởi động lại hệ thống

; Hàm khởi tạo chương trình
RESET_HANDLER:
LDI R16, HIGH(RAMEND)               ; Lưu giá trị cao của RAMEND vào thanh ghi R16
OUT SPH, R16                         ; Ghi giá trị cao vào thanh ghi SPH (Stack Pointer High)
LDI R16, LOW(RAMEND)                ; Lưu giá trị thấp của RAMEND vào thanh ghi R16
OUT SPL, R16                         ; Ghi giá trị thấp vào thanh ghi SPL (Stack Pointer Low)

; Cấu hình cổng LED ma trận và thanh ghi dịch
CALL LEDMATRIX_INIT                  ; Gọi hàm khởi tạo cổng LED ma trận
CALL SHIFTREGISTER_INITPORT          ; Gọi hàm khởi tạo cổng thanh ghi dịch

MAIN:
; Hiển thị điểm sáng (Cột 0, Hàng 7)
LDI R27, 0b10000000                 ; Đặt giá trị 0b10000000 (cột 0) vào thanh ghi R27
CALL SHIFTREGISTER_SHIFTOUTDATA     ; Gọi hàm xuất dữ liệu ra thanh ghi dịch
LDI R27, 0b10000000                 ; Đặt giá trị 0b10000000 (bật LED hàng 7) vào R27
OUT LEDMATRIXPORT, R27              ; Gửi dữ liệu vào cổng điều khiển LED ma trận
RJMP MAIN                           ; Lặp vô hạn

; ========================================
; Hàm khởi tạo cổng LED ma trận
LEDMATRIX_INIT:
LDI R16, 0xFF                      ; Gán giá trị 0xFF (tất cả chân đều là output)
OUT LEDMATRIXDIR, R16               ; Cấu hình cổng PORTD làm đầu ra
RET

; ========================================
; Hàm khởi tạo cổng thanh ghi dịch
SHIFTREGISTER_INITPORT:
LDI R16, (1<<SHIFTCLOCKPIN) | (1<<LATCHPIN) | (1<<SHIFTDATAPIN)  ; Cấu hình các chân của PORTB làm output
OUT DDRB, R16                    ; Cấu hình cổng PORTB làm đầu ra
RET

; ========================================
; Xuất dữ liệu ra thanh ghi dịch
SHIFTREGISTER_SHIFTOUTDATA:
PUSH R18                         ; Lưu giá trị của R18 vào stack
CBI SHIFTCLOCKPORT, SHIFTCLOCKPIN  ; Xóa tín hiệu đồng hồ (clock)
LDI R18, 8                        ; Đặt số lần dịch (8 bit dữ liệu)
SHIFTLOOP:
SBRC R27, 7                       ; Kiểm tra bit cao nhất của R27 (nếu bằng 1, bit 7)
SBI SHIFTDATAPORT, SHIFTDATAPIN    ; Nếu có, đặt bit dữ liệu
SBI SHIFTCLOCKPORT, SHIFTCLOCKPIN  ; Cấp tín hiệu clock cho thanh ghi dịch
LSL R27                           ; Dịch bit trái giá trị trong R27
CBI SHIFTCLOCKPORT, SHIFTCLOCKPIN  ; Xóa tín hiệu clock
CBI SHIFTDATAPORT, SHIFTDATAPIN    ; Xóa bit dữ liệu
DEC R18                           ; Giảm số lần dịch
BRNE SHIFTLOOP                     ; Nếu chưa đủ 8 bit, tiếp tục dịch
; Latch dữ liệu ra LED ma trận
SBI LATCHPORT, LATCHPIN            ; Đặt tín hiệu latch
CBI LATCHPORT, LATCHPIN            ; Xóa tín hiệu latch
POP R18                           ; Lấy lại giá trị của R18 từ stack
RET


;BÀI 5: 1 VẠCH SÁNG BÊN TRÁI LED MA TRẬN

; Định nghĩa cổng điều khiển LED ma trận
.EQU LEDMATRIXPORT = PORTD           ; Cổng điều khiển LED ma trận, gán PORTD
.EQU LEDMATRIXDIR = DDRD             ; Định hướng cổng LED ma trận, gán DDRD

; Thanh ghi dịch - PORTB
.EQU SHIFTCLOCKPORT = PORTB         ; Cổng điều khiển tín hiệu đồng hồ (clock) cho thanh ghi dịch
.EQU SHIFTCLOCKPIN = 2              ; Chân điều khiển tín hiệu đồng hồ (clock) của thanh ghi dịch
.EQU LATCHPORT = PORTB              ; Cổng điều khiển tín hiệu latch (chốt) cho thanh ghi dịch
.EQU LATCHPIN = 1                   ; Chân điều khiển tín hiệu latch (chốt) của thanh ghi dịch
.EQU SHIFTDATAPORT = PORTB          ; Cổng điều khiển dữ liệu của thanh ghi dịch
.EQU SHIFTDATAPIN = 0               ; Chân điều khiển dữ liệu của thanh ghi dịch

.ORG 0x0000                         ; Đặt địa chỉ bắt đầu chương trình tại 0x0000
RJMP RESET_HANDLER                  ; Nhảy đến nhãn RESET_HANDLER để khởi động lại hệ thống

; Hàm khởi tạo chương trình
RESET_HANDLER:
LDI R16, HIGH(RAMEND)               ; Lưu giá trị cao của RAMEND vào thanh ghi R16
OUT SPH, R16                         ; Ghi giá trị cao vào thanh ghi SPH (Stack Pointer High)
LDI R16, LOW(RAMEND)                ; Lưu giá trị thấp của RAMEND vào thanh ghi R16
OUT SPL, R16                         ; Ghi giá trị thấp vào thanh ghi SPL (Stack Pointer Low)

; Cấu hình cổng LED ma trận và thanh ghi dịch
CALL LEDMATRIX_INIT                  ; Gọi hàm khởi tạo cổng LED ma trận
CALL SHIFTREGISTER_INITPORT          ; Gọi hàm khởi tạo cổng thanh ghi dịch

MAIN:
; Hiển thị điểm sáng (Cột 0, Hàng 7)
LDI R27, 0b11111111                 ; Đặt giá trị 0b11111111 (cột 0, bật tất cả LED) vào thanh ghi R27
CALL SHIFTREGISTER_SHIFTOUTDATA     ; Gọi hàm xuất dữ liệu ra thanh ghi dịch
LDI R27, 0b10000000                 ; Đặt giá trị 0b10000000 (bật LED hàng 7) vào R27
OUT LEDMATRIXPORT, R27              ; Gửi dữ liệu vào cổng điều khiển LED ma trận
RJMP MAIN                           ; Lặp vô hạn

; ========================================
; Hàm khởi tạo cổng LED ma trận
LEDMATRIX_INIT:
LDI R16, 0xFF                      ; Gán giá trị 0xFF (tất cả chân đều là output)
OUT LEDMATRIXDIR, R16               ; Cấu hình cổng PORTD làm đầu ra
RET

; ========================================
; Hàm khởi tạo cổng thanh ghi dịch
SHIFTREGISTER_INITPORT:
LDI R16, (1<<SHIFTCLOCKPIN) | (1<<LATCHPIN) | (1<<SHIFTDATAPIN)  ; Cấu hình các chân của PORTB làm output
OUT DDRB, R16                    ; Cấu hình cổng PORTB làm đầu ra
RET

; ========================================
; Xuất dữ liệu ra thanh ghi dịch
SHIFTREGISTER_SHIFTOUTDATA:
PUSH R18                         ; Lưu giá trị của R18 vào stack
CBI SHIFTCLOCKPORT, SHIFTCLOCKPIN  ; Xóa tín hiệu đồng hồ (clock)
LDI R18, 8                        ; Đặt số lần dịch (8 bit dữ liệu)
SHIFTLOOP:
SBRC R27, 7                       ; Kiểm tra bit cao nhất của R27 (nếu bằng 1, bit 7)
SBI SHIFTDATAPORT, SHIFTDATAPIN    ; Nếu có, đặt bit dữ liệu
SBI SHIFTCLOCKPORT, SHIFTCLOCKPIN  ; Cấp tín hiệu clock cho thanh ghi dịch
LSL R27                           ; Dịch bit trái giá trị trong R27
CBI SHIFTCLOCKPORT, SHIFTCLOCKPIN  ; Xóa tín hiệu clock
CBI SHIFTDATAPORT, SHIFTDATAPIN    ; Xóa bit dữ liệu
DEC R18                           ; Giảm số lần dịch
BRNE SHIFTLOOP                     ; Nếu chưa đủ 8 bit, tiếp tục dịch
; Latch dữ liệu ra LED ma trận
SBI LATCHPORT, LATCHPIN            ; Đặt tín hiệu latch
CBI LATCHPORT, LATCHPIN            ; Xóa tín hiệu latch
POP R18                           ; Lấy lại giá trị của R18 từ stack
RET


; BÀI 6: TẤT CẢ ĐIỂM SÁNG CẢU LED MA TRẬN

; Định nghĩa cổng điều khiển LED ma trận
.EQU LEDMATRIXPORT = PORTD           ; Cổng điều khiển LED ma trận (PORTD)
.EQU LEDMATRIXDIR = DDRD             ; Cấu hình cổng PORTD là đầu ra (DDR - Data Direction Register)

; Thanh ghi dịch - PORTB
.EQU SHIFTCLOCKPORT = PORTB         ; Cổng điều khiển tín hiệu đồng hồ (Clock) của thanh ghi dịch (PORTB)
.EQU SHIFTCLOCKPIN = 2              ; Chân điều khiển tín hiệu đồng hồ (Clock) của thanh ghi dịch
.EQU LATCHPORT = PORTB              ; Cổng điều khiển tín hiệu latch (Chốt) cho thanh ghi dịch
.EQU LATCHPIN = 1                   ; Chân điều khiển tín hiệu latch (Chốt) của thanh ghi dịch
.EQU SHIFTDATAPORT = PORTB          ; Cổng điều khiển dữ liệu của thanh ghi dịch
.EQU SHIFTDATAPIN = 0               ; Chân điều khiển dữ liệu của thanh ghi dịch

.ORG 0x0000                         ; Địa chỉ bắt đầu của chương trình tại 0x0000
RJMP RESET_HANDLER                  ; Nhảy đến hàm RESET_HANDLER

RESET_HANDLER:
LDI R16, HIGH(RAMEND)               ; Đặt giá trị cao của RAMEND vào thanh ghi R16
OUT SPH, R16                         ; Ghi giá trị cao vào thanh ghi SPH (Stack Pointer High)
LDI R16, LOW(RAMEND)                ; Đặt giá trị thấp của RAMEND vào thanh ghi R16
OUT SPL, R16                         ; Ghi giá trị thấp vào thanh ghi SPL (Stack Pointer Low)

; Cấu hình các cổng
CALL LEDMATRIX_INIT                  ; Gọi hàm khởi tạo cổng LED ma trận
CALL SHIFTREGISTER_INITPORT          ; Gọi hàm khởi tạo cổng thanh ghi dịch

MAIN:
; Hiển thị điểm sáng (Cột 0, Hàng 7)
LDI R27, 0b11111111                 ; Đặt giá trị 0b11111111 (bật tất cả các bit của cột 0) vào thanh ghi R27
CALL SHIFTREGISTER_SHIFTOUTDATA     ; Gọi hàm xuất dữ liệu ra thanh ghi dịch
LDI R27, 0b11111111                 ; Đặt giá trị 0b11111111 (bật LED hàng 7) vào thanh ghi R27
OUT LEDMATRIXPORT, R27              ; Gửi dữ liệu vào cổng PORTD (điều khiển LED ma trận)
RJMP MAIN                           ; Quay lại vòng lặp chính (lặp vô hạn)

; ========================================
; Hàm khởi tạo cổng LED ma trận
LEDMATRIX_INIT:
LDI R16, 0xFF                      ; Đặt giá trị 0xFF (tất cả chân của PORTD là output)
OUT LEDMATRIXDIR, R16               ; Cấu hình PORTD làm đầu ra
RET

; ========================================
; Hàm khởi tạo cổng thanh ghi dịch
SHIFTREGISTER_INITPORT:
LDI R16, (1<<SHIFTCLOCKPIN) | (1<<LATCHPIN) | (1<<SHIFTDATAPIN)  ; Cấu hình các chân của PORTB là output
OUT DDRB, R16                    ; Cấu hình PORTB làm đầu ra
RET

; ========================================
; Xuất dữ liệu vào thanh ghi dịch
SHIFTREGISTER_SHIFTOUTDATA:
PUSH R18                         ; Lưu giá trị của R18 vào stack (bảo vệ giá trị của R18)
CBI SHIFTCLOCKPORT, SHIFTCLOCKPIN  ; Xóa tín hiệu đồng hồ (Clock) trước khi bắt đầu dịch
LDI R18, 8                        ; Đặt số lượng bit cần dịch (8 bit)
SHIFTLOOP:
SBRC R27, 7                       ; Kiểm tra bit cao nhất của R27 (nếu = 1, chuyển sang bước tiếp theo)
SBI SHIFTDATAPORT, SHIFTDATAPIN    ; Nếu bit = 1, bật tín hiệu dữ liệu cho thanh ghi dịch
SBI SHIFTCLOCKPORT, SHIFTCLOCKPIN  ; Bật tín hiệu đồng hồ (Clock)
LSL R27                           ; Dịch bit của R27 sang trái (left shift)
CBI SHIFTCLOCKPORT, SHIFTCLOCKPIN  ; Tắt tín hiệu đồng hồ (Clock)
CBI SHIFTDATAPORT, SHIFTDATAPIN    ; Tắt tín hiệu dữ liệu
DEC R18                           ; Giảm số lượng bit cần dịch
BRNE SHIFTLOOP                     ; Nếu còn bit cần dịch, tiếp tục vòng lặp

; Latch dữ liệu ra LED ma trận
SBI LATCHPORT, LATCHPIN            ; Bật tín hiệu latch (chốt)
CBI LATCHPORT, LATCHPIN            ; Tắt tín hiệu latch (chốt)
POP R18                           ; Khôi phục giá trị của R18 từ stack
RET


;BÀI 7: HIỂN THỊ CHỮ A LED MA TRẬN

; =======================================
; INTERRUPT VECTOR TABLE
.ORG 0x0000
RJMP RESET_HANDLER ; RESET
.ORG 0x001A
RJMP TIMER1_COMP_ISR ; Timer1 Compare Interrupt

RESET_HANDLER:
; INITIALIZE STACK POINTER
LDI R16, HIGH(RAMEND)        ; Tải giá trị cao của RAMEND vào R16
OUT SPH, R16                 ; Đưa giá trị cao vào thanh ghi SPH (Stack Pointer High)
LDI R16, LOW(RAMEND)         ; Tải giá trị thấp của RAMEND vào R16
OUT SPL, R16                 ; Đưa giá trị thấp vào thanh ghi SPL (Stack Pointer Low)

; Initialize Shift Register and Timer
CALL SHIFTREGISTER_INITPORT  ; Gọi hàm khởi tạo cổng cho thanh ghi dịch
CALL SHIFTREGISTER_CLEARDATA ; Gọi hàm xóa dữ liệu trong thanh ghi dịch
CALL INITTIMER1CTC           ; Gọi hàm khởi tạo Timer1 ở chế độ CTC

; ENABLE GLOBAL INTERRUPTS
SEI                          ; Bật ngắt toàn cục

; Initialize LED Matrix Ports
CALL LEDMATRIX_PORTINIT      ; Gọi hàm khởi tạo các cổng LED Matrix

MAIN:
JMP MAIN                     ; Vòng lặp vô hạn

; =======================================
; Port Configuration Definitions
.EQU CLEARSIGNALPORT = PORTB  ; Đặt cổng CLEAR SIGNAL là PORTB
.EQU CLEARSIGNALPIN = 3       ; Đặt chân CLEAR SIGNAL là PIN 3 của PORTB
.EQU SHIFTCLOCKPORT = PORTB   ; Đặt cổng SHIFT CLOCK là PORTB
.EQU SHIFTCLOCKPIN = 2        ; Đặt chân SHIFT CLOCK là PIN 2 của PORTB
.EQU LATCHPORT = PORTB        ; Đặt cổng LATCH là PORTB
.EQU LATCHPIN = 1             ; Đặt chân LATCH là PIN 1 của PORTB
.EQU SHIFTDATAPORT = PORTB    ; Đặt cổng SHIFT DATA là PORTB
.EQU SHIFTDATAPIN = 0         ; Đặt chân SHIFT DATA là PIN 0 của PORTB

; Initialize Shift Register Ports as Output
SHIFTREGISTER_INITPORT:
PUSH R24                     ; Lưu trữ giá trị của R24 vào Stack
LDI R24, (1<<CLEARSIGNALPIN) | (1<<SHIFTCLOCKPIN) | (1<<LATCHPIN) | (1<<SHIFTDATAPIN)
                             ; Đặt các chân của PORTB là output
OUT DDRB, R24                ; Đưa giá trị vào thanh ghi DDRB để cấu hình PORTB là output
POP R24                      ; Khôi phục giá trị của R24
RET                          ; Trở lại từ hàm

; Clear Shift Register Data
SHIFTREGISTER_CLEARDATA:
CBI CLEARSIGNALPORT, CLEARSIGNALPIN ; Đặt chân CLEAR SIGNAL về mức LOW
; Wait for a short time (This can be done via a simple delay)
SBI CLEARSIGNALPORT, CLEARSIGNALPIN ; Đặt chân CLEAR SIGNAL về mức HIGH
RET                          ; Trở lại từ hàm

; Shift Out Data to Shift Register
SHIFTREGISTER_SHIFTOUTDATA:
PUSH R18                     ; Lưu trữ giá trị của R18 vào Stack
CBI SHIFTCLOCKPORT, SHIFTCLOCKPIN ; Đặt chân SHIFT CLOCK về mức LOW
LDI R18, 8                   ; Đặt số bit cần dịch là 8
SHIFTLOOP:
SBRC R27, 7                  ; Kiểm tra xem bit cao nhất của R27 có phải là 1 không
SBI SHIFTDATAPORT, SHIFTDATAPIN ; Nếu có, đặt chân SHIFT DATA về mức HIGH
SBI SHIFTCLOCKPORT, SHIFTCLOCKPIN ; Đặt chân SHIFT CLOCK về mức HIGH
LSL R27                      ; Dịch R27 sang trái
CBI SHIFTCLOCKPORT, SHIFTCLOCKPIN ; Đặt chân SHIFT CLOCK về mức LOW
CBI SHIFTDATAPORT, SHIFTDATAPIN ; Đặt chân SHIFT DATA về mức LOW
DEC R18                      ; Giảm giá trị R18
BRNE SHIFTLOOP               ; Nếu R18 không bằng 0, quay lại vòng lặp SHIFTLOOP
; Latch Data
SBI LATCHPORT, LATCHPIN      ; Đặt chân LATCH về mức HIGH
CBI LATCHPORT, LATCHPIN      ; Đặt chân LATCH về mức LOW
POP R18                      ; Khôi phục giá trị của R18
RET                          ; Trở lại từ hàm

; =======================================
; LED Matrix Column Control Lookup Table
LEDMATRIX_COL_CONTROL: .DB 0x80, 0x40, 0x20, 0x10, 0x08, 0x04, 0x02, 0x01

; Font Data for Character 'A' (8x8 matrix)
LEDMATRIX_FONT_A:
.DB 0b00111000, 0b01000100, 0b01000100, 0b01111100, 0b01000100, 0b01000100, 0b01000100, 0b00000000

; =======================================
; Initialize LED Matrix Ports
LEDMATRIX_PORTINIT:
PUSH R20                     ; Lưu trữ giá trị của R20 vào Stack
PUSH R21                     ; Lưu trữ giá trị của R21 vào Stack
LDI R20, 0b11111111          ; Đặt tất cả các chân của PORTD làm output
OUT LEDMATRIXDIR, R20        ; Đưa giá trị vào thanh ghi DDRD để cấu hình PORTD là output
LDI R20, 0                   ; Đặt chỉ số cột bắt đầu là 0
LDI R31, HIGH(LEDMATRIXCOLINDEX)
LDI R30, LOW(LEDMATRIXCOLINDEX)
ST Z, R20                    ; Lưu giá trị vào bộ nhớ cột
LDI R20, 0                   ; Đặt giá trị ban đầu cho R20
LDI R31, HIGH(LEDMATRIX_FONT_A << 1) ; Địa chỉ của font A trong bộ nhớ Flash
LDI R30, LOW(LEDMATRIX_FONT_A << 1)
LDI R29, HIGH(LEDMATRIXBUFFER) ; Địa chỉ của bộ đệm LED matrix
LDI R28, LOW(LEDMATRIXBUFFER)
LDI R20, 8                   ; Đặt số lượng byte font
LEDMATRIX_PORTINIT_LOOP:
LPM R21, Z+                  ; Đọc từng byte font từ bộ nhớ Flash
ST Y+, R21                   ; Lưu vào bộ đệm LED Matrix
DEC R20                      ; Giảm giá trị R20
CPI R20, 0                   ; Kiểm tra xem đã hết byte chưa
BRNE LEDMATRIX_PORTINIT_LOOP ; Nếu chưa hết, tiếp tục vòng lặp
POP R21                      ; Khôi phục giá trị của R21
POP R20                      ; Khôi phục giá trị của R20
RET                          ; Trở lại từ hàm

; Display One Column of LED Matrix
LEDMATRIX_DISPLAY_COL:
PUSH R16                     ; Lưu trữ giá trị của R16 vào Stack
PUSH R27                     ; Lưu trữ giá trị của R27 vào Stack
CLR R16                      ; Xóa giá trị R16
OUT LEDMATRIXPORT, R16       ; Đưa giá trị vào cổng PORTD để xóa cột hiện tại
CALL SHIFTREGISTER_SHIFTOUTDATA ; Gửi dữ liệu đến thanh ghi dịch
LDI R31, HIGH(LEDMATRIX_COL_CONTROL << 1) ; Địa chỉ của bảng điều khiển cột
LDI R30, LOW(LEDMATRIX_COL_CONTROL << 1)
CLR R16                      ; Xóa giá trị R16
ADD R30, R26                 ; Thêm chỉ số cột vào R30
ADC R31, R16                 ; Cộng với phần nhớ cao của cột
LPM R27, Z                   ; Đọc giá trị cột từ bộ nhớ Flash
OUT LEDMATRIXPORT, R27       ; Đưa giá trị cột vào cổng PORTD
POP R27                      ; Khôi phục giá trị của R27
POP R16                      ; Khôi phục giá trị của R16
RET                          ; Trở lại từ hàm

; =======================================
; Timer1 Compare Match Interrupt Service Routine
TIMER1_COMP_ISR:
PUSH R16
PUSH R26
PUSH R27
LDI R31, HIGH(LEDMATRIXCOLINDEX)
LDI R30, LOW(LEDMATRIXCOLINDEX)
LD R16, Z
MOV R26, R16
LDI R31, HIGH(LEDMATRIXBUFFER)
LDI R30, LOW(LEDMATRIXBUFFER)
ADD R30, R16
CLR R16
ADC R31, R16
LD R27, Z
CALL LEDMATRIX_DISPLAY_COL ; Hiển thị cột LED
INC R26
CPI R26, 8                 ; Kiểm tra nếu chỉ số cột đã đạt 8
BRNE TIMER1_COMP_ISR_CONT  ; Nếu chưa, tiếp tục
LDI R26, 0                 ; Nếu đã đạt 8, đặt lại chỉ số cột về 0
TIMER1_COMP_ISR_CONT:
LDI R31, HIGH(LEDMATRIXCOLINDEX)
LDI R30, LOW(LEDMATRIXCOLINDEX)
ST Z, R26
POP R27
POP R26
POP R16
RET

; =======================================
; Timer1 CTC Mode Initialization
INITTIMER1CTC:
PUSH R16
LDI R16, HIGH(2500)         ; Tải giá trị cao của Timer Compare
STS OCR1AH, R16             ; Đặt giá trị cao vào OCR1A
LDI R16, LOW(2500)          ; Tải giá trị thấp vào Timer Compare
STS OCR1AL, R16             ; Đặt giá trị thấp vào OCR1A
LDI R16, (1 << CS10) | (1 << WGM12) ; Cấu hình Timer1 ở chế độ CTC
STS TCCR1B, R16
LDI R16, (1 << OCIE1A)      ; Kích hoạt ngắt khi so sánh Timer1
STS TIMSK1, R16
POP R16
RET


;--------------------------------buổi 3-------------------------------------

;BÀI 1: a) Viết chương trình con delay 1 ms sử dụng timer 0. Sử dụng chương trình con này để tạo xung 1 Khz trên chân PA0. 

.ORG 0                  ; Bắt đầu chương trình tại địa chỉ 0 (Vector Reset)
RJMP MAIN              ; Nhảy đến nhãn MAIN (hàm chính)

.ORG 0x40              ; Đặt mã chương trình chính bắt đầu tại địa chỉ 0x40

MAIN:
LDI R16,HIGH(RAMEND)   ; Nạp byte cao của địa chỉ RAMEND vào R16
OUT SPH,R16            ; Ghi vào thanh ghi SPH để thiết lập Stack Pointer (byte cao)
LDI R16,LOW(RAMEND)    ; Nạp byte thấp của địa chỉ RAMEND vào R16
OUT SPL,R16            ; Ghi vào thanh ghi SPL để thiết lập Stack Pointer (byte thấp)

LDI R16,0x01           ; Nạp giá trị 0x01 vào R16 (bật bit 0 – PB0)
OUT DDRB,R16           ; Thiết lập chân PB0 của PORTB làm output (DDRB = 0x01)

LDI R17,0x00           ; Đặt chế độ hoạt động bình thường cho Timer0 (Normal Mode)
OUT TCCR0A,R17         ; Ghi vào thanh ghi điều khiển TCCR0A

LDI R17,0x00           ; Dừng Timer0 ban đầu (CS02..0 = 000)
OUT TCCR0B,R17         ; Ghi vào thanh ghi điều khiển TCCR0B

START:
RCALL DELAY            ; Gọi chương trình con DELAY để tạo độ rộng xung

IN R17,PORTB           ; Đọc giá trị hiện tại của PORTB vào R17
EOR R17,R16            ; Thực hiện phép XOR với R16 (0x01) để đảo bit PB0
OUT PORTB,R17          ; Ghi lại giá trị mới ra PORTB => đảo trạng thái LED
RJMP START             ; Nhảy về START để lặp lại liên tục

; =====================================================
; CHƯƠNG TRÌNH CON TẠO DELAY KHOẢNG 1ms SỬ DỤNG TIMER0
; =====================================================

DELAY:
LDI R16,-125           ; Nạp giá trị đếm trước vào R16 (TCNT0 = 0x83)
OUT TCNT0,R16          ; Đặt thanh ghi đếm Timer0 với giá trị 0x83

LDI R16,0x00           ; Thiết lập chế độ Normal cho Timer0
OUT TCCR0A,R16         ; Ghi vào thanh ghi TCCR0A

LDI R16,0x03           ; Bật Timer0 với prescaler = 64 (CS01 và CS00 = 1)
OUT TCCR0B,R16         ; Ghi vào TCCR0B để bắt đầu đếm

WAIT:
SBIS TIFR0,TOV0        ; Kiểm tra cờ tràn TOV0 (nếu chưa = 1 thì bỏ qua lệnh tiếp theo)
RJMP WAIT              ; Nếu TOV0 = 0, quay lại đợi tiếp

SBI TIFR0,TOV0         ; Cờ TOV0 = 1 => xóa cờ bằng cách ghi 1 vào TOV0
LDI R17,0x00           ; Dừng Timer0 (CS02..0 = 000)
OUT TCCR0B,R17         ; Ghi vào TCCR0B để dừng Timer
RET                    ; Trở về chương trình chính (START)

;b) Mô phỏng, chỉnh sửa chương trình để tạo ra xung chính xác. 
; Cấu hình Timer1 để tạo sóng vuông có chu kỳ sử dụng Timer1 trong chế độ CTC 
; Xuất xung vuông lên chân PD5 (OC1A) 


.equ P_OUT = 5           ; Đặt tên nhãn cho chân xuất xung là P_OUT (bit 5)

.org 0                   ; Bắt đầu chương trình tại địa chỉ 0 (Reset vector)
RJMP MAIN                   ; Nhảy tới chương trình chính (MAIN)

.org 0x40                   ; Địa chỉ thực thi mã chương trình

MAIN:
; =============================
; CÀI ĐẶT STACK POINTER
; =============================
LDI R16, HIGH(RAMEND)       ; Nạp byte cao của địa chỉ cuối SRAM vào R16
OUT SPH, R16                ; Ghi vào thanh ghi SPH (Stack Pointer High)
LDI R16, LOW(RAMEND)        ; Nạp byte thấp của địa chỉ cuối SRAM vào R16
OUT SPL, R16                ; Ghi vào thanh ghi SPL (Stack Pointer Low)

; =============================
; CẤU HÌNH CHÂN PD5 LÀ OUTPUT
; =============================
LDI R16, (1 << P_OUT)       ; Ghi 0b00100000 (bit 5 set) vào R16
OUT DDRD, R16               ; Thiết lập PD5 là output (DDRD |= (1 << PD5))

; =============================
; CẤU HÌNH TIMER1 Ở CHẾ ĐỘ CTC
; =============================
LDI R17, HIGH(31)           ; Nạp byte cao của 31 vào R17
STS OCR1AH, R17             ; Ghi vào thanh ghi OCR1AH (TOP = 31)

LDI R17, LOW(31)            ; Nạp byte thấp của 31 vào R17
STS OCR1AL, R17             ; Ghi vào thanh ghi OCR1AL

LDI R17, 0x00               ; TCCR1A = 0, không dùng OC1A, chọn chế độ CTC
STS TCCR1A, R17             ; Ghi giá trị vào TCCR1A

LDI R17, 0x0A               ; TCCR1B = 0x0A → chọn CTC mode (WGM12 = 1), Prescaler = 8 (CS11 = 1)
STS TCCR1B, R17             ; Ghi giá trị vào TCCR1B

; =============================
; VÒNG LẶP CHÍNH - TẠO XUNG
; =============================
WAIT:
SBIS TIFR1, OCF1A           ; Kiểm tra cờ OCF1A (so sánh xong chưa?)
RJMP WAIT                  ; Nếu chưa (OCF1A = 0), quay lại chờ

SBI TIFR1, OCF1A            ; Nếu cờ bật (OCF1A = 1), xóa cờ để chuẩn bị cho lần so sánh tiếp theo

IN R17, PORTD               ; Đọc giá trị hiện tại của PORTD
LDI R16, 0x20               ; 0x20 = 0b0010 0000 → bit 5 (PD5)
EOR R17, R16                ; Đảo bit PD5: 1→0 hoặc 0→1 (toggle)
OUT PORTD, R17              ; Ghi giá trị mới ra PORTD (tạo xung)

RJMP WAIT                   ; Lặp lại vòng đợi → tiếp tục tạo xung

;BÀI 2: a) Viết chương trình tạo 1 xung vuông 64 us sử dụng timer 0 ở chế độ Normal mode. Ngõ ra sử dụng chân OC0.  

; Đặt vùng bắt đầu chương trình tại địa chỉ 0
.ORG 0
RJMP MAIN              ; Nhảy đến nhãn MAIN khi reset

; Đặt chương trình chính ở địa chỉ 0x40 để tránh đè vùng vector
.ORG 0x40
MAIN:
    ; Cấu hình Stack Pointer (bắt buộc trong AVR)
    LDI R16, HIGH(RAMEND)   ; Tải byte cao địa chỉ RAMEND vào R16
    OUT SPH, R16            ; Gán SPH (Stack Pointer High)
    LDI R16, LOW(RAMEND)    ; Tải byte thấp địa chỉ RAMEND vào R16
    OUT SPL, R16            ; Gán SPL (Stack Pointer Low)

    ; Cấu hình PB0 là output
    LDI R16, 0x01           ; Bit 0 = 1 (PB0 là output)
    OUT DDRB, R16           ; Cấu hình DDRB (Data Direction Register B)

    ; Cấu hình Timer0 ở chế độ Normal và dừng timer ban đầu
    LDI R17, 0x00
    OUT TCCR0A, R17         ; Chế độ Normal
    LDI R17, 0x00
    OUT TCCR0B, R17         ; Timer dừng lại, chờ kích hoạt sau

START:
    RCALL DELAY             ; Gọi hàm delay khoảng 1ms

    IN R17, PORTB           ; Đọc giá trị hiện tại của PORTB
    EOR R17, R16            ; Đảo bit PB0 (XOR với 0x01)
    OUT PORTB, R17          ; Ghi ngược lại ra PORTB -> tạo xung

    RJMP START              ; Lặp lại vô hạn

;---------------------------------------------------
; Hàm tạo delay ~1ms bằng Timer0 (chế độ Normal, prescaler = 64)
DELAY:
    ; Đặt giá trị TCNT0 để bắt đầu từ 0x83 (131), cho phép đếm đến 255
    ; 256 - 131 = 125 xung => với prescaler = 64, 1 xung = 8µs (8MHz)
    ; 125 * 8µs = 1ms
    LDI R16, -7             ; -7 = 0xF9 = 249 (cho TCNT0 bắt đầu từ 131)
    OUT TCNT0, R16          ; Gán TCNT0 = 0x83 (131)

    LDI R16, 0x00
    OUT TCCR0A, R16         ; Vẫn là chế độ Normal

    LDI R16, 0x03           ; Prescaler = 64 (CS01=1, CS00=1)
    OUT TCCR0B, R16         ; Bắt đầu Timer0

WAIT:
    SBIS TIFR0, TOV0        ; Chờ cho đến khi Timer0 tràn (TOV0 = 1)
    RJMP WAIT               ; Nếu chưa tràn, tiếp tục chờ

    SBI TIFR0, TOV0         ; Xóa cờ TOV0 bằng cách ghi 1 vào nó

    ; Dừng Timer sau khi delay xong
    LDI R17, 0x00
    OUT TCCR0B, R17

    RET                     ; Trở về chương trình chính

;Bài 3: chương trình sau tạo 2 xung PWM trên OC0A và OC0B

.ORG 0x00
    RJMP MAIN         ; Nhảy đến chương trình chính sau khi reset

MAIN:
    CALL initTimer0   ; Gọi hàm khởi tạo Timer0
START:
    RJMP START        ; Lặp vô hạn

;---------------------------------------------------
; Hàm khởi tạo Timer0 ở chế độ Fast PWM
; OC0A (PB3) và OC0B (PB4) sẽ xuất ra xung PWM
initTimer0:
    ; Đặt chân PB3 (OC0A) và PB4 (OC0B) là output
    LDI R16, (1 << PB3) | (1 << PB4) ; PB3=1 và PB4=1
    OUT DDRB, R16                   ; Cấu hình chân PB3, PB4 là output

    ; Cấu hình thanh ghi TCCR0A:
    ; COM0A1:0 = 10 → Non-inverting mode cho OC0A (PB3)
    ; COM0B1:0 = 10 → Non-inverting mode cho OC0B (PB4)
    ; WGM01:0 = 11 → Chọn chế độ Fast PWM (2-bit WGM)
    LDI R16, (1 << COM0A1) | (1 << COM0B1) | (1 << WGM00) | (1 << WGM01)
    OUT TCCR0A, R16

    ; Cấu hình thanh ghi TCCR0B:
    ; WGM02 = 0 → (kết hợp với WGM01:0 = 11) => Fast PWM, TOP = 0xFF
    ; CS01 = 1 → Prescaler = 8
    LDI R16, (1 << CS01)
    OUT TCCR0B, R16

    ; Thiết lập giá trị so sánh:
    LDI R16, 100         ; OCR0A = 100 => Duty cycle OC0A = 100/255 ~ 39%
    OUT OCR0A, R16

    LDI R16, 75          ; OCR0B = 75 => Duty cycle OC0B = 75/255 ~ 29%
    OUT OCR0B, R16

    RET                 ; Trở về MAIN

;Bài 4: Viết chương trình tạo ra 1 xung tần số 1Khz, duty cycle 25% trên chân OC0B 

.EQU P_OUT = 4        ; Định nghĩa P_OUT là chân PB4 (bit 4)
.EQU TP_H = -31       ; Giá trị đặt trước cho mức HIGH (xung rộng)
.EQU TP_L = -93       ; Giá trị đặt trước cho mức LOW (xung hẹp)

.ORG 0
    RJMP MAIN         ; Nhảy đến chương trình chính sau reset

.ORG 0x40
MAIN:
    ; Khởi tạo Stack Pointer lên đỉnh SRAM
    LDI R16, HIGH(RAMEND)
    OUT SPH, R16
    LDI R16, LOW(RAMEND)
    OUT SPL, R16

    ; Cấu hình PB4 là OUTPUT (P_OUT = 4)
    LDI R16, (1 << P_OUT)
    OUT DDRB, R16

    ; Khởi tạo Timer0: Clear thanh ghi điều khiển
    LDI R17, 0x00
    OUT TCCR0A, R17
    OUT TCCR0B, R17

START:
    ; Phát mức HIGH lên chân PB4
    SBI PORTB, P_OUT        ; Set bit PB4 (output = 1)
    LDI R17, TP_H           ; Nạp giá trị đặt trước để tạo độ rộng xung mức 1
    RCALL DELAY_T0          ; Gọi hàm trễ bằng Timer0

    ; Phát mức LOW lên chân PB4
    CBI PORTB, P_OUT        ; Clear bit PB4 (output = 0)
    LDI R17, TP_L           ; Nạp giá trị đặt trước để tạo độ rộng xung mức 0
    RCALL DELAY_T0          ; Gọi hàm trễ

    RJMP START              ; Quay lại đầu vòng lặp để tiếp tục tạo xung

;-----------------------------------------------------
; Subroutine tạo trễ bằng Timer0 (dựa trên giá trị preload)
;-----------------------------------------------------
DELAY_T0:
    OUT TCNT0, R17          ; Gán giá trị đặt trước cho bộ đếm (TCNT0 = preload)
    LDI R17, 0x03           ; Prescaler = 64 (CS01=1, CS00=1), chế độ Normal
    OUT TCCR0B, R17         ; Bắt đầu đếm

WAIT:
    IN R17, TIFR0           ; Đọc cờ ngắt Timer0
    SBRS R17, TOV0          ; Kiểm tra xem đã tràn chưa (TOV0 = 1?)
    RJMP WAIT               ; Nếu chưa tràn thì tiếp tục chờ

    OUT TIFR0, R17          ; Xóa cờ TOV0 bằng cách ghi lại vào TIFR0
    LDI R17, 0x00
    OUT TCCR0B, R17         ; Dừng Timer0 (prescaler = 0)
    RET                     ; Quay lại chương trình chính

;b) Kết nối OC0B vào kênh R của 1 LED RGB. Viết chương trình để tăng duty cycle trên OC0B từ 0% lên 100% rồi lại giảm xuống 0, sau 10 ms duty cycle tăng/giảm 1%. 

.ORG 0x40                ; Chỉ định vị trí bắt đầu của mã

MAIN:
    LDI R16, HIGH(RAMEND)    ; Đặt giá trị stack pointer, đưa stack lên đỉnh RAM
    OUT SPH, R16
    LDI R16, LOW(RAMEND)
    OUT SPL, R16

    LDI R16, (1 << P_OUT)    ; Thiết lập chân P_OUT (PB4) làm OUTPUT
    OUT DDRB, R16

    LDI R17, 0x00            ; Đặt giá trị khởi tạo cho TCCR0A
    OUT TCCR0A, R17
    LDI R17, 0x00            ; Đặt giá trị khởi tạo cho TCCR0B
    OUT TCCR0B, R17

START:
    ; Phát tín hiệu HIGH lên PB4
    SBI PORTB, P_OUT         ; Set bit PB4 = 1 (Output = High)
    LDI R17, TP_H            ; Nạp giá trị TP_H vào R17 (độ rộng xung High)
    RCALL DELAY_T0           ; Gọi hàm tạo độ trễ bằng Timer0

    ; Phát tín hiệu LOW lên PB4
    CBI PORTB, P_OUT         ; Clear bit PB4 = 0 (Output = Low)
    LDI R17, TP_L            ; Nạp giá trị TP_L vào R17 (độ rộng xung Low)
    RCALL DELAY_T0           ; Gọi hàm tạo độ trễ bằng Timer0

    RJMP START               ; Lặp lại vòng lặp tạo xung PWM

;-----------------------------------------------------------
; Subroutine tạo độ trễ bằng Timer0
;-----------------------------------------------------------
DELAY_T0:
    OUT TCNT0, R17           ; Nạp giá trị TP_H hoặc TP_L vào bộ đếm Timer0 (TCNT0)
    LDI R17, 0x03            ; Prescaler của Timer0 = 64 (CS01 = 1, CS00 = 1)
    OUT TCCR0B, R17          ; Bắt đầu đếm Timer0 với prescaler là 64

WAIT:
    IN R17, TIFR0            ; Đọc cờ ngắt Timer0 (TIFR0)
    SBRS R17, TOV0           ; Nếu TOV0 = 1 (overflow), bỏ qua và nhảy đến WAIT
    RJMP WAIT                ; Nếu chưa overflow, tiếp tục chờ

    OUT TIFR0, R17           ; Xóa cờ TOV0 (TOV0 = 1)
    LDI R17, 0x00            ; Dừng Timer0
    OUT TCCR0B, R17          ; Dừng Timer0 (prescaler = 0)

    RET                      ; Quay lại chương trình chính

;Baif1 :Trả lời các câu hỏi 
; a. Khoảng thời gian trễ lớn nhất có thể tạo ra bởi timer 0 với tần số 8Mhz là bao 
; nhiêu? Trình bày cách tính toán. 
; Với Fosc = 8Mhz   Tosc = 0,125us 
; Ta có: TDL = n x Tosc x N.  
; Muốn TDL max thì nxN max  N = 1024 và n = 256. 
; Khi đó TDL = 256 x 0.125uS x 1024 = 0.032768 s 
; b. Khoảng thời gian trễ lớn nhất có thể tạo ra bởi timer 1 với tần số 8Mhz là bao 
; nhiêu? Trình bày cách tính toán. 
; Với Fosc = 8Mhz   Tosc = 0,125us 
; Ta có: TDL = n x Tosc x N.  
; Muốn TDL max thì nxN max  N = 1024 và n = 2^15. 
; Khi đó TDL = 2^15 x 0.125uS x 1024  4,19 s 
; c. Trình bày cách tính prescaler và các giá trị nạp vào các thanh ghi của timer0 
; trong bài thí nghiệm. 
; Ở mode NOR các bit WGM03:WGM02:WGM01 = 000 
; Suy ra bit 1 và bit 0 của thanh ghi TCCR0A = 00 và bit 3 của thanh ghi TCCR0B 
; = 0 
; Để chọn prescaler cho TDL = 1ms ta dùng công thức: 
; TDL = n x Tosc x prescal.  Với Tosc = 0.125us 
; Prescaler của timer0 có các giá trị 1, 8, 64, 256, 1024. Ta chọn lần lượt các giá trị 
; này và tính n. Thấy rằng prescaler = 64 ta được kết quả n là 1 số nguyên 125 (điều 
; này giúp ta dễ nạp giá trị cho thanh ghi vì số không lẻ).
; Với n =125 đồng nghĩa ta nạp giá trị -125 cho thanh ghi TCNT0 
; Với prescaler = 64 đồng nghĩa 3 bit CS02:CS01:CS00 của thanh ghi TCCR0B 
; = 011 
; Vậy các giá trị của các thanh ghi trong timer 0 lần lượt là  
; TCNT0 = -125,  TCCR0A = $00, TCCR0B = $03. 

.ORG 0
RJMP MAIN                      ; Nhảy tới nhãn MAIN, bắt đầu chương trình
.ORG 0x40                       ; Đặt vị trí bộ nhớ bắt đầu cho mã chính

MAIN:
    LDI R16, HIGH(RAMEND)      ; Nạp phần cao của RAMEND vào thanh ghi R16
    OUT SPH, R16               ; Đưa phần cao của RAMEND vào SPH (Stack Pointer High)
    LDI R16, LOW(RAMEND)       ; Nạp phần thấp của RAMEND vào thanh ghi R16
    OUT SPL, R16               ; Đưa phần thấp của RAMEND vào SPL (Stack Pointer Low)

    LDI R16, 0x01              ; Nạp giá trị 0x01 vào R16, đặt PA0 (Port A, bit 0) làm OUTPUT
    OUT DDRA, R16              ; Ghi giá trị R16 vào DDRA để cấu hình PA0 là OUTPUT

    CLR R17                    ; Xóa thanh ghi R17, giá trị R17 = 0
    OUT TCCR0A, R17            ; Tắt Timer0 bằng cách ghi 0 vào TCCR0A (Timer/Counter Control Register A)
    OUT TCCR0B, R17            ; Tắt Timer0 bằng cách ghi 0 vào TCCR0B (Timer/Counter Control Register B)

START:
    SBI PORTA, 0               ; Đặt PA0 (bit 0 của PORTA) lên mức HIGH (1)
    RCALL DELAY                ; Gọi hàm DELAY để tạo độ trễ
    CBI PORTA, 0               ; Đặt PA0 (bit 0 của PORTA) về mức LOW (0)
    RCALL DELAY                ; Gọi hàm DELAY để tạo độ trễ
    RJMP START                 ; Quay lại và lặp lại quá trình

; Subroutine DELAY: Tạo độ trễ bằng Timer0
DELAY:
    LDI R17, -125              ; Nạp giá trị -125 vào R17 để thiết lập giá trị bộ đếm Timer0 (để tạo độ trễ 1000us)
    OUT TCNT0, R17             ; Ghi giá trị vào bộ đếm Timer0 (TCNT0)
    LDI R17, 0x03              ; Nạp giá trị 0x03 vào R17 (Prescaler = 64)
    OUT TCCR0B, R17            ; Cấu hình Timer0 với prescaler = 64, bắt đầu bộ đếm

WAIT:
    IN R17, TIFR0              ; Đọc giá trị của TIFR0 (Timer Interrupt Flag Register) vào R17
    SBRS R17, TOV0             ; Kiểm tra bit TOV0, nếu TOV0 = 0 (chưa tràn), tiếp tục chờ
    RJMP WAIT                  ; Nếu TOV0 chưa tràn, quay lại vòng lặp WAIT

    SBI TIFR0, TOV0            ; Nếu Timer0 tràn, xóa cờ TOV0
    CLR R17                    ; Xóa R17
    OUT TCCR0B, R17            ; Dừng Timer0 bằng cách ghi 0 vào TCCR0B
    RET                         ; Quay lại từ subroutine DELAY

;Bài 2a: Timer0 và PORTB để tạo ra một xung vuông (PWM) delay 1ms mode norma;

.ORG 0
RJMP MAIN                          ; Nhảy đến nhãn MAIN, bắt đầu chương trình
.ORG 0x40                           ; Đặt vị trí bộ nhớ bắt đầu cho mã chính

MAIN:
    LDI R16, HIGH(RAMEND)           ; Nạp phần cao của RAMEND vào thanh ghi R16
    OUT SPH, R16                    ; Đưa phần cao của RAMEND vào SPH (Stack Pointer High)
    LDI R16, LOW(RAMEND)            ; Nạp phần thấp của RAMEND vào thanh ghi R16
    OUT SPL, R16                    ; Đưa phần thấp của RAMEND vào SPL (Stack Pointer Low)

    LDI R16, (1 << 3)               ; Nạp giá trị 0x08 (0000 1000) vào R16, tương ứng với bit 3
    OUT DDRB, R16                   ; Đặt PB3 (bit 3 của PORTB) làm OUTPUT (bit 3 là 1, các bit còn lại là 0)

    LDI R17, 0x00                   ; Đặt giá trị 0 vào R17 (dùng để tắt Timer0)
    OUT TCCR0A, R17                 ; Tắt Timer0 bằng cách ghi 0 vào TCCR0A
    LDI R17, 0x00                   ; Đặt giá trị 0 vào R17 (dùng để tắt Timer0)
    OUT TCCR0B, R17                 ; Tắt Timer0 bằng cách ghi 0 vào TCCR0B

START:
    RCALL DELAY                     ; Gọi hàm DELAY để tạo độ trễ
    IN R17, PORTB                   ; Đọc giá trị của PORTB vào R17
    EOR R17, R16                    ; XOR giá trị R17 với R16 (đảo bit 3 của PORTB)
    OUT PORTB, R17                  ; Ghi kết quả vào PORTB, đảo trạng thái của PB3
    RJMP START                      ; Lặp lại quá trình

; Subroutine DELAY: Tạo độ trễ bằng Timer0
DELAY:
    LDI R17, -230                   ; Nạp giá trị -230 vào R17 (để đặt giá trị bộ đếm của Timer0)
    OUT TCNT0, R17                  ; Ghi giá trị vào bộ đếm Timer0 (TCNT0)
    LDI R17, 0x01                   ; Nạp giá trị 0x01 vào R17 (prescaler = 8)
    OUT TCCR0B, R17                 ; Cấu hình Timer0 với prescaler = 8, bắt đầu đếm

WAIT:
    IN R17, TIFR0                   ; Đọc giá trị của TIFR0 (Timer Interrupt Flag Register) vào R17
    SBRS R17, TOV0                  ; Nếu TOV0 = 0 (chưa tràn), tiếp tục chờ
    RJMP WAIT                       ; Nếu TOV0 chưa tràn, quay lại vòng lặp WAIT

    SBI TIFR0, TOV0                 ; Nếu Timer0 tràn, xóa cờ TOV0
    CLR R17                         ; Đặt giá trị của R17 về 0
    OUT TCCR0B, R17                 ; Dừng Timer0 bằng cách ghi 0 vào TCCR0B
    RET                              ; Quay lại từ subroutine DELAY

;Bài 2b: Timer1 với chế độ CTC (Clear Timer on Compare Match) và prescaler là 8, để tạo ra một PWM signal trên chân PB3.60 ms

.ORG 0           ; Địa chỉ bắt đầu của chương trình

RJMP MAIN        ; Nhảy đến phần MAIN để bắt đầu chương trình

.ORG 0X40        ; Địa chỉ khởi tạo MAIN

MAIN: 
    LDI R16, HIGH(RAMEND)   ; Tải giá trị cao của RAMEND vào R16
    OUT SPH, R16             ; Đưa giá trị vào SPH để thiết lập con trỏ ngăn xếp
    LDI R16, LOW(RAMEND)    ; Tải giá trị thấp của RAMEND vào R16
    OUT SPL, R16             ; Đưa giá trị vào SPL để thiết lập con trỏ ngăn xếp

    LDI R16, (1 << 3)       ; Tải giá trị 0x08 vào R16 (chân PB3 làm output)
    OUT DDRB, R16           ; Đặt PB3 (chân số 3 của PORTB) làm output

    CBI PORTC, 3            ; Đặt chân 3 của PORTC thành mức thấp (nếu sử dụng)

    LDI R17, HIGH(239)      ; Tải giá trị cao của 239 vào R17
    STS OCR1AH, R17         ; Lưu giá trị cao của 239 vào thanh ghi OCR1AH

    LDI R17, LOW(239)       ; Tải giá trị thấp của 239 vào R17
    STS OCR1AL, R17         ; Lưu giá trị thấp của 239 vào thanh ghi OCR1AL

    CLR R17                 ; Xóa giá trị trong R17
    STS TCCR1A, R17         ; Dừng Timer1 bằng cách xóa TCCR1A (chế độ bình thường)

    LDI R17, 0X00          ; Tải giá trị 0x00 vào R17
    STS TCCR1B, R17         ; Dừng Timer1 bằng cách xóa TCCR1B

START: 
    RCALL DELAY            ; Gọi subroutine DELAY để tạo độ trễ

    IN R17, PORTB           ; Đọc giá trị từ PORTB vào R17
    EOR R17, R16            ; XOR giá trị R17 với R16 để đảo bit PB3
    OUT PORTB, R17          ; Ghi giá trị mới vào PORTB (thay đổi trạng thái của PB3)

    RJMP START              ; Nhảy lại START để tạo vòng lặp vô hạn

DELAY:  
    LDI R17, 0X09           ; Tải giá trị 0x09 vào R17 để cấu hình Timer1
    STS TCCR1B, R17         ; Cấu hình Timer1 với giá trị 0x09, trong đó 0x09 là chế độ CTC và prescaler = 8

WAIT: 
    IN R17, TIFR1           ; Đọc thanh ghi cờ TIFR1 để kiểm tra cờ TOV1
    SBRS R17, OCF1A         ; Nếu cờ OCF1A (Clear Timer on Compare Match) chưa được thiết lập, nhảy tới WAIT
    RJMP WAIT               ; Tiếp tục đợi cho đến khi cờ OCF1A được thiết lập

    OUT TIFR1, R17          ; Xóa cờ OCF1A sau khi Timer1 tràn (reset)
    CLR R17                 ; Xóa giá trị trong R17
    STS TCCR1B, R17         ; Dừng Timer1 bằng cách xóa TCCR1B (chế độ bình thường)

    RET                      ; Trở về từ subroutine DELAY
