<%@ Page Title="Bảng điều khiển" Language="C#" MasterPageFile="~/Admin/Admin.Master" AutoEventWireup="true" CodeBehind="Dashboard.aspx.cs" Inherits="Laptop.Admin.Dashboard" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <style>
        /* KPI Cards */
        .kpi-card { background: #fff; padding: 20px; border-radius: 8px; box-shadow: 0 2px 10px rgba(0,0,0,0.05); display: flex; align-items: center; justify-content: space-between; border-left: 5px solid #ccc; height: 100%; transition: 0.3s; cursor: pointer; }
        .kpi-card:hover { transform: translateY(-5px); } /* Hiệu ứng hover */
        .kpi-icon { font-size: 2.5rem; opacity: 0.2; }
        .kpi-value { font-size: 1.8rem; font-weight: 800; color: #333; }
        .kpi-title { font-size: 0.9rem; color: #666; font-weight: 600; text-transform: uppercase; }
        
        /* Cảnh báo đỏ */
        .kpi-danger-alert { border-left-color: #dc3545 !important; background-color: #fff5f5; }

        /* Table Styles */
        .card-box { background: #fff; border-radius: 8px; box-shadow: 0 2px 10px rgba(0,0,0,0.05); padding: 20px; margin-bottom: 20px; }
        .card-header-custom { border-bottom: 1px solid #eee; padding-bottom: 10px; margin-bottom: 15px; display: flex; justify-content: space-between; align-items: center; }
        .badge-status { padding: 5px 10px; border-radius: 15px; font-size: 0.8rem; font-weight: 600; }
        .st-cho-duyet { background: #fff3cd; color: #856404; } 

        /* Invoice Modal CSS */
        .invoice-box { padding: 20px; font-family: 'Roboto', sans-serif; }
        .invoice-header { border-bottom: 2px solid #ff6600; padding-bottom: 15px; margin-bottom: 20px; }
        .invoice-total { font-size: 1.2rem; font-weight: 800; color: #d70018; text-align: right; margin-top: 15px; border-top: 1px solid #ddd; padding-top: 10px; }
        
        /* Low Stock Modal Table */
        .table-low-stock th { background-color: #dc3545; color: white; }

        @media print {
            body * { visibility: hidden; }
            #invoiceModal, #invoiceModal * { visibility: visible; }
            #invoiceModal { position: absolute; left: 0; top: 0; width: 100%; height: 100%; margin: 0; padding: 0; background: #fff; }
            .modal-header, .modal-footer, .btn-close { display: none !important; }
            .invoice-box { width: 100%; }
        }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <div class="container-fluid">
        <div class="row g-3 mb-4">
            <div class="col-md-3">
                <div class="kpi-card" style="border-left-color: #198754;">
                    <div><div class="kpi-title">Doanh thu bán hàng</div><div class="kpi-value text-success"><asp:Label ID="lblDoanhThu" runat="server">0</asp:Label></div></div>
                    <i class="fa-solid fa-sack-dollar kpi-icon text-success"></i>
                </div>
            </div>
            <div class="col-md-3">
                <div class="kpi-card" style="border-left-color: #dc3545;">
                    <div><div class="kpi-title">Tổng tiền nhập</div><div class="kpi-value text-danger"><asp:Label ID="lblTienNhap" runat="server">0</asp:Label></div></div>
                    <i class="fa-solid fa-file-invoice-dollar kpi-icon text-danger"></i>
                </div>
            </div>
            <div class="col-md-3">
                <div class="kpi-card" style="border-left-color: #ffc107;">
                    <div><div class="kpi-title">Đơn chờ duyệt</div><div class="kpi-value text-warning"><asp:Label ID="lblDonCho" runat="server">0</asp:Label></div></div>
                    <i class="fa-solid fa-clock kpi-icon text-warning"></i>
                </div>
            </div>
            <div class="col-md-3">
                <asp:LinkButton ID="btnCanhBaoTonKho" runat="server" OnClick="btnCanhBaoTonKho_Click" style="text-decoration:none;">
                    <div id="divCanhBao" runat="server" class="kpi-card" style="border-left-color: #6c757d;">
                        <div>
                            <div class="kpi-title">Cảnh báo tồn kho</div>
                            <div class="kpi-value"><asp:Label ID="lblTonKho" runat="server">0</asp:Label></div>
                            <small class="text-muted fst-italic">Nhấn để xem chi tiết</small>
                        </div>
                        <i class="fa-solid fa-triangle-exclamation kpi-icon"></i>
                    </div>
                </asp:LinkButton>
            </div>
        </div>

        <div class="row">
            <div class="col-12">
                <div class="card-box">
                    <div class="card-header-custom">
                        <h5 class="fw-bold m-0 text-primary"><i class="fa-solid fa-cart-shopping me-2"></i>Đơn hàng mới chờ duyệt</h5>
                        <a href="QuanLyDonHang.aspx" class="btn btn-sm btn-primary">Quản lý tất cả</a>
                    </div>
                    
                    <asp:Panel ID="pnlDonHang" runat="server">
                        <div class="table-responsive">
                            <table class="table table-hover align-middle">
                                <thead class="table-light">
                                    <tr>
                                        <th>Mã</th>
                                        <th>Khách hàng</th>
                                        <th>Ngày đặt</th>
                                        <th>Tổng tiền</th>
                                        <th>Trạng thái</th>
                                        <th>Thao tác</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <asp:Repeater ID="rptDonHang" runat="server" OnItemCommand="rptDonHang_ItemCommand">
                                        <ItemTemplate>
                                            <tr>
                                                <td class="fw-bold">#<%# Eval("MaDH") %></td>
                                                <td><div class="fw-bold"><%# Eval("HoTen") %></div></td>
                                                <td><%# Eval("NgayDat", "{0:dd/MM/yyyy HH:mm}") %></td>
                                                <td class="text-danger fw-bold"><%# Convert.ToDecimal(Eval("TongTien")).ToString("N0") %></td>
                                                <td><span class="badge st-cho-duyet"><%# Eval("TrangThai") %></span></td>
                                                <td>
                                                    <asp:LinkButton ID="btnXem" runat="server" CommandName="View" CommandArgument='<%# Eval("MaDH") %>' CssClass="btn btn-sm btn-outline-info me-1"><i class="fa-solid fa-eye"></i></asp:LinkButton>
                                                    <asp:LinkButton ID="btnDuyet" runat="server" CommandName="Approve" CommandArgument='<%# Eval("MaDH") %>' CssClass="btn btn-sm btn-success me-1" OnClientClick="return confirm('Duyệt đơn này?');"><i class="fa-solid fa-check"></i></asp:LinkButton>
                                                    <asp:LinkButton ID="btnHuy" runat="server" CommandName="Cancel" CommandArgument='<%# Eval("MaDH") %>' CssClass="btn btn-sm btn-outline-danger" OnClientClick="return confirm('Hủy đơn này?');"><i class="fa-solid fa-xmark"></i></asp:LinkButton>
                                                </td>
                                            </tr>
                                        </ItemTemplate>
                                    </asp:Repeater>
                                </tbody>
                            </table>
                        </div>
                    </asp:Panel>
                    <asp:Label ID="lblNoDataOrder" runat="server" Visible="false" CssClass="alert alert-info d-block">Tuyệt vời! Không có đơn hàng nào đang chờ duyệt.</asp:Label>
                </div>
            </div>
        </div>
    </div>

    <div class="modal fade" id="invoiceModal" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog modal-lg">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title">Chi tiết đơn hàng #<asp:Label ID="lblModalMaDon" runat="server"></asp:Label></h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body">
                    <div class="invoice-box" id="printArea">
                        <div class="invoice-header row">
                            <div class="col-7 company-info">
                                <h4>Laptop Tân Nguyễn</h4>
                                <p><i class="fa-solid fa-location-dot me-1"></i> Đ/c: Ấp Tân lễ 2, Xã An Định, Tỉnh Vĩnh Long</p>
                                <p><i class="fa-solid fa-phone me-1"></i> SĐT: 0975 728 913</p>
                            </div>
                            <div class="col-5 text-end">
                                <h2 class="text-secondary">PHIẾU ĐƠN HÀNG</h2>
                                <p>Ngày: <asp:Label ID="lblModalNgayDat" runat="server" Font-Bold="true"></asp:Label></p>
                            </div>
                        </div>
                        <div class="bg-light p-3 rounded mb-3">
                            <p class="mb-1"><b>Khách:</b> <asp:Label ID="lblModalNguoiNhan" runat="server"></asp:Label></p>
                            <p class="mb-1"><b>SĐT:</b> <asp:Label ID="lblModalSDT" runat="server"></asp:Label></p>
                            <p class="mb-0"><b>Đ/c:</b> <asp:Label ID="lblModalDiaChi" runat="server"></asp:Label></p>
                        </div>
                        <table class="table table-bordered">
                            <thead class="table-dark"><tr><th>SP</th><th class="text-center">SL</th><th class="text-end">Giá</th><th class="text-end">Thành tiền</th></tr></thead>
                            <tbody>
                                <asp:Repeater ID="rptChiTietModal" runat="server">
                                    <ItemTemplate>
                                        <tr>
                                            <td><%# Eval("TenLap") %></td>
                                            <td class="text-center"><%# Eval("SoLuong") %></td>
                                            <td class="text-end"><%# Convert.ToDecimal(Eval("GiaBan")).ToString("N0") %></td>
                                            <td class="text-end fw-bold"><%# (Convert.ToDecimal(Eval("GiaBan")) * Convert.ToInt32(Eval("SoLuong"))).ToString("N0") %></td>
                                        </tr>
                                    </ItemTemplate>
                                </asp:Repeater>
                            </tbody>
                        </table>
                        <div class="invoice-total">TỔNG: <asp:Label ID="lblModalTongTien" runat="server"></asp:Label></div>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Đóng</button>
                    <button type="button" class="btn btn-primary" onclick="window.print()"><i class="fa-solid fa-print me-2"></i>In</button>
                </div>
            </div>
        </div>
    </div>

    <div class="modal fade" id="lowStockModal" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog modal-lg">
            <div class="modal-content">
                <div class="modal-header bg-danger text-white">
                    <h5 class="modal-title"><i class="fa-solid fa-triangle-exclamation me-2"></i> Danh sách sản phẩm sắp hết hàng (<= 5)</h5>
                    <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body">
                    <p class="text-muted">Các sản phẩm dưới đây cần được lên kế hoạch nhập hàng ngay.</p>
                    <div class="table-responsive">
                        <table class="table table-bordered table-striped table-low-stock align-middle">
                            <thead>
                                <tr>
                                    <th>Hình</th>
                                    <th>Tên Laptop</th>
                                    <th>Giá bán</th>
                                    <th class="text-center">Tồn kho</th>
                                </tr>
                            </thead>
                            <tbody>
                                <asp:Repeater ID="rptLowStock" runat="server">
                                    <ItemTemplate>
                                        <tr>
                                            <td style="width: 60px;">
                                                <img src='<%# ResolveUrl("~/Images/Products/" + Eval("HinhAnh")) %>' width="50" onerror="this.src='/Images/no-image.png'" />
                                            </td>
                                            <td><%# Eval("TenLap") %></td>
                                            <td><%# Convert.ToDecimal(Eval("GiaBan")).ToString("N0") %></td>
                                            <td class="text-center fw-bold text-danger" style="font-size: 1.1rem;">
                                                <%# Eval("TonKho") %>
                                            </td>
                                        </tr>
                                    </ItemTemplate>
                                </asp:Repeater>
                            </tbody>
                        </table>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Đóng</button>
                    <a href="QuanLyNhapHang.aspx" class="btn btn-danger"><i class="fa-solid fa-truck-field me-2"></i> Đến trang Nhập Hàng</a>
                </div>
            </div>
        </div>
    </div>
    
    <script>
        function openInvoiceModal() {
            new bootstrap.Modal(document.getElementById('invoiceModal')).show();
        }
        function openLowStockModal() {
            new bootstrap.Modal(document.getElementById('lowStockModal')).show();
        }
    </script>
</asp:Content>