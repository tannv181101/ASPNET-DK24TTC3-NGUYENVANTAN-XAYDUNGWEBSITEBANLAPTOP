<%@ Page Title="Quản lý Đơn hàng" Language="C#" MasterPageFile="~/Admin/Admin.Master" AutoEventWireup="true" CodeBehind="QuanLyDonHang.aspx.cs" Inherits="Laptop.Admin.QuanLyDonHang" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <style>
        .order-table-container { background: #fff; padding: 20px; border-radius: 8px; box-shadow: 0 4px 10px rgba(0,0,0,0.05); }
        .filter-area { background: #f8f9fa; padding: 15px; border-radius: 6px; margin-bottom: 20px; border: 1px solid #eee; }
        
        /* Màu trạng thái */
        .badge-status { font-size: 0.85rem; padding: 6px 12px; border-radius: 20px; font-weight: 600; }
        .st-cho-duyet { background: #fff3cd; color: #856404; }
        .st-da-giao { background: #d1e7dd; color: #0f5132; }
        .st-da-huy { background: #f8d7da; color: #842029; }

        /* Invoice Modal CSS */
        .invoice-box { padding: 20px; font-family: 'Roboto', sans-serif; }
        .invoice-header { border-bottom: 2px solid #ff6600; padding-bottom: 15px; margin-bottom: 20px; }
        .company-info h4 { color: #ff6600; font-weight: 800; text-transform: uppercase; margin-bottom: 5px; }
        .invoice-total { font-size: 1.2rem; font-weight: 800; color: #d70018; text-align: right; margin-top: 15px; border-top: 1px solid #ddd; padding-top: 10px; }

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
        
        <div class="filter-area row g-3 align-items-end">
            <div class="col-md-3">
                <label class="form-label fw-bold">Trạng thái:</label>
                <asp:DropDownList ID="ddlTrangThai" runat="server" CssClass="form-select">
                    <asp:ListItem Value="All" Text="-- Tất cả --"></asp:ListItem>
                    <asp:ListItem Value="Chờ duyệt" Text="Chờ duyệt"></asp:ListItem>
                    <asp:ListItem Value="Đã giao" Text="Đã giao"></asp:ListItem>
                    <asp:ListItem Value="Đã hủy" Text="Đã hủy"></asp:ListItem>
                </asp:DropDownList>
            </div>
            <div class="col-md-4">
                <label class="form-label fw-bold">Tìm kiếm:</label>
                <div class="input-group">
                    <asp:TextBox ID="txtSearch" runat="server" CssClass="form-control" placeholder="Nhập Mã đơn hoặc Tên khách..."></asp:TextBox>
                    <asp:Button ID="btnLoc" runat="server" Text="Tìm & Lọc" CssClass="btn btn-primary" OnClick="btnLoc_Click" />
                </div>
            </div>
        </div>

        <div class="order-table-container">
            <h5 class="fw-bold mb-3 text-secondary">Danh sách Đơn hàng</h5>
            
            <div class="table-responsive">
                <table class="table table-hover align-middle mb-0">
                    <thead class="bg-light">
                        <tr>
                            <th>Mã đơn</th>
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
                                    <td><%# Eval("HoTen") %></td>
                                    <td><%# Eval("NgayDat", "{0:dd/MM/yyyy HH:mm}") %></td>
                                    <td class="fw-bold text-danger"><%# Convert.ToDecimal(Eval("TongTien")).ToString("N0") %></td>
                                    <td>
                                        <span class="badge badge-status <%# GetStatusClass(Eval("TrangThai")) %>"><%# Eval("TrangThai") %></span>
                                    </td>
                                    <td>
                                        <asp:LinkButton ID="btnXem" runat="server" CssClass="btn btn-sm btn-outline-info me-1"
                                            CommandName="View" CommandArgument='<%# Eval("MaDH") %>' ToolTip="Xem chi tiết & In">
                                            <i class="fa-solid fa-eye"></i>
                                        </asp:LinkButton>

                                        <asp:LinkButton ID="btnDuyet" runat="server" CssClass="btn btn-sm btn-success me-1"
                                            CommandName="Approve" CommandArgument='<%# Eval("MaDH") %>' ToolTip="Duyệt đơn"
                                            Visible='<%# Eval("TrangThai").ToString() == "Chờ duyệt" %>'
                                            OnClientClick="return confirm('Xác nhận duyệt đơn hàng này? Trạng thái sẽ chuyển thành Đã Giao.');">
                                            <i class="fa-solid fa-check"></i>
                                        </asp:LinkButton>

                                        <asp:LinkButton ID="btnHuy" runat="server" CssClass="btn btn-sm btn-outline-danger"
                                            CommandName="Cancel" CommandArgument='<%# Eval("MaDH") %>' ToolTip="Hủy đơn"
                                            Visible='<%# Eval("TrangThai").ToString() == "Chờ duyệt" %>'
                                            OnClientClick="return confirm('Hủy đơn hàng này sẽ hoàn lại số lượng tồn kho. Bạn chắc chứ?');">
                                            <i class="fa-solid fa-xmark"></i>
                                        </asp:LinkButton>
                                    </td>
                                </tr>
                            </ItemTemplate>
                        </asp:Repeater>
                    </tbody>
                </table>
            </div>
            <asp:Label ID="lblThongBao" runat="server" Text="<div class='alert alert-info text-center my-3'>Không tìm thấy đơn hàng nào.</div>" Visible="false"></asp:Label>
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
                                <p><i class="fa-solid fa-envelope me-1"></i> Email: cskh@tannguyen.com</p>
                            </div>
                            <div class="col-5 text-end">
                                <h2 class="text-secondary">PHIẾU ĐƠN HÀNG</h2>
                                <p>Ngày: <asp:Label ID="lblModalNgayDat" runat="server" Font-Bold="true"></asp:Label></p>
                                <p>Trạng thái: <asp:Label ID="lblModalTrangThai" runat="server"></asp:Label></p>
                            </div>
                        </div>

                        <div class="bg-light p-3 rounded mb-3">
                            <h6 class="fw-bold border-bottom pb-2 mb-2">Thông tin khách hàng</h6>
                            <p class="mb-1"><b>Người nhận:</b> <asp:Label ID="lblModalNguoiNhan" runat="server"></asp:Label></p>
                            <p class="mb-1"><b>SĐT Liên hệ:</b> <asp:Label ID="lblModalSDT" runat="server"></asp:Label></p>
                            <p class="mb-0"><b>Địa chỉ giao:</b> <asp:Label ID="lblModalDiaChi" runat="server"></asp:Label></p>
                        </div>

                        <table class="table table-bordered">
                            <thead class="table-dark">
                                <tr>
                                    <th>STT</th>
                                    <th>Sản phẩm</th>
                                    <th class="text-center">SL</th>
                                    <th class="text-end">Đơn giá</th>
                                    <th class="text-end">Thành tiền</th>
                                </tr>
                            </thead>
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
                        <div class="invoice-total">
                            TỔNG CỘNG: <asp:Label ID="lblModalTongTien" runat="server"></asp:Label>
                        </div>
                        <div class="text-center mt-4 fst-italic text-muted small">
                            Cảm ơn quý khách đã tin tưởng Laptop Tân Nguyễn!
                        </div>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Đóng</button>
                    <button type="button" class="btn btn-primary" onclick="window.print()"><i class="fa-solid fa-print me-2"></i>In Đơn Hàng</button>
                </div>
            </div>
        </div>
    </div>
    
    <script>
        function openInvoiceModal() {
            var myModal = new bootstrap.Modal(document.getElementById('invoiceModal'));
            myModal.show();
        }
    </script>
</asp:Content>