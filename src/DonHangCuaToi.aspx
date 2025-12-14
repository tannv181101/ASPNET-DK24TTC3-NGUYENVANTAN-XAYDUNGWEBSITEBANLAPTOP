<%@ Page Title="Đơn hàng của tôi" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="DonHangCuaToi.aspx.cs" Inherits="Laptop.DonHangCuaToi" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <style>
        .order-card { background: #fff; border-radius: 8px; box-shadow: 0 2px 10px rgba(0,0,0,0.05); margin-bottom: 20px; overflow: hidden; border: 1px solid #eee; }
        .badge-status { font-size: 0.85rem; padding: 6px 12px; border-radius: 20px; }
        .st-cho-duyet { background: #fff3cd; color: #856404; border: 1px solid #ffeeba; }
        .st-da-giao { background: #d1e7dd; color: #0f5132; border: 1px solid #badbcc; }
        .st-da-huy { background: #f8d7da; color: #842029; border: 1px solid #f5c2c7; }

        /* Invoice Style */
        .invoice-box { padding: 20px; font-family: 'Roboto', sans-serif; }
        .invoice-header { border-bottom: 2px solid #ff6600; padding-bottom: 15px; margin-bottom: 20px; }
        .company-info h4 { color: #ff6600; font-weight: 800; text-transform: uppercase; margin-bottom: 5px; }
        .company-info p { margin: 2px 0; font-size: 0.9rem; color: #555; }
        .invoice-title { text-align: right; }
        .invoice-title h2 { font-weight: 800; color: #333; margin-bottom: 5px; }
        .invoice-details { text-align: right; font-size: 0.9rem; color: #666; }
        .customer-info { background: #f9f9f9; padding: 15px; border-radius: 5px; margin-bottom: 20px; }
        .invoice-table th { background: #ff6600; color: #fff; text-transform: uppercase; font-size: 0.85rem; }
        .invoice-total { font-size: 1.2rem; font-weight: 800; color: #d70018; text-align: right; margin-top: 15px; }

        @media print {
            body * { visibility: hidden; }
            #invoiceModal, #invoiceModal * { visibility: visible; }
            #invoiceModal { position: absolute; left: 0; top: 0; margin: 0; padding: 0; width: 100%; border: none; }
            .modal-header, .modal-footer, .btn-close { display: none !important; }
            .invoice-box { padding: 0; }
        }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div class="container py-5">
        <h3 class="mb-4 fw-bold text-uppercase border-bottom pb-2">
            <i class="fa-solid fa-file-invoice text-primary me-2"></i>Quản lý đơn hàng
        </h3>

        <asp:Panel ID="pnlChuaDangNhap" runat="server" Visible="false" CssClass="text-center py-5">
            <h5 class="text-muted">Vui lòng đăng nhập để xem đơn hàng.</h5>
            <a href="Login.aspx" class="btn btn-primary mt-2">Đăng nhập</a>
        </asp:Panel>

        <asp:Panel ID="pnlDaDangNhap" runat="server">
            <asp:Label ID="lblThongBao" runat="server"></asp:Label>
            <div class="table-responsive">
                <table class="table table-hover bg-white border shadow-sm rounded align-middle">
                    <thead class="bg-light text-secondary">
                        <tr>
                            <th class="py-3 ps-3">Mã đơn</th>
                            <th>Ngày đặt</th>
                            <th>Địa chỉ nhận</th>
                            <th>Tổng tiền</th>
                            <th>Trạng thái</th>
                            <th class="text-end pe-3">Thao tác</th>
                        </tr>
                    </thead>
                    <tbody>
                        <asp:Repeater ID="rptDonHang" runat="server" OnItemCommand="rptDonHang_ItemCommand">
                            <ItemTemplate>
                                <tr>
                                    <td class="ps-3 fw-bold">#<%# Eval("MaDH") %></td>
                                    <td><%# Eval("NgayDat", "{0:dd/MM/yyyy HH:mm}") %></td>
                                    <td style="max-width: 200px;" class="text-truncate" title='<%# Eval("DiaChiGiaoHang") %>'><%# Eval("DiaChiGiaoHang") %></td>
                                    <td class="fw-bold text-danger"><%# Convert.ToDecimal(Eval("TongTien")).ToString("N0") %>₫</td>
                                    <td><span class='badge-status <%# GetStatusClass(Eval("TrangThai")) %>'><%# Eval("TrangThai") %></span></td>
                                    <td class="text-end pe-3">
                                        <asp:LinkButton ID="btnXem" runat="server" CommandName="XemDon" CommandArgument='<%# Eval("MaDH") %>' CssClass="btn btn-sm btn-info text-white me-1"><i class="fa-solid fa-print"></i> Xem/In</asp:LinkButton>
                                        <asp:LinkButton ID="btnHuy" runat="server" CommandName="HuyDon" CommandArgument='<%# Eval("MaDH") %>' CssClass="btn btn-sm btn-outline-danger" Visible='<%# Eval("TrangThai").ToString() == "Chờ duyệt" %>' OnClientClick="return confirm('Bạn chắc chắn muốn hủy?');"><i class="fa-solid fa-trash-can"></i> Hủy</asp:LinkButton>
                                    </td>
                                </tr>
                            </ItemTemplate>
                        </asp:Repeater>
                    </tbody>
                </table>
            </div>
        </asp:Panel>

        <div class="modal fade" id="invoiceModal" tabindex="-1" aria-hidden="true">
            <div class="modal-dialog modal-lg">
                <div class="modal-content">
                    <div class="modal-header bg-light">
                        <h5 class="modal-title fw-bold"><i class="fa-solid fa-print me-2"></i>Chi tiết đơn hàng</h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                    </div>
                    <div class="modal-body">
                        <div class="invoice-box" id="printArea">
                            <div class="invoice-header row">
                                <div class="col-7 company-info">
                                    <h4>Laptop Tân Nguyễn</h4>
                                    <p><i class="fa-solid fa-location-dot me-1"></i> <b>Địa chỉ:</b> Ấp Tân lễ 2, Xã An Định, Tỉnh Vĩnh Long</p>
                                    <p><i class="fa-solid fa-phone me-1"></i> <b>SĐT:</b> 0975 728 913</p>
                                    <p><i class="fa-solid fa-envelope me-1"></i> <b>Email:</b> cskh@tannguyen.com</p>
                                </div>
                                <div class="col-5 invoice-title">
                                    <h2>HÓA ĐƠN</h2>
                                    <div class="invoice-details">
                                        <p>Mã đơn: <b>#<asp:Label ID="lblModalMaDon" runat="server"></asp:Label></b></p>
                                        <p>Ngày: <asp:Label ID="lblModalNgayDat" runat="server"></asp:Label></p>
                                        <p>Trạng thái: <asp:Label ID="lblModalTrangThai" runat="server"></asp:Label></p>
                                    </div>
                                </div>
                            </div>
                            <div class="customer-info">
                                <h6 class="fw-bold border-bottom pb-2 mb-2">Thông tin khách hàng</h6>
                                <p class="mb-1"><b>Người nhận:</b> <asp:Label ID="lblModalNguoiNhan" runat="server"></asp:Label></p>
                                <p class="mb-1"><b>Địa chỉ:</b> <asp:Label ID="lblModalDiaChi" runat="server"></asp:Label></p>
                                <p class="mb-0 fst-italic text-muted"><b>Ghi chú:</b> <asp:Label ID="lblModalGhiChu" runat="server"></asp:Label></p>
                            </div>
                            <table class="table table-bordered invoice-table">
                                <thead><tr><th>STT</th><th>Tên Sản Phẩm</th><th class="text-center">SL</th><th class="text-end">Đơn giá</th><th class="text-end">Thành tiền</th></tr></thead>
                                <tbody>
                                    <asp:Repeater ID="rptChiTietModal" runat="server">
                                        <ItemTemplate>
                                            <tr>
                                                <td class="text-center"><%# Container.ItemIndex + 1 %></td>
                                                <td><%# Eval("TenLap") %></td>
                                                <td class="text-center"><%# Eval("SoLuong") %></td>
                                                <td class="text-end"><%# Convert.ToDecimal(Eval("GiaBan")).ToString("N0") %></td>
                                                <td class="text-end fw-bold"><%# (Convert.ToDecimal(Eval("GiaBan")) * Convert.ToInt32(Eval("SoLuong"))).ToString("N0") %></td>
                                            </tr>
                                        </ItemTemplate>
                                    </asp:Repeater>
                                </tbody>
                            </table>
                            <div class="invoice-total">TỔNG CỘNG: <asp:Label ID="lblModalTongTien" runat="server"></asp:Label></div>
                            <div class="text-center mt-5 mb-3 fst-italic text-muted small"><p>Cảm ơn quý khách đã mua hàng tại Laptop Tân Nguyễn!</p></div>
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Đóng</button>
                        <button type="button" class="btn btn-primary" onclick="window.print()"><i class="fa-solid fa-print me-2"></i>In Hóa Đơn</button>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script>
        function openInvoiceModal() {
            var myModalElement = document.getElementById('invoiceModal');
            if (myModalElement) {
                var myModal = new bootstrap.Modal(myModalElement);
                myModal.show();
            }
        }
    </script>
</asp:Content>