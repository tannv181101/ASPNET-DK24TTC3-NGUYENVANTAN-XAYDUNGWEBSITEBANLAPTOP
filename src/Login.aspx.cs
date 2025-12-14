using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;

namespace Laptop
{
    public partial class Login : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                // Nếu đã đăng nhập rồi thì đá về trang chủ
                if (Session["MaTK"] != null)
                {
                    Response.Redirect("Default.aspx");
                }
            }
        }

        protected void btnLogin_Click(object sender, EventArgs e)
        {
            string input = txtEmail.Text.Trim(); // Có thể là Email hoặc SĐT
            string matKhau = txtMatKhau.Text.Trim();

            if (string.IsNullOrEmpty(input) || string.IsNullOrEmpty(matKhau))
            {
                lblLoi.Text = "Vui lòng nhập đầy đủ thông tin!";
                return;
            }

            // Query kiểm tra: Cho phép đăng nhập bằng Email HOẶC Số điện thoại
            // Lưu ý: Mật khẩu hiện tại đang so sánh plain-text (123). 
            // Nếu thực tế bạn dùng MD5 thì chỗ này phải mã hóa matKhau trước khi so sánh.
            string sql = @"SELECT * FROM TaiKhoan 
                           WHERE (Email = @Input OR SoDienThoai = @Input) 
                           AND MatKhau = @MatKhau";

            SqlParameter[] p = {
                new SqlParameter("@Input", input),
                new SqlParameter("@MatKhau", matKhau)
            };

            DataRow row = DBConnect.GetOneRow(sql, p);

            if (row != null)
            {
                // Đăng nhập thành công -> Lưu Session
                Session["MaTK"] = row["MaTK"].ToString();
                Session["HoTen"] = row["HoTen"].ToString();
                Session["Quyen"] = row["VaiTro"].ToString(); // 'Admin' hoặc 'Khach'
                Session["Email"] = row["Email"].ToString();

                // Điều hướng phân quyền
                string vaiTro = row["VaiTro"].ToString();

                if (vaiTro == "Admin")
                {
                    Response.Redirect("Admin/Dashboard.aspx"); // Vào thẳng trang quản lý
                }
                else
                {
                    // Nếu là khách, kiểm tra xem khách muốn đi đâu trước đó không?
                    // Ở đây mặc định về trang Đơn hàng của tôi cho tiện theo dõi
                    Response.Redirect("DonHangCuaToi.aspx");
                }
            }
            else
            {
                lblLoi.Text = "Sai tài khoản hoặc mật khẩu!";
            }
        }
    }
}