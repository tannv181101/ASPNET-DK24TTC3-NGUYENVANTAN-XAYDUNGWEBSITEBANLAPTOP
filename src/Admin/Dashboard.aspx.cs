using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.HtmlControls;
using System.Web.UI.WebControls;

namespace Laptop.Admin
{
    public partial class Dashboard : System.Web.UI.Page
    {
        protected HtmlGenericControl divCanhBao;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadKPIs();
                LoadRecentOrders();
            }
        }

        private void LoadKPIs()
        {
            // Doanh thu (Đã giao)
            object rev = DBConnect.ExecuteScalar("SELECT SUM(TongTien) FROM DonHang WHERE TrangThai = N'Đã giao'");
            lblDoanhThu.Text = (rev != DBNull.Value && rev != null) ? Convert.ToDecimal(rev).ToString("N0") : "0";

            // Tổng tiền nhập
            object imp = DBConnect.ExecuteScalar("SELECT SUM(TongTien) FROM PhieuNhap");
            lblTienNhap.Text = (imp != DBNull.Value && imp != null) ? Convert.ToDecimal(imp).ToString("N0") : "0";

            // Đơn chờ duyệt
            object pending = DBConnect.ExecuteScalar("SELECT COUNT(*) FROM DonHang WHERE TrangThai = N'Chờ duyệt'");
            lblDonCho.Text = (pending != DBNull.Value) ? pending.ToString() : "0";

            // Cảnh báo tồn kho
            object lowStock = DBConnect.ExecuteScalar("SELECT COUNT(*) FROM Laptop WHERE TonKho <= 5");
            int countLow = (lowStock != DBNull.Value) ? Convert.ToInt32(lowStock) : 0;
            lblTonKho.Text = countLow.ToString();

            if (countLow > 0)
            {
                divCanhBao.Attributes["class"] += " kpi-danger-alert";
                lblTonKho.ForeColor = System.Drawing.Color.Red;
            }
        }

        private void LoadRecentOrders()
        {
            // Load đơn hàng chờ duyệt
            string sql = @"
                SELECT TOP 10 d.MaDH, d.NgayDat, d.TongTien, d.TrangThai, t.HoTen 
                FROM DonHang d JOIN TaiKhoan t ON d.MaTK = t.MaTK 
                WHERE d.TrangThai = N'Chờ duyệt' 
                ORDER BY d.NgayDat DESC";

            DataTable dt = DBConnect.GetData(sql);
            if (dt != null && dt.Rows.Count > 0)
            {
                rptDonHang.DataSource = dt;
                rptDonHang.DataBind();
                pnlDonHang.Visible = true;
                lblNoDataOrder.Visible = false;
            }
            else
            {
                pnlDonHang.Visible = false;
                lblNoDataOrder.Visible = true;
            }
        }

        // --- XỬ LÝ CLICK KPI TỒN KHO ---
        protected void btnCanhBaoTonKho_Click(object sender, EventArgs e)
        {
            // Load danh sách sản phẩm tồn kho <= 5
            string sql = "SELECT * FROM Laptop WHERE TonKho <= 5 ORDER BY TonKho ASC";
            DataTable dt = DBConnect.GetData(sql);

            rptLowStock.DataSource = dt;
            rptLowStock.DataBind();

            // Mở Modal
            ScriptManager.RegisterStartupScript(this, GetType(), "OpenLowStock", "openLowStockModal();", true);
        }

        // --- CÁC HÀM XỬ LÝ ĐƠN HÀNG (GIỮ NGUYÊN) ---
        protected void rptDonHang_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            int maDH = Convert.ToInt32(e.CommandArgument);
            string cmd = e.CommandName;

            if (cmd == "View")
            {
                LoadInvoiceModal(maDH);
                ScriptManager.RegisterStartupScript(this, GetType(), "OpenModal", "openInvoiceModal();", true);
            }
            else if (cmd == "Approve")
            {
                string sql = "UPDATE DonHang SET TrangThai = N'Đã giao' WHERE MaDH = @MaDH";
                SqlParameter[] p = { new SqlParameter("@MaDH", maDH) };
                DBConnect.Execute(sql, p);

                LoadKPIs(); LoadRecentOrders();
                ScriptManager.RegisterStartupScript(this, GetType(), "alert", "alert('Đã duyệt đơn hàng!');", true);
            }
            else if (cmd == "Cancel")
            {
                // Cộng lại kho thủ công (nếu chưa có trigger update status)
                DataTable dtCT = DBConnect.GetData("SELECT MaLap, SoLuong FROM ChiTietDonHang WHERE MaDH = " + maDH);
                foreach (DataRow dr in dtCT.Rows)
                {
                    string sqlKho = "UPDATE Laptop SET TonKho = TonKho + @Sl WHERE MaLap = @MaLap";
                    SqlParameter[] pKho = { new SqlParameter("@Sl", dr["SoLuong"]), new SqlParameter("@MaLap", dr["MaLap"]) };
                    DBConnect.Execute(sqlKho, pKho);
                }

                string sqlHuy = "UPDATE DonHang SET TrangThai = N'Đã hủy' WHERE MaDH = @MaDH";
                SqlParameter[] pHuy = { new SqlParameter("@MaDH", maDH) };
                DBConnect.Execute(sqlHuy, pHuy);

                LoadKPIs(); LoadRecentOrders();
                ScriptManager.RegisterStartupScript(this, GetType(), "alert", "alert('Đã hủy đơn hàng!');", true);
            }
        }

        private void LoadInvoiceModal(int maDH)
        {
            string sqlInfo = @"SELECT d.*, t.HoTen, t.SoDienThoai FROM DonHang d JOIN TaiKhoan t ON d.MaTK = t.MaTK WHERE MaDH = " + maDH;
            DataRow row = DBConnect.GetOneRow(sqlInfo);

            if (row != null)
            {
                lblModalMaDon.Text = maDH.ToString();
                lblModalNgayDat.Text = Convert.ToDateTime(row["NgayDat"]).ToString("dd/MM/yyyy HH:mm");
                lblModalTongTien.Text = Convert.ToDecimal(row["TongTien"]).ToString("N0") + " đ";
                lblModalNguoiNhan.Text = row["HoTen"].ToString();
                lblModalSDT.Text = row["SoDienThoai"].ToString();
                lblModalDiaChi.Text = row["DiaChiGiaoHang"].ToString();
            }

            string sqlCT = @"SELECT ct.*, l.TenLap FROM ChiTietDonHang ct JOIN Laptop l ON ct.MaLap = l.MaLap WHERE MaDH = " + maDH;
            DataTable dtCT = DBConnect.GetData(sqlCT);
            rptChiTietModal.DataSource = dtCT;
            rptChiTietModal.DataBind();
        }
    }
}