using System;
using System.Collections.Generic;
using System.Linq;
using System.Web.UI;
using System.Web.UI.WebControls;
using Laptop.Models;

namespace Laptop
{
    public partial class GioHang : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadGioHang();
            }
        }

        private void LoadGioHang()
        {
            List<CartItem> cart = Session["GioHang"] as List<CartItem>;
            if (cart != null && cart.Count > 0)
            {
                pnlCoHang.Visible = true;
                pnlTrong.Visible = false;

                // Chỉ bind dữ liệu lần đầu hoặc khi cần thiết, không bind lại khi postback từ Textbox 
                // (Tuy nhiên với logic TextChanged bên dưới, ta cần bind lại sau khi tính toán xong)
                rptGioHang.DataSource = cart;
                rptGioHang.DataBind();

                TinhTongTien(cart);
            }
            else
            {
                pnlCoHang.Visible = false;
                pnlTrong.Visible = true;
            }
        }

        private void TinhTongTien(List<CartItem> cart)
        {
            decimal tong = cart.Sum(x => x.ThanhTien);
            lblTamTinh.Text = tong.ToString("N0") + "₫";
            lblTongTien.Text = tong.ToString("N0") + "₫";
        }

        // --- XỬ LÝ THAY ĐỔI SỐ LƯỢNG TỰ ĐỘNG ---
        protected void txtSoLuong_TextChanged(object sender, EventArgs e)
        {
            TextBox txtQty = (TextBox)sender;
            RepeaterItem item = (RepeaterItem)txtQty.NamingContainer;

            // Tìm HiddenField chứa Mã Laptop trong cùng dòng
            HiddenField hfMaLap = (HiddenField)item.FindControl("hfMaLap");

            int maLap = int.Parse(hfMaLap.Value);
            int slMoi;

            List<CartItem> cart = Session["GioHang"] as List<CartItem>;

            if (int.TryParse(txtQty.Text, out slMoi))
            {
                var sp = cart.FirstOrDefault(x => x.MaLap == maLap);
                if (sp != null)
                {
                    if (slMoi <= 0)
                    {
                        // Nếu nhập <= 0 thì tự động xóa hoặc reset về 1 (Ở đây ta chọn reset về 1 để an toàn)
                        sp.SoLuong = 1;
                    }
                    else
                    {
                        // Kiểm tra tồn kho thực tế nếu cần (Code nâng cao)
                        // ...
                        sp.SoLuong = slMoi;
                    }
                }
            }

            // Lưu lại session
            Session["GioHang"] = cart;

            // Load lại trang để cập nhật Thành tiền và Tổng tiền
            // Không dùng Response.Redirect để tránh mất focus, chỉ cần Load lại dữ liệu
            LoadGioHang();
        }

        // Xử lý Xóa (Giữ nguyên)
        protected void rptGioHang_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName == "Xoa")
            {
                int maLap = Convert.ToInt32(e.CommandArgument);
                List<CartItem> cart = Session["GioHang"] as List<CartItem>;

                var item = cart.FirstOrDefault(x => x.MaLap == maLap);
                if (item != null) cart.Remove(item);

                Session["GioHang"] = cart;
                LoadGioHang();

                // Cập nhật lại giỏ hàng trên Header bằng cách reload
                Response.Redirect(Request.RawUrl);
            }
        }

        protected void btnThanhToan_Click(object sender, EventArgs e)
        {
            Response.Redirect("DatHang.aspx");
        }
    }
}