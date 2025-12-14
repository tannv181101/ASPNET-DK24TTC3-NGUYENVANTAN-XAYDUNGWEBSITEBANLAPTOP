<%@ Page Title="Quản lý Sản phẩm" Language="C#" MasterPageFile="~/Admin/Admin.Master" AutoEventWireup="true" CodeBehind="QuanLySanPham.aspx.cs" Inherits="Laptop.Admin.QuanLySanPham" ValidateRequest="false" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <script src="https://cdn.ckeditor.com/4.22.1/full/ckeditor.js"></script>
    <style>
        .table-container { background: #fff; padding: 20px; border-radius: 8px; box-shadow: 0 4px 10px rgba(0,0,0,0.05); }
        .product-img { width: 60px; height: 60px; object-fit: cover; border-radius: 5px; border: 1px solid #ddd; }
        .filter-bar { background: #f8f9fa; padding: 15px; border-radius: 6px; margin-bottom: 20px; border: 1px solid #eee; }
        
        /* FIX LỖI POPUP CKEDITOR BỊ CHÌM HOẶC ĐƠ */
        .cke_dialog { z-index: 10000005 !important; }
        .cke_dialog_background_cover { z-index: 10000000 !important; }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <div class="container-fluid">
        
        <div class="filter-bar row g-3 align-items-end">
            <div class="col-md-3">
                <label class="form-label fw-bold">Hãng sản xuất:</label>
                <asp:DropDownList ID="ddlFilterHang" runat="server" CssClass="form-select"></asp:DropDownList>
            </div>
            
            <div class="col-md-2">
                <label class="form-label fw-bold">Tồn kho <=</label>
                <asp:TextBox ID="txtFilterTon" runat="server" CssClass="form-control" TextMode="Number" placeholder="VD: 5"></asp:TextBox>
            </div>

            <div class="col-md-4">
                <label class="form-label fw-bold">Tìm kiếm:</label>
                <div class="input-group">
                    <asp:TextBox ID="txtSearch" runat="server" CssClass="form-control" placeholder="Tên laptop..."></asp:TextBox>
                    <asp:Button ID="btnSearch" runat="server" Text="Lọc & Tìm" CssClass="btn btn-primary" OnClick="btnSearch_Click" />
                </div>
            </div>
            <div class="col-md-3 text-end">
                 <a href="QuanLyNhapHang.aspx" class="btn btn-info">
                    <i class="fa-solid fa-plus me-2"></i> Nhập SP Mới
                </a>
            </div>
        </div>

        <div class="table-container">
            <h5 class="fw-bold mb-3 text-secondary">Danh sách Laptop hiện có</h5>
            <div class="table-responsive">
                <table class="table table-hover align-middle mb-0">
                    <thead class="bg-light">
                        <tr>
                            <th>Hình</th>
                            <th>Tên Laptop</th>
                            <th>Hãng</th>
                            <th>Giá bán</th>
                            <th>Tồn kho</th>
                            <th class="text-end">Thao tác</th>
                        </tr>
                    </thead>
                    <tbody>
                        <asp:Repeater ID="rptLaptop" runat="server" OnItemCommand="rptLaptop_ItemCommand">
                            <ItemTemplate>
                                <tr>
                                    <td>
                                        <img src='<%# ResolveUrl("~/Images/Products/" + Eval("HinhAnh")) %>' class="product-img" onerror="this.src='/Images/no-image.png'" />
                                    </td>
                                    <td>
                                        <div class="fw-bold"><%# Eval("TenLap") %></div>
                                        <small class="text-muted">ID: #<%# Eval("MaLap") %></small>
                                    </td>
                                    <td><span class="badge bg-secondary"><%# Eval("TenHang") %></span></td>
                                    <td class="text-danger fw-bold"><%# Convert.ToDecimal(Eval("GiaBan")).ToString("N0") %></td>
                                    <td>
                                        <%# Convert.ToInt32(Eval("TonKho")) <= 5 ? "<span class='text-danger fw-bold'>"+Eval("TonKho")+"</span>" : Eval("TonKho") %>
                                    </td>
                                    <td class="text-end">
                                        <a href="QuanLyNhapHang.aspx?id=<%# Eval("MaLap") %>" class="btn btn-sm btn-success me-1" title="Nhập thêm hàng này">
                                            <i class="fa-solid fa-download"></i> Nhập
                                        </a>

                                        <asp:LinkButton ID="btnEdit" runat="server" CommandName="EditLap" CommandArgument='<%# Eval("MaLap") %>' 
                                            CssClass="btn btn-sm btn-outline-warning me-1" ToolTip="Cập nhật"><i class="fa-solid fa-pen-to-square"></i></asp:LinkButton>
                                        
                                        <asp:LinkButton ID="btnDelete" runat="server" CommandName="DeleteLap" CommandArgument='<%# Eval("MaLap") %>' 
                                            CssClass="btn btn-sm btn-outline-danger" ToolTip="Xóa"
                                            OnClientClick="return confirm('CẢNH BÁO: Xóa sản phẩm sẽ mất hết lịch sử!\nBạn có chắc chắn?');">
                                            <i class="fa-solid fa-trash-can"></i></asp:LinkButton>
                                    </td>
                                </tr>
                            </ItemTemplate>
                        </asp:Repeater>
                    </tbody>
                </table>
            </div>
             <asp:Label ID="lblThongBao" runat="server" Visible="false" CssClass="alert alert-info d-block mt-3 text-center">Không tìm thấy sản phẩm nào phù hợp.</asp:Label>
        </div>
    </div>

    <div class="modal fade" id="productModal" aria-hidden="true" data-bs-backdrop="static">
        <div class="modal-dialog modal-xl">
            <div class="modal-content">
                <div class="modal-header bg-warning text-dark">
                    <h5 class="modal-title">Cập nhật thông tin Laptop</h5>
                    <button type="button" class="btn-close" onclick="closeProductModal()"></button>
                </div>
                <div class="modal-body">
                    <asp:HiddenField ID="hfMaLap" runat="server" Value="0" />
                    <asp:HiddenField ID="hfOldImage" runat="server" />

                    <div class="row">
                        <div class="col-md-4 border-end">
                            <div class="mb-3">
                                <label class="form-label fw-bold">Tên Laptop (*)</label>
                                <asp:TextBox ID="txtTenLap" runat="server" CssClass="form-control"></asp:TextBox>
                            </div>
                            <div class="mb-3">
                                <label class="form-label fw-bold">Hãng sản xuất</label>
                                <asp:DropDownList ID="ddlHang" runat="server" CssClass="form-select"></asp:DropDownList>
                            </div>
                            <div class="row">
                                <div class="col-6 mb-3">
                                    <label class="form-label fw-bold">Giá bán</label>
                                    <asp:TextBox ID="txtGiaBan" runat="server" CssClass="form-control" TextMode="Number"></asp:TextBox>
                                </div>
                                <div class="col-6 mb-3">
                                    <label class="form-label fw-bold">Tồn kho</label>
                                    <asp:TextBox ID="txtTonKho" runat="server" CssClass="form-control bg-light" Enabled="false"></asp:TextBox>
                                </div>
                            </div>
                            
                            <div class="mb-3">
                                <label class="form-label fw-bold">Hình ảnh đại diện</label>
                                <asp:FileUpload ID="fuHinhAnh" runat="server" CssClass="form-control" />
                                <div class="mt-2 text-center">
                                    <asp:Image ID="imgPreview" runat="server" CssClass="product-img" Visible="false" style="width: 100px; height: 100px;" />
                                </div>
                            </div>

                            <div class="mb-3">
                                <label class="form-label fw-bold text-success"><i class="fa-solid fa-images me-1"></i>Thêm ảnh vào Album</label>
                                <asp:FileUpload ID="fuAlbum" runat="server" CssClass="form-control" AllowMultiple="true" />
                                <div class="form-text small">Giữ <b>Ctrl</b> để chọn nhiều file.</div>
                            </div>

                            <div class="mb-3">
                                <label class="form-label fw-bold">Cấu hình tóm tắt</label>
                                <asp:TextBox ID="txtCauHinh" runat="server" CssClass="form-control" TextMode="MultiLine" Rows="4"></asp:TextBox>
                            </div>
                        </div>

                        <div class="col-md-8">
                            <label class="form-label fw-bold">Mô tả chi tiết</label>
                            <p class="small text-muted mb-1"><i class="fa-solid fa-circle-info"></i> Upload ảnh trực tiếp và chỉnh kích thước thoải mái.</p>
                            <asp:TextBox ID="txtMoTa" runat="server" TextMode="MultiLine" CssClass="form-control"></asp:TextBox>
                            
                            <script>
                                document.addEventListener("DOMContentLoaded", function () {
                                    if (document.getElementById('<%= txtMoTa.ClientID %>')) {
                                        CKEDITOR.replace('<%= txtMoTa.ClientID %>', {
                                            filebrowserUploadUrl: '/Admin/UploadHandler.ashx',
                                            uploadUrl: '/Admin/UploadHandler.ashx',
                                            allowedContent: true,
                                            baseFloatZIndex: 10000000, // Đẩy lên cao để không bị chìm dưới modal
                                            height: 400,
                                            toolbar: [
                                                { name: 'document', items: ['Source', '-', 'NewPage', 'Preview'] },
                                                { name: 'clipboard', items: ['Cut', 'Copy', 'Paste', '-', 'Undo', 'Redo'] },
                                                { name: 'basicstyles', items: ['Bold', 'Italic', 'Underline', 'Strike'] },
                                                { name: 'paragraph', items: ['NumberedList', 'BulletedList', '-', 'JustifyLeft', 'JustifyCenter', 'JustifyRight', 'JustifyBlock'] },
                                                { name: 'insert', items: ['Image', 'Table', 'HorizontalRule', 'SpecialChar'] },
                                                { name: 'styles', items: ['Format', 'Font', 'FontSize'] },
                                                { name: 'colors', items: ['TextColor', 'BGColor'] },
                                                { name: 'tools', items: ['Maximize'] }
                                            ]
                                        });
                                    }
                                });
                            </script>
                        </div>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" onclick="closeProductModal()">Hủy</button>
                    <asp:Button ID="btnSave" runat="server" Text="Lưu thay đổi" CssClass="btn btn-warning fw-bold" OnClick="btnSave_Click" />
                </div>
            </div>
        </div>
    </div>

    <script>
        function showModalServer() {
            var modalElement = document.getElementById('productModal');
            if (modalElement) {
                var myModal = bootstrap.Modal.getInstance(modalElement);
                if (!myModal) {
                    myModal = new bootstrap.Modal(modalElement, {
                        backdrop: 'static',
                        keyboard: false,
                        focus: false // QUAN TRỌNG
                    });
                }
                myModal.show();
            }
        }

        function closeProductModal() {
            var modalElement = document.getElementById('productModal');
            var myModal = bootstrap.Modal.getInstance(modalElement);
            if (myModal) myModal.hide();

            document.querySelectorAll('.modal-backdrop').forEach(el => el.remove());
            document.body.classList.remove('modal-open');
        }
    </script>
</asp:Content>