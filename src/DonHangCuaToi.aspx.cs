using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Laptop
{
    public partial class DonHangCuaToi : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                if (Session["MaTK"] == null)
                {
                    pnlChuaDangNhap.Visible = true;
                    pnlDaDangNhap.Visible = false;
                }
                else
                {
                    pnlChuaDangNhap.Visible = false;
                    pnlDaDangNhap.Visible = true;
                    LoadDanhSachDonHang();
                }
            }
        }

        private void LoadDanhSachDonHang()
        {
            int maTK = Convert.ToInt32(Session["MaTK"]);
            string sql = "SELECT * FROM DonHang WHERE MaTK = @MaTK ORDER BY MaDH DESC";
            SqlParameter[] p = { new SqlParameter("@MaTK", maTK) };

            DataTable dt = DBConnect.GetData(sql, p);
            if (dt != null && dt.Rows.Count > 0)
            {
                rptDonHang.DataSource = dt;
                rptDonHang.DataBind();
            }
            else
            {
                lblThongBao.Text = "<div class='alert alert-warning text-center'>Bạn chưa có đơn hàng nào. <a href='Default.aspx'>Mua sắm ngay</a></div>";
            }
        }

        protected void rptDonHang_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            int maDH = Convert.ToInt32(e.CommandArgument);

            if (e.CommandName == "HuyDon")
            {
                DataRow row = DBConnect.GetOneRow("SELECT TrangThai FROM DonHang WHERE MaDH=" + maDH);
                if (row != null && row["TrangThai"].ToString() == "Chờ duyệt")
                {
                    // Trigger trg_HuyChiTietDon chỉ chạy khi DELETE
                    // Vì chúng ta UPDATE trạng thái nên phải CỘNG KHO THỦ CÔNG
                    DataTable dtCT = DBConnect.GetData("SELECT MaLap, SoLuong FROM ChiTietDonHang WHERE MaDH=" + maDH);
                    foreach (DataRow dr in dtCT.Rows)
                    {
                        DBConnect.Execute($"UPDATE Laptop SET TonKho = TonKho + {dr["SoLuong"]} WHERE MaLap = {dr["MaLap"]}");
                    }

                    DBConnect.Execute("UPDATE DonHang SET TrangThai = N'Đã hủy' WHERE MaDH=" + maDH);
                    LoadDanhSachDonHang();
                    ScriptManager.RegisterStartupScript(this, GetType(), "alert", "alert('Đã hủy đơn hàng thành công!');", true);
                }
                else
                {
                    ScriptManager.RegisterStartupScript(this, GetType(), "alert", "alert('Không thể hủy đơn hàng này!');", true);
                }
            }
            else if (e.CommandName == "XemDon")
            {
                LoadChiTietHoaDon(maDH);

                // GỌI HÀM JS CHÚNG TA VỪA TẠO
                ScriptManager.RegisterStartupScript(this, this.GetType(), "Pop", "openInvoiceModal();", true);
            }
        }

        private void LoadChiTietHoaDon(int maDH)
        {
            string sqlDon = @"SELECT d.*, t.HoTen, t.SoDienThoai 
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
                lblModalTongTien.Text = Convert.ToDecimal(row["TongTien"]).ToString("N0") + "₫";
            }

            string sqlCT = @"SELECT c.*, l.TenLap 
                             FROM ChiTietDonHang c 
                             JOIN Laptop l ON c.MaLap = l.MaLap 
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