using System;
using System.Data;
using System.Collections.Generic;
using System.Linq;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Laptop
{
    public partial class Default : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadMenuHang();
                LoadSanPham();
            }
        }

        // 1. Load Menu Hãng
        private void LoadMenuHang()
        {
            DataTable dt = DBConnect.GetData("SELECT * FROM HangSanXuat ORDER BY TenHang");
            rptMenuHang.DataSource = dt;
            rptMenuHang.DataBind();
        }

        // 2. Load Danh sách Sản phẩm
        private void LoadSanPham()
        {
            string sql = "SELECT l.*, h.TenHang FROM Laptop l JOIN HangSanXuat h ON l.MaHang = h.MaHang WHERE 1=1";

            // Lọc theo Hãng
            if (Request.QueryString["hang"] != null)
            {
                int maHang;
                if (int.TryParse(Request.QueryString["hang"], out maHang))
                {
                    sql += " AND l.MaHang = " + maHang;

                    // Lấy tên hãng để hiển thị tiêu đề
                    DataTable dtHang = DBConnect.GetData("SELECT TenHang FROM HangSanXuat WHERE MaHang=" + maHang);
                    if (dtHang.Rows.Count > 0) lblTieuDe.Text = "Laptop " + dtHang.Rows[0]["TenHang"].ToString();
                }
            }

            // Tìm kiếm
            if (Request.QueryString["k"] != null)
            {
                string k = Request.QueryString["k"].ToString().Trim().Replace("'", "");
                sql += " AND (l.TenLap LIKE N'%" + k + "%' OR l.CauHinh LIKE N'%" + k + "%')";
                lblTieuDe.Text = "Kết quả tìm kiếm: " + k;
            }

            // Sắp xếp: Mới nhất lên đầu
            sql += " ORDER BY l.NgayTao DESC";

            DataTable dt = DBConnect.GetData(sql);

            if (dt != null && dt.Rows.Count > 0)
            {
                rptSanPham.DataSource = dt;
                rptSanPham.DataBind();
                lblSoLuong.Text = dt.Rows.Count.ToString();
                //pnlNoData.Visible = false;
            }
            else
            {
                //pnlNoData.Visible = true;
                lblSoLuong.Text = "0";
            }
        }

        // 3. Xử lý Mua hàng
        protected void btnMua_Click(object sender, EventArgs e)
        {
            LinkButton btn = (LinkButton)sender;
            int maLap = Convert.ToInt32(btn.CommandArgument);

            DataRow row = DBConnect.GetOneRow("SELECT * FROM Laptop WHERE MaLap=" + maLap);
            if (row != null)
            {
                int tonKho = Convert.ToInt32(row["TonKho"]);
                if (tonKho <= 0)
                {
                    Response.Write("<script>alert('Sản phẩm này vừa hết hàng!'); window.location.href='Default.aspx';</script>");
                    return;
                }

                // Quản lý Session Giỏ hàng
                List<CartItem> cart = Session["GioHang"] as List<CartItem> ?? new List<CartItem>();

                var item = cart.FirstOrDefault(x => x.MaLap == maLap);
                if (item != null)
                {
                    // Nếu số lượng trong giỏ < tồn kho thì mới cho tăng
                    if (item.SoLuong < tonKho) item.SoLuong++;
                    else Response.Write("<script>alert('Bạn đã chọn tối đa số lượng có sẵn!');</script>");
                }
                else
                {
                    cart.Add(new CartItem()
                    {
                        MaLap = maLap,
                        TenLap = row["TenLap"].ToString(),
                        HinhAnh = row["HinhAnh"].ToString(),
                        GiaBan = Convert.ToDecimal(row["GiaBan"]),
                        SoLuong = 1
                    });
                }

                Session["GioHang"] = cart;
                Response.Redirect(Request.RawUrl);
            }
        }

        protected string CheckActive(object maHang)
        {
            return (Request.QueryString["hang"] != null && Request.QueryString["hang"] == maHang.ToString()) ? "active" : "";
        }
    }

    // Class CartItem (Nên để trong App_Code/CartItem.cs, nhưng để đây cho tiện copy)
    [Serializable]
    public class CartItem
    {
        public int MaLap { get; set; }
        public string TenLap { get; set; }
        public string HinhAnh { get; set; }
        public decimal GiaBan { get; set; }
        public int SoLuong { get; set; }
        public decimal ThanhTien { get { return GiaBan * SoLuong; } }
    }
}