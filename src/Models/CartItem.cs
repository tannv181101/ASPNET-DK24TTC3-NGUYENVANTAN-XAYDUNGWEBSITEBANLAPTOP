using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace Laptop.Models
{
    [Serializable]
    public class CartItem
    {
        public int MaLap { get; set; }
        public string TenLap { get; set; }
        public string HinhAnh { get; set; }
        public decimal GiaBan { get; set; }
        public int SoLuong { get; set; }
        public decimal ThanhTien { get { return GiaBan * SoLuong; } }
    }
}