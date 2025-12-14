using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Laptop.Admin
{
    public partial class QuanLyDonHang : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadDanhSachDonHang();
            }
        }

        private void LoadDanhSachDonHang()
        {
            string trangThai = ddlTrangThai.SelectedValue;
            string tuKhoa = txtSearch.Text.Trim();

            // Xây dựng câu truy vấn động
            string sql = @"
                SELECT d.*, t.HoTen
                FROM DonHang d LEFT JOIN TaiKhoan t ON d.MaTK = t.MaTK
                WHERE (@TrangThai = 'All' OR d.TrangThai = @TrangThai)
                AND (@TuKhoa = '' OR d.MaDH LIKE '%' + @TuKhoa + '%' OR t.HoTen LIKE N'%' + @TuKhoa + '%')
                ORDER BY d.NgayDat DESC";

            SqlParameter[] p = {
                new SqlParameter("@TrangThai", trangThai),
                new SqlParameter("@TuKhoa", tuKhoa)
            };

            DataTable dt = DBConnect.GetData(sql, p);

            if (dt != null && dt.Rows.Count > 0)
            {
                rptDonHang.DataSource = dt;
                rptDonHang.DataBind();
                lblThongBao.Visible = false;
            }
            else
            {
                rptDonHang.DataSource = null;
                rptDonHang.DataBind();
                lblThongBao.Visible = true;
            }
        }

        protected void btnLoc_Click(object sender, EventArgs e)
        {
            LoadDanhSachDonHang();
        }

        protected void rptDonHang_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            int maDH = Convert.ToInt32(e.CommandArgument);
            string cmd = e.CommandName;

            if (cmd == "View")
            {
                LoadInvoiceModal(maDH);
                ScriptManager.RegisterStartupScript(this, GetType(), "OpenModal", "openInvoiceModal();", true);
            }
            else if (cmd == "Approve") // DUYỆT ĐƠN
            {
                string sql = "UPDATE DonHang SET TrangThai = N'Đã giao' WHERE MaDH = @MaDH";
                SqlParameter[] p = { new SqlParameter("@MaDH", maDH) };
                DBConnect.Execute(sql, p);

                LoadDanhSachDonHang(); // Refresh
                ScriptManager.RegisterStartupScript(this, GetType(), "alert", "alert('Đã duyệt đơn hàng thành công!');", true);
            }
            else if (cmd == "Cancel") // HỦY ĐƠN
            {
                // Bước 1: Cộng lại kho thủ công (Chỉ khi hủy đơn chưa giao)
                DataTable dtCT = DBConnect.GetData("SELECT MaLap, SoLuong FROM ChiTietDonHang WHERE MaDH = " + maDH);
                foreach (DataRow dr in dtCT.Rows)
                {
                    string sqlKho = "UPDATE Laptop SET TonKho = TonKho + @Sl WHERE MaLap = @MaLap";
                    SqlParameter[] pKho = {
                        new SqlParameter("@Sl", dr["SoLuong"]),
                        new SqlParameter("@MaLap", dr["MaLap"])
                    };
                    DBConnect.Execute(sqlKho, pKho);
                }

                // Bước 2: Cập nhật trạng thái
                string sqlHuy = "UPDATE DonHang SET TrangThai = N'Đã hủy' WHERE MaDH = @MaDH";
                SqlParameter[] pHuy = { new SqlParameter("@MaDH", maDH) };
                DBConnect.Execute(sqlHuy, pHuy);

                LoadDanhSachDonHang(); // Refresh
                ScriptManager.RegisterStartupScript(this, GetType(), "alert", "alert('Đã hủy đơn hàng và hoàn lại kho!');", true);
            }
        }

        private void LoadInvoiceModal(int maDH)
        {
            string sqlDon = @"
                SELECT d.*, t.HoTen, t.SoDienThoai 
                FROM DonHang d LEFT JOIN TaiKhoan t ON d.MaTK = t.MaTK 
                WHERE MaDH = " + maDH;
            DataRow row = DBConnect.GetOneRow(sqlDon);

            if (row != null)
            {
                lblModalMaDon.Text = maDH.ToString();
                lblModalNgayDat.Text = Convert.ToDateTime(row["NgayDat"]).ToString("dd/MM/yyyy HH:mm");
                lblModalTrangThai.Text = row["TrangThai"].ToString();

                lblModalDiaChi.Text = row["DiaChiGiaoHang"].ToString();
                lblModalNguoiNhan.Text = row["HoTen"].ToString();
                lblModalSDT.Text = row["SoDienThoai"].ToString();
                lblModalTongTien.Text = Convert.ToDecimal(row["TongTien"]).ToString("N0") + "₫";
            }

            string sqlCT = @"
                SELECT c.*, l.TenLap 
                FROM ChiTietDonHang c JOIN Laptop l ON c.MaLap = l.MaLap 
                WHERE c.MaDH = " + maDH;

            DataTable dtCT = DBConnect.GetData(sqlCT);
            rptChiTietModal.DataSource = dtCT;
            rptChiTietModal.DataBind();
        }

        public string GetStatusClass(object trangThai)
        {
            string s = trangThai.ToString();
            if (s == "Chờ duyệt") return "st-cho-duyet";
            if (s == "Đã giao") return "st-da-giao";
            if (s == "Đã hủy") return "st-da-huy";
            return "";
        }
    }
}