using System;
using System.Web;
using System.IO;

namespace Laptop.Admin // <--- QUAN TRỌNG: Namespace này phải khớp với dòng Class ở Bước 2
{
    public class UploadHandler : IHttpHandler
    {
        public void ProcessRequest(HttpContext context)
        {
            // Trả về định dạng JSON
            context.Response.ContentType = "application/json";

            // Kiểm tra xem có file gửi lên không
            if (context.Request.Files.Count > 0)
            {
                try
                {
                    HttpPostedFile file = context.Request.Files[0];
                    string fileExtension = Path.GetExtension(file.FileName).ToLower();

                    // 1. Kiểm tra đuôi file an toàn
                    if (fileExtension == ".jpg" || fileExtension == ".jpeg" || fileExtension == ".png" || fileExtension == ".gif")
                    {
                        // 2. Tạo tên file duy nhất (Tránh trùng lặp)
                        string fileName = DateTime.Now.Ticks.ToString() + "_" + Path.GetFileName(file.FileName);

                        // 3. Đường dẫn lưu file: /Images/Products/
                        string uploadFolder = "~/Images/Products/";
                        string serverPath = context.Server.MapPath(uploadFolder);

                        // Tạo thư mục nếu chưa có
                        if (!Directory.Exists(serverPath))
                        {
                            Directory.CreateDirectory(serverPath);
                        }

                        // 4. Lưu file vật lý
                        string fullPath = Path.Combine(serverPath, fileName);
                        file.SaveAs(fullPath);

                        // 5. Trả về URL cho CKEditor
                        // Sử dụng VirtualPathUtility để đảm bảo đường dẫn đúng dù chạy ở localhost hay server thật
                        string imageUrl = VirtualPathUtility.ToAbsolute(uploadFolder + fileName);

                        // Cấu trúc JSON chuẩn của CKEditor 4.x
                        context.Response.Write("{\"uploaded\": 1, \"fileName\": \"" + fileName + "\", \"url\": \"" + imageUrl + "\"}");
                    }
                    else
                    {
                        context.Response.Write("{\"uploaded\": 0, \"error\": {\"message\": \"Chỉ cho phép file ảnh (jpg, png, gif).\"}}");
                    }
                }
                catch (Exception ex)
                {
                    // Báo lỗi server nếu có
                    context.Response.Write("{\"uploaded\": 0, \"error\": {\"message\": \"Lỗi Server: " + ex.Message + "\"}}");
                }
            }
            else
            {
                context.Response.Write("{\"uploaded\": 0, \"error\": {\"message\": \"Không tìm thấy file gửi lên.\"}}");
            }
        }

        public bool IsReusable
        {
            get { return false; }
        }
    }
}