<%@ Page Title="Đặt hàng" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="DatHang.aspx.cs" Inherits="Laptop.DatHang" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <style>
        .checkout-box { background: #fff; padding: 30px; border-radius: 8px; box-shadow: 0 4px 10px rgba(0,0,0,0.05); }
        .step-title { font-weight: 700; color: #555; border-bottom: 2px solid #eee; padding-bottom: 10px; margin-bottom: 20px; text-transform: uppercase; }
        .form-label { font-weight: 600; color: #444; }
        
        .btn-check-phone { background: #fff3e0; color: #ff6600; border: 1px solid #ffccbc; font-weight: 600; }
        .btn-check-phone:hover { background: #ff6600; color: #fff; }

        .summary-box { background: #f8f9fa; border: 1px solid #eee; border-radius: 8px; padding: 20px; }
        .item-row { display: flex; justify-content: space-between; margin-bottom: 10px; font-size: 0.95rem; }
        .total-row { border-top: 2px solid #ddd; margin-top: 15px; padding-top: 15px; display: flex; justify-content: space-between; align-items: center; }
        .total-price { font-size: 1.4rem; font-weight: 800; color: #d70018; }

        .btn-submit-order {
            background: linear-gradient(135deg, #ff6600 0%, #ff4500 100%);
            color: #fff; font-size: 1.1rem; font-weight: 800; text-transform: uppercase;
            padding: 15px; border-radius: 6px; width: 100%; border: none; transition: 0.3s;
        }
        .btn-submit-order:hover {
            background: linear-gradient(135deg, #e63e00 0%, #d43600 100%);
            transform: translateY(-2px); box-shadow: 0 5px 15px rgba(255, 69, 0, 0.3); color: #fff;
        }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div class="container py-5">
        <h2 class="mb-4 fw-bold text-center text-uppercase text-secondary">Thanh toán & Giao hàng</h2>

        <div class="row">
            <div class="col-lg-7 mb-4">
                <div class="checkout-box h-100">
                    <h5 class="step-title"><i class="fa-solid fa-address-card me-2 text-warning"></i>Thông tin người nhận</h5>
                    
                    <asp:HiddenField ID="hfMaTK" runat="server" />
                    <asp:HiddenField ID="hfIsNewMember" runat="server" Value="true" />

                    <div class="mb-3">
                        <label class="form-label">Số điện thoại (*)</label>
                        <div class="input-group">
                            <span class="input-group-text bg-white"><i class="fa-solid fa-phone text-secondary"></i></span>
                            <asp:TextBox ID="txtSoDT" runat="server" CssClass="form-control" placeholder="Nhập SĐT và bấm Kiểm tra..." AutoPostBack="true" OnTextChanged="btnCheckSDT_Click"></asp:TextBox>
                            <asp:LinkButton ID="btnCheckSDT" runat="server" CssClass="btn btn-check-phone" OnClick="btnCheckSDT_Click" CausesValidation="false">
                                <i class="fa-solid fa-magnifying-glass"></i> Kiểm tra
                            </asp:LinkButton>
                        </div>
                        <asp:RequiredFieldValidator ID="rfvSDT" runat="server" ControlToValidate="txtSoDT" ErrorMessage="Vui lòng nhập SĐT" CssClass="text-danger small" Display="Dynamic" />
                        <asp:Label ID="lblThongBao" runat="server" CssClass="small mt-1 d-block"></asp:Label>
                    </div>

                    <div class="mb-3">
                        <label class="form-label">Họ tên (*)</label>
                        <asp:TextBox ID="txtHoTen" runat="server" CssClass="form-control" placeholder="Nguyễn Văn A"></asp:TextBox>
                        <asp:RequiredFieldValidator ID="rfvHoTen" runat="server" ControlToValidate="txtHoTen" ErrorMessage="Vui lòng nhập họ tên" CssClass="text-danger small" Display="Dynamic" />
                    </div>

                    <div class="mb-3">
                        <label class="form-label">Địa chỉ nhận hàng (*)</label>
                        <asp:TextBox ID="txtDiaChi" runat="server" CssClass="form-control" TextMode="MultiLine" Rows="2" placeholder="Số nhà, đường, phường/xã..."></asp:TextBox>
                        <asp:RequiredFieldValidator ID="rfvDiaChi" runat="server" ControlToValidate="txtDiaChi" ErrorMessage="Vui lòng nhập địa chỉ" CssClass="text-danger small" Display="Dynamic" />
                    </div>

                    <asp:Panel ID="pnlDangKy" runat="server">
                        <div class="row mb-3">
                            <div class="col-md-6">
                                <label class="form-label">Email (Tùy chọn)</label>
                                <asp:TextBox ID="txtEmail" runat="server" CssClass="form-control" TextMode="Email" placeholder="Để trống nếu không có"></asp:TextBox>
                                </div>
                            <div class="col-md-6">
                                <label class="form-label">Mật khẩu (Tạo mới)</label>
                                <asp:TextBox ID="txtMatKhau" runat="server" CssClass="form-control" TextMode="Password" placeholder="Nhập mật khẩu..."></asp:TextBox>
                                <asp:RequiredFieldValidator ID="rfvMatKhau" runat="server" ControlToValidate="txtMatKhau" ErrorMessage="Cần tạo mật khẩu" CssClass="text-danger small" Display="Dynamic" />
                            </div>
                        </div>
                    </asp:Panel>

                    <div class="mb-3">
                        <label class="form-label">Ghi chú (Tùy chọn)</label>
                        <asp:TextBox ID="txtGhiChu" runat="server" CssClass="form-control" TextMode="MultiLine" Rows="2"></asp:TextBox>
                    </div>
                </div>
            </div>

            <div class="col-lg-5">
                <div class="summary-box sticky-top" style="top: 90px; z-index: 1;">
                    <h5 class="step-title"><i class="fa-solid fa-receipt me-2 text-warning"></i>Đơn hàng</h5>
                    
                    <div style="max-height: 300px; overflow-y: auto; padding-right: 5px;">
                        <asp:Repeater ID="rptTomTat" runat="server">
                            <ItemTemplate>
                                <div class="item-row">
                                    <div class="d-flex align-items-start">
                                        <span class="badge bg-secondary me-2 rounded-pill"><%# Eval("SoLuong") %></span>
                                        <div style="line-height: 1.2;">
                                            <div class="fw-bold text-dark"><%# Eval("TenLap") %></div>
                                        </div>
                                    </div>
                                    <div class="fw-bold"><%# Convert.ToDecimal(Eval("ThanhTien")).ToString("N0") %>₫</div>
                                </div>
                            </ItemTemplate>
                        </asp:Repeater>
                    </div>

                    <div class="total-row">
                        <span class="fs-5 fw-bold">TỔNG CỘNG:</span>
                        <asp:Label ID="lblTongTien" runat="server" CssClass="total-price"></asp:Label>
                    </div>
                    
                    <div class="alert alert-info mt-3 small">
                        <i class="fa-solid fa-truck-fast me-1"></i> Thanh toán khi nhận hàng (COD)
                    </div>

                    <asp:Button ID="btnHoanTat" runat="server" Text="HOÀN TẤT ĐẶT HÀNG" CssClass="btn-submit-order mt-2" OnClick="btnHoanTat_Click" />
                    
                    <div class="text-center mt-3">
                        <a href="GioHang.aspx" class="text-decoration-none text-muted small"><i class="fa-solid fa-arrow-left me-1"></i>Quay lại giỏ hàng</a>
                    </div>
                </div>
            </div>
        </div>
    </div>
</asp:Content>