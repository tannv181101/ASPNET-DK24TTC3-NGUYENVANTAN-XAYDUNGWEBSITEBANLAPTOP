using System;
using System.Collections.Generic;
using System.Data;
using System.Linq; // Dùng cho hàm Sum()
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Laptop
{
    public partial class SiteMaster : MasterPage
    {
        // Trong file Site.master.cs

        
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadMenu();
                CheckLoginStatus();
            }
        }

        // 1. Load Menu Hãng lên Navbar
        private void LoadMenu()
        {
            DataTable dt = DBConnect.GetData("SELECT * FROM HangSanXuat");
            rptMenuHang.DataSource = dt;
            rptMenuHang.DataBind();
        }

        // 2. Kiểm tra đăng nhập
        private void CheckLoginStatus()
        {
            if (Session["HoTen"] != null && Session["Quyen"] != null)
            {
                // Đã đăng nhập
                pnlGuest.Visible = false;
                pnlUser.Visible = true;
                lblHoTen.Text = Session["HoTen"].ToString();

                string quyen = Session["Quyen"].ToString();

                // Phân quyền menu Admin/User
                pnlAdminMenu.Visible = (quyen == "Admin");
                pnlCustomerMenu.Visible = (quyen != "Admin");
            }
            else
            {
                // Chưa đăng nhập
                pnlGuest.Visible = true;
                pnlUser.Visible = false;
            }
        }

        // 3. Xử lý Đăng xuất
        protected void btnLogout_Click(object sender, EventArgs e)
        {
            Session.Abandon();
            Response.Redirect("~/Default.aspx");
        }

        // 4. Xử lý Tìm kiếm
        protected void btnTimKiem_Click(object sender, EventArgs e)
        {
            if (!string.IsNullOrEmpty(txtTimKiem.Text))
            {
                Response.Redirect("~/Default.aspx?k=" + txtTimKiem.Text.Trim());
            }
        }

        // 5. Hiển thị số lượng giỏ hàng
        protected void Page_PreRender(object sender, EventArgs e)
        {
            // Ép kiểu Session về List<CartItem>
            // Lưu ý: Class CartItem phải được định nghĩa (thường trong App_Code)
            List<CartItem> cart = Session["GioHang"] as List<CartItem>; 

            if (cart != null && cart.Count > 0)
            {
                int totalQty = cart.Sum(item => item.SoLuong);
                lblCartCount.Text = totalQty.ToString();
                lblCartCount.Visible = true;
            }
            else
            {
                lblCartCount.Text = "0";
                lblCartCount.Visible = false;
            }
        }

    }
}