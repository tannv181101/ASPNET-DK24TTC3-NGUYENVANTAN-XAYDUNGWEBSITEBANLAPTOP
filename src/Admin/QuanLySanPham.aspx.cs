using System;
using System.Data;
using System.Data.SqlClient;
using System.IO;
using System.Text.RegularExpressions;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Laptop.Admin
{
    public partial class QuanLySanPham : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadComboboxHang();
                LoadDanhSachLaptop();
            }
        }

        private void LoadComboboxHang()
        {
            DataTable dt = DBConnect.GetData("SELECT * FROM HangSanXuat");
            // Dropdown lọc
            ddlFilterHang.DataSource = dt;
            ddlFilterHang.DataTextField = "TenHang";
            ddlFilterHang.DataValueField = "MaHang";
            ddlFilterHang.DataBind();
            ddlFilterHang.Items.Insert(0, new ListItem("-- Tất cả Hãng --", "0"));

            // Dropdown trong Modal sửa
            ddlHang.DataSource = dt;
            ddlHang.DataTextField = "TenHang";
            ddlHang.DataValueField = "MaHang";
            ddlHang.DataBind();
        }

        private void LoadDanhSachLaptop()
        {
            string maHang = ddlFilterHang.SelectedValue;
            string key = txtSearch.Text.Trim();

            int maxTonKho = -1;
            if (!string.IsNullOrEmpty(txtFilterTon.Text))
            {
                int.TryParse(txtFilterTon.Text, out maxTonKho);
            }

            string sql = @"
                SELECT l.*, h.TenHang 
                FROM Laptop l JOIN HangSanXuat h ON l.MaHang = h.MaHang 
                WHERE (@MaHang = 0 OR l.MaHang = @MaHang)
                AND (@Key = '' OR l.TenLap LIKE N'%' + @Key + '%')
                AND (@MaxTon = -1 OR l.TonKho <= @MaxTon)
                ORDER BY l.TonKho ASC, l.MaLap DESC";

            SqlParameter[] p = {
                new SqlParameter("@MaHang", maHang),
                new SqlParameter("@Key", key),
                new SqlParameter("@MaxTon", maxTonKho)
            };

            DataTable dt = DBConnect.GetData(sql, p);
            if (dt != null && dt.Rows.Count > 0)
            {
                rptLaptop.DataSource = dt;
                rptLaptop.DataBind();
                lblThongBao.Visible = false;
            }
            else
            {
                rptLaptop.DataSource = null;
                rptLaptop.DataBind();
                lblThongBao.Visible = true;
            }
        }

        protected void btnSearch_Click(object sender, EventArgs e)
        {
            LoadDanhSachLaptop();
        }

        protected void rptLaptop_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            int maLap = Convert.ToInt32(e.CommandArgument);

            if (e.CommandName == "DeleteLap")
            {
                try
                {
                    DataRow row = DBConnect.GetOneRow("SELECT HinhAnh, MoTa FROM Laptop WHERE MaLap=" + maLap);
                    if (row != null)
                    {
                        DeleteFile(row["HinhAnh"].ToString());
                        DeleteImagesInHtml(row["MoTa"].ToString());
                    }

                    DataTable dtAlbum = DBConnect.GetData("SELECT DuongDan FROM Albums WHERE MaLap=" + maLap);
                    if (dtAlbum != null)
                    {
                        foreach (DataRow dr in dtAlbum.Rows) DeleteFile(dr["DuongDan"].ToString());
                    }

                    DBConnect.Execute("DELETE FROM Laptop WHERE MaLap=" + maLap);
                    LoadDanhSachLaptop();
                    ScriptManager.RegisterStartupScript(this, GetType(), "alert", "alert('Đã xóa sản phẩm thành công!');", true);
                }
                catch (Exception ex)
                {
                    ScriptManager.RegisterStartupScript(this, GetType(), "alert", $"alert('Lỗi: {ex.Message}');", true);
                }
            }
            else if (e.CommandName == "EditLap")
            {
                // LOAD DỮ LIỆU LÊN MODAL ĐỂ SỬA
                DataRow row = DBConnect.GetOneRow("SELECT * FROM Laptop WHERE MaLap=" + maLap);
                if (row != null)
                {
                    hfMaLap.Value = maLap.ToString();
                    txtTenLap.Text = row["TenLap"].ToString();
                    ddlHang.SelectedValue = row["MaHang"].ToString();
                    txtGiaBan.Text = Convert.ToInt32(row["GiaBan"]).ToString();
                    txtTonKho.Text = row["TonKho"].ToString();
                    txtCauHinh.Text = row["CauHinh"].ToString();
                    txtMoTa.Text = row["MoTa"].ToString();

                    string oldImg = row["HinhAnh"].ToString();
                    hfOldImage.Value = oldImg;
                    imgPreview.ImageUrl = "~/Images/Products/" + oldImg;
                    imgPreview.Visible = true;

                    // Gọi hàm JS để hiện Modal
                    ScriptManager.RegisterStartupScript(this, GetType(), "ShowModal", "showModalServer();", true);
                }
            }
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            int maLap = Convert.ToInt32(hfMaLap.Value);
            if (maLap == 0) return;

            string tenLap = txtTenLap.Text.Trim();
            int maHang = Convert.ToInt32(ddlHang.SelectedValue);
            decimal giaBan = string.IsNullOrEmpty(txtGiaBan.Text) ? 0 : Convert.ToDecimal(txtGiaBan.Text);
            string cauHinh = txtCauHinh.Text;
            string moTa = txtMoTa.Text;

            // Xử lý ảnh đại diện
            string hinhAnh = hfOldImage.Value;
            if (fuHinhAnh.HasFile)
            {
                if (!string.IsNullOrEmpty(hinhAnh)) DeleteFile(hinhAnh);
                hinhAnh = UploadFile(fuHinhAnh);
            }

            // Cập nhật CSDL
            string sql = @"UPDATE Laptop SET 
                           TenLap=@Ten, 
                           CauHinh=@CauHinh, 
                           MaHang=@MaHang, 
                           GiaBan=@Gia, 
                           HinhAnh=@Hinh, 
                           MoTa=@MoTa 
                           WHERE MaLap=@MaLap";

            SqlParameter[] p = {
                new SqlParameter("@Ten", tenLap),
                new SqlParameter("@CauHinh", cauHinh),
                new SqlParameter("@MaHang", maHang),
                new SqlParameter("@Gia", giaBan),
                new SqlParameter("@Hinh", hinhAnh),
                new SqlParameter("@MoTa", moTa),
                new SqlParameter("@MaLap", maLap)
            };

            DBConnect.Execute(sql, p);

            // Thêm ảnh vào Album nếu có chọn
            if (fuAlbum.HasFiles)
            {
                foreach (HttpPostedFile uploadedFile in fuAlbum.PostedFiles)
                {
                    string albumFileName = DateTime.Now.Ticks.ToString() + "_" + uploadedFile.FileName;
                    string savePath = Server.MapPath("~/Images/Products/") + albumFileName;
                    uploadedFile.SaveAs(savePath);

                    string sqlAlbum = "INSERT INTO Albums (MaLap, DuongDan) VALUES (@MaLap, @DuongDan)";
                    SqlParameter[] pAlbum = {
                        new SqlParameter("@MaLap", maLap),
                        new SqlParameter("@DuongDan", albumFileName)
                    };
                    DBConnect.Execute(sqlAlbum, pAlbum);
                }
            }

            ScriptManager.RegisterStartupScript(this, GetType(), "alert", "alert('Cập nhật thành công!');", true);
            LoadDanhSachLaptop();
        }

        private string UploadFile(FileUpload fu)
        {
            if (fu.HasFile)
            {
                try
                {
                    string fileName = DateTime.Now.Ticks.ToString() + "_" + fu.FileName;
                    string filePath = Server.MapPath("~/Images/Products/") + fileName;
                    fu.SaveAs(filePath);
                    return fileName;
                }
                catch { }
            }
            return "";
        }

        private void DeleteFile(string fileName)
        {
            if (!string.IsNullOrEmpty(fileName))
            {
                try
                {
                    string filePath = Server.MapPath("~/Images/Products/") + fileName;
                    if (File.Exists(filePath)) File.Delete(filePath);
                }
                catch { }
            }
        }

        private void DeleteImagesInHtml(string htmlContent)
        {
            if (string.IsNullOrEmpty(htmlContent)) return;
            string pattern = "<img.+?src=[\"'](.+?)[\"'].*?>";
            foreach (Match match in Regex.Matches(htmlContent, pattern, RegexOptions.IgnoreCase))
            {
                string src = match.Groups[1].Value;
                if (src.Contains("/Images/Products/"))
                {
                    string fileName = Path.GetFileName(src);
                    DeleteFile(fileName);
                }
            }
        }
    }
}