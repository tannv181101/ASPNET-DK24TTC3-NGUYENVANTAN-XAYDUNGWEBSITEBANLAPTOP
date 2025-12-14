using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Collections.Generic;

namespace Laptop.Admin
{
    public partial class QuanLyTaiKhoan : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadDanhSachTaiKhoan();
            }
        }

        private void LoadDanhSachTaiKhoan()
        {
            string role = ddlFilterRole.SelectedValue;
            string keyword = txtSearch.Text.Trim();

            // CẬP NHẬT SQL: Thêm tìm kiếm theo SoDienThoai
            string sql = @"
                SELECT * FROM TaiKhoan 
                WHERE (@Role = 'All' OR VaiTro = @Role)
                AND (@Key = '' 
                     OR HoTen LIKE N'%' + @Key + '%' 
                     OR Email LIKE '%' + @Key + '%' 
                     OR SoDienThoai LIKE '%' + @Key + '%')
                ORDER BY MaTK DESC";

            SqlParameter[] p = {
                new SqlParameter("@Role", role),
                new SqlParameter("@Key", keyword)
            };

            DataTable dt = DBConnect.GetData(sql, p);
            if (dt != null && dt.Rows.Count > 0)
            {
                rptTaiKhoan.DataSource = dt;
                rptTaiKhoan.DataBind();
                lblThongBao.Visible = false;
            }
            else
            {
                rptTaiKhoan.DataSource = null;
                rptTaiKhoan.DataBind();
                lblThongBao.Visible = true;
            }
        }

        protected void btnSearch_Click(object sender, EventArgs e)
        {
            LoadDanhSachTaiKhoan();
        }

        protected void btnOpenModal_Click(object sender, EventArgs e)
        {
            ResetForm();
            ScriptManager.RegisterStartupScript(this, GetType(), "ShowModal", "showModalServer();", true);
        }

        protected void rptTaiKhoan_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            int maTK = Convert.ToInt32(e.CommandArgument);

            if (e.CommandName == "DeleteUser")
            {
                string sql = "DELETE FROM TaiKhoan WHERE MaTK = @MaTK";
                SqlParameter[] p = { new SqlParameter("@MaTK", maTK) };

                try
                {
                    DBConnect.Execute(sql, p);

                    // SỬA LỖI: Xóa ô tìm kiếm sau khi xóa xong để hiện lại toàn bộ danh sách
                    txtSearch.Text = "";

                    ScriptManager.RegisterStartupScript(this, GetType(), "alert", "alert('Đã xóa tài khoản thành công!');", true);
                    LoadDanhSachTaiKhoan();
                }
                catch (Exception ex)
                {
                    ScriptManager.RegisterStartupScript(this, GetType(), "alert", $"alert('Lỗi xóa: {ex.Message}');", true);
                }
            }
            else if (e.CommandName == "EditUser")
            {
                DataRow row = DBConnect.GetOneRow("SELECT * FROM TaiKhoan WHERE MaTK = " + maTK);
                if (row != null)
                {
                    hfMaTK.Value = maTK.ToString();
                    txtHoTen.Text = row["HoTen"].ToString();
                    txtEmail.Text = row["Email"].ToString();
                    txtSDT.Text = row["SoDienThoai"].ToString();
                    txtDiaChi.Text = row["DiaChi"].ToString();
                    ddlVaiTro.SelectedValue = row["VaiTro"].ToString();
                    txtMatKhau.Text = "";

                    ScriptManager.RegisterStartupScript(this, GetType(), "ShowModal",
                        "document.getElementById('userModalTitle').innerText = 'Cập nhật tài khoản'; showModalServer();", true);
                }
            }
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            int maTK = Convert.ToInt32(hfMaTK.Value);
            string hoTen = txtHoTen.Text.Trim();
            string email = txtEmail.Text.Trim();
            string sdt = txtSDT.Text.Trim();
            string diaChi = txtDiaChi.Text.Trim();
            string vaiTro = ddlVaiTro.SelectedValue;
            string matKhau = txtMatKhau.Text.Trim();

            object valEmail = string.IsNullOrEmpty(email) ? DBNull.Value : (object)email;
            object valSDT = string.IsNullOrEmpty(sdt) ? DBNull.Value : (object)sdt;
            object valDiaChi = string.IsNullOrEmpty(diaChi) ? DBNull.Value : (object)diaChi;

            if (maTK == 0) // THÊM MỚI
            {
                if (string.IsNullOrEmpty(matKhau)) matKhau = "123";

                string sql = @"INSERT INTO TaiKhoan (HoTen, Email, MatKhau, SoDienThoai, DiaChi, VaiTro, NgayTao) 
                               VALUES (@HoTen, @Email, @MatKhau, @SDT, @DiaChi, @VaiTro, GETDATE())";

                SqlParameter[] p = {
                    new SqlParameter("@HoTen", hoTen),
                    new SqlParameter("@Email", valEmail),
                    new SqlParameter("@MatKhau", matKhau),
                    new SqlParameter("@SDT", valSDT),
                    new SqlParameter("@DiaChi", valDiaChi),
                    new SqlParameter("@VaiTro", vaiTro)
                };
                DBConnect.Execute(sql, p);
                ScriptManager.RegisterStartupScript(this, GetType(), "alert", "alert('Thêm tài khoản thành công!');", true);
            }
            else // CẬP NHẬT
            {
                string sql = "";
                List<SqlParameter> listP = new List<SqlParameter>();

                listP.Add(new SqlParameter("@HoTen", hoTen));
                listP.Add(new SqlParameter("@Email", valEmail));
                listP.Add(new SqlParameter("@SDT", valSDT));
                listP.Add(new SqlParameter("@DiaChi", valDiaChi));
                listP.Add(new SqlParameter("@VaiTro", vaiTro));
                listP.Add(new SqlParameter("@MaTK", maTK));

                if (string.IsNullOrEmpty(matKhau))
                {
                    sql = @"UPDATE TaiKhoan SET HoTen=@HoTen, Email=@Email, SoDienThoai=@SDT, DiaChi=@DiaChi, VaiTro=@VaiTro 
                            WHERE MaTK=@MaTK";
                }
                else
                {
                    sql = @"UPDATE TaiKhoan SET HoTen=@HoTen, Email=@Email, MatKhau=@MatKhau, SoDienThoai=@SDT, DiaChi=@DiaChi, VaiTro=@VaiTro 
                            WHERE MaTK=@MaTK";
                    listP.Add(new SqlParameter("@MatKhau", matKhau));
                }

                DBConnect.Execute(sql, listP.ToArray());
                ScriptManager.RegisterStartupScript(this, GetType(), "alert", "alert('Cập nhật thành công!');", true);
            }

            // SỬA LỖI: Xóa ô tìm kiếm sau khi Lưu thành công để tránh lỗi tự tìm số cũ
            txtSearch.Text = "";

            LoadDanhSachTaiKhoan();
        }

        private void ResetForm()
        {
            hfMaTK.Value = "0";
            txtHoTen.Text = "";
            txtEmail.Text = "";
            txtSDT.Text = "";
            txtDiaChi.Text = "";
            txtMatKhau.Text = "";
            ddlVaiTro.SelectedValue = "Khach";
        }
    }
}