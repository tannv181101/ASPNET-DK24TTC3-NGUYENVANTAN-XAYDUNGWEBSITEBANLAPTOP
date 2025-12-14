using System;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;

namespace Laptop
{
    public class DBConnect
    {
        // Chuỗi kết nối lấy từ Web.config
        private static string strKetNoi = ConfigurationManager.ConnectionStrings["LaptopTanNguyenDB"].ConnectionString;

        // 1. Lấy dữ liệu (SELECT)
        public static DataTable GetData(string query, SqlParameter[] param = null)
        {
            using (SqlConnection con = new SqlConnection(strKetNoi))
            {
                try
                {
                    con.Open();
                    using (SqlCommand cmd = new SqlCommand(query, con))
                    {
                        if (param != null) cmd.Parameters.AddRange(param);
                        SqlDataAdapter da = new SqlDataAdapter(cmd);
                        DataTable dt = new DataTable();
                        da.Fill(dt);
                        return dt;
                    }
                }
                catch { return null; }
            }
        }

        // 2. Thực thi lệnh (INSERT, UPDATE, DELETE)
        public static void Execute(string query, SqlParameter[] param = null)
        {
            using (SqlConnection con = new SqlConnection(strKetNoi))
            {
                con.Open();
                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    if (param != null) cmd.Parameters.AddRange(param);
                    cmd.ExecuteNonQuery();
                }
            }
        }

        // 3. Lấy 1 giá trị (Scalar)
        public static object ExecuteScalar(string query, SqlParameter[] param = null)
        {
            using (SqlConnection con = new SqlConnection(strKetNoi))
            {
                con.Open();
                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    if (param != null) cmd.Parameters.AddRange(param);
                    return cmd.ExecuteScalar();
                }
            }
        }

        // 4. Lấy 1 dòng dữ liệu
        public static DataRow GetOneRow(string query, SqlParameter[] param = null)
        {
            DataTable dt = GetData(query, param);
            if (dt != null && dt.Rows.Count > 0)
                return dt.Rows[0];
            return null;
        }
    }
}