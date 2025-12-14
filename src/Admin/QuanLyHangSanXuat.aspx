<%@ Page Title="Quản lý Hãng sản xuất" Language="C#" MasterPageFile="~/Admin/Admin.Master" AutoEventWireup="true" CodeBehind="QuanLyHangSanXuat.aspx.cs" Inherits="Laptop.Admin.QuanLyHangSanXuat" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <style>
        .table-container { background: #fff; padding: 20px; border-radius: 8px; box-shadow: 0 4px 10px rgba(0,0,0,0.05); }
        .filter-bar { background: #f8f9fa; padding: 15px; border-radius: 6px; margin-bottom: 20px; border: 1px solid #eee; }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <div class="container-fluid">
        
        <div class="filter-bar row g-3 align-items-center">
            <div class="col-md-6">
                <div class="input-group">
                    <span class="input-group-text bg-white"><i class="fa-solid fa-magnifying-glass"></i></span>
                    <asp:TextBox ID="txtSearch" runat="server" CssClass="form-control" placeholder="Tìm kiếm tên hãng..."></asp:TextBox>
                    <asp:Button ID="btnSearch" runat="server" Text="Tìm kiếm" CssClass="btn btn-primary" OnClick="btnSearch_Click" />
                </div>
            </div>
            <div class="col-md-6 text-end">
                <button type="button" class="btn btn-success" onclick="openModal('Thêm hãng mới')">
                    <i class="fa-solid fa-plus me-2"></i> Thêm Hãng
                </button>
                <asp:Button ID="btnOpenModalHidden" runat="server" OnClick="btnOpenModal_Click" style="display:none;" />
            </div>
        </div>

        <div class="table-container">
            <h5 class="fw-bold mb-3 text-secondary">Danh sách Hãng sản xuất</h5>
            
            <div class="table-responsive">
                <table class="table table-hover align-middle mb-0">
                    <thead class="bg-light">
                        <tr>
                            <th style="width: 10%;">ID</th>
                            <th style="width: 30%;">Tên Hãng</th>
                            <th style="width: 40%;">Mô tả</th>
                            <th style="width: 20%;" class="text-end">Thao tác</th>
                        </tr>
                    </thead>
                    <tbody>
                        <asp:Repeater ID="rptHang" runat="server" OnItemCommand="rptHang_ItemCommand">
                            <ItemTemplate>
                                <tr>
                                    <td class="fw-bold text-muted">#<%# Eval("MaHang") %></td>
                                    <td class="fw-bold text-primary"><%# Eval("TenHang") %></td>
                                    <td class="text-muted"><%# Eval("MoTa") %></td>
                                    <td class="text-end">
                                        <asp:LinkButton ID="btnEdit" runat="server" CommandName="EditHang" CommandArgument='<%# Eval("MaHang") %>' 
                                            CssClass="btn btn-sm btn-outline-warning me-1" ToolTip="Sửa">
                                            <i class="fa-solid fa-pen-to-square"></i>
                                        </asp:LinkButton>

                                        <asp:LinkButton ID="btnDelete" runat="server" CommandName="DeleteHang" CommandArgument='<%# Eval("MaHang") %>' 
                                            CssClass="btn btn-sm btn-outline-danger" ToolTip="Xóa"
                                            OnClientClick="return confirm('NGUY HIỂM: Xóa hãng này sẽ XÓA SẠCH TẤT CẢ LAPTOP thuộc hãng này!\nBạn có chắc chắn muốn tiếp tục không?');">
                                            <i class="fa-solid fa-trash-can"></i>
                                        </asp:LinkButton>
                                    </td>
                                </tr>
                            </ItemTemplate>
                        </asp:Repeater>
                    </tbody>
                </table>
            </div>
            <asp:Label ID="lblThongBao" runat="server" Visible="false" CssClass="alert alert-info d-block mt-3 text-center">Không tìm thấy hãng nào.</asp:Label>
        </div>
    </div>

    <div class="modal fade" id="brandModal" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header bg-success text-white">
                    <h5 class="modal-title" id="brandModalTitle">Thông tin hãng</h5>
                    <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body">
                    <asp:HiddenField ID="hfMaHang" runat="server" Value="0" />
                    
                    <div class="mb-3">
                        <label class="form-label">Tên hãng (*)</label>
                        <asp:TextBox ID="txtTenHang" runat="server" CssClass="form-control" placeholder="Ví dụ: Dell, Asus..."></asp:TextBox>
                        <asp:RequiredFieldValidator ID="rfvTen" runat="server" ControlToValidate="txtTenHang" ErrorMessage="Vui lòng nhập tên hãng" CssClass="text-danger small" ValidationGroup="HangGroup" Display="Dynamic"></asp:RequiredFieldValidator>
                    </div>

                    <div class="mb-3">
                        <label class="form-label">Mô tả</label>
                        <asp:TextBox ID="txtMoTa" runat="server" CssClass="form-control" TextMode="MultiLine" Rows="3" placeholder="Mô tả ngắn về thương hiệu..."></asp:TextBox>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Hủy</button>
                    <asp:Button ID="btnSave" runat="server" Text="Lưu lại" CssClass="btn btn-success" OnClick="btnSave_Click" ValidationGroup="HangGroup" />
                </div>
            </div>
        </div>
    </div>

    <script>
        function openModal(title) {
            document.getElementById('brandModalTitle').innerText = title;
            if (title === 'Thêm hãng mới') {
                document.getElementById('<%= btnOpenModalHidden.ClientID %>').click();
            } else {
                new bootstrap.Modal(document.getElementById('brandModal')).show();
            }
        }
        function showModalServer() {
            new bootstrap.Modal(document.getElementById('brandModal')).show();
        }
    </script>
</asp:Content>