using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Web.UI;
using System.Web.UI.WebControls;
using Laptop.Models; // Sử dụng Model CartItem đã tạo

namespace Laptop
{
    public partial class ChiTietSanPham : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                if (Request.QueryString["id"] == null)
                {
                    Response.Redirect("Default.aspx");
                }
                else
                {
                    int id;
                    if (int.TryParse(Request.QueryString["id"], out id))
                    {
                        LoadChiTiet(id);
                    }
                    else
                    {
                        Response.Redirect("Default.aspx");
                    }
                }
            }
        }

        private void LoadChiTiet(int id)
        {
            string sql = "SELECT l.*, h.TenHang FROM Laptop l JOIN HangSanXuat h ON l.MaHang = h.MaHang WHERE MaLap = " + id;
            DataRow row = DBConnect.GetOneRow(sql);

            if (row != null)
            {
                // Thông tin cơ bản
                lblTenLap.Text = row["TenLap"].ToString();
                lblTenLapBreadcrumb.Text = row["TenLap"].ToString();
                lblMaLap.Text = row["MaLap"].ToString();
                lblThuongHieu.Text = row["TenHang"].ToString();
                lblHang.Text = row["TenHang"].ToString();
                lblGiaBan.Text = Convert.ToDecimal(row["GiaBan"]).ToString("N0") + " đ";

                // Album ảnh
                DataTable dtAlbum = DBConnect.GetData("SELECT * FROM Albums WHERE MaLap = " + id + " ORDER BY SapXep ASC");
                if (dtAlbum != null && dtAlbum.Rows.Count > 0)
                {
                    rptAlbum.DataSource = dtAlbum; rptAlbum.DataBind();
                    rptThumb.DataSource = dtAlbum; rptThumb.DataBind();
                    pnlControls.Visible = (dtAlbum.Rows.Count > 1);
                }
                else
                {
                    DataTable dtFake = new DataTable(); dtFake.Columns.Add("DuongDan");
                    dtFake.Rows.Add(row["HinhAnh"]);
                    rptAlbum.DataSource = dtFake; rptAlbum.DataBind();
                    rptThumb.Visible = false; pnlControls.Visible = false;
                }

                // Cấu hình
                string cauHinhFull = row["CauHinh"].ToString();
                string[] specs = cauHinhFull.Split(',');
                if (specs.Length > 0) lblCPU.Text = specs[0].Trim();
                if (specs.Length > 1) lblRamSsd.Text = specs[1].Trim();
                if (specs.Length > 2) lblManHinh.Text = specs[2].Trim();
                else lblManHinh.Text = cauHinhFull;

                // Mô tả
                string moTa = row["MoTa"].ToString();
                litMoTa.Text = string.IsNullOrEmpty(moTa) ? "<p class='text-muted fst-italic'>Đang cập nhật nội dung...</p>" : moTa;

                // Tồn kho
                int tonKho = Convert.ToInt32(row["TonKho"]);
                if (tonKho > 0)
                {
                    lblTinhTrang.Text = "Còn hàng"; lblTinhTrang.CssClass = "badge bg-success";
                    btnMuaNgay.Visible = true; lblHetHang.Visible = false;
                }
                else
                {
                    lblTinhTrang.Text = "Hết hàng"; lblTinhTrang.CssClass = "badge bg-danger";
                    btnMuaNgay.Visible = false; lblHetHang.Visible = true;
                }

                // Load Liên quan
                LoadLienQuan(Convert.ToInt32(row["MaHang"]), id);
            }
            else
            {
                Response.Redirect("Default.aspx");
            }
        }

        private void LoadLienQuan(int maHang, int currentId)
        {
            // Lấy 4 sản phẩm cùng hãng, khác SP hiện tại
            string sql = $"SELECT TOP 4 * FROM Laptop WHERE MaHang={maHang} AND MaLap!={currentId} ORDER BY NEWID()";
            rptLienQuan.DataSource = DBConnect.GetData(sql);
            rptLienQuan.DataBind();
        }

        // Xử lý nút "MUA NGAY" to đùng ở chi tiết
        protected void btnMuaNgay_Click(object sender, EventArgs e)
        {
            if (Request.QueryString["id"] != null)
            {
                AddToCart(int.Parse(Request.QueryString["id"]));
                Response.Redirect("GioHang.aspx");
            }
        }

        // Xử lý nút "MUA NGAY" nhỏ ở danh sách liên quan (MỚI THÊM)
        protected void btnMuaLienQuan_Click(object sender, EventArgs e)
        {
            LinkButton btn = (LinkButton)sender;
            int maLap = Convert.ToInt32(btn.CommandArgument);
            AddToCart(maLap);

            // Reload lại trang để cập nhật số lượng trên Header
            Response.Redirect(Request.RawUrl);
        }

        // Hàm chung thêm vào giỏ
        private void AddToCart(int id)
        {
            DataRow row = DBConnect.GetOneRow("SELECT * FROM Laptop WHERE MaLap=" + id);
            if (row != null)
            {
                int tonKho = Convert.ToInt32(row["TonKho"]);
                if (tonKho <= 0) return;

                List<CartItem> cart = Session["GioHang"] as List<CartItem> ?? new List<CartItem>();
                var item = cart.FirstOrDefault(x => x.MaLap == id);

                if (item != null)
                {
                    if (item.SoLuong < tonKho) item.SoLuong++;
                }
                else
                {
                    cart.Add(new CartItem()
                    {
                        MaLap = id,
                        TenLap = row["TenLap"].ToString(),
                        HinhAnh = row["HinhAnh"].ToString(),
                        GiaBan = Convert.ToDecimal(row["GiaBan"]),
                        SoLuong = 1
                    });
                }
                Session["GioHang"] = cart;
            }
        }
    }
}