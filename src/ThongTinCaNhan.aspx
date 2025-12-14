<%@ Page Title="Thông tin cá nhân" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="ThongTinCaNhan.aspx.cs" Inherits="Laptop.ThongTinCaNhan" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <style>
        .profile-card {
            max-width: 650px; /* Tăng chiều rộng một chút */
            margin: 40px auto;
            padding: 30px;
            background: #fff;
            border-radius: 10px;
            box-shadow: 0 4px 15px rgba(0,0,0,0.08);
            border-top: 5px solid #ff6600;
        }
        .profile-header {
            text-align: center;
            margin-bottom: 30px;
            padding-bottom: 15px;
            border-bottom: 1px solid #eee;
        }
        .profile-header i {
            font-size: 3rem;
            color: #ff6600;
            margin-bottom: 10px;
        }
        .profile-header h4 {
            font-weight: 700;
            color: #333;
        }
        .form-control:focus {
            border-color: #ff6600;
            box-shadow: 0 0 0 0.2rem rgba(255, 102, 0, 0.25);
        }
        .btn-update {
            background: linear-gradient(135deg, #ff6600 0%, #ff4500 100%);
            color: #fff;
            font-weight: 700;
            padding: 10px 25px;
            border: none;
            transition: 0.3s;
        }
        .btn-update:hover {
            transform: translateY(-2px);
            box-shadow: 0 5px 15px rgba(255, 69, 0, 0.3);
            color: #fff;
        }
        .password-section {
            margin-top: 40px;
            padding-top: 30px;
            border-top: 1px dashed #ddd; /* Dùng đường đứt quãng để phân biệt */
        }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div class="container">
        <div class="profile-card">
            
            <div class="profile-header">
                <i class="fa-solid fa-user-gear"></i>
                <h4>Thông tin cá nhân & Bảo mật</h4>
                <asp:Label ID="lblEmail" runat="server" CssClass="text-muted small"></asp:Label>
            </div>

            <asp:Panel ID="pnlProfile" runat="server">
                <h5><i class="fa-solid fa-user me-2 text-primary"></i> Thông tin cơ bản</h5>
                
                <div class="mb-3">
                    <label class="form-label">Họ tên (*)</label>
                    <asp:TextBox ID="txtHoTen" runat="server" CssClass="form-control" placeholder="Họ tên"></asp:TextBox>
                    <asp:RequiredFieldValidator ID="rfvHoTen" runat="server" ControlToValidate="txtHoTen" ErrorMessage="Vui lòng nhập họ tên" CssClass="text-danger small" Display="Dynamic" ValidationGroup="ProfileGroup" />
                </div>

                <div class="mb-3">
                    <label class="form-label">Số điện thoại</label>
                    <asp:TextBox ID="txtSoDienThoai" runat="server" CssClass="form-control" placeholder="Số điện thoại"></asp:TextBox>
                </div>

                <div class="mb-3">
                    <label class="form-label">Địa chỉ</label>
                    <asp:TextBox ID="txtDiaChi" runat="server" CssClass="form-control" TextMode="MultiLine" Rows="3" placeholder="Địa chỉ"></asp:TextBox>
                </div>
                
                <div class="d-grid mt-4">
                    <asp:Button ID="btnCapNhat" runat="server" Text="CẬP NHẬT THÔNG TIN" CssClass="btn-update" OnClick="btnCapNhat_Click" ValidationGroup="ProfileGroup" />
                </div>
                <div class="text-center mt-3">
                    <asp:Label ID="lblThongBaoProfile" runat="server" CssClass="small fw-bold"></asp:Label>
                </div>
            </asp:Panel>
            
            <asp:Panel ID="pnlPassword" runat="server" CssClass="password-section">
                <h5><i class="fa-solid fa-lock me-2 text-primary"></i> Đổi mật khẩu</h5>

                <div class="mb-3">
                    <label class="form-label">Mật khẩu cũ (*)</label>
                    <asp:TextBox ID="txtMatKhauCu" runat="server" CssClass="form-control" TextMode="Password"></asp:TextBox>
                    <asp:RequiredFieldValidator ID="rfvCu" runat="server" ControlToValidate="txtMatKhauCu" ErrorMessage="Vui lòng nhập mật khẩu cũ" CssClass="text-danger small" Display="Dynamic" ValidationGroup="PasswordGroup" />
                </div>

                <div class="mb-3">
                    <label class="form-label">Mật khẩu mới (*)</label>
                    <asp:TextBox ID="txtMatKhauMoi" runat="server" CssClass="form-control" TextMode="Password"></asp:TextBox>
                    <asp:RequiredFieldValidator ID="rfvMoi" runat="server" ControlToValidate="txtMatKhauMoi" ErrorMessage="Vui lòng nhập mật khẩu mới" CssClass="text-danger small" Display="Dynamic" ValidationGroup="PasswordGroup" />
                </div>

                <div class="mb-3">
                    <label class="form-label">Xác nhận mật khẩu mới (*)</label>
                    <asp:TextBox ID="txtXacNhanMoi" runat="server" CssClass="form-control" TextMode="Password"></asp:TextBox>
                    <asp:CompareValidator ID="cvXacNhan" runat="server" ControlToValidate="txtXacNhanMoi" ControlToCompare="txtMatKhauMoi" ErrorMessage="Mật khẩu xác nhận không khớp!" CssClass="text-danger small" Display="Dynamic" ValidationGroup="PasswordGroup" />
                </div>
                
                <div class="d-grid mt-4">
                    <asp:Button ID="btnDoiMatKhau" runat="server" Text="ĐỔI MẬT KHẨU" CssClass="btn-update" OnClick="btnDoiMatKhau_Click" ValidationGroup="PasswordGroup" />
                </div>
                <div class="text-center mt-3">
                    <asp:Label ID="lblThongBaoPassword" runat="server" CssClass="small fw-bold"></asp:Label>
                </div>
            </asp:Panel>
            
            <asp:Panel ID="pnlChuaLogin" runat="server" Visible="false" CssClass="text-center py-4">
                <p class="text-muted">Bạn cần đăng nhập để xem thông tin cá nhân.</p>
                <a href="Login.aspx" class="btn btn-outline-primary">Đăng nhập ngay</a>
            </asp:Panel>
        </div>
    </div>
</asp:Content>