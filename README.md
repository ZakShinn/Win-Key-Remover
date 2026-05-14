# Win Key Remover

<a id="readme-top"></a>

**Nhanh / Quick — chọn ngôn ngữ / pick language:**

| [**Tiếng Việt**](#lang-vi) | [**English**](#lang-en) |
|:-------------------------:|:-----------------------:|

---

<a id="lang-vi"></a>

## Tiếng Việt

<p align="right"><a href="#lang-en">English ↓</a> · <a href="#readme-top">Lên đầu ↑</a></p>

Script PowerShell gỡ **product key Windows** và/hoặc **Microsoft Office** bằng các công cụ chính thức của Microsoft (`slmgr.vbs`, `ospp.vbs`).

**Kho mã nguồn:** [github.com/ZakShinn/Win-Key-Remover](https://github.com/ZakShinn/Win-Key-Remover)

### Yêu cầu

- Windows với PowerShell.
- Chạy **PowerShell với quyền Administrator** (script có `#Requires -RunAsAdministrator`).
- Office (nếu chọn gỡ key Office) phải được cài đặt để tìm thấy `ospp.vbs`.

### Tải script

- Clone repo: `git clone https://github.com/ZakShinn/Win-Key-Remover.git`
- Hoặc tải file [Win-Key-Remover.ps1](https://github.com/ZakShinn/Win-Key-Remover/blob/main/Win-Key-Remover.ps1) từ trang GitHub.

### Cách chạy

1. Mở **PowerShell** (hoặc Windows Terminal) **Run as administrator**.
2. Nếu cần, cho phép chạy script trong phiên hiện tại (ví dụ):

   ```powershell
   Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
   ```

3. Chuyển vào thư mục chứa script, rồi chạy:

   ```powershell
   cd "Đường-dẫn-tới-thư-mục-Win-Key-Remover"
   .\Win-Key-Remover.ps1
   ```

4. Chọn ngôn ngữ giao diện khi được hỏi: **1** = Tiếng Việt, **2** = English (hoặc dùng tham số `-Lang` bên dưới để bỏ qua bước này).

### Tham số dòng lệnh

| Tham số | Giá trị | Mô tả |
|--------|---------|--------|
| `-Lang` | `vi` hoặc `en` | Cố định ngôn ngữ, không hỏi lúc khởi động. |

Ví dụ giao diện tiếng Anh ngay từ đầu:

```powershell
.\Win-Key-Remover.ps1 -Lang en
```

### Menu sau khi chạy

Sau phần cảnh báo, nhập một trong các lựa chọn:

| Nhập | Ý nghĩa |
|------|---------|
| **1** | Chỉ Windows — `slmgr` `/upk`, `/cpky`, `/ckms` |
| **2** | Chỉ Office — `ospp.vbs` `/unpkey` theo kết quả `/dstatus` |
| **3** | Cả Windows và Office |

Sau khi gỡ key Windows, kiểm tra **Cài đặt → Hệ thống → Kích hoạt** (hoặc tương đương). Với Office, có thể kiểm tra bằng lệnh gợi ý trên màn hình sau khi chạy xong.

### Tùy chọn: tải bản mới từ GitHub trong script

Trong file `Win-Key-Remover.ps1`, biến `$RemoteScriptUrl` mặc định là placeholder. Nếu bạn sửa thành URL raw của repo này, script có thể hỏi có muốn tải bản mới nhất trước khi tiếp tục:

`https://raw.githubusercontent.com/ZakShinn/Win-Key-Remover/main/Win-Key-Remover.ps1`

### Lưu ý quan trọng

- Bạn tự chịu rủi ro khi chạy script. Windows hoặc Office có thể chuyển sang trạng thái **chưa kích hoạt**.
- Script **không** gỡ crack dạng file patch, chỉnh `hosts`, hay dịch vụ giả mạo.
- Không phải mọi phiên bản Windows đều có chế độ dùng thử sau khi gỡ key.

### Giấy phép

Dự án dùng giấy phép **GPL-3.0** — xem file [`LICENSE`](LICENSE) trong repo.

| [**English**](#lang-en) | [**Lên đầu / Top**](#readme-top) |
|:-----------------------:|:--------------------------------:|

---

<a id="lang-en"></a>

## English

<p align="right"><a href="#lang-vi">Tiếng Việt ↑</a> · <a href="#readme-top">Top ↑</a></p>

PowerShell script to remove **Windows** and/or **Microsoft Office** product keys using Microsoft’s official tools (`slmgr.vbs`, `ospp.vbs`).

**Repository:** [github.com/ZakShinn/Win-Key-Remover](https://github.com/ZakShinn/Win-Key-Remover)

### Requirements

- Windows with PowerShell.
- Run **PowerShell as Administrator** (the script includes `#Requires -RunAsAdministrator`).
- Office must be installed (for the Office key removal path) so `ospp.vbs` can be found.

### Download

- Clone: `git clone https://github.com/ZakShinn/Win-Key-Remover.git`
- Or download [Win-Key-Remover.ps1](https://github.com/ZakShinn/Win-Key-Remover/blob/main/Win-Key-Remover.ps1) from GitHub.

### How to run

1. Open **PowerShell** (or Windows Terminal) **as administrator**.
2. If needed, allow scripts for the current session only, for example:

   ```powershell
   Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
   ```

3. Go to the folder that contains the script, then run:

   ```powershell
   cd "C:\path\to\Win-Key-Remover"
   .\Win-Key-Remover.ps1
   ```

4. When prompted, choose the UI language: **1** = Vietnamese, **2** = English (or use `-Lang` below to skip the prompt).

### Command-line parameters

| Parameter | Values | Description |
|-----------|--------|-------------|
| `-Lang` | `vi` or `en` | Fix the UI language; no prompt at startup. |

Example: English UI from the start:

```powershell
.\Win-Key-Remover.ps1 -Lang en
```

### Menu after launch

After the disclaimer, enter one of the following:

| Key | Action |
|-----|--------|
| **1** | Windows only — `slmgr` `/upk`, `/cpky`, `/ckms` |
| **2** | Office only — `ospp.vbs` `/unpkey` based on `/dstatus` |
| **3** | Both Windows and Office |

After removing the Windows key, check **Settings → System → Activation** (or the equivalent). For Office, use the command suggested on screen when the script finishes.

### Optional: pull the latest script from GitHub

In `Win-Key-Remover.ps1`, `$RemoteScriptUrl` is a placeholder by default. If you set it to this repository’s raw URL, the script can offer to download the latest copy before continuing:

`https://raw.githubusercontent.com/ZakShinn/Win-Key-Remover/main/Win-Key-Remover.ps1`

### Important notes

- You accept all risks. Windows or Office may show as **not activated**.
- This script does **not** remove cracks that rely on patched files, `hosts` edits, or fake services.
- Not every Windows edition offers a trial period after the key is removed.

### License

This project is licensed under **GPL-3.0** — see [`LICENSE`](LICENSE) in the repository.

| [**Tiếng Việt**](#lang-vi) | [**Top**](#readme-top) |
|:-------------------------:|:----------------------:|
