using System;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Laptop.Admin
{
    public partial class AdminMaster : MasterPage
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                CheckAdminPermission();
                LoadUserInfo();
            }
        }

        // 1. Kiểm tra xem user có phải Admin không
        private void CheckAdminPermission()
        {
            // Nếu chưa đăng nhập hoặc không phải Admin thì đá về Login
            if (Session["MaTK"] == null || Session["Quyen"].ToString() != "Admin")
            {
                // Lưu lại URL đang cố truy cập (tùy chọn)
                // Session["ReturnUrl"] = Request.RawUrl; 
                Response.Redirect("~/Login.aspx");
            }
        }

        // 2. Hiển thị tên Admin
        private void LoadUserInfo()
        {
            if (Session["HoTen"] != null)
            {
                lblHoTen.Text = Session["HoTen"].ToString();
            }
        }

        // 3. Đăng xuất
        protected void btnLogout_Click(object sender, EventArgs e)
        {
            Session.Abandon();
            Response.Redirect("~/Default.aspx");
        }
    }
}