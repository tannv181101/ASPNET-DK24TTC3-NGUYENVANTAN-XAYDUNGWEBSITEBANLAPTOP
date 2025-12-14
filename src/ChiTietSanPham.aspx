<%@ Page Title="Chi tiết sản phẩm" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="ChiTietSanPham.aspx.cs" Inherits="Laptop.ChiTietSanPham" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <style>
        /* --- 1. SLIDER ẢNH --- */
        .detail-gallery { border: 1px solid #eee; border-radius: 12px; padding: 15px; background: #fff; overflow: hidden; }
        .carousel-inner { background-color: #f8f9fa; border-radius: 8px; }
        .carousel-item { height: 400px; min-height: 400px; width: 100%; background-color: #fff; display: flex !important; align-items: center; justify-content: center; }
        .carousel-item img { max-height: 100%; max-width: 100%; width: auto; height: auto; object-fit: contain; margin: 0 auto; display: block; }
        
        .thumb-box { display: flex; gap: 10px; margin-top: 15px; justify-content: center; overflow-x: auto; padding-bottom: 5px; }
        .thumb-box::-webkit-scrollbar { height: 4px; }
        .thumb-box::-webkit-scrollbar-thumb { background: #ccc; border-radius: 4px; }
        .thumb-item { width: 70px; height: 70px; border: 2px solid #eee; border-radius: 8px; cursor: pointer; overflow: hidden; opacity: 0.6; transition: all 0.2s ease; flex-shrink: 0; background: #fff; display: flex; align-items: center; justify-content: center; }
        .thumb-item:hover { border-color: #ff6600; opacity: 1; transform: translateY(-2px); }
        .thumb-item img { max-width: 100%; max-height: 100%; object-fit: contain; }

        /* --- 2. THÔNG TIN SẢN PHẨM --- */
        .product-title-detail { font-size: 1.8rem; font-weight: 800; color: #333; margin-bottom: 10px; line-height: 1.3; }
        .brand-badge { background-color: #fff3e0; color: #ff6600; padding: 5px 15px; border-radius: 20px; font-weight: 700; font-size: 0.85rem; border: 1px solid #ffccbc; display: inline-block; margin-bottom: 15px; }
        .price-wrapper { background: #f8f9fa; padding: 20px; border-radius: 8px; margin-bottom: 25px; }
        .price-detail { font-size: 2.2rem; color: #d70018; font-weight: 800; line-height: 1; }
        .price-note { font-size: 0.9rem; color: #666; margin-top: 5px; }
        .specs-table { width: 100%; font-size: 0.95rem; }
        .specs-table td { padding: 12px 0; border-bottom: 1px solid #eee; }
        .specs-table td:first-child { width: 130px; font-weight: 600; color: #555; }
        .specs-table i { color: #ff6600; width: 25px; text-align: center; margin-right: 5px; }

        .btn-buy-now { background: linear-gradient(135deg, #ff6600 0%, #ff4500 100%); color: #fff; font-size: 1.3rem; font-weight: 800; text-transform: uppercase; padding: 16px; border-radius: 8px; border: none; width: 100%; box-shadow: 0 4px 15px rgba(255, 69, 0, 0.3); transition: all 0.3s ease; }
        .btn-buy-now:hover { background: linear-gradient(135deg, #e63e00 0%, #d43600 100%); transform: translateY(-3px); box-shadow: 0 6px 20px rgba(255, 69, 0, 0.4); color: #fff; }
        .btn-disabled-large { background: #e9ecef; color: #adb5bd; font-size: 1.3rem; font-weight: 700; padding: 16px; border-radius: 8px; width: 100%; text-align: center; cursor: not-allowed; border: 1px solid #dee2e6; }

        /* --- 3. MÔ TẢ --- */
        .content-box { background: #fff; padding: 30px; border-radius: 12px; box-shadow: 0 2px 10px rgba(0,0,0,0.05); margin-top: 40px; }
        .section-header { font-size: 1.4rem; font-weight: 800; border-left: 5px solid #ff6600; padding-left: 15px; margin-bottom: 25px; color: #333; }
        .ck-content { line-height: 1.8; color: #444; overflow: hidden; }
        .ck-content img { max-width: 100%; height: auto !important; border-radius: 8px; margin: 15px auto; display: block; }
        .ck-content h2, .ck-content h3 { font-weight: 700; color: #333; margin-top: 20px; }

        /* --- 4. CSS PRODUCT CARD (ĐỒNG BỘ TRANG CHỦ & FIX TRÀN ẢNH) --- */
        .product-card { 
            background: #fff; border: 1px solid #f0f0f0; border-radius: 8px; 
            transition: 0.3s; height: 100%; position: relative; overflow: hidden; 
        }
        .product-card:hover { 
            transform: translateY(-5px); box-shadow: 0 10px 20px rgba(0,0,0,0.08); border-color: #ff4500; 
        }
        
        /* KHUNG ẢNH CỐ ĐỊNH - QUAN TRỌNG ĐỂ KHÔNG TRÀN */
        .product-card .img-wrap {
            height: 200px;           /* Chiều cao chuẩn giống trang chủ */
            width: 100%;             /* Rộng 100% card */
            display: flex;           
            align-items: center;     
            justify-content: center;
            overflow: hidden;        /* Cắt bỏ phần thừa */
            background-color: #fff;
            padding: 15px;
            border-bottom: 1px solid #f8f9fa;
        }

        /* THẺ A BAO QUANH ẢNH */
        .product-card .img-wrap a {
            display: flex;           /* Flex để căn giữa ảnh bên trong */
            width: 100%;
            height: 100%;
            align-items: center;
            justify-content: center;
        }

        /* ẢNH BÊN TRONG */
        .product-card .img-wrap img {
            max-height: 100%;        /* Không cao quá khung 200px */
            max-width: 100%;         /* Không rộng quá khung */
            width: auto;
            height: auto;
            object-fit: contain;     /* Co ảnh lại vừa khít */
            margin: auto;
        }
        
        /* CÁC PHẦN KHÁC CỦA CARD */
        .card-body { padding: 12px; }
        .prod-title { font-size: 0.95rem; font-weight: 700; color: #333; margin: 5px 0; height: 2.6em; overflow: hidden; line-height: 1.3; }
        .prod-title a { text-decoration: none; color: inherit; }
        .prod-title a:hover { color: #ff4500; }
        
        .specs { font-size: 0.75rem; color: #666; background: #f8f9fa; padding: 4px; border-radius: 4px; margin-bottom: 8px; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
        .price { color: #d70018; font-size: 1.1rem; font-weight: 800; }
        
        .btn-buy { width: 100%; border: 1px solid #ff4500; background: #fff; color: #ff4500; padding: 6px; border-radius: 4px; font-weight: 600; margin-top: 10px; transition: 0.2s; text-align: center; display: inline-block; }
        .btn-buy:hover { background: #ff4500; color: #fff; }
        
        .stock-tag { position: absolute; top: 10px; right: 10px; background: #e7f1ff; color: #0d6efd; font-size: 0.65rem; padding: 3px 8px; border-radius: 4px; font-weight: 700; z-index: 10; }
        .stock-tag.out { background: #ffebeb; color: #dc3545; }
        .btn-disabled { width: 100%; background: #e9ecef; color: #999; border: 1px solid #dee2e6; padding: 6px; border-radius: 4px; font-weight: 600; margin-top: 10px; cursor: not-allowed; text-align: center; display: block; }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div class="container py-4">
        
        <nav aria-label="breadcrumb" class="mb-4">
            <ol class="breadcrumb">
                <li class="breadcrumb-item"><a href="Default.aspx" class="text-muted text-decoration-none">Trang chủ</a></li>
                <li class="breadcrumb-item"><a href="#" class="text-muted text-decoration-none"><asp:Label ID="lblHang" runat="server"></asp:Label></a></li>
                <li class="breadcrumb-item active fw-bold text-dark" aria-current="page"><asp:Label ID="lblTenLapBreadcrumb" runat="server"></asp:Label></li>
            </ol>
        </nav>

        <div class="row g-4">
            <div class="col-lg-6">
                <div class="detail-gallery">
                    <div id="productCarousel" class="carousel slide carousel-fade" data-bs-ride="false" data-bs-interval="false">
                        <div class="carousel-inner">
                            <asp:Repeater ID="rptAlbum" runat="server">
                                <ItemTemplate>
                                    <div class='carousel-item <%# Container.ItemIndex == 0 ? "active" : "" %>'>
                                        <img src='<%# ResolveUrl("~/Images/Products/" + Eval("DuongDan")) %>' alt="Ảnh sản phẩm" onerror="this.src='https://via.placeholder.com/600x400?text=No+Image'">
                                    </div>
                                </ItemTemplate>
                            </asp:Repeater>
                        </div>
                        <asp:PlaceHolder ID="pnlControls" runat="server" Visible="false">
                            <button class="carousel-control-prev" type="button" data-bs-target="#productCarousel" data-bs-slide="prev"><span class="carousel-control-prev-icon bg-dark rounded-circle p-2 bg-opacity-25"></span></button>
                            <button class="carousel-control-next" type="button" data-bs-target="#productCarousel" data-bs-slide="next"><span class="carousel-control-next-icon bg-dark rounded-circle p-2 bg-opacity-25"></span></button>
                        </asp:PlaceHolder>
                    </div>
                    <div class="thumb-box">
                        <asp:Repeater ID="rptThumb" runat="server">
                            <ItemTemplate>
                                <div class="thumb-item" onclick="var myCarousel = document.getElementById('productCarousel'); var carousel = new bootstrap.Carousel(myCarousel); carousel.to(<%# Container.ItemIndex %>);">
                                    <img src='<%# ResolveUrl("~/Images/Products/" + Eval("DuongDan")) %>' onerror="this.src='/Images/no-image.png'">
                                </div>
                            </ItemTemplate>
                        </asp:Repeater>
                    </div>
                </div>
            </div>

            <div class="col-lg-6">
                <div class="ps-lg-3">
                    <div class="brand-badge"><i class="fa-solid fa-laptop me-2"></i><asp:Label ID="lblThuongHieu" runat="server"></asp:Label></div>
                    <h1 class="product-title-detail"><asp:Label ID="lblTenLap" runat="server"></asp:Label></h1>
                    <div class="mb-3 d-flex align-items-center gap-2">
                        <span class="text-muted small">Mã SP: <asp:Label ID="lblMaLap" runat="server" Font-Bold="true"></asp:Label></span>
                        <span class="text-muted small">|</span>
                        <asp:Label ID="lblTinhTrang" runat="server" CssClass="badge bg-success"></asp:Label>
                    </div>
                    <div class="price-wrapper">
                        <div class="price-detail"><asp:Label ID="lblGiaBan" runat="server"></asp:Label></div>
                        <div class="price-note"><i class="fa-solid fa-tag me-1"></i> Giá đã bao gồm VAT</div>
                    </div>
                    <div class="card border-0 bg-light mb-4">
                        <div class="card-body">
                            <h6 class="fw-bold text-uppercase mb-3 text-secondary">Cấu hình chi tiết</h6>
                            <table class="specs-table">
                                <tr><td><i class="fa-solid fa-microchip"></i> CPU</td><td><asp:Label ID="lblCPU" runat="server"></asp:Label></td></tr>
                                <tr><td><i class="fa-solid fa-memory"></i> RAM/SSD</td><td><asp:Label ID="lblRamSsd" runat="server"></asp:Label></td></tr>
                                <tr><td><i class="fa-solid fa-display"></i> Màn hình</td><td><asp:Label ID="lblManHinh" runat="server">Đang cập nhật...</asp:Label></td></tr>
                            </table>
                        </div>
                    </div>
                    <div class="mb-4">
                        <asp:Button ID="btnMuaNgay" runat="server" Text="MUA NGAY - GIAO TẬN NƠI" CssClass="btn-buy-now" OnClick="btnMuaNgay_Click" />
                        <asp:Label ID="lblHetHang" runat="server" Text="SẢN PHẨM TẠM HẾT HÀNG" CssClass="btn-disabled-large" Visible="false"></asp:Label>
                    </div>
                    <div class="row text-center g-2">
                        <div class="col-4"><div class="p-2 border rounded bg-white small"><i class="fa-solid fa-shield-halved text-success d-block mb-1 fs-5"></i><br>Bảo hành 12T</div></div>
                        <div class="col-4"><div class="p-2 border rounded bg-white small"><i class="fa-solid fa-rotate text-primary d-block mb-1 fs-5"></i><br>Đổi trả 30 ngày</div></div>
                        <div class="col-4"><div class="p-2 border rounded bg-white small"><i class="fa-solid fa-truck-fast text-warning d-block mb-1 fs-5"></i><br>FreeShip</div></div>
                    </div>
                </div>
            </div>
        </div>

        <div class="content-box">
            <h3 class="section-header">Đánh giá chi tiết sản phẩm</h3>
            <div class="ck-content"><asp:Literal ID="litMoTa" runat="server"></asp:Literal></div>
        </div>

        <div class="mt-5 mb-5">
            <h3 class="section-header">Có thể bạn quan tâm</h3>
            <div class="row row-cols-2 row-cols-md-4 g-3">
                <asp:Repeater ID="rptLienQuan" runat="server">
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
                                        <a href='<%# ResolveUrl("~/ChiTietSanPham.aspx?id=" + Eval("MaLap")) %>'><%# Eval("TenLap") %></a>
                                    </div>
                                    <div class="specs" title='<%# Eval("CauHinh") %>'><i class="fa-solid fa-microchip me-1"></i><%# Eval("CauHinh") %></div>
                                    <div class="price"><%# Convert.ToDecimal(Eval("GiaBan")).ToString("N0") %> đ</div>
                                    
                                    <asp:LinkButton ID="btnMuaLienQuan" runat="server" CssClass="btn btn-buy" 
                                        CommandArgument='<%# Eval("MaLap") %>' OnClick="btnMuaLienQuan_Click"
                                        Visible='<%# Convert.ToInt32(Eval("TonKho")) > 0 %>'>
                                        <i class="fa-solid fa-cart-plus me-1"></i> Mua ngay
                                    </asp:LinkButton>
                                    
                                    <asp:Label ID="lblHetHangLienQuan" runat="server" CssClass="btn-disabled" 
                                        Visible='<%# Convert.ToInt32(Eval("TonKho")) <= 0 %>' Text="Tạm hết hàng"></asp:Label>
                                </div>
                            </div>
                        </div>
                    </ItemTemplate>
                </asp:Repeater>
            </div>
        </div>
    </div>
    
    <script>
        document.addEventListener("DOMContentLoaded", function () {
            var myCarousel = document.getElementById('productCarousel');
            if (myCarousel) { new bootstrap.Carousel(myCarousel, { interval: false, ride: false }); }
        });
    </script>
</asp:Content>