<%@ Page Title="Quản lý Tài khoản" Language="C#" MasterPageFile="~/Admin/Admin.Master" AutoEventWireup="true" CodeBehind="QuanLyTaiKhoan.aspx.cs" Inherits="Laptop.Admin.QuanLyTaiKhoan" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <style>
        .table-container { background: #fff; padding: 20px; border-radius: 8px; box-shadow: 0 4px 10px rgba(0,0,0,0.05); }
        .filter-bar { background: #f8f9fa; padding: 15px; border-radius: 6px; margin-bottom: 20px; border: 1px solid #eee; }
        
        /* Badge vai trò */
        .badge-role { font-size: 0.8rem; padding: 5px 10px; border-radius: 4px; display: inline-block; min-width: 60px; text-align: center; }
        .role-admin { background-color: #dc3545; color: white; } /* Đỏ */
        .role-khach { background-color: #0d6efd; color: white; } /* Xanh */
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <div class="container-fluid">
        
        <div class="filter-bar row g-3 align-items-end">
            <div class="col-md-3">
                <label class="form-label fw-bold">Vai trò:</label>
                <asp:DropDownList ID="ddlFilterRole" runat="server" CssClass="form-select">
                    <asp:ListItem Value="All" Text="-- Tất cả --"></asp:ListItem>
                    <asp:ListItem Value="Admin" Text="Quản trị viên (Admin)"></asp:ListItem>
                    <asp:ListItem Value="Khach" Text="Khách hàng"></asp:ListItem>
                </asp:DropDownList>
            </div>
            <div class="col-md-4">
                <label class="form-label fw-bold">Tìm kiếm:</label>
                <div class="input-group">
                    <asp:TextBox ID="txtSearch" runat="server" CssClass="form-control" placeholder="Tên hoặc Email..."></asp:TextBox>
                    <asp:Button ID="btnSearch" runat="server" Text="Tìm kiếm" CssClass="btn btn-primary" OnClick="btnSearch_Click" />
                </div>
            </div>
            <div class="col-md-5 text-end">
                <button type="button" class="btn btn-success" onclick="openModal('Thêm tài khoản mới')">
                    <i class="fa-solid fa-user-plus me-2"></i> Thêm Tài Khoản
                </button>
                <asp:Button ID="btnOpenModalHidden" runat="server" OnClick="btnOpenModal_Click" style="display:none;" />
            </div>
        </div>

        <div class="table-container">
            <h5 class="fw-bold mb-3 text-secondary">Danh sách Người dùng</h5>
            
            <div class="table-responsive">
                <table class="table table-hover align-middle mb-0">
                    <thead class="bg-light">
                        <tr>
                            <th>ID</th>
                            <th>Họ Tên</th>
                            <th>Liên hệ</th>
                            <th>Địa chỉ</th>
                            <th>Vai trò</th>
                            <th>Thao tác</th>
                        </tr>
                    </thead>
                    <tbody>
                        <asp:Repeater ID="rptTaiKhoan" runat="server" OnItemCommand="rptTaiKhoan_ItemCommand">
                            <ItemTemplate>
                                <tr>
                                    <td class="fw-bold text-muted">#<%# Eval("MaTK") %></td>
                                    <td>
                                        <div class="fw-bold"><%# Eval("HoTen") %></div>
                                        <small class="text-muted">Tham gia: <%# Eval("NgayTao", "{0:dd/MM/yyyy}") %></small>
                                    </td>
                                    <td>
                                        <%# string.IsNullOrEmpty(Eval("Email").ToString()) ? "<span class='text-muted fst-italic'>Không có Email</span>" : "<div><i class='fa-solid fa-envelope me-1 text-primary'></i> " + Eval("Email") + "</div>" %>
                                        <%# string.IsNullOrEmpty(Eval("SoDienThoai").ToString()) ? "" : "<div><i class='fa-solid fa-phone me-1 text-success'></i> " + Eval("SoDienThoai") + "</div>" %>
                                    </td>
                                    <td><%# Eval("DiaChi") %></td>
                                    <td>
                                        <span class='badge-role <%# Eval("VaiTro").ToString() == "Admin" ? "role-admin" : "role-khach" %>'>
                                            <%# Eval("VaiTro") %>
                                        </span>
                                    </td>
                                    <td>
                                        <asp:LinkButton ID="btnEdit" runat="server" CommandName="EditUser" CommandArgument='<%# Eval("MaTK") %>' 
                                            CssClass="btn btn-sm btn-outline-warning me-1" ToolTip="Sửa thông tin">
                                            <i class="fa-solid fa-pen-to-square"></i>
                                        </asp:LinkButton>

                                        <asp:LinkButton ID="btnDelete" runat="server" CommandName="DeleteUser" CommandArgument='<%# Eval("MaTK") %>' 
                                            CssClass="btn btn-sm btn-outline-danger" ToolTip="Xóa tài khoản"
                                            OnClientClick="return confirm('CẢNH BÁO: Xóa tài khoản này sẽ xóa TOÀN BỘ ĐƠN HÀNG liên quan!\nBạn có chắc chắn muốn xóa không?');">
                                            <i class="fa-solid fa-trash-can"></i>
                                        </asp:LinkButton>
                                    </td>
                                </tr>
                            </ItemTemplate>
                        </asp:Repeater>
                    </tbody>
                </table>
            </div>
            <asp:Label ID="lblThongBao" runat="server" Visible="false" CssClass="alert alert-info d-block mt-3 text-center">Không tìm thấy tài khoản nào.</asp:Label>
        </div>
    </div>

    <div class="modal fade" id="userModal" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header bg-primary text-white">
                    <h5 class="modal-title" id="userModalTitle">Thông tin tài khoản</h5>
                    <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body">
                    <asp:HiddenField ID="hfMaTK" runat="server" Value="0" />
                    
                    <div class="mb-3">
                        <label class="form-label">Họ tên (*)</label>
                        <asp:TextBox ID="txtHoTen" runat="server" CssClass="form-control" placeholder="Nhập họ tên"></asp:TextBox>
                        <asp:RequiredFieldValidator ID="rfvTen" runat="server" ControlToValidate="txtHoTen" ErrorMessage="Họ tên là bắt buộc" CssClass="text-danger small" ValidationGroup="UserGroup" Display="Dynamic"></asp:RequiredFieldValidator>
                    </div>

                    <div class="mb-3">
                        <label class="form-label">Email (Tùy chọn)</label>
                        <asp:TextBox ID="txtEmail" runat="server" CssClass="form-control" placeholder="example@gmail.com"></asp:TextBox>
                    </div>

                    <div class="mb-3">
                        <label class="form-label">Mật khẩu</label>
                        <asp:TextBox ID="txtMatKhau" runat="server" CssClass="form-control" TextMode="Password" placeholder="Để trống = Mặc định '123' (Khi tạo) hoặc Giữ nguyên (Khi sửa)"></asp:TextBox>
                        <div class="form-text small text-muted">Nếu tạo mới mà không nhập, mật khẩu sẽ là <b>123</b>.</div>
                    </div>

                    <div class="row">
                        <div class="col-md-6 mb-3">
                            <label class="form-label">Số điện thoại</label>
                            <asp:TextBox ID="txtSDT" runat="server" CssClass="form-control" placeholder="09xxxx"></asp:TextBox>
                        </div>
                        <div class="col-md-6 mb-3">
                            <label class="form-label">Vai trò (*)</label>
                            <asp:DropDownList ID="ddlVaiTro" runat="server" CssClass="form-select">
                                <asp:ListItem Value="Khach" Text="Khách hàng"></asp:ListItem>
                                <asp:ListItem Value="Admin" Text="Quản trị viên"></asp:ListItem>
                            </asp:DropDownList>
                        </div>
                    </div>

                    <div class="mb-3">
                        <label class="form-label">Địa chỉ</label>
                        <asp:TextBox ID="txtDiaChi" runat="server" CssClass="form-control" TextMode="MultiLine" Rows="2"></asp:TextBox>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Hủy</button>
                    <asp:Button ID="btnSave" runat="server" Text="Lưu thông tin" CssClass="btn btn-primary" OnClick="btnSave_Click" ValidationGroup="UserGroup" />
                </div>
            </div>
        </div>
    </div>

    <script>
        // Hàm mở modal dùng cho cả nút Thêm mới (JS gọi) và Nút Sửa (Server gọi)
        function openModal(title) {
            document.getElementById('userModalTitle').innerText = title;
            // Nếu là nút Thêm mới gọi, cần clear form (Sử dụng ID của server control rendered)
            if (title === 'Thêm tài khoản mới') {
                // Gọi nút ẩn phía server để reset form
                document.getElementById('<%= btnOpenModalHidden.ClientID %>').click();
            } else {
                new bootstrap.Modal(document.getElementById('userModal')).show();
            }
        }

        function showModalServer() {
            new bootstrap.Modal(document.getElementById('userModal')).show();
        }
    </script>
</asp:Content>