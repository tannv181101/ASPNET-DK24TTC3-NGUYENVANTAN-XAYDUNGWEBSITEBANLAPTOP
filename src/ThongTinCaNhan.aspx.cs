using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Laptop
{
    public partial class ThongTinCaNhan : System.Web.UI.Page
    {
        // Khai báo các Controls đã đổi tên và Controls mới
        // (Visual Studio sẽ tự tạo các trường này, nhưng tôi để đây để bạn dễ hình dung)
        // protected Label lblThongBaoProfile; 
        // protected TextBox txtMatKhauCu; 
        // protected TextBox txtMatKhauMoi; 
        // protected TextBox txtXacNhanMoi;
        // protected Label lblThongBaoPassword;
        // protected Panel pnlPassword;

        protected void Page_Load(object sender, EventArgs e)
        {
            // Kiểm tra đăng nhập
            if (Session["MaTK"] == null)
            {
                // Nếu chưa đăng nhập, ẩn cả 2 phần form
                pnlProfile.Visible = false;
                pnlPassword.Visible = false;
                pnlChuaLogin.Visible = true;
                return;
            }

            if (!IsPostBack)
            {
                LoadThongTin();
            }
        }

        private void LoadThongTin()
        {
            int maTK = Convert.ToInt32(Session["MaTK"]);

            string sql = "SELECT HoTen, Email, SoDienThoai, DiaChi FROM TaiKhoan WHERE MaTK = @MaTK";
            SqlParameter[] p = { new SqlParameter("@MaTK", maTK) };
            DataRow row = DBConnect.GetOneRow(sql, p);

            if (row != null)
            {
                txtHoTen.Text = row["HoTen"].ToString();
                lblEmail.Text = "Email: " + row["Email"].ToString();
                txtSoDienThoai.Text = row["SoDienThoai"].ToString();
                txtDiaChi.Text = row["DiaChi"].ToString();
            }
        }

        protected void btnCapNhat_Click(object sender, EventArgs e)
        {
            // Kiểm tra ValidationGroup="ProfileGroup"
            if (Page.IsValid)
            {
                int maTK = Convert.ToInt32(Session["MaTK"]);

                // Xử lý các trường cho phép NULL (nếu SĐT/Địa chỉ không bắt buộc)
                object valSoDT = string.IsNullOrEmpty(txtSoDienThoai.Text.Trim()) ? DBNull.Value : (object)txtSoDienThoai.Text.Trim();
                object valDiaChi = string.IsNullOrEmpty(txtDiaChi.Text.Trim()) ? DBNull.Value : (object)txtDiaChi.Text.Trim();

                string sql = @"UPDATE TaiKhoan SET 
                               HoTen = @HoTen, 
                               SoDienThoai = @SDT, 
                               DiaChi = @DiaChi 
                               WHERE MaTK = @MaTK";

                SqlParameter[] p = {
                    new SqlParameter("@HoTen", txtHoTen.Text.Trim()),
                    new SqlParameter("@SDT", valSoDT),
                    new SqlParameter("@DiaChi", valDiaChi),
                    new SqlParameter("@MaTK", maTK)
                };

                try
                {
                    DBConnect.Execute(sql, p);

                    // Cập nhật lại Session HoTen (cho header)
                    Session["HoTen"] = txtHoTen.Text.Trim();

                    lblThongBaoProfile.Text = "Cập nhật thông tin thành công!";
                    lblThongBaoProfile.CssClass = "text-success";
                    lblThongBaoPassword.Text = ""; // Xóa thông báo của phần mật khẩu
                }
                catch (Exception ex)
                {
                    lblThongBaoProfile.Text = "Lỗi cập nhật: " + ex.Message;
                    lblThongBaoProfile.CssClass = "text-danger";
                }
            }
        }

        protected void btnDoiMatKhau_Click(object sender, EventArgs e)
        {
            if (Session["MaTK"] == null) return;

            // Kiểm tra ValidationGroup="PasswordGroup"
            if (Page.IsValid)
            {
                int maTK = Convert.ToInt32(Session["MaTK"]);
                string matKhauCu = txtMatKhauCu.Text.Trim();
                string matKhauMoi = txtMatKhauMoi.Text.Trim();

                // 1. KIỂM TRA MẬT KHẨU CŨ
                string sqlCheck = "SELECT MatKhau FROM TaiKhoan WHERE MaTK = @MaTK AND MatKhau = @MatKhauCu";
                SqlParameter[] pCheck = {
                    new SqlParameter("@MaTK", maTK),
                    new SqlParameter("@MatKhauCu", matKhauCu)
                };

                DataRow row = DBConnect.GetOneRow(sqlCheck, pCheck);

                if (row == null)
                {
                    lblThongBaoPassword.Text = "Mật khẩu cũ không chính xác!";
                    lblThongBaoPassword.CssClass = "text-danger";
                    lblThongBaoProfile.Text = ""; // Xóa thông báo của phần profile
                    return;
                }

                // 2. CẬP NHẬT MẬT KHẨU MỚI
                string sqlUpdate = "UPDATE TaiKhoan SET MatKhau = @MatKhauMoi WHERE MaTK = @MaTK";
                SqlParameter[] pUpdate = {
                    new SqlParameter("@MatKhauMoi", matKhauMoi),
                    new SqlParameter("@MaTK", maTK)
                };

                try
                {
                    DBConnect.Execute(sqlUpdate, pUpdate);

                    lblThongBaoPassword.Text = "Đổi mật khẩu thành công!";
                    lblThongBaoPassword.CssClass = "text-success";
                    lblThongBaoProfile.Text = ""; // Xóa thông báo của phần profile

                    // Reset các ô nhập liệu
                    txtMatKhauCu.Text = "";
                    txtMatKhauMoi.Text = "";
                    txtXacNhanMoi.Text = "";
                }
                catch (Exception)
                {
                    lblThongBaoPassword.Text = "Lỗi hệ thống: Không thể cập nhật mật khẩu.";
                    lblThongBaoPassword.CssClass = "text-danger";
                }
            }
        }
    }
}