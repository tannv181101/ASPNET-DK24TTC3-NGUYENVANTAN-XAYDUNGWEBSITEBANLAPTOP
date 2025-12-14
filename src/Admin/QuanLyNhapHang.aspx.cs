using System;
using System.Data;
using System.Data.SqlClient;
using System.IO;
using System.Web; // Để dùng HttpPostedFile
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Laptop.Admin
{
    public partial class QuanLyNhapHang : System.Web.UI.Page
    {
        // ... (Giữ nguyên các Property DtChiTiet và Page_Load như cũ) ...

        // Property DtChiTiet
        private DataTable DtChiTiet
        {
            get
            {
                if (ViewState["ChiTietNhap"] == null)
                {
                    DataTable dt = new DataTable();
                    dt.Columns.Add("MaLap", typeof(int));
                    dt.Columns.Add("TenLap", typeof(string));
                    dt.Columns.Add("GiaNhap", typeof(decimal));
                    dt.Columns.Add("SoLuong", typeof(int));
                    dt.Columns.Add("ThanhTien", typeof(decimal), "GiaNhap * SoLuong");
                    ViewState["ChiTietNhap"] = dt;
                }
                return (DataTable)ViewState["ChiTietNhap"];
            }
            set { ViewState["ChiTietNhap"] = value; }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                txtNgayNhap.Text = DateTime.Now.ToString("yyyy-MM-dd");
                LoadHang();
                LoadNCC();
                LoadLaptop();
                LoadLichSuNhap();
                BindGridTam();
            }
            if (Request.QueryString["id"] != null)
            {
                string selectedId = Request.QueryString["id"];

                // Kiểm tra ID có tồn tại trong Dropdown không rồi chọn
                if (ddlLaptop.Items.FindByValue(selectedId) != null)
                {
                    ddlLaptop.SelectedValue = selectedId;

                    // Focus vào ô số lượng để nhập nhanh
                    txtSoLuong.Focus();
                }
            }
        }

        // ... (Giữ nguyên các hàm LoadData: LoadHang, LoadNCC, LoadLaptop, LoadLichSuNhap) ...
        private void LoadHang()
        {
            DataTable dt = DBConnect.GetData("SELECT * FROM HangSanXuat");
            ddlHangMoi.DataSource = dt;
            ddlHangMoi.DataTextField = "TenHang";
            ddlHangMoi.DataValueField = "MaHang";
            ddlHangMoi.DataBind();
        }

        private void LoadNCC()
        {
            DataTable dt = DBConnect.GetData("SELECT * FROM NhaCungCap");
            ddlNCC.DataSource = dt;
            ddlNCC.DataTextField = "TenNCC";
            ddlNCC.DataValueField = "MaNCC";
            ddlNCC.DataBind();
        }

        private void LoadLaptop()
        {
            string sql = "SELECT MaLap, TenLap + N' (Tồn: ' + CAST(TonKho AS NVARCHAR) + N')' as TenHienThi FROM Laptop ORDER BY TenLap";
            DataTable dt = DBConnect.GetData(sql);
            ddlLaptop.DataSource = dt;
            ddlLaptop.DataTextField = "TenHienThi";
            ddlLaptop.DataValueField = "MaLap";
            ddlLaptop.DataBind();
            ddlLaptop.Items.Insert(0, new ListItem("-- Chọn Laptop cần nhập --", "0"));
        }

        private void LoadLichSuNhap()
        {
            string sql = @"SELECT pn.*, ncc.TenNCC FROM PhieuNhap pn JOIN NhaCungCap ncc ON pn.MaNCC = ncc.MaNCC ORDER BY pn.NgayNhap DESC";
            gvLichSuNhap.DataSource = DBConnect.GetData(sql);
            gvLichSuNhap.DataBind();
        }

        protected void btnRefreshDropdown_Click(object sender, EventArgs e)
        {
            LoadLaptop();
            object maxID = DBConnect.ExecuteScalar("SELECT MAX(MaLap) FROM Laptop");
            if (maxID != null && maxID != DBNull.Value)
            {
                string newID = maxID.ToString();
                if (ddlLaptop.Items.FindByValue(newID) != null) ddlLaptop.SelectedValue = newID;
            }
        }

        // ... (Giữ nguyên btnThemSP_Click, BindGridTam, gvChiTietTam_RowCommand) ...
        protected void btnThemSP_Click(object sender, EventArgs e)
        {
            litError.Text = "";
            int maLap = int.Parse(ddlLaptop.SelectedValue);
            if (maLap == 0) { litError.Text = "Vui lòng chọn sản phẩm!"; return; }

            decimal giaNhap;
            int soLuong;

            if (!decimal.TryParse(txtGiaNhap.Text, out giaNhap) || giaNhap <= 0) { litError.Text = "Giá nhập không hợp lệ!"; return; }
            if (!int.TryParse(txtSoLuong.Text, out soLuong) || soLuong <= 0) { litError.Text = "Số lượng phải > 0!"; return; }

            string tenFull = ddlLaptop.SelectedItem.Text;
            string tenLap = tenFull.Contains(" (") ? tenFull.Substring(0, tenFull.LastIndexOf(" (")) : tenFull;

            DataTable dt = DtChiTiet;
            DataRow[] rows = dt.Select("MaLap=" + maLap);
            if (rows.Length > 0)
            {
                rows[0]["SoLuong"] = (int)rows[0]["SoLuong"] + soLuong;
                rows[0]["GiaNhap"] = giaNhap;
            }
            else
            {
                dt.Rows.Add(maLap, tenLap, giaNhap, soLuong);
            }

            DtChiTiet = dt;
            BindGridTam();
            txtSoLuong.Text = "1";
            txtGiaNhap.Text = "";
            ddlLaptop.SelectedIndex = 0;
        }

        private void BindGridTam()
        {
            DataTable dt = DtChiTiet;
            gvChiTietTam.DataSource = dt;
            gvChiTietTam.DataBind();
            decimal tong = 0;
            foreach (DataRow dr in dt.Rows) tong += Convert.ToDecimal(dr["ThanhTien"]);
            lblTongTienPhieu.Text = tong.ToString("N0");
            divEmpty.Visible = (dt.Rows.Count == 0);
            btnLuuPhieu.Visible = (dt.Rows.Count > 0);
        }

        protected void gvChiTietTam_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName == "Xoa")
            {
                int index = Convert.ToInt32(e.CommandArgument);
                DataTable dt = DtChiTiet;
                dt.Rows.RemoveAt(index);
                DtChiTiet = dt;
                BindGridTam();
            }
        }


        // --- B. THÊM SẢN PHẨM MỚI (CÓ ALBUM + CKEDITOR) ---
        protected void btnLuuSPMoi_Click(object sender, EventArgs e)
        {
            if (Page.IsValid)
            {
                string tenLap = txtTenLapMoi.Text.Trim();
                int maHang = int.Parse(ddlHangMoi.SelectedValue);
                decimal giaBan = string.IsNullOrEmpty(txtGiaBanMoi.Text) ? 0 : Convert.ToDecimal(txtGiaBanMoi.Text);
                string cauHinh = txtCauHinhMoi.Text;
                string moTa = txtMoTaMoi.Text;
                string hinhAnh = "";

                if (fuHinhAnhMoi.HasFile)
                {
                    hinhAnh = UploadFile(fuHinhAnhMoi); // Upload hình đại diện
                }

                try
                {
                    // 1. Insert Laptop
                    string sqlInsert = @"INSERT INTO Laptop (TenLap, MaHang, GiaBan, TonKho, HinhAnh, CauHinh, MoTa, NgayTao) 
                                         VALUES (@Ten, @MaHang, @GiaBan, 0, @HinhAnh, @CauHinh, @MoTa, GETDATE()); 
                                         SELECT SCOPE_IDENTITY();";

                    SqlParameter[] p = {
                        new SqlParameter("@Ten", tenLap),
                        new SqlParameter("@MaHang", maHang),
                        new SqlParameter("@GiaBan", giaBan),
                        new SqlParameter("@HinhAnh", hinhAnh),
                        new SqlParameter("@CauHinh", cauHinh),
                        new SqlParameter("@MoTa", moTa)
                    };

                    object resID = DBConnect.ExecuteScalar(sqlInsert, p);
                    int maLapMoi = Convert.ToInt32(resID);

                    // 2. Xử lý ALBUM ẢNH (New)
                    if (fuAlbum.HasFiles)
                    {
                        foreach (HttpPostedFile uploadedFile in fuAlbum.PostedFiles)
                        {
                            // Lưu file vật lý
                            string albumFileName = DateTime.Now.Ticks.ToString() + "_" + uploadedFile.FileName;
                            string savePath = Server.MapPath("~/Images/Products/") + albumFileName;
                            uploadedFile.SaveAs(savePath);

                            // Lưu vào CSDL
                            string sqlAlbum = "INSERT INTO Albums (MaLap, DuongDan) VALUES (@MaLap, @DuongDan)";
                            SqlParameter[] pAlbum = {
                                new SqlParameter("@MaLap", maLapMoi),
                                new SqlParameter("@DuongDan", albumFileName)
                            };
                            DBConnect.Execute(sqlAlbum, pAlbum);
                        }
                    }

                    // 3. Kết thúc
                    lblThongBaoThemSP.Text = "Thêm sản phẩm thành công!";
                    lblThongBaoThemSP.CssClass = "text-success";

                    ScriptManager.RegisterStartupScript(this, GetType(), "Refresh", "refreshAndCloseModal();", true);

                    // Reset Form
                    txtTenLapMoi.Text = "";
                    txtGiaBanMoi.Text = "0";
                    txtCauHinhMoi.Text = "";
                    txtMoTaMoi.Text = "";
                    ddlHangMoi.SelectedIndex = 0;
                }
                catch (Exception ex)
                {
                    lblThongBaoThemSP.Text = "Lỗi: " + ex.Message;
                    lblThongBaoThemSP.CssClass = "text-danger";
                    ScriptManager.RegisterStartupScript(this, GetType(), "KeepOpen", "openProductModal();", true);
                }
            }
        }

        // --- C. LƯU PHIẾU NHẬP (GIỮ NGUYÊN TRIGGER) ---
        protected void btnLuuPhieu_Click(object sender, EventArgs e)
        {
            DataTable dt = DtChiTiet;
            if (dt.Rows.Count == 0) return;

            int maNCC = int.Parse(ddlNCC.SelectedValue);
            string ngayNhap = txtNgayNhap.Text;
            decimal tongTien = decimal.Parse(lblTongTienPhieu.Text.Replace(",", "").Replace(".", ""));

            try
            {
                string sqlPN = @"INSERT INTO PhieuNhap (MaNCC, NgayNhap, TongTien) VALUES (@MaNCC, @NgayNhap, @TongTien); 
                                 SELECT SCOPE_IDENTITY();";
                SqlParameter[] pPN = {
                    new SqlParameter("@MaNCC", maNCC),
                    new SqlParameter("@NgayNhap", ngayNhap),
                    new SqlParameter("@TongTien", tongTien)
                };

                object resID = DBConnect.ExecuteScalar(sqlPN, pPN);
                int maPN = Convert.ToInt32(resID);

                foreach (DataRow dr in dt.Rows)
                {
                    string sqlCT = "INSERT INTO ChiTietPhieuNhap (MaPN, MaLap, SoLuong, GiaNhap) VALUES (@MaPN, @MaLap, @SL, @Gia)";
                    SqlParameter[] pCT = {
                        new SqlParameter("@MaPN", maPN),
                        new SqlParameter("@MaLap", (int)dr["MaLap"]),
                        new SqlParameter("@SL", (int)dr["SoLuong"]),
                        new SqlParameter("@Gia", (decimal)dr["GiaNhap"])
                    };
                    DBConnect.Execute(sqlCT, pCT);
                }

                ScriptManager.RegisterStartupScript(this, GetType(), "alert", "alert('Nhập kho hoàn tất!');", true);
                ViewState["ChiTietNhap"] = null;
                BindGridTam();
                LoadLichSuNhap();
                LoadLaptop();
            }
            catch (Exception ex)
            {
                ScriptManager.RegisterStartupScript(this, GetType(), "alert", $"alert('Lỗi: {ex.Message}');", true);
            }
        }

        protected void gvLichSuNhap_PageIndexChanging(object sender, GridViewPageEventArgs e)
        {
            gvLichSuNhap.PageIndex = e.NewPageIndex;
            LoadLichSuNhap();
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
                catch { return ""; }
            }
            return "";
        }
    }
}