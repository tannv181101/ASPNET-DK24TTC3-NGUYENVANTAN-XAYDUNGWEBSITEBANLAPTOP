<%@ Page Title="Đăng nhập" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Login.aspx.cs" Inherits="Laptop.Login" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <style>
        .login-container {
            max-width: 450px;
            margin: 50px auto;
            background: #fff;
            padding: 40px;
            border-radius: 10px;
            box-shadow: 0 10px 25px rgba(0,0,0,0.05);
        }
        .login-header { text-align: center; margin-bottom: 30px; }
        .login-header h3 { font-weight: 800; color: #333; text-transform: uppercase; }
        .login-header i { font-size: 3rem; color: #ff6600; margin-bottom: 10px; }
        
        .form-control { height: 45px; border-radius: 5px; }
        .form-control:focus { border-color: #ff6600; box-shadow: 0 0 0 0.2rem rgba(255, 102, 0, 0.25); }
        
        .btn-login {
            background: linear-gradient(135deg, #ff6600 0%, #ff4500 100%);
            color: #fff; font-weight: 700; height: 45px; width: 100%;
            border: none; border-radius: 5px; text-transform: uppercase;
            transition: 0.3s;
        }
        .btn-login:hover {
            background: linear-gradient(135deg, #e63e00 0%, #d43600 100%);
            transform: translateY(-2px); box-shadow: 0 5px 15px rgba(255, 69, 0, 0.3); color: #fff;
        }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div class="container">
        <div class="login-container">
            <div class="login-header">
                <i class="fa-solid fa-circle-user"></i>
                <h3>Đăng nhập</h3>
                <p class="text-muted">Chào mừng bạn quay trở lại!</p>
            </div>

            <asp:Panel ID="pnlLogin" runat="server" DefaultButton="btnLogin">
                <div class="mb-3">
                    <label class="form-label fw-bold">Email hoặc SĐT</label>
                    <div class="input-group">
                        <span class="input-group-text bg-light"><i class="fa-solid fa-envelope text-secondary"></i></span>
                        <asp:TextBox ID="txtEmail" runat="server" CssClass="form-control" placeholder="Nhập email hoặc số điện thoại"></asp:TextBox>
                    </div>
                </div>

                <div class="mb-3">
                    <label class="form-label fw-bold">Mật khẩu</label>
                    <div class="input-group">
                        <span class="input-group-text bg-light"><i class="fa-solid fa-lock text-secondary"></i></span>
                        <asp:TextBox ID="txtMatKhau" runat="server" CssClass="form-control" TextMode="Password" placeholder="Nhập mật khẩu"></asp:TextBox>
                    </div>
                </div>

                <div class="mb-3 form-check">
                    <asp:CheckBox ID="chkGhiNho" runat="server" CssClass="form-check-input" />
                    <label class="form-check-label" for="MainContent_chkGhiNho">Ghi nhớ đăng nhập</label>
                </div>

                <asp:Label ID="lblLoi" runat="server" CssClass="text-danger small mb-3 d-block text-center fw-bold"></asp:Label>

                <asp:Button ID="btnLogin" runat="server" Text="ĐĂNG NHẬP" CssClass="btn-login" OnClick="btnLogin_Click" />
            </asp:Panel>

            <div class="text-center mt-4 pt-3 border-top">
                <p class="mb-0 text-muted">Bạn chưa có tài khoản?</p>
                <a href="DangKy.aspx" class="text-decoration-none fw-bold text-primary">Đăng ký ngay</a>
            </div>
        </div>
    </div>
</asp:Content>