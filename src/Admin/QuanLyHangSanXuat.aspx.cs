using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Laptop.Admin
{
    public partial class QuanLyHangSanXuat : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadDanhSachHang();
            }
        }

        private void LoadDanhSachHang()
        {
            string keyword = txtSearch.Text.Trim();
            string sql = "SELECT * FROM HangSanXuat WHERE TenHang LIKE N'%' + @Key + '%' ORDER BY MaHang DESC";
            SqlParameter[] p = { new SqlParameter("@Key", keyword) };

            DataTable dt = DBConnect.GetData(sql, p);
            if (dt != null && dt.Rows.Count > 0)
            {
                rptHang.DataSource = dt;
                rptHang.DataBind();
                lblThongBao.Visible = false;
            }
            else
            {
                rptHang.DataSource = null;
                rptHang.DataBind();
                lblThongBao.Visible = true;
            }
        }

        protected void btnSearch_Click(object sender, EventArgs e)
        {
            LoadDanhSachHang();
        }

        // Reset form khi bấm Thêm mới
        protected void btnOpenModal_Click(object sender, EventArgs e)
        {
            ResetForm();
            ScriptManager.RegisterStartupScript(this, GetType(), "ShowModal", "showModalServer();", true);
        }

        protected void rptHang_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            int maHang = Convert.ToInt32(e.CommandArgument);

            if (e.CommandName == "DeleteHang")
            {
                // CẢNH BÁO: Xóa hãng sẽ xóa luôn Laptop (Do CASCADE DELETE trong SQL)
                string sql = "DELETE FROM HangSanXuat WHERE MaHang = @MaHang";
                SqlParameter[] p = { new SqlParameter("@MaHang", maHang) };

                try
                {
                    DBConnect.Execute(sql, p);

                    // Xóa ô tìm kiếm để load lại toàn bộ
                    txtSearch.Text = "";
                    LoadDanhSachHang();
                    ScriptManager.RegisterStartupScript(this, GetType(), "alert", "alert('Đã xóa hãng và toàn bộ laptop liên quan!');", true);
                }
                catch (Exception ex)
                {
                    ScriptManager.RegisterStartupScript(this, GetType(), "alert", $"alert('Lỗi khi xóa: {ex.Message}');", true);
                }
            }
            else if (e.CommandName == "EditHang")
            {
                DataRow row = DBConnect.GetOneRow("SELECT * FROM HangSanXuat WHERE MaHang = " + maHang);
                if (row != null)
                {
                    hfMaHang.Value = maHang.ToString();
                    txtTenHang.Text = row["TenHang"].ToString();
                    txtMoTa.Text = row["MoTa"].ToString();

                    ScriptManager.RegisterStartupScript(this, GetType(), "ShowModal",
                        "document.getElementById('brandModalTitle').innerText = 'Cập nhật hãng'; showModalServer();", true);
                }
            }
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            int maHang = Convert.ToInt32(hfMaHang.Value);
            string tenHang = txtTenHang.Text.Trim();
            string moTa = txtMoTa.Text.Trim();

            object valMoTa = string.IsNullOrEmpty(moTa) ? DBNull.Value : (object)moTa;

            try
            {
                if (maHang == 0) // THÊM MỚI
                {
                    string sql = "INSERT INTO HangSanXuat (TenHang, MoTa) VALUES (@TenHang, @MoTa)";
                    SqlParameter[] p = {
                        new SqlParameter("@TenHang", tenHang),
                        new SqlParameter("@MoTa", valMoTa)
                    };
                    DBConnect.Execute(sql, p);
                    ScriptManager.RegisterStartupScript(this, GetType(), "alert", "alert('Thêm hãng thành công!');", true);
                }
                else // CẬP NHẬT
                {
                    string sql = "UPDATE HangSanXuat SET TenHang = @TenHang, MoTa = @MoTa WHERE MaHang = @MaHang";
                    SqlParameter[] p = {
                        new SqlParameter("@TenHang", tenHang),
                        new SqlParameter("@MoTa", valMoTa),
                        new SqlParameter("@MaHang", maHang)
                    };
                    DBConnect.Execute(sql, p);
                    ScriptManager.RegisterStartupScript(this, GetType(), "alert", "alert('Cập nhật thành công!');", true);
                }

                // Xóa ô tìm kiếm sau khi lưu
                txtSearch.Text = "";
                LoadDanhSachHang();
            }
            catch (Exception ex)
            {
                // Bắt lỗi trùng tên (Unique Constraint)
                if (ex.Message.Contains("UNIQUE KEY"))
                {
                    ScriptManager.RegisterStartupScript(this, GetType(), "alert", "alert('Lỗi: Tên hãng này đã tồn tại, vui lòng chọn tên khác!');", true);
                }
                else
                {
                    ScriptManager.RegisterStartupScript(this, GetType(), "alert", $"alert('Lỗi hệ thống: {ex.Message}');", true);
                }
            }
        }

        private void ResetForm()
        {
            hfMaHang.Value = "0";
            txtTenHang.Text = "";
            txtMoTa.Text = "";
        }
    }
}