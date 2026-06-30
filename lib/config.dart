class APIConfig {
  static const baseURL = "https://portfolio-backend-1001564012467.asia-south1.run.app";
  static const portfolio = '$baseURL/api/v1/data/portfolio';
  static const blogList = '$baseURL/api/v1/data/blogs';
  static getBlog(String slug) => "$baseURL/api/v1/data/blogs/$slug";
}
