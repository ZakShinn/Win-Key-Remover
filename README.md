# Win Key Remover

<a id="readme-top"></a>

**Nhanh / Quick — chọn ngôn ngữ / pick language:**

| [**Tiếng Việt**](#lang-vi) | [**English**](#lang-en) |
|:-------------------------:|:-----------------------:|

---

<a id="lang-vi"></a>

## Tiếng Việt — Hướng dẫn sử dụng

<p align="right"><a href="#lang-en">English ↓</a> · <a href="#readme-top">Lên đầu ↑</a></p>

Script PowerShell dùng công cụ chính thức của Microsoft (`slmgr.vbs`, `ospp.vbs`) để **gỡ product key Windows** và/hoặc **Microsoft Office**.

**Kho mã nguồn:** [github.com/ZakShinn/Win-Key-Remover](https://github.com/ZakShinn/Win-Key-Remover)

### Mục lục

| Bước | Nội dung |
|:----:|----------|
| 1 | [Chuẩn bị — yêu cầu](#vi-1) |
| 2 | [Lấy file script](#vi-2) |
| 3 | [Chạy lần đầu (PowerShell Admin)](#vi-3) |
| 4 | [Chạy bằng lệnh / đường dẫn đầy đủ / tải từ GitHub](#vi-4) |
| 5 | [Tham số `-Lang`](#vi-5) |
| 6 | [Trong khi chạy: cảnh báo và menu](#vi-6) |
| 7 | [Tùy chọn: cập nhật script trong file `.ps1`](#vi-7) |
| 0 | [Chế độ debug (kiểm tra lỗi)](#vi-debug) |
| ? | [Sự cố thường gặp](#vi-faq) |
| — | [Lưu ý quan trọng](#vi-notes) · [Giấy phép](#vi-license) |

<a id="vi-debug"></a>

### Bước 0. Chế độ debug (kiểm tra lỗi, không gỡ key)

Chạy **trước** khi dùng script chính nếu gặp lỗi. Script debug **không** gỡ key, chỉ kiểm tra môi trường và ghi log.

```powershell
cd "G:\Github\Win-Key-Remover"
.\Win-Key-Remover-Debug.ps1
```

Hoặc double-click **`Run-Win-Key-Remover-Debug.cmd`** (có thêm thử tải từ GitHub).

Tiếng Anh + thử mạng:

```powershell
.\Win-Key-Remover-Debug.ps1 -Lang en -DownloadTest
```

Log lưu tại `%TEMP%\Win-Key-Remover-debug-*.log`. **FAIL** = cần sửa (thường là chưa Admin); **WARN** = cảnh báo (ví dụ PowerShell 7, chưa cài Office).

<a id="vi-1"></a>

### Bước 1. Chuẩn bị — yêu cầu

1. Máy chạy **Windows** và có **PowerShell**.
2. Bạn phải mở **PowerShell (hoặc Windows Terminal) với quyền Administrator** — trong script có `#Requires -RunAsAdministrator`, không đủ quyền sẽ không chạy.
3. **Khuyến nghị:** **Windows PowerShell 5.1** (`powershell.exe`). Nếu bạn dùng **PowerShell 7** (`pwsh`), script sẽ **tự chuyển** sang `powershell.exe` 5.1.
4. Nếu cần gỡ key **Office**, máy phải đã cài Office để script tìm được `ospp.vbs`.
5. **Không cần `cd`:** có thể double-click file **`Run-Win-Key-Remover.cmd`** (cạnh `Win-Key-Remover.ps1`) để mở cửa sổ Admin và chạy script.

<a id="vi-2"></a>

### Bước 2. Lấy file script

Chọn một cách:

- **Clone repo:**  
  `git clone https://github.com/ZakShinn/Win-Key-Remover.git`
- **Tải một file:** mở [Win-Key-Remover.ps1 trên GitHub](https://github.com/ZakShinn/Win-Key-Remover/blob/main/Win-Key-Remover.ps1), bấm **Raw** hoặc **Download**, lưu vào thư mục bạn nhớ được (ví dụ `G:\Github\Win-Key-Remover`).

Ghi nhớ **đường dẫn đầy đủ** tới `Win-Key-Remover.ps1` — bước sau sẽ dùng.

<a id="vi-3"></a>

### Bước 3. Chạy lần đầu (PowerShell Admin)

1. Nhấn **Win**, gõ `PowerShell`, chuột phải **Windows PowerShell** → **Run as administrator** (hoặc trong Terminal: mở tab PowerShell rồi **Run as administrator**).
2. Nếu máy chặn script chưa ký, chỉ **nới trong phiên hiện tại** (an toàn hơn đổi policy vĩnh viễn):

   ```powershell
   Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
   ```

3. Vào thư mục chứa script, rồi chạy (sửa đường dẫn `cd` cho đúng):

   ```powershell
   cd "G:\Github\Win-Key-Remover"
   .\Win-Key-Remover.ps1
   ```

   Trong PowerShell, script nằm **cùng thư mục hiện tại** chỉ chạy được nếu có tiền tố **`.\`**. Gõ `Win-Key-Remover.ps1` (không có `.\`) sẽ báo *The term 'Win-Key-Remover.ps1' is not recognized* — đó là cách hoạt động mặc định của PowerShell (xem `Get-Help about_Command_Precedence`).

4. Khi được hỏi ngôn ngữ giao diện: nhập **1** = Tiếng Việt, **2** = English.  
   Muốn **bỏ bước hỏi ngôn ngữ**, xem [Bước 5](#vi-5).

<a id="vi-4"></a>

### Bước 4. Chạy bằng lệnh (không cần `cd`)

Vẫn trong **PowerShell (Admin)**. Thay chuỗi trong ngoặc kép bằng đường dẫn thật trên máy bạn.

**Cách A — Gọi file bằng toán tử `&`:**

```powershell
& "G:\Github\Win-Key-Remover\Win-Key-Remover.ps1"
```

**Cách B — Gọi qua `powershell.exe`** (tiện khi dán lệnh từ **CMD** hoặc hộp thoại **Run**):

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "G:\Github\Win-Key-Remover\Win-Key-Remover.ps1"
```

**Cách C — Tải bản mới nhất từ GitHub rồi chạy** (chỉ khi bạn tin URL; nên mở [raw](https://raw.githubusercontent.com/ZakShinn/Win-Key-Remover/main/Win-Key-Remover.ps1) và xem nội dung trước):

```powershell
$url = "https://raw.githubusercontent.com/ZakShinn/Win-Key-Remover/main/Win-Key-Remover.ps1"
$tmp = Join-Path $env:TEMP "Win-Key-Remover.ps1"
Invoke-WebRequest -Uri $url -OutFile $tmp -UseBasicParsing
powershell.exe -NoProfile -ExecutionPolicy Bypass -File $tmp
```

**Cách D — Một dòng tải và chạy (khuyến nghị thay `irm | iex`):**

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -Command "$u='https://raw.githubusercontent.com/ZakShinn/Win-Key-Remover/main/Win-Key-Remover.ps1'; $p=Join-Path $env:TEMP 'Win-Key-Remover.ps1'; (New-Object Net.WebClient).DownloadFile($u,$p); & \"$env:SystemRoot\System32\WindowsPowerShell\v1.0\powershell.exe\" -NoProfile -ExecutionPolicy Bypass -File $p"
```

**Cách E — `irm | iex`** (vẫn dùng được trên bản script mới): script tự tải lại file vào `%TEMP%` rồi chạy bằng Windows PowerShell 5.1 (tránh lỗi biến `$Lang` / khác phiên bản):

```powershell
irm https://raw.githubusercontent.com/ZakShinn/Win-Key-Remover/main/Win-Key-Remover.ps1 | iex
```

Cố định ngôn ngữ: dùng cách A/B/C/D với `-Lang vi` hoặc `-Lang en`.

<a id="vi-5"></a>

### Bước 5. Tham số `-Lang`

| Tham số | Giá trị | Tác dụng |
|---------|---------|----------|
| `-Lang` | `vi` hoặc `en` | Giao diện cố định, **không** hỏi chọn ngôn ngữ lúc mở script. |

Ví dụ (đường dẫn tùy máy bạn):

```powershell
& "G:\Github\Win-Key-Remover\Win-Key-Remover.ps1" -Lang vi
```

```powershell
.\Win-Key-Remover.ps1 -Lang en
```

<a id="vi-6"></a>

### Bước 6. Trong khi chạy: cảnh báo và menu

1. Script hiển thị **cảnh báo / disclaimer** — đọc kỹ rồi tiếp tục theo hướng dẫn trên màn hình.
2. Sau đó chọn chế độ, nhập **một** số rồi **Enter**:

| Nhập | Ý nghĩa |
|------|---------|
| **1** | Chỉ Windows — `slmgr` `/upk`, `/cpky`, `/ckms` |
| **2** | Chỉ Office — `ospp.vbs` `/unpkey` (theo `/dstatus`) |
| **3** | Cả Windows và Office |

3. **Kiểm tra sau khi xong:** Windows — **Cài đặt → Hệ thống → Kích hoạt** (hoặc tương đương). Office — dùng lệnh script gợi ý (thường dạng `cscript //Nologo "…\ospp.vbs" /dstatus`).

<a id="vi-7"></a>

### Bước 7. Tùy chọn: cập nhật từ GitHub trong file script

Khi chạy, script có thể hỏi có muốn tải bản mới từ GitHub trước khi tiếp tục. **Nhấn `N` (Enter)** nếu bạn đã có bản `D:\Win-Key-Remover` mới hơn GitHub. Bản script mới **kiểm tra cú pháp** sau khi tải; nếu GitHub chưa được push bản sửa lỗi, sẽ **không** chạy file lỗi mà tiếp tục bản local.

<a id="vi-faq"></a>

### Sự cố thường gặp

- **`The term 'Win-Key-Remover.ps1' is not recognized`** — Thiếu tiền tố **`.\`**. Chạy **`.\Win-Key-Remover.ps1`** hoặc xem [Bước 4](#vi-4).
- **`ScriptRequiresElevation` / không đủ quyền** — Mở **PowerShell (Admin)** hoặc dùng **`Run-Win-Key-Remover.cmd`**.
- **Lỗi `variable Lang` khi `irm | iex`** — Cập nhật script mới trên GitHub (bản mới tự tải file rồi chạy), hoặc dùng [Cách D](#vi-4) thay `iex`.
- **PowerShell 7 (`pwsh`) lỗi lạ** — Script tự chuyển sang **5.1**; hoặc mở **Windows PowerShell** (không phải `pwsh`) rồi chạy lại.
- **Vẫn lỗi sau khi sửa local** — Đảm bảo đã **push GitHub** và chạy lại lệnh tải từ raw (không dùng file `.ps1` cũ trên ổ `D:\`).

<a id="vi-notes"></a>

### Lưu ý quan trọng

- Bạn tự chịu rủi ro. Windows hoặc Office có thể ở trạng thái **chưa kích hoạt**.
- Script **không** gỡ crack kiểu patch file, `hosts`, hay dịch vụ giả.
- Không phải mọi bản Windows đều còn trial sau khi gỡ key.

<a id="vi-license"></a>

### Giấy phép

**GPL-3.0** — xem [`LICENSE`](LICENSE).

| [**English**](#lang-en) | [**Lên đầu / Top**](#readme-top) |
|:-----------------------:|:--------------------------------:|

---

<a id="lang-en"></a>

## English — User guide

<p align="right"><a href="#lang-vi">Tiếng Việt ↑</a> · <a href="#readme-top">Top ↑</a></p>

PowerShell script that uses Microsoft’s official tools (`slmgr.vbs`, `ospp.vbs`) to **remove Windows** and/or **Microsoft Office** product keys.

**Repository:** [github.com/ZakShinn/Win-Key-Remover](https://github.com/ZakShinn/Win-Key-Remover)

### Table of contents

| Step | Topic |
|:----:|-------|
| 1 | [Prerequisites](#en-1) |
| 2 | [Get the script file](#en-2) |
| 3 | [First run (PowerShell as Administrator)](#en-3) |
| 4 | [Run from anywhere / full path / download from GitHub](#en-4) |
| 5 | [The `-Lang` parameter](#en-5) |
| 6 | [While it runs: disclaimer and menu](#en-6) |
| 7 | [Optional: self-update URL inside `.ps1`](#en-7) |
| 0 | [Debug mode (diagnostics)](#en-debug) |
| ? | [Troubleshooting](#en-faq) |
| — | [Important notes](#en-notes) · [License](#en-license) |

<a id="en-debug"></a>

### Step 0. Debug mode (diagnostics, no key removal)

Run **before** the main script if something fails. Debug mode **does not** remove keys; it checks your environment and writes a log.

```powershell
cd "C:\path\to\Win-Key-Remover"
.\Win-Key-Remover-Debug.ps1
```

Or double-click **`Run-Win-Key-Remover-Debug.cmd`** (includes a GitHub download test).

English + network test:

```powershell
.\Win-Key-Remover-Debug.ps1 -Lang en -DownloadTest
```

Log file: `%TEMP%\Win-Key-Remover-debug-*.log`. **FAIL** = must fix (often: not Administrator); **WARN** = notice (e.g. PowerShell 7, Office not found).

<a id="en-1"></a>

### Step 1. Prerequisites

1. **Windows** with **PowerShell** available.
2. Start **PowerShell** (or Windows Terminal) **as Administrator** — the script contains `#Requires -RunAsAdministrator`.
3. **Recommended:** **Windows PowerShell 5.1** (`powershell.exe`). On **PowerShell 7** (`pwsh`), the script **re-launches** in 5.1 automatically.
4. For **Office** key removal, Office must be installed so `ospp.vbs` can be located.
5. **No `cd` needed:** double-click **`Run-Win-Key-Remover.cmd`** next to the `.ps1` file to elevate and run.

<a id="en-2"></a>

### Step 2. Get the script file

Pick one method:

- **Clone the repository:**  
  `git clone https://github.com/ZakShinn/Win-Key-Remover.git`
- **Download a single file:** open [Win-Key-Remover.ps1 on GitHub](https://github.com/ZakShinn/Win-Key-Remover/blob/main/Win-Key-Remover.ps1), use **Raw** or **Download**, and save it somewhere you remember (for example `C:\Tools\Win-Key-Remover`).

Keep the **full path** to `Win-Key-Remover.ps1` — you will need it next.

<a id="en-3"></a>

### Step 3. First run (PowerShell as Administrator)

1. Press **Win**, type `PowerShell`, right‑click **Windows PowerShell** → **Run as administrator** (or run your terminal elevated).
2. If execution policy blocks unsigned scripts, relax it **for this session only**:

   ```powershell
   Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
   ```

3. Change to the folder that contains the script, then run (adjust `cd`):

   ```powershell
   cd "C:\path\to\Win-Key-Remover"
   .\Win-Key-Remover.ps1
   ```

   In PowerShell, a script in the **current folder** must be started with the **`.\` prefix**. Typing `Win-Key-Remover.ps1` without `.\` produces *The term 'Win-Key-Remover.ps1' is not recognized* — that is by design (see `Get-Help about_Command_Precedence`).

4. When asked for the UI language, type **1** for Vietnamese or **2** for English.  
   To **skip that prompt**, see [Step 5](#en-5).

<a id="en-4"></a>

### Step 4. Run with commands (no `cd` needed)

Still in **PowerShell as Administrator**. Replace the quoted paths with your real path.

**Option A — Call operator `&`:**

```powershell
& "C:\path\to\Win-Key-Remover\Win-Key-Remover.ps1"
```

**Option B — `powershell.exe`** (handy from **CMD** or the **Run** dialog):

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "C:\path\to\Win-Key-Remover\Win-Key-Remover.ps1"
```

**Option C — Download latest from GitHub, then run** (only if you trust the URL; open the [raw file](https://raw.githubusercontent.com/ZakShinn/Win-Key-Remover/main/Win-Key-Remover.ps1) and read it first):

```powershell
$url = "https://raw.githubusercontent.com/ZakShinn/Win-Key-Remover/main/Win-Key-Remover.ps1"
$tmp = Join-Path $env:TEMP "Win-Key-Remover.ps1"
Invoke-WebRequest -Uri $url -OutFile $tmp -UseBasicParsing
powershell.exe -NoProfile -ExecutionPolicy Bypass -File $tmp
```

**Option D — One-liner download + run (preferred over `irm | iex`):**

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -Command "$u='https://raw.githubusercontent.com/ZakShinn/Win-Key-Remover/main/Win-Key-Remover.ps1'; $p=Join-Path $env:TEMP 'Win-Key-Remover.ps1'; (New-Object Net.WebClient).DownloadFile($u,$p); & \"$env:SystemRoot\System32\WindowsPowerShell\v1.0\powershell.exe\" -NoProfile -ExecutionPolicy Bypass -File $p"
```

**Option E — `irm | iex`** (supported on current script): re-downloads to `%TEMP%` and runs via Windows PowerShell 5.1:

```powershell
irm https://raw.githubusercontent.com/ZakShinn/Win-Key-Remover/main/Win-Key-Remover.ps1 | iex
```

Use A/B/C/D with `-Lang vi` or `-Lang en` to fix the UI language.

<a id="en-5"></a>

### Step 5. The `-Lang` parameter

| Parameter | Values | Effect |
|-----------|--------|--------|
| `-Lang` | `vi` or `en` | Locks the UI language; **no** language prompt at startup. |

Examples:

```powershell
& "C:\path\to\Win-Key-Remover\Win-Key-Remover.ps1" -Lang vi
```

```powershell
.\Win-Key-Remover.ps1 -Lang en
```

<a id="en-6"></a>

### Step 6. While it runs: disclaimer and menu

1. Read the **disclaimer** printed by the script, then continue as prompted.
2. Choose a mode — type **one** digit and press **Enter**:

| Key | Action |
|-----|--------|
| **1** | Windows only — `slmgr` `/upk`, `/cpky`, `/ckms` |
| **2** | Office only — `ospp.vbs` `/unpkey` (from `/dstatus`) |
| **3** | Both Windows and Office |

3. **Verify:** Windows — **Settings → System → Activation**. Office — use the command the script prints (often `cscript //Nologo "…\ospp.vbs" /dstatus`).

<a id="en-7"></a>

### Step 7. Optional: self-update inside the script

The script may ask to download the newest copy from GitHub. Press **`N`** if your local copy is already newer. After download, the script **validates syntax**; if GitHub is outdated, it **keeps your local copy** instead of running a broken file.

<a id="en-faq"></a>

### Troubleshooting

- **`The term 'Win-Key-Remover.ps1' is not recognized`** — Omit the **`.\` prefix**. Run **`.\Win-Key-Remover.ps1`** or see [Step 4](#en-4).
- **`ScriptRequiresElevation`** — Open **PowerShell as Administrator** or use **`Run-Win-Key-Remover.cmd`**.
- **`variable Lang` with `irm | iex`** — Pull the latest script (new builds bootstrap via a temp file), or use [Option D](#en-4) instead of `iex`.
- **Weird errors on PowerShell 7** — The script switches to **5.1** automatically; or run **Windows PowerShell** (not `pwsh`) manually.
- **Still failing** — Make sure changes are **pushed to GitHub** and you are not running an old copy from disk.

<a id="en-notes"></a>

### Important notes

- You accept all risks. Windows or Office may show as **not activated**.
- This script does **not** remove cracks based on patched binaries, `hosts` files, or fake services.
- Not every Windows edition still offers a trial after the product key is removed.

<a id="en-license"></a>

### License

**GPL-3.0** — see [`LICENSE`](LICENSE).

| [**Tiếng Việt**](#lang-vi) | [**Top**](#readme-top) |
|:-------------------------:|:----------------------:|
