<%@ Page Title="Quản lý Nhập hàng" Language="C#" MasterPageFile="~/Admin/Admin.Master" AutoEventWireup="true" CodeBehind="QuanLyNhapHang.aspx.cs" Inherits="Laptop.Admin.QuanLyNhapHang" ValidateRequest="false" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <script src="https://cdn.ckeditor.com/4.22.1/full/ckeditor.js"></script>
    <style>
        .import-section { background: #fff; padding: 20px; border-radius: 8px; box-shadow: 0 4px 10px rgba(0,0,0,0.05); }
        .temp-list { background: #f8f9fa; min-height: 200px; border: 1px dashed #ccc; border-radius: 5px; padding: 10px; }
        .total-price { font-size: 1.5rem; font-weight: 800; color: #dc3545; }
        .modal-xl { max-width: 1140px; }

        /* --- STYLE QUAN TRỌNG TỪ FILE THAM KHẢO --- */
        /* Đẩy hộp thoại CKEditor lên mức cao nhất (trên cả Modal Bootstrap) */
        .cke_dialog {
            z-index: 10000005 !important;
        }
        /* Đẩy lớp mờ nền của CKEditor lên theo */
        .cke_dialog_background_cover {
            z-index: 10000000 !important;
        }
    </style>

    <script>
        function openProductModal() {
            var modalElement = document.getElementById('productModal');
            if (modalElement) {
                // Kiểm tra xem instance đã tồn tại chưa
                var myModal = bootstrap.Modal.getInstance(modalElement);
                if (!myModal) {
                    myModal = new bootstrap.Modal(modalElement, {
                        backdrop: 'static',
                        keyboard: false,

                        // --- QUAN TRỌNG NHẤT: ---
                        // focus: false giúp CKEditor nhận được con trỏ chuột để nhập số liệu
                        focus: false
                    });
                }
                myModal.show();
            }
        }

        function closeProductModal() {
            var modalElement = document.getElementById('productModal');
            var myModal = bootstrap.Modal.getInstance(modalElement);
            if (myModal) myModal.hide();

            // Dọn dẹp backdrop nếu bị kẹt (Fix thêm cho chắc chắn)
            document.querySelectorAll('.modal-backdrop').forEach(el => el.remove());
            document.body.classList.remove('modal-open');
        }

        function refreshAndCloseModal() {
            closeProductModal();
            document.getElementById('<%= btnRefreshDropdown.ClientID %>').click();
        }
    </script>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <div class="container-fluid">
        <div class="row">
            <div class="col-lg-7">
                <div class="import-section mb-4">
                    <h5 class="fw-bold text-primary mb-3"><i class="fa-solid fa-cart-plus me-2"></i>Tạo Phiếu Nhập Kho</h5>
                    
                    <div class="row mb-3">
                        <div class="col-md-6">
                            <label class="form-label fw-bold">Nhà cung cấp (*)</label>
                            <div class="input-group">
                                <asp:DropDownList ID="ddlNCC" runat="server" CssClass="form-select"></asp:DropDownList>
                            </div>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label fw-bold">Ngày nhập</label>
                            <asp:TextBox ID="txtNgayNhap" runat="server" CssClass="form-control" TextMode="Date"></asp:TextBox>
                        </div>
                    </div>
                    <hr />
                    <div class="card bg-light border-0 mb-3">
                        <div class="card-body">
                            <h6 class="card-title fw-bold">Chi tiết nhập</h6>
                            <div class="row g-2">
                                <div class="col-md-9 mb-2">
                                    <label class="small">Chọn Laptop</label>
                                    <div class="input-group">
                                        <asp:DropDownList ID="ddlLaptop" runat="server" CssClass="form-select"></asp:DropDownList>
                                        <button class="btn btn-primary" type="button" onclick="openProductModal()"><i class="fa-solid fa-plus"></i> Mới</button>
                                    </div>
                                </div>
                                <div class="col-md-4">
                                    <label class="small">Giá nhập</label>
                                    <asp:TextBox ID="txtGiaNhap" runat="server" CssClass="form-control" TextMode="Number"></asp:TextBox>
                                </div>
                                <div class="col-md-4">
                                    <label class="small">Số lượng</label>
                                    <asp:TextBox ID="txtSoLuong" runat="server" CssClass="form-control" TextMode="Number" Text="1"></asp:TextBox>
                                </div>
                                <div class="col-md-4 d-flex align-items-end">
                                    <asp:Button ID="btnThemSP" runat="server" Text="Thêm vào phiếu" CssClass="btn btn-warning w-100" OnClick="btnThemSP_Click" />
                                </div>
                            </div>
                            <div class="mt-2 text-danger small">
                                <asp:Literal ID="litError" runat="server"></asp:Literal>
                            </div>
                        </div>
                    </div>
                    
                    <div class="temp-list mb-3">
                        <asp:GridView ID="gvChiTietTam" runat="server" AutoGenerateColumns="False" CssClass="table table-sm table-bordered bg-white mb-0" OnRowCommand="gvChiTietTam_RowCommand">
                            <Columns>
                                <asp:BoundField DataField="MaLap" HeaderText="ID" />
                                <asp:BoundField DataField="TenLap" HeaderText="Tên Laptop" />
                                <asp:BoundField DataField="GiaNhap" HeaderText="Giá nhập" DataFormatString="{0:N0}" />
                                <asp:BoundField DataField="SoLuong" HeaderText="SL" />
                                <asp:BoundField DataField="ThanhTien" HeaderText="Thành tiền" DataFormatString="{0:N0}" />
                                <asp:TemplateField>
                                    <ItemTemplate>
                                        <asp:LinkButton ID="btnXoaTam" runat="server" CommandName="Xoa" CommandArgument='<%# Container.DataItemIndex %>' CssClass="text-danger"><i class="fa-solid fa-trash"></i></asp:LinkButton>
                                    </ItemTemplate>
                                </asp:TemplateField>
                            </Columns>
                        </asp:GridView>
                        <div class="text-center p-3" id="divEmpty" runat="server">
                            <span class="text-muted fst-italic">Chưa có sản phẩm nào trong phiếu nhập.</span>
                        </div>
                    </div>
                    <div class="d-flex justify-content-between align-items-center">
                        <div>
                            Tổng tiền phiếu: <span class="total-price"><asp:Label ID="lblTongTienPhieu" runat="server">0</asp:Label> ₫</span>
                        </div>
                        <asp:Button ID="btnLuuPhieu" runat="server" Text="HOÀN TẤT NHẬP KHO" CssClass="btn btn-success fw-bold px-4 py-2" OnClick="btnLuuPhieu_Click" OnClientClick="return confirm('Xác nhận lưu phiếu nhập?');" />
                    </div>
                </div>
            </div>

            <div class="col-lg-5">
                <div class="import-section">
                    <h5 class="fw-bold text-secondary mb-3"><i class="fa-solid fa-clock-rotate-left me-2"></i>Lịch sử Nhập hàng</h5>
                    <div class="table-responsive">
                        <asp:GridView ID="gvLichSuNhap" runat="server" AutoGenerateColumns="False" CssClass="table table-hover" AllowPaging="True" PageSize="10" OnPageIndexChanging="gvLichSuNhap_PageIndexChanging">
                            <Columns>
                                <asp:BoundField DataField="MaPN" HeaderText="#" />
                                <asp:BoundField DataField="TenNCC" HeaderText="Nhà cung cấp" />
                                <asp:BoundField DataField="NgayNhap" HeaderText="Ngày" DataFormatString="{0:dd/MM/yyyy}" />
                                <asp:BoundField DataField="TongTien" HeaderText="Tổng tiền" DataFormatString="{0:N0}" ItemStyle-CssClass="fw-bold text-danger" />
                            </Columns>
                        </asp:GridView>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <div class="modal fade" id="productModal" aria-hidden="true">
        <div class="modal-dialog modal-xl">
            <div class="modal-content">
                <div class="modal-header bg-primary text-white">
                    <h5 class="modal-title">Thêm Laptop Mới</h5>
                    <button type="button" class="btn-close btn-close-white" onclick="closeProductModal()"></button>
                </div>
                <div class="modal-body">
                    <div class="row">
                        <div class="col-md-4 border-end">
                            <div class="mb-3">
                                <label class="form-label fw-bold">Tên Laptop (*)</label>
                                <asp:TextBox ID="txtTenLapMoi" runat="server" CssClass="form-control"></asp:TextBox>
                                <asp:RequiredFieldValidator ID="rfvTenMoi" runat="server" ControlToValidate="txtTenLapMoi" ErrorMessage="Nhập tên máy" CssClass="text-danger small" ValidationGroup="NewProductGroup" Display="Dynamic"></asp:RequiredFieldValidator>
                            </div>
                            <div class="mb-3">
                                <label class="form-label fw-bold">Hãng sản xuất (*)</label>
                                <asp:DropDownList ID="ddlHangMoi" runat="server" CssClass="form-select"></asp:DropDownList>
                            </div>
                            <div class="mb-3">
                                <label class="form-label fw-bold">Giá bán đề xuất</label>
                                <asp:TextBox ID="txtGiaBanMoi" runat="server" CssClass="form-control" TextMode="Number" Text="0"></asp:TextBox>
                            </div>
                            <div class="mb-3">
                                <label class="form-label fw-bold">Hình ảnh đại diện</label>
                                <asp:FileUpload ID="fuHinhAnhMoi" runat="server" CssClass="form-control" />
                                <div class="form-text small">Lưu vào: <code>/Images/Products/</code></div>
                            </div>
                            <div class="mb-3">
                                <label class="form-label fw-bold text-success"><i class="fa-solid fa-images me-1"></i>Album ảnh phụ</label>
                                <asp:FileUpload ID="fuAlbum" runat="server" CssClass="form-control" AllowMultiple="true" />
                                <div class="form-text small">Giữ phím <b>Ctrl</b> để chọn nhiều ảnh.</div>
                            </div>
                            <div class="mb-3">
                                <label class="form-label fw-bold">Cấu hình tóm tắt</label>
                                <asp:TextBox ID="txtCauHinhMoi" runat="server" CssClass="form-control" TextMode="MultiLine" Rows="4"></asp:TextBox>
                            </div>
                        </div>

                        <div class="col-md-8">
                            <label class="form-label fw-bold">Mô tả chi tiết</label>
                            <p class="small text-muted mb-1"><i class="fa-solid fa-circle-info"></i> Upload ảnh, nhập kích thước Width/Height thoải mái.</p>
                            
                            <asp:TextBox ID="txtMoTaMoi" runat="server" TextMode="MultiLine" CssClass="form-control"></asp:TextBox>
                            
                            <script>
                                document.addEventListener("DOMContentLoaded", function () {
                                    if (document.getElementById('<%= txtMoTaMoi.ClientID %>')) {
                                        CKEDITOR.replace('<%= txtMoTaMoi.ClientID %>', {
                                            // 1. Đường dẫn Upload (Trỏ về file Handler của bạn)
                                            filebrowserUploadUrl: '/Admin/UploadHandler.ashx',
                                            uploadUrl: '/Admin/UploadHandler.ashx',

                                            // 2. Cho phép mọi Style để lưu Width/Height
                                            allowedContent: true,
                                            pasteFilter: null,

                                            // 3. QUAN TRỌNG: Z-Index cơ sở cực cao để popup không bị chìm
                                            baseFloatZIndex: 10000000,

                                            height: 350,

                                            // 4. Thanh công cụ đầy đủ như file tham khảo
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
                    
                    <div class="text-center mt-3">
                        <asp:Label ID="lblThongBaoThemSP" runat="server" CssClass="text-danger small"></asp:Label>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" onclick="closeProductModal()">Đóng</button>
                    <asp:Button ID="btnLuuSPMoi" runat="server" Text="Lưu Sản Phẩm & Chọn Nhập" CssClass="btn btn-primary fw-bold" OnClick="btnLuuSPMoi_Click" ValidationGroup="NewProductGroup" />
                </div>
            </div>
        </div>
    </div>

    <asp:Button ID="btnRefreshDropdown" runat="server" OnClick="btnRefreshDropdown_Click" style="display:none;" />
</asp:Content>