using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web.UI;
using System.Web.UI.WebControls;
using Laptop.Models;

namespace Laptop
{
    public partial class DatHang : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadTomTat();
                txtSoDT.Focus();

                // Mặc định ẩn phần mật khẩu nếu đã đăng nhập
                if (Session["MaTK"] != null)
                {
                    // Logic tự điền thông tin nếu đang đăng nhập (nếu cần)
                    // Hiện tại ta ưu tiên luồng nhập SĐT để check
                }
            }
        }

        private void LoadTomTat()
        {
            List<CartItem> cart = Session["GioHang"] as List<CartItem>;
            if (cart == null || cart.Count == 0)
            {
                Response.Redirect("Default.aspx");
            }
            else
            {
                rptTomTat.DataSource = cart;
                rptTomTat.DataBind();
                lblTongTien.Text = cart.Sum(x => x.ThanhTien).ToString("N0") + "₫";
            }
        }

        // --- 1. TÌM KIẾM KHÁCH HÀNG BẰNG SĐT (LOGIC MỚI) ---
        protected void btnCheckSDT_Click(object sender, EventArgs e)
        {
            string sdt = txtSoDT.Text.Trim();
            if (string.IsNullOrEmpty(sdt)) return;

            // Tìm trong bảng TaiKhoan xem SĐT này đã có chưa
            string sql = "SELECT * FROM TaiKhoan WHERE SoDienThoai = @SDT";
            SqlParameter[] p = { new SqlParameter("@SDT", sdt) };
            DataRow row = DBConnect.GetOneRow(sql, p);

            if (row != null)
            {
                // -- TRƯỜNG HỢP 1: ĐÃ CÓ TÀI KHOẢN --
                txtHoTen.Text = row["HoTen"].ToString();
                txtDiaChi.Text = row["DiaChi"].ToString();
                txtEmail.Text = row["Email"].ToString();

                // Lưu lại ID tài khoản cũ
                hfMaTK.Value = row["MaTK"].ToString();
                hfIsNewMember.Value = "false";

                // Ẩn phần đăng ký vì đã có tài khoản
                pnlDangKy.Visible = false;
                rfvMatKhau.Enabled = false; // Tắt bắt buộc nhập mật khẩu

                lblThongBao.Text = "<i class='fa-solid fa-check-circle text-success'></i> Khách hàng cũ: " + row["HoTen"];
                lblThongBao.CssClass = "small mt-1 d-block text-success fw-bold";
            }
            else
            {
                // -- TRƯỜNG HỢP 2: KHÁCH MỚI HOÀN TOÀN --
                txtHoTen.Text = "";
                txtDiaChi.Text = "";
                txtEmail.Text = "";

                hfMaTK.Value = "";
                hfIsNewMember.Value = "true";

                // Hiện phần đăng ký mật khẩu
                pnlDangKy.Visible = true;
                rfvMatKhau.Enabled = true; // Bật bắt buộc nhập mật khẩu
                txtHoTen.Focus();

                lblThongBao.Text = "SĐT chưa tồn tại. Vui lòng nhập thông tin để tạo tài khoản mới.";
                lblThongBao.CssClass = "small mt-1 d-block text-primary";
            }
        }

        // --- 2. XỬ LÝ ĐẶT HÀNG ---
        protected void btnHoanTat_Click(object sender, EventArgs e)
        {
            if (Page.IsValid)
            {
                List<CartItem> cart = Session["GioHang"] as List<CartItem>;
                if (cart == null) return;

                int maTK_Order = 0;

                // A. XỬ LÝ TÀI KHOẢN
                // Nếu là khách cũ đã tìm thấy ID -> Dùng lại ID đó
                if (hfIsNewMember.Value == "false" && !string.IsNullOrEmpty(hfMaTK.Value))
                {
                    maTK_Order = Convert.ToInt32(hfMaTK.Value);
                }
                else
                {
                    // Nếu là khách mới -> INSERT TÀI KHOẢN MỚI
                    string email = txtEmail.Text.Trim();
                    // Xử lý Email rỗng -> DBNull
                    object valEmail = string.IsNullOrEmpty(email) ? DBNull.Value : (object)email;

                    string sqlNewAcc = @"INSERT INTO TaiKhoan(HoTen, Email, MatKhau, SoDienThoai, DiaChi, VaiTro, NgayTao) 
                                         VALUES(@HoTen, @Email, @MatKhau, @SDT, @DiaChi, 'Khach', GETDATE());
                                         SELECT SCOPE_IDENTITY();";

                    SqlParameter[] pAcc = {
                        new SqlParameter("@HoTen", txtHoTen.Text.Trim()),
                        new SqlParameter("@Email", valEmail),
                        new SqlParameter("@MatKhau", txtMatKhau.Text.Trim()),
                        new SqlParameter("@SDT", txtSoDT.Text.Trim()),
                        new SqlParameter("@DiaChi", txtDiaChi.Text.Trim())
                    };

                    object resAcc = DBConnect.ExecuteScalar(sqlNewAcc, pAcc);
                    if (resAcc != null)
                    {
                        maTK_Order = Convert.ToInt32(resAcc);
                        // Auto login
                        Session["MaTK"] = maTK_Order;
                        Session["HoTen"] = txtHoTen.Text.Trim();
                        Session["Quyen"] = "Khach";
                    }
                    else
                    {
                        Response.Write("<script>alert('Lỗi tạo tài khoản! Vui lòng thử lại.');</script>");
                        return;
                    }
                }

                // B. TẠO ĐƠN HÀNG
                decimal tongTien = cart.Sum(x => x.ThanhTien); // Tạm tính (Trigger sẽ cập nhật lại sau)
                string ghiChu = txtGhiChu.Text.Trim();
                string diaChiGiao = txtDiaChi.Text.Trim() + " (SĐT: " + txtSoDT.Text.Trim() + ")";
                if (!string.IsNullOrEmpty(ghiChu)) diaChiGiao += ". Ghi chú: " + ghiChu;

                string sqlDon = @"INSERT INTO DonHang(MaTK, NgayDat, TrangThai, TongTien, DiaChiGiaoHang) 
                                  VALUES(@MaTK, GETDATE(), N'Chờ duyệt', @TongTien, @DiaChi);
                                  SELECT SCOPE_IDENTITY();";

                SqlParameter[] pDon = {
                    new SqlParameter("@MaTK", maTK_Order),
                    new SqlParameter("@TongTien", tongTien),
                    new SqlParameter("@DiaChi", diaChiGiao)
                };

                object resDon = DBConnect.ExecuteScalar(sqlDon, pDon);

                if (resDon != null)
                {
                    int maDonMoi = Convert.ToInt32(resDon);

                    // C. LƯU CHI TIẾT
                    // (Quan trọng: Không cần trừ kho bằng C# nữa vì Trigger trg_BanHang đã làm việc đó)
                    foreach (var item in cart)
                    {
                        string sqlCT = "INSERT INTO ChiTietDonHang(MaDH, MaLap, SoLuong, GiaBan) VALUES(@MaDon, @MaLap, @SoLuong, @GiaBan)";
                        SqlParameter[] pCT = {
                            new SqlParameter("@MaDon", maDonMoi),
                            new SqlParameter("@MaLap", item.MaLap),
                            new SqlParameter("@SoLuong", item.SoLuong),
                            new SqlParameter("@GiaBan", item.GiaBan)
                        };
                        DBConnect.Execute(sqlCT, pCT);
                        // Trigger sẽ tự động chạy sau lệnh INSERT này để:
                        // 1. Trừ tồn kho trong bảng Laptop
                        // 2. Cập nhật lại TongTien trong bảng DonHang
                    }

                    // D. HOÀN TẤT
                    Session["GioHang"] = null;
                    string js = "alert('🎉 Đặt hàng thành công! Mã đơn: #" + maDonMoi + "'); window.location='Default.aspx';";
                    ClientScript.RegisterStartupScript(this.GetType(), "success", js, true);
                }
            }
        }
    }
}