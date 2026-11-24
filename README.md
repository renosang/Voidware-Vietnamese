# Voidware Vietnamese — V7.2

Bản dịch giao diện tiếng Việt, tổng hợp từ bản dịch gốc và 7 đợt ảnh. Chỉ xử lý văn bản hiển thị. Chưa kiểm thử thực tế trên Delta.

## Cấu trúc
- `loader.lua`: tải từ điển và mã xử lý, ghi log lỗi.
- `translator.lua`: xử lý văn bản trong các vùng WindUI.
- `vi.json`: 627 mục dịch hợp nhất, UTF-8.
- `version.json`: thông tin phiên bản.

## Sử dụng
Repository cần ở chế độ Public để URL RAW truy cập được mà không cần đăng nhập. Không đưa token GitHub vào script.

Sau khi giao diện Voidware đã tải, chạy:

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/renosang/Voidware-Vietnamese/main/loader.lua", true))()
```

Kiểm tra Roblox Console: `[VI7.2] START`, `[VI7.2] Download: vi.json`, `[VI7.2] Download: translator.lua`, `[VI7.2] READY!`. Nếu gặp lỗi, kiểm tra dòng `[VI7.2 ERROR]`.

Các mục chưa dịch được có thể xuất hiện với tiền tố `[VI7 MISSING]`. Việc dịch dropdown, popup phụ thuộc vào các vùng giao diện mà phiên bản WindUI cung cấp.
