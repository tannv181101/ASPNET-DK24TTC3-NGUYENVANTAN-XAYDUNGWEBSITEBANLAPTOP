<%@ Page Title="Trang chủ" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Default.aspx.cs" Inherits="Laptop.Default" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <style>
        /* ... CSS CŨ GIỮ NGUYÊN ... */
        /* Thêm CSS cho link để khi hover vào ảnh/tên vẫn đẹp */
        .product-card a { text-decoration: none; color: inherit; display: block; }
        
        /* Menu Hãng */
        .brand-list { padding: 5px; }
        .list-group-item { 
            border: none; padding: 12px 15px; font-weight: 500; color: #555; 
            border-radius: 6px !important; margin-bottom: 4px; display: flex; justify-content: space-between; align-items: center;
        }
        .list-group-item:hover { background-color: #fff3e0; color: #ff4500; font-weight: 600; padding-left: 20px; transition: 0.2s; }
        .list-group-item.active { background-color: #ff4500; color: #fff; font-weight: 600; box-shadow: 0 4px 10px rgba(255, 69, 0, 0.3); }
        .list-group-item i { font-size: 0.8rem; }

        /* Responsive Mobile */
        @media (max-width: 991.98px) {
            .brand-header { display: none !important; }
            .brand-card { border: none !important; background: transparent !important; margin-bottom: 5px !important; }
            .brand-list {
                display: flex; flex-direction: row; flex-wrap: nowrap;
                overflow-x: auto; padding-bottom: 10px; gap: 10px;
                -webkit-overflow-scrolling: touch; scrollbar-width: none;
            }
            .brand-list::-webkit-scrollbar { display: none; }
            .list-group-item {
                flex: 0 0 auto; width: auto; border: 1px solid #ddd;
                border-radius: 20px !important; padding: 6px 18px; background: #fff;
                white-space: nowrap; margin: 0; font-size: 0.9rem; justify-content: center;
            }
            .list-group-item:hover { padding-left: 18px; background: #fff; color: #ff4500; border-color: #ff4500; }
            .list-group-item.active { background-color: #ff4500; border-color: #ff4500; color: #fff; }
            .list-group-item i { display: none; }
        }

        /* Banner Màu Cam */
        .hero-banner { 
            background: linear-gradient(135deg, #ff6600 0%, #ff4500 100%); 
            color: white; padding: 40px 0; margin-bottom: 30px; border-radius: 0 0 20px 20px; 
        }

        /* Sản phẩm */
        .product-card { background: #fff; border: 1px solid #f0f0f0; border-radius: 8px; transition: 0.3s; height: 100%; position: relative; overflow: hidden; }
        .product-card:hover { transform: translateY(-5px); box-shadow: 0 10px 20px rgba(0,0,0,0.08); border-color: #ff4500; }
        
        .img-wrap {
            height: 200px; /* Chiều cao cố định */
            min-height: 200px; /* Bắt buộc chiếm chỗ dù không có ảnh */
            padding: 15px;
            display: flex;
            align-items: center;
            justify-content: center;
            background-color: #f8f9fa; /* Màu nền xám nhẹ giữ chỗ khi ảnh chưa hiện */
        }
        .img-wrap img { max-height: 100%; max-width: 100%; object-fit: contain; }
        
        .card-body { padding: 12px; }
        .prod-title { font-size: 0.95rem; font-weight: 700; color: #333; margin: 5px 0; height: 2.6em; overflow: hidden; line-height: 1.3; }
        .prod-title a { text-decoration: none; color: inherit; }
        .prod-title a:hover { color: #ff4500; }
        .specs { font-size: 0.75rem; color: #666; background: #f8f9fa; padding: 4px; border-radius: 4px; margin-bottom: 8px; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
        .price { color: #d70018; font-size: 1.1rem; font-weight: 800; }
        
        .btn-buy { width: 100%; border: 1px solid #ff4500; background: #fff; color: #ff4500; padding: 6px; border-radius: 4px; font-weight: 600; margin-top: 10px; transition: 0.2s; }
        .btn-buy:hover { background: #ff4500; color: #fff; }
        .stock-tag { position: absolute; top: 10px; right: 10px; background: #e7f1ff; color: #0d6efd; font-size: 0.65rem; padding: 3px 8px; border-radius: 4px; font-weight: 700; }
        .stock-tag.out { background: #ffebeb; color: #dc3545; }
        .btn-disabled { width: 100%; background: #e9ecef; color: #999; border: 1px solid #dee2e6; padding: 6px; border-radius: 4px; font-weight: 600; margin-top: 10px; cursor: not-allowed; text-align: center; display: block; }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    
    <div class="hero-banner">
        <div class="container">
            <div class="row align-items-center">
                <div class="col-lg-7">
                    <h2 class="fw-bold mb-2">Kho Laptop Tân Nguyễn</h2>
                    <p class="lead mb-0 opacity-75">Chất lượng thật - Giá trị thật - Bảo hành uy tín.</p>
                </div>
                <div class="col-lg-5 d-none d-lg-block text-center">
                    <i class="fa-brands fa-apple fa-4x me-4 text-white opacity-50"></i>
                    <i class="fa-brands fa-microsoft fa-4x me-4 text-white opacity-50"></i>
                    <i class="fa-brands fa-hp fa-4x me-4 text-white opacity-50"></i>
                    <i class="fa-brands fa-dell fa-4x text-white opacity-50"></i>
                </div>
            </div>
        </div>
    </div>

    <div class="container mb-5">
        <div class="row">
            
            <div class="col-lg-3 mb-4">
                <div class="card shadow-sm border-0 h-100 brand-card">
                    <div class="card-header bg-white fw-bold text-uppercase py-3 border-bottom brand-header">
                        <i class="fa-solid fa-list me-2"></i> Thương hiệu
                    </div>
                    
                    <div class="list-group list-group-flush brand-list">
                        <a href="Default.aspx" class='list-group-item list-group-item-action <%= Request.QueryString["hang"] == null ? "active" : "" %>'>
                            <span>Tất cả</span>
                        </a>
                        <asp:Repeater ID="rptMenuHang" runat="server">
                            <ItemTemplate>
                                <a href='Default.aspx?hang=<%# Eval("MaHang") %>' class='list-group-item list-group-item-action <%# CheckActive(Eval("MaHang")) %>'>
                                    <span><%# Eval("TenHang") %></span>
                                    <i class="fa-solid fa-chevron-right"></i>
                                </a>
                            </ItemTemplate>
                        </asp:Repeater>
                    </div>
                </div>
            </div>

            <div class="col-lg-9">
                <div class="d-flex justify-content-between align-items-center mb-4 pb-2 border-bottom">
                    <h5 class="fw-bold m-0"><asp:Label ID="lblTieuDe" runat="server" Text="Tất cả sản phẩm"></asp:Label></h5>
                    <small class="text-muted"><asp:Label ID="lblSoLuong" runat="server" Text="0"></asp:Label> sản phẩm</small>
                </div>

                <div class="row row-cols-1 row-cols-sm-2 row-cols-md-3 g-3">
                    <asp:Repeater ID="rptSanPham" runat="server">
                        <ItemTemplate>
                            <div class="col">
                                <div class="product-card">
                                    <span class='stock-tag <%# Convert.ToInt32(Eval("TonKho")) > 0 ? "" : "out" %>'>
                                        <%# Convert.ToInt32(Eval("TonKho")) > 0 ? "Sẵn hàng" : "Hết hàng" %>
                                    </span>
                                    
                                    <div class="img-wrap">
                                        <a href='<%# ResolveUrl("~/ChiTietSanPham.aspx?id=" + Eval("MaLap")) %>'>
                                            <img src='<%# ResolveUrl("~/Images/Products/" + Eval("HinhAnh")) %>' onerror="this.src='/Images/no-image.png'">
                                        </a>
                                    </div>

                                    <div class="card-body">
                                        <div class="prod-title">
                                            <a href='<%# ResolveUrl("~/ChiTietSanPham.aspx?id=" + Eval("MaLap")) %>'>
                                                <%# Eval("TenLap") %>
                                            </a>
                                        </div>

                                        <div class="specs" title='<%# Eval("CauHinh") %>'><i class="fa-solid fa-microchip me-1"></i><%# Eval("CauHinh") %></div>
                                        <div class="price"><%# Convert.ToDecimal(Eval("GiaBan")).ToString("N0") %> đ</div>
                                        
                                        <asp:LinkButton ID="btnMua" runat="server" CssClass="btn btn-buy" 
                                            CommandArgument='<%# Eval("MaLap") %>' OnClick="btnMua_Click"
                                            Visible='<%# Convert.ToInt32(Eval("TonKho")) > 0 %>'>
                                            <i class="fa-solid fa-cart-plus me-1"></i> Mua ngay
                                        </asp:LinkButton>
                                        
                                        <asp:Label ID="lblHetHang" runat="server" CssClass="btn-disabled" 
                                            Visible='<%# Convert.ToInt32(Eval("TonKho")) <= 0 %>' Text="Tạm hết hàng"></asp:Label>
                                    </div>
                                </div>
                            </div>
                        </ItemTemplate>
                    </asp:Repeater>
                </div>
                
                <asp:Panel ID="pnlNoData" runat="server" Visible="false" CssClass="text-center py-5">
                    <h5 class="text-muted">Không có sản phẩm nào.</h5>
                    <a href="Default.aspx" class="btn btn-outline-primary mt-2">Xem tất cả</a>
                </asp:Panel>
            </div>

        </div>
    </div>
</asp:Content>